using System;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class EventsHandler : IRequestHandler
    {
        private readonly WindowsEventLogService _eventLogService;

        public EventsHandler(WindowsEventLogService eventLogService)
        {
            _eventLogService = eventLogService;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "get_security_events", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                int max = 30;
                if (request.Parameters != null && request.Parameters.ContainsKey("maxPerChannel"))
                {
                    int.TryParse(request.Parameters["maxPerChannel"]?.ToString(), out max);
                    if (max <= 0) max = 30;
                    if (max > 100) max = 100;
                }

                var snapshot = _eventLogService.GetSecurityEvents(max);
                return IpcResponse<object>.CreateSuccess(request.RequestId, snapshot);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "EVENTS_ERROR",
                    "Security event log query failed: " + ex.Message
                );
            }
        }
    }
}

