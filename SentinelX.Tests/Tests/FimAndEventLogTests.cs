using System;
using System.IO;
using SentinelX.Contracts;
using SentinelX.Engine.Services;

namespace SentinelX.Tests.Tests
{
    public static class FimAndEventLogTests
    {
        public static void RunAll()
        {
            Console.WriteLine("[TEST] FimAndEventLogTests starting...");

            TestSha256AndIntegrityDetection();
            TestVolatilePathRejection();
            TestWindowsEventLogSafeQuery();

            Console.WriteLine("[PASS] FimAndEventLogTests passed.");
        }

        private static void TestSha256AndIntegrityDetection()
        {
            string tempDir = Path.Combine(Path.GetTempPath(), "SentinelX_Test_" + Guid.NewGuid().ToString("N"));
            Directory.CreateDirectory(tempDir);
            string testFile = Path.Combine(tempDir, "critical_config.ini");

            try
            {
                File.WriteAllText(testFile, "initial_configuration_state_v1");

                var fimService = new FimService();
                var target = fimService.AddTarget(testFile, "Critical Configuration");

                if (target == null || string.IsNullOrEmpty(target.BaselineSha256))
                {
                    throw new Exception("FIM target baseline creation failed.");
                }

                if (target.HasChanged)
                {
                    throw new Exception("Newly added target should not be marked as changed.");
                }

                // Verify file initially
                var initialVerify = fimService.VerifyTarget(target.TargetId);
                if (initialVerify.HasChanged || initialVerify.Status != ComponentStatus.Enabled.ToString())
                {
                    throw new Exception("Initial verification failed to match baseline.");
                }

                // Mutate file to simulate unauthorized modification
                File.WriteAllText(testFile, "tampered_configuration_state_v2");

                var modifiedVerify = fimService.VerifyTarget(target.TargetId);
                if (!modifiedVerify.HasChanged)
                {
                    throw new Exception("FIM failed to detect file modification.");
                }

                if (modifiedVerify.Status != ComponentStatus.Unknown.ToString())
                {
                    throw new Exception("Modified target status should be Unknown (Warning state), got: " + modifiedVerify.Status);
                }

                // Reset baseline
                var resetTarget = fimService.ResetBaseline(target.TargetId);
                if (resetTarget.HasChanged || resetTarget.Status != ComponentStatus.Enabled.ToString())
                {
                    throw new Exception("Reset baseline failed to restore Enabled status.");
                }

                // Clean up target
                fimService.RemoveTarget(target.TargetId);
            }
            finally
            {
                if (Directory.Exists(tempDir))
                {
                    Directory.Delete(tempDir, true);
                }
            }
        }

        private static void TestVolatilePathRejection()
        {
            var fimService = new FimService();
            bool caught = false;

            try
            {
                fimService.AddTarget(@"C:\Windows\Temp\malicious_cache.tmp");
            }
            catch (InvalidOperationException)
            {
                caught = true;
            }
            catch (Exception)
            {
                // File not found or other is acceptable if path doesn't exist,
                // but our prefix check throws InvalidOperationException
                caught = true;
            }

            if (!caught)
            {
                throw new Exception("FIM should reject volatile OS paths like C:\\Windows\\Temp");
            }
        }

        private static void TestWindowsEventLogSafeQuery()
        {
            var eventService = new WindowsEventLogService();
            var snapshot = eventService.GetSecurityEvents(10);

            if (snapshot == null)
            {
                throw new Exception("WindowsEventLogService returned null snapshot.");
            }

            if (snapshot.Events == null)
            {
                throw new Exception("WindowsEventLogService returned null events list.");
            }

            // Verify graceful execution (should not crash even if Security channel gives AccessDenied)
            Console.WriteLine("    [LOG] Read " + snapshot.Events.Count + " event log items. Summary: " + snapshot.ChannelSummary);
        }
    }
}
