using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Net;
using System.Text;
using System.Threading;
using SentinelX.Contracts;
using SentinelX.Engine.Handlers;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Ipc
{
    public class IpcServer : IDisposable
    {
        private readonly StructuredLogger _logger;
        private readonly SessionData _session;
        private readonly List<IRequestHandler> _handlers;
        private readonly Action _onShutdownRequested;

        private HttpListener _httpListener;
        private Thread _httpThread;
        private Thread _pipeThread;
        private volatile bool _isRunning;
        private readonly CancellationTokenSource _cts;

        public IpcServer(StructuredLogger logger, SessionData session, List<IRequestHandler> handlers, Action onShutdownRequested)
        {
            _logger = logger;
            _session = session;
            _handlers = handlers;
            _onShutdownRequested = onShutdownRequested;
            _cts = new CancellationTokenSource();
        }

        public void Start()
        {
            _isRunning = true;

            // Start HTTP loopback listener
            try
            {
                _httpListener = new HttpListener();
                var prefix = string.Format("http://127.0.0.1:{0}/", _session.Port);
                _httpListener.Prefixes.Add(prefix);
                _httpListener.Start();

                _httpThread = new Thread(HttpWorkerLoop) { IsBackground = true, Name = "IpcHttpWorker" };
                _httpThread.Start();
                _logger.Info("IPC HTTP listener active on " + prefix, "IpcServer");
            }
            catch (Exception ex)
            {
                _logger.Error("Failed to initialize IPC HTTP listener on port " + _session.Port, ex, "IpcServer");
            }

            // Start Named Pipe listener
            _pipeThread = new Thread(PipeWorkerLoop) { IsBackground = true, Name = "IpcPipeWorker" };
            _pipeThread.Start();
            _logger.Info("IPC Named Pipe listener active on " + _session.PipeName, "IpcServer");
        }

        private void HttpWorkerLoop()
        {
            while (_isRunning && _httpListener != null && _httpListener.IsListening)
            {
                try
                {
                    var context = _httpListener.GetContext();
                    ThreadPool.QueueUserWorkItem(ProcessHttpContext, context);
                }
                catch (HttpListenerException)
                {
                    // Listener stopped
                    break;
                }
                catch (Exception ex)
                {
                    if (_isRunning)
                    {
                        _logger.Error("Error accepting HTTP IPC connection", ex, "IpcServer");
                    }
                }
            }
        }

        private void ProcessHttpContext(object state)
        {
            var context = (HttpListenerContext)state;
            var response = context.Response;

            try
            {
                // Enforce CORS for local Flutter web / desktop
                response.Headers.Add("Access-Control-Allow-Origin", "*");
                response.Headers.Add("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
                response.Headers.Add("Access-Control-Allow-Headers", "Content-Type, X-SentinelX-Token");

                if (context.Request.HttpMethod == "OPTIONS")
                {
                    response.StatusCode = 200;
                    response.Close();
                    return;
                }

                // Verify loopback remote endpoint
                if (!IPAddress.IsLoopback(context.Request.RemoteEndPoint.Address))
                {
                    _logger.Warning("Rejected non-loopback connection from " + context.Request.RemoteEndPoint.Address, "IpcServer");
                    SendErrorResponse(response, 403, "FORBIDDEN", "Remote access is strictly prohibited.");
                    return;
                }

                // Verify Token
                var receivedToken = context.Request.Headers["X-SentinelX-Token"];
                if (string.IsNullOrEmpty(receivedToken))
                {
                    receivedToken = context.Request.QueryString["token"];
                }

                if (string.IsNullOrEmpty(receivedToken) || !string.Equals(receivedToken, _session.Token, StringComparison.Ordinal))
                {
                    _logger.Warning("Rejected unauthorized IPC request: invalid or missing authentication token", "IpcServer");
                    SendErrorResponse(response, 401, "UNAUTHORIZED", "Missing or invalid SentinelX authentication token.");
                    return;
                }

                // Check payload length
                if (context.Request.ContentLength64 > ContractConstants.MaxPayloadBytes)
                {
                    _logger.Warning("Rejected oversized IPC request: " + context.Request.ContentLength64 + " bytes", "IpcServer");
                    SendErrorResponse(response, 413, "PAYLOAD_TOO_LARGE", "Request payload exceeds 1MB limit.");
                    return;
                }

                string requestBody;
                using (var reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                {
                    requestBody = reader.ReadToEnd();
                }

                // Parse request
                IpcRequest request;
                try
                {
                    request = JsonHelper.Deserialize<IpcRequest>(requestBody);
                    if (request == null)
                    {
                        SendErrorResponse(response, 400, "BAD_REQUEST", "Empty or invalid JSON body.");
                        return;
                    }
                }
                catch (Exception ex)
                {
                    SendErrorResponse(response, 400, "PARSE_ERROR", "Failed to deserialize request JSON: " + ex.Message);
                    return;
                }

                // Check Contract Version
                if (!string.Equals(request.ContractVersion, ContractConstants.CurrentVersion, StringComparison.Ordinal))
                {
                    _logger.Warning("Contract version mismatch: Client=" + request.ContractVersion + ", Server=" + ContractConstants.CurrentVersion, "IpcServer");
                    var mismatchResp = IpcResponse<object>.CreateError(
                        request.RequestId,
                        "CONTRACT_MISMATCH",
                        string.Format("Unsupported contract version '{0}'. Expected '{1}'.", request.ContractVersion, ContractConstants.CurrentVersion)
                    );
                    SendJsonResponse(response, 400, mismatchResp);
                    return;
                }

                // Handle shutdown
                if (string.Equals(request.Action, "shutdown", StringComparison.OrdinalIgnoreCase))
                {
                    _logger.Info("Shutdown requested via IPC", "IpcServer");
                    var shutdownResp = IpcResponse<object>.CreateSuccess(request.RequestId, new Dictionary<string, object> { { "status", "shutting_down" } });
                    SendJsonResponse(response, 200, shutdownResp);
                    _onShutdownRequested?.Invoke();
                    return;
                }

                // Dispatch to handlers
                IRequestHandler targetHandler = null;
                foreach (var handler in _handlers)
                {
                    if (handler.CanHandle(request.Action))
                    {
                        targetHandler = handler;
                        break;
                    }
                }

                if (targetHandler == null)
                {
                    _logger.Warning("No handler registered for action: " + request.Action, "IpcServer");
                    var unhandledResp = IpcResponse<object>.CreateError(request.RequestId, "UNKNOWN_ACTION", "Action not recognized: " + request.Action);
                    SendJsonResponse(response, 404, unhandledResp);
                    return;
                }

                var handlerResponse = targetHandler.Handle(request);
                SendJsonResponse(response, 200, handlerResponse);
            }
            catch (Exception ex)
            {
                _logger.Error("Unhandled error processing IPC HTTP request", ex, "IpcServer");
                try
                {
                    SendErrorResponse(response, 500, "INTERNAL_ERROR", "Engine internal error: " + ex.Message);
                }
                catch { }
            }
        }

        private void PipeWorkerLoop()
        {
            while (_isRunning)
            {
                try
                {
                    using (var pipe = new NamedPipeServerStream(
                        _session.PipeName,
                        PipeDirection.InOut,
                        NamedPipeServerStream.MaxAllowedServerInstances,
                        PipeTransmissionMode.Byte,
                        PipeOptions.Asynchronous))
                    {
                        pipe.WaitForConnection();

                        using (var reader = new StreamReader(pipe, Encoding.UTF8))
                        using (var writer = new StreamWriter(pipe, Encoding.UTF8) { AutoFlush = true })
                        {
                            var line = reader.ReadLine();
                            if (!string.IsNullOrEmpty(line))
                            {
                                var request = JsonHelper.Deserialize<IpcRequest>(line);
                                if (request != null)
                                {
                                    IRequestHandler targetHandler = null;
                                    foreach (var handler in _handlers)
                                    {
                                        if (handler.CanHandle(request.Action))
                                        {
                                            targetHandler = handler;
                                            break;
                                        }
                                    }

                                    var resp = targetHandler != null
                                        ? targetHandler.Handle(request)
                                        : IpcResponse<object>.CreateError(request.RequestId, "UNKNOWN_ACTION", "No handler for: " + request.Action);

                                    writer.WriteLine(JsonHelper.Serialize(resp));
                                }
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    if (!_isRunning) break;
                    Thread.Sleep(100);
                }
            }
        }

        private void SendJsonResponse(HttpListenerResponse response, int statusCode, object data)
        {
            try
            {
                var json = JsonHelper.Serialize(data);
                var buffer = Encoding.UTF8.GetBytes(json);
                response.StatusCode = statusCode;
                response.ContentType = "application/json; charset=utf-8";
                response.ContentLength64 = buffer.Length;
                response.OutputStream.Write(buffer, 0, buffer.Length);
                response.Close();
            }
            catch (Exception ex)
            {
                _logger.Error("Failed to send JSON response", ex, "IpcServer");
            }
        }

        private void SendErrorResponse(HttpListenerResponse response, int statusCode, string errorCode, string message)
        {
            var err = IpcResponse<object>.CreateError(Guid.NewGuid().ToString(), errorCode, message);
            SendJsonResponse(response, statusCode, err);
        }

        public void Stop()
        {
            _isRunning = false;
            _cts.Cancel();

            try
            {
                if (_httpListener != null && _httpListener.IsListening)
                {
                    _httpListener.Stop();
                    _httpListener.Close();
                }
            }
            catch { }
        }

        public void Dispose()
        {
            Stop();
            _cts.Dispose();
        }
    }
}

