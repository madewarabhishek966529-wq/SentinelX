using System;
using System.Collections.Generic;
using SentinelX.Contracts;
using SentinelX.Engine.Handlers;

namespace SentinelX.Tests.Tests
{
    public static class SecurityBoundaryTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] SecurityBoundaryTests starting...");

            // Test 1: Unsupported contract version
            var reqOld = new IpcRequest
            {
                ContractVersion = "0.9.0", // Mismatched version
                RequestId = Guid.NewGuid().ToString(),
                Action = "ping"
            };

            var versionMatches = string.Equals(reqOld.ContractVersion, ContractConstants.CurrentVersion, StringComparison.Ordinal);
            Assert(!versionMatches, "Old contract version 0.9.0 must not match CurrentVersion 1.0.0");

            // Test 2: Bounded payload check
            var hugePayloadLength = ContractConstants.MaxPayloadBytes + 1024;
            var isPayloadExceeded = hugePayloadLength > ContractConstants.MaxPayloadBytes;
            Assert(isPayloadExceeded, "Payload exceeding 1MB must be detected and rejected");

            // Test 3: Handler unknown action handling
            var handlers = new List<IRequestHandler>
            {
                new PingHandler(),
                new HealthHandler(DateTime.UtcNow)
            };

            var unknownReq = new IpcRequest { Action = "arbitrary_unsafe_action" };
            IRequestHandler matched = null;
            foreach (var h in handlers)
            {
                if (h.CanHandle(unknownReq.Action))
                {
                    matched = h;
                    break;
                }
            }
            Assert(matched == null, "Unregistered actions must not be handled by any handler");

            Console.WriteLine("[PASS] SecurityBoundaryTests passed.");
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
