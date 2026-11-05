using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security.Principal;
using SentinelX.Contracts;

namespace SentinelX.Engine.Handlers
{
    public class HealthHandler : IRequestHandler
    {
        private readonly DateTime _startedAtUtc;

        public HealthHandler(DateTime startedAtUtc)
        {
            _startedAtUtc = startedAtUtc;
        }

        public bool CanHandle(string action)
        {
            return string.Equals(action, "health", StringComparison.OrdinalIgnoreCase) ||
                   string.Equals(action, "handshake", StringComparison.OrdinalIgnoreCase);
        }

        public IpcResponse<object> Handle(IpcRequest request)
        {
            var proc = Process.GetCurrentProcess();
            var isElevated = CheckIsElevated();

            var health = new EngineHealthData
            {
                EngineVersion = "1.0.0",
                ContractVersion = ContractConstants.CurrentVersion,
                ProcessId = proc.Id,
                StartedAtUtc = _startedAtUtc.ToString("o"),
                OsVersion = Environment.OSVersion.VersionString,
                IsElevated = isElevated,
                Status = "healthy",
                MemoryBytes = proc.WorkingSet64,
                SupportedActions = new List<string> { "ping", "health", "handshake", "shutdown" }
            };

            return IpcResponse<object>.CreateSuccess(request.RequestId, health);
        }

        private static bool CheckIsElevated()
        {
            try
            {
                using (var identity = WindowsIdentity.GetCurrent())
                {
                    var principal = new WindowsPrincipal(identity);
                    return principal.IsInRole(WindowsBuiltInRole.Administrator);
                }
            }
            catch
            {
                return false;
            }
        }
    }
}

