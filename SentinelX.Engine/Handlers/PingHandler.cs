using System;
using System.Collections.Generic;
using SentinelX.Contracts;

namespace SentinelX.Engine.Handlers
{
    public class PingHandler : IRequestHandler
    {
        public bool CanHandle(string action)
        {
            return string.Equals(action, "ping", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            var data = new Dictionary<string, object>
            {
                { "reply", "pong" },
                { "serverTimeUtc", DateTime.UtcNow.ToString("o") },
                { "receivedRequestId", request.RequestId }
            };
            return IpcResponse<object>.CreateSuccess(request.RequestId, data);
        }
    }
}
