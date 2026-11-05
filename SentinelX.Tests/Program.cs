using System;
using SentinelX.Tests.Tests;

namespace SentinelX.Tests
{
    class Program
    {
        static int Main(string[] args)
        {
            Console.WriteLine("==================================================");
            Console.WriteLine("     SentinelX Automated Engine Test Suite        ");
            Console.WriteLine("==================================================");

            int passed = 0;
            int failed = 0;

            Action[] testSuites = new Action[]
            {
                ContractSerializationTests.Run,
                SecurityBoundaryTests.Run,
                HealthHandshakeTests.Run,
                LoggerSanitizationTests.Run
            };

            foreach (var test in testSuites)
            {
                try
                {
                    test();
                    passed++;
                }
                catch (Exception ex)
                {
                    failed++;
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine("[FAIL] Suite failed: " + ex.Message);
                    Console.WriteLine(ex.StackTrace);
                    Console.ResetColor();
                }
            }

            Console.WriteLine("--------------------------------------------------");
            Console.WriteLine(string.Format("Test Results: {0} passed, {1} failed.", passed, failed));
            Console.WriteLine("==================================================");

            return failed == 0 ? 0 : 1;
        }
    }
}
