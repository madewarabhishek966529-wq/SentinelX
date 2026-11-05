using System;
using System.Collections.Generic;
using System.Threading;
using SentinelX.Contracts;
using SentinelX.Engine.Handlers;
using SentinelX.Engine.Ipc;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine
{
    class Program
    {
        private static readonly ManualResetEventSlim ShutdownEvent = new ManualResetEventSlim(false);

        static int Main(string[] args)
        {
            var logger = new StructuredLogger(null, LogLevel.Debug);
            logger.Info("Starting SentinelX.Engine v1.0.0...", "Main");
            logger.Info("Contract Version: " + ContractConstants.CurrentVersion, "Main");

            SessionManager sessionManager = null;
            IpcServer ipcServer = null;

            try
            {
                var startedAtUtc = DateTime.UtcNow;
                sessionManager = new SessionManager(logger, ContractConstants.DefaultPort);
                sessionManager.SaveSession();

                var securityService = new Services.WindowsSecurityService(logger);

                var handlers = new List<IRequestHandler>
                {
                    new PingHandler(),
                    new HealthHandler(startedAtUtc),
                    new ProtectionHandler(securityService)
                };

                ipcServer = new IpcServer(logger, sessionManager.CurrentSession, handlers, () =>
                {
                    logger.Info("IPC requested engine shutdown.", "Main");
                    ShutdownEvent.Set();
                });

                ipcServer.Start();
                logger.Info("SentinelX.Engine ready. Listening on 127.0.0.1:" + sessionManager.CurrentSession.Port, "Main");

                Console.CancelKeyPress += (s, e) =>
                {
                    e.Cancel = true;
                    logger.Info("Received cancellation signal (Ctrl+C). Initiating graceful shutdown...", "Main");
                    ShutdownEvent.Set();
                };

                AppDomain.CurrentDomain.ProcessExit += (s, e) =>
                {
                    logger.Info("Process exit event triggered.", "Main");
                };

                // Wait until shutdown is signaled
                ShutdownEvent.Wait();
                logger.Info("Shutting down SentinelX.Engine cleanly...", "Main");
                return 0;
            }
            catch (Exception ex)
            {
                logger.Error("Fatal unhandled exception in SentinelX.Engine", ex, "Main");
                return 1;
            }
            finally
            {
                ipcServer?.Dispose();
                sessionManager?.Dispose();
                logger.Info("SentinelX.Engine stopped.", "Main");
            }
        }
    }
}

