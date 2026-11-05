using System;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Engine.Handlers
{
    public class DeviceProcessHandler : IRequestHandler
    {
        private readonly DeviceProcessService _service;

        public DeviceProcessHandler(DeviceProcessService service)
        {
            _service = service;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "get_device_inventory", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "get_processes", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "get_startup_apps", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            try
            {
                if (string.Equals(request.Action, "get_device_inventory", StringComparison.OrdinalIgnoreCase))
                {
                    var inventory = _service.GetDeviceInventory();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, inventory);
                }

                if (string.Equals(request.Action, "get_processes", StringComparison.OrdinalIgnoreCase))
                {
                    var processes = _service.GetProcesses();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, processes);
                }

                if (string.Equals(request.Action, "get_startup_apps", StringComparison.OrdinalIgnoreCase))
                {
                    var startup = _service.GetStartupEntries();
                    return IpcResponse<object>.CreateSuccess(request.RequestId, startup);
                }

                return IpcResponse<object>.CreateError(request.RequestId, "UNKNOWN_ACTION", "Unhandled action: " + request.Action);
            }
            catch (Exception ex)
            {
                return IpcResponse<object>.CreateError(
                    request.RequestId,
                    "DEVICE_PROCESS_ERROR",
                    "Failed processing " + request.Action + ": " + ex.Message
                );
            }
        }
    }
}
