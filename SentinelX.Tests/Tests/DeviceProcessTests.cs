using System;
using System.Diagnostics;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;
using SentinelX.Engine.Services;

namespace SentinelX.Tests.Tests
{
    public static class DeviceProcessTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] DeviceProcessTests starting...");

            var logger = new StructuredLogger(null, LogLevel.Debug);
            var service = new DeviceProcessService(logger);

            // Test 1: Device Inventory
            var inventory = service.GetDeviceInventory();
            Assert(inventory != null, "Device inventory must not be null");
            Assert(!string.IsNullOrEmpty(inventory.OsVersion), "OS version must be present");
            Assert(inventory.ProcessorCount > 0, "Processor count must be positive");
            Assert(inventory.Drives != null && inventory.Drives.Count > 0, "At least one drive must be enumerated");

            // Test 2: Process Enumeration & PID Reuse Handling
            var processes = service.GetProcesses();
            Assert(processes != null && processes.Count > 0, "Must enumerate active processes");

            bool foundCurrentProc = false;
            var currentPid = Process.GetCurrentProcess().Id;
            foreach (var proc in processes)
            {
                Assert(proc.ProcessId >= 0, "PID must be non-negative");
                Assert(!string.IsNullOrEmpty(proc.ProcessName), "ProcessName must not be empty");
                Assert(!string.IsNullOrEmpty(proc.CompositeKey), "CompositeKey must be formed to handle PID reuse");

                if (proc.ProcessId == currentPid)
                {
                    foundCurrentProc = true;
                    Assert(proc.CompositeKey.Contains(currentPid.ToString()), "Composite key must contain PID");
                }
            }
            Assert(foundCurrentProc, "Process list must include current running test process");

            // Test 3: Startup Applications Enumeration
            var startupItems = service.GetStartupEntries();
            Assert(startupItems != null, "Startup items list must not be null");

            // Test 4: Serialization of Device/Process Contracts
            var jsonInv = JsonHelper.Serialize(inventory);
            var desInv = JsonHelper.Deserialize<DeviceInventorySnapshot>(jsonInv);
            Assert(desInv.ProcessorCount == inventory.ProcessorCount, "Deserialized inventory must match");

            var jsonProc = JsonHelper.Serialize(processes);
            var desProc = JsonHelper.Deserialize<System.Collections.Generic.List<ProcessItem>>(jsonProc);
            Assert(desProc.Count == processes.Count, "Deserialized process list count must match");

            Console.WriteLine("[PASS] DeviceProcessTests passed.");
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
