using System;
using System.Collections.Generic;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;
using SentinelX.Engine.Services;

namespace SentinelX.Tests.Tests
{
    public static class ProtectionPostureTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] ProtectionPostureTests starting...");

            var logger = new StructuredLogger(null, LogLevel.Debug);
            var service = new WindowsSecurityService(logger);

            // Test 1: Query actual Windows posture snapshot
            var snapshot = service.GetPostureSnapshot();
            Assert(snapshot != null, "ProtectionPostureSnapshot must not be null");
            Assert(snapshot.FirewallProfiles != null && snapshot.FirewallProfiles.Count >= 3, "Must return at least 3 firewall profiles (Domain, Private, Public)");
            Assert(snapshot.Uac != null, "UAC info must not be null");
            Assert(!string.IsNullOrEmpty(snapshot.Uac.Source), "UAC must attribute source");
            Assert(snapshot.WindowsUpdate != null, "Windows Update info must not be null");

            // Test 2: Serialization and Deserialization
            var json = JsonHelper.Serialize(snapshot);
            var desSnapshot = JsonHelper.Deserialize<ProtectionPostureSnapshot>(json);
            Assert(desSnapshot != null, "Deserialized ProtectionPostureSnapshot must not be null");
            Assert(desSnapshot.FirewallProfiles.Count == snapshot.FirewallProfiles.Count, "Firewall profile count must match");

            // Test 3: WSC ProductState bitmask verification
            // ProductState = 0x61100 (Active, up to date)
            uint defenderState = 0x61100;
            bool isActive = (defenderState & 0x1000) != 0;
            bool isUpToDate = (defenderState & 0x10) == 0;
            Assert(isActive, "ProductState 0x61100 must be active");
            Assert(isUpToDate, "ProductState 0x61100 must be up to date");

            // ProductState = 0x60010 (Disabled, out of date)
            uint disabledState = 0x60010;
            bool disabledActive = (disabledState & 0x1000) != 0;
            bool disabledUpToDate = (disabledState & 0x10) == 0;
            Assert(!disabledActive, "ProductState 0x60010 must be disabled");
            Assert(!disabledUpToDate, "ProductState 0x60010 must be out of date");

            Console.WriteLine("[PASS] ProtectionPostureTests passed.");
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
