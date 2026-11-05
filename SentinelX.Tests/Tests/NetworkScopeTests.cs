using System;
using System.Threading;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;
using SentinelX.Engine.Services;

namespace SentinelX.Tests.Tests
{
    public static class NetworkScopeTests
    {
        public static void Run()
        {
            Console.WriteLine("[TEST] NetworkScopeTests starting...");

            // Test 1: Private IP Range Validation (RFC 1918 & RFC 3927)
            Assert(NetworkService.IsPrivateIpAddress("192.168.1.1"), "192.168.1.1 must be accepted as private");
            Assert(NetworkService.IsPrivateIpAddress("192.168.0.0/24"), "192.168.0.0/24 must be accepted as private");
            Assert(NetworkService.IsPrivateIpAddress("10.0.0.5"), "10.0.0.5 must be accepted as private");
            Assert(NetworkService.IsPrivateIpAddress("10.254.254.254"), "10.254.254.254 must be accepted as private");
            Assert(NetworkService.IsPrivateIpAddress("172.16.0.1"), "172.16.0.1 must be accepted as private");
            Assert(NetworkService.IsPrivateIpAddress("172.31.255.255"), "172.31.255.255 must be accepted as private");
            Assert(NetworkService.IsPrivateIpAddress("169.254.10.20"), "169.254.10.20 must be accepted as link-local private");
            Assert(NetworkService.IsPrivateIpAddress("127.0.0.1"), "127.0.0.1 loopback must be accepted");

            // Test 2: Public Range Rejection (PRD SX-006)
            Assert(!NetworkService.IsPrivateIpAddress("8.8.8.8"), "8.8.8.8 (Google DNS) must be REJECTED as public");
            Assert(!NetworkService.IsPrivateIpAddress("1.1.1.1"), "1.1.1.1 (Cloudflare DNS) must be REJECTED as public");
            Assert(!NetworkService.IsPrivateIpAddress("142.250.190.46"), "Public IP 142.250.190.46 must be REJECTED");
            Assert(!NetworkService.IsPrivateIpAddress("203.0.113.1"), "Public test IP 203.0.113.1 must be REJECTED");
            Assert(!NetworkService.IsPrivateIpAddress("invalid_string"), "Malformed string must be REJECTED");

            // Test 3: Exception thrown when discovering outside private scope
            var logger = new StructuredLogger(null, LogLevel.Debug);
            var service = new NetworkService(logger);

            bool exceptionCaught = false;
            try
            {
                service.DiscoverAuthorizedLocalDevices("8.8.8.8", CancellationToken.None);
            }
            catch (InvalidOperationException ex)
            {
                exceptionCaught = true;
                Assert(ex.Message.Contains("SCOPE_REJECTED"), "Exception must state SCOPE_REJECTED");
            }
            Assert(exceptionCaught, "DiscoverAuthorizedLocalDevices must reject public target 8.8.8.8 with exception");

            // Test 4: Network Activity Enumeration
            var activity = service.GetNetworkActivity();
            Assert(activity != null, "NetworkActivitySnapshot must not be null");
            Assert(activity.Adapters != null && activity.Adapters.Count > 0, "At least one network adapter must be active");

            // Test 5: Contract Serialization
            var json = JsonHelper.Serialize(activity);
            var des = JsonHelper.Deserialize<NetworkActivitySnapshot>(json);
            Assert(des.Adapters.Count == activity.Adapters.Count, "Deserialized adapter count must match");

            Console.WriteLine("[PASS] NetworkScopeTests passed.");
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

