using System;
using System.Collections.Generic;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class FimHandler : IRequestHandler
    {
        private readonly FimService _fimService;

        public FimHandler(FimService fimService)
        {
            _fimService = fimService;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "get_fim_snapshot", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "add_fim_target", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "remove_fim_target", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "verify_fim_target", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "verify_all_fim_targets", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "reset_fim_baseline", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                if (string.Equals(request.Action, "get_fim_snapshot", StringComparison.OrdinalIgnoreCase))
                {
                    var snapshot = _fimService.GetSnapshot();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, snapshot);
                }

                if (string.Equals(request.Action, "add_fim_target", StringComparison.OrdinalIgnoreCase))
                {
                    if (request.Parameters == null || !request.Parameters.ContainsKey("filePath"))
                    {
                        return IpcResponse<object>.CreateError(request.RequestId, "INVALID_PARAM", "filePath is required.");
                    }

                    string path = request.Parameters["filePath"]?.ToString();
                    string label = request.Parameters.ContainsKey("label") ? request.Parameters["label"]?.ToString() : null;

                    var item = _fimService.AddTarget(path, label);
                    return IpcResponse<object>.CreateSuccess(request.RequestId, item);
                }

                if (string.Equals(request.Action, "remove_fim_target", StringComparison.OrdinalIgnoreCase))
                {
                    if (request.Parameters == null || !request.Parameters.ContainsKey("targetId"))
                    {
                        return IpcResponse<object>.CreateError(request.RequestId, "INVALID_PARAM", "targetId is required.");
                    }

                    string targetId = request.Parameters["targetId"]?.ToString();
                    bool removed = _fimService.RemoveTarget(targetId);
                    return IpcResponse<object>.CreateSuccess(request.RequestId, new { removed });
                }

                if (string.Equals(request.Action, "verify_fim_target", StringComparison.OrdinalIgnoreCase))
                {
                    if (request.Parameters == null || !request.Parameters.ContainsKey("targetId"))
                    {
                        return IpcResponse<object>.CreateError(request.RequestId, "INVALID_PARAM", "targetId is required.");
                    }

                    string targetId = request.Parameters["targetId"]?.ToString();
                    var item = _fimService.VerifyTarget(targetId);
                    return IpcResponse<object>.CreateSuccess(request.RequestId, item);
                }

                if (string.Equals(request.Action, "verify_all_fim_targets", StringComparison.OrdinalIgnoreCase))
                {
                    var snapshot = _fimService.GetSnapshot();
                    var updated = new List<FimTargetItem>();
                    foreach (var t in snapshot.Targets)
                    {
                        updated.Add(_fimService.VerifyTarget(t.TargetId));
                    }
                    return IpcResponse<object>.CreateSuccess(request.RequestId, updated);
                }

                if (string.Equals(request.Action, "reset_fim_baseline", StringComparison.OrdinalIgnoreCase))
                {
                    if (request.Parameters == null || !request.Parameters.ContainsKey("targetId"))
                    {
                        return IpcResponse<object>.CreateError(request.RequestId, "INVALID_PARAM", "targetId is required.");
                    }

                    string targetId = request.Parameters["targetId"]?.ToString();
                    var item = _fimService.ResetBaseline(targetId);
                    return IpcResponse<object>.CreateSuccess(request.RequestId, item);
                }

                return IpcResponse<object>.CreateError(request.RequestId, "UNKNOWN_ACTION", "Unhandled action: " + request.Action);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "FIM_ERROR",
                    "FIM operation failed: " + ex.Message
                );
            }
        }
    }
}

