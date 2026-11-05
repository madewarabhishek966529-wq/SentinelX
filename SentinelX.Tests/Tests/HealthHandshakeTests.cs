using System;
using System.Collections.Generic;
using SentinelX.Contracts;
using SentinelX.Engine.Handlers;

namespace SentinelX.Tests.Tests
{
    public static class HealthHandshakeTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] HealthHandshakeTests starting...");

            var pingHandler = new PingHandler();
            var pingReq = new IpcRequest { Action = "ping", RequestId = "test-ping-1" };
            var pingResp = pingHandler.Handle(pingReq);

            Assert(pingResp.Status == "success", "Ping response status must be success");
            var pingData = pingResp.Data as Dictionary<string, object>;
            Assert(pingData != null, "Ping response data must be a dictionary");
            Assert(pingData["reply"].ToString() == "pong", "Ping response reply must be pong");

            var healthHandler = new HealthHandler(DateTime.UtcNow.AddMinutes(-5));
            var healthReq = new IpcRequest { Action = "health", RequestId = "test-health-1" };
            var healthResp = healthHandler.Handle(healthReq);

            Assert(healthResp.Status == "success", "Health response status must be success");
            var healthData = healthResp.Data as EngineHealthData;
            Assert(healthData != null, "Health response data must be EngineHealthData");
            Assert(healthData.ContractVersion == ContractConstants.CurrentVersion, "Health contract version must match");
            Assert(healthData.ProcessId > 0, "ProcessId must be valid");
            Assert(healthData.Status == "healthy", "Engine status must be healthy");
            Assert(healthData.SupportedActions.Contains("ping"), "SupportedActions must include ping");

            Console.WriteLine("[PASS] HealthHandshakeTests passed.");
        }

        private static void Assert(bool condition, string message)
        {
            if (!condition)
            {
                throw new Exception("Assertion Failed: " + message);
            }
        }
    }
}

