using System;
using System.Threading;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class NetworkHandler : IRequestHandler
    {
        private readonly NetworkService _networkService;
        private CancellationTokenSource _discoveryCts;

        public NetworkHandler(NetworkService networkService)
        {
            _networkService = networkService;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "get_network_activity", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "discover_local_devices", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "cancel_discovery", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                if (string.Equals(request.Action, "get_network_activity", StringComparison.OrdinalIgnoreCase))
                {
                    var snapshot = _networkService.GetNetworkActivity();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, snapshot);
                }

                if (string.Equals(request.Action, "cancel_discovery", StringComparison.OrdinalIgnoreCase))
                {
                    _discoveryCts?.Cancel();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, new { canceled = true });
                }

                if (string.Equals(request.Action, "discover_local_devices", StringComparison.OrdinalIgnoreCase))
                {
                    // Require confirmed private subnet
                    string targetSubnet = "192.168.1.0/24";
                    if (request.Parameters != null && request.Parameters.ContainsKey("targetSubnet"))
                    {
                        targetSubnet = request.Parameters["targetSubnet"]?.ToString() ?? "192.168.1.0/24";
                    }

                    _discoveryCts = new CancellationTokenSource();
                    var devices = _networkService.DiscoverAuthorizedLocalDevices(targetSubnet, _discoveryCts.Token);
                    return IpcResponse<object>.CreateSuccess(request.RequestId, devices);
                }

                return IpcResponse<object>.CreateError(request.RequestId, "UNKNOWN_ACTION", "Unhandled network action: " + request.Action);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "NETWORK_ERROR",
                    "Network operation failed: " + ex.Message
                );
            }
        }
    }
}

