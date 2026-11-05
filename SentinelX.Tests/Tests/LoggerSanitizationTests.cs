using System;
using SentinelX.Engine.Logging;

namespace SentinelX.Tests.Tests
{
    public static class LoggerSanitizationTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] LoggerSanitizationTests starting...");

            var logger = new StructuredLogger(null, LogLevel.Debug);

            var sensitive1 = "User attempted auth with token=a1b2c3d4e5f67890abcdef123456";
            var redacted1 = logger.Redact(sensitive1);
            Assert(!redacted1.Contains("a1b2c3d4e5f67890"), "Token value must be redacted from log");
            Assert(redacted1.Contains("[REDACTED]"), "Redaction placeholder must be present");

            var sensitive2 = "Payload received with secret: \"mySuperSecretPassword123\"";
            var redacted2 = logger.Redact(sensitive2);
            Assert(!redacted2.Contains("mySuperSecretPassword123"), "Secret value must be redacted");

            Console.WriteLine("[PASS] LoggerSanitizationTests passed.");
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
