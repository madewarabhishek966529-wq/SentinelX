using System;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class ProtectionHandler : IRequestHandler
    {
        private readonly WindowsSecurityService _securityService;

        public ProtectionHandler(WindowsSecurityService securityService)
        {
            _securityService = securityService;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "get_protection_posture", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                var snapshot = _securityService.GetPostureSnapshot();
                return IpcResponse<object>.CreateSuccess(request.RequestId, snapshot);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "PROTECTION_QUERY_FAILED",
                    "Failed to query Windows protection posture: " + ex.Message
                );
            }
        }
    }
}

