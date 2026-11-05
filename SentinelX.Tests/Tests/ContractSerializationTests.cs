using System;
using System.Collections.Generic;
using SentinelX.Contracts;

namespace SentinelX.Tests.Tests
{
    public static class ContractSerializationTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] ContractSerializationTests starting...");

            // Test 1: IpcRequest serialization/deserialization
            var req = new IpcRequest
            {
                Action = "ping",
                RequestId = "req-12345",
                ContractVersion = ContractConstants.CurrentVersion,
                Parameters = new Dictionary<string, object> { { "detail", true }, { "count", 42 } }
            };

            var jsonReq = JsonHelper.Serialize(req);
            var deserializedReq = JsonHelper.Deserialize<IpcRequest>(jsonReq);

            Assert(deserializedReq != null, "Deserialized request must not be null");
            Assert(deserializedReq.Action == "ping", "Action must be 'ping'");
            Assert(deserializedReq.RequestId == "req-12345", "RequestId must match");
            Assert(deserializedReq.ContractVersion == ContractConstants.CurrentVersion, "ContractVersion must match");

            // Test 2: IpcResponse success serialization
            var resp = IpcResponse<Dictionary<string, object>>.CreateSuccess("req-12345", new Dictionary<string, object>
            {
                { "status", "ok" },
                { "code", 200 }
            });

            var jsonResp = JsonHelper.Serialize(resp);
            var deserializedResp = JsonHelper.Deserialize<IpcResponse<Dictionary<string, object>>>(jsonResp);

            Assert(deserializedResp != null, "Deserialized response must not be null");
            Assert(deserializedResp.Status == "success", "Response status must be 'success'");
            Assert(deserializedResp.Error == null, "Response error must be null on success");

            // Test 3: IpcResponse error serialization
            var errResp = IpcResponse<object>.CreateError("req-999", "ERR_CODE", "A safe message", "diag-001");
            var jsonErr = JsonHelper.Serialize(errResp);
            var deserializedErr = JsonHelper.Deserialize<IpcResponse<object>>(jsonErr);

            Assert(deserializedErr != null, "Deserialized error response must not be null");
            Assert(deserializedErr.Status == "error", "Response status must be 'error'");
            Assert(deserializedErr.Error != null, "Error object must be populated");
            Assert(deserializedErr.Error.ErrorCode == "ERR_CODE", "ErrorCode must match");
            Assert(deserializedErr.Error.DiagnosticId == "diag-001", "DiagnosticId must match");

            // Test 4: StatusSnapshot and 7 status states
            foreach (ComponentStatus status in Enum.GetValues(typeof(ComponentStatus)))
            {
                var snapshot = new StatusSnapshot
                {
                    ComponentKey = "test_component",
                    Status = status.ToString(),
                    Source = "UnitTest",
                    FreshnessSeconds = 60,
                    Limitations = "None"
                };

                var jsonSnap = JsonHelper.Serialize(snapshot);
                var desSnap = JsonHelper.Deserialize<StatusSnapshot>(jsonSnap);
                Assert(desSnap.Status == status.ToString(), "Snapshot status must preserve " + status);
            }

            Console.WriteLine("[PASS] ContractSerializationTests passed.");
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

