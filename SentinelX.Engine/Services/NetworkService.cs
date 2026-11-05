using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Net;
using System.Net.NetworkInformation;
using System.Net.Sockets;
using System.Text.RegularExpressions;
using System.Threading;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class NetworkService
    {
        private readonly StructuredLogger _logger;
        private readonly Dictionary<string, long> _lastRxBytes = new Dictionary<string, long>();
        private readonly Dictionary<string, long> _lastTxBytes = new Dictionary<string, long>();
        private DateTime _lastPollTime = DateTime.UtcNow;

        public NetworkService(StructuredLogger logger)
        {
            _logger = logger;
        }

        public NetworkActivitySnapshot GetNetworkActivity()
        {
            var snapshot = new NetworkActivitySnapshot();
            var now = DateTime.UtcNow;
            var elapsedSeconds = Math.Max(0.5, (now - _lastPollTime).TotalSeconds);

            long totalRxSec = 0;
            long totalTxSec = 0;

            try
            {
                foreach (var nic in NetworkInterface.GetAllNetworkInterfaces())
                {
                    // Filter out disabled or tunnel interfaces if inactive
                    if (nic.OperationalStatus != OperationalStatus.Up && nic.NetworkInterfaceType != NetworkInterfaceType.Loopback)
                    {
                        continue;
                    }

                    var ipProps = nic.GetIPProperties();
                    var ipv4Props = ipProps.GetIPv4Properties();
                    var stats = nic.GetIPv4Statistics();

                    var adapter = new NetworkAdapterInfo
                    {
                        Id = nic.Id,
                        Name = nic.Name,
                        Description = nic.Description,
                        OperationalStatus = nic.OperationalStatus.ToString(),
                        InterfaceType = nic.NetworkInterfaceType.ToString(),
                        BytesReceived = stats.BytesReceived,
                        BytesSent = stats.BytesSent
                    };

                    // Extract IPv4 & Subnet Mask
                    foreach (var addr in ipProps.UnicastAddresses)
                    {
                        if (addr.Address.AddressFamily == AddressFamily.InterNetwork)
                        {
                            adapter.Ipv4Address = addr.Address.ToString();
                            adapter.SubnetMask = addr.IPv4Mask?.ToString() ?? "255.255.255.0";
                            break;
                        }
                    }

                    // Extract Gateway
                    foreach (var gw in ipProps.GatewayAddresses)
                    {
                        if (gw.Address.AddressFamily == AddressFamily.InterNetwork)
                        {
                            adapter.Gateway = gw.Address.ToString();
                            break;
                        }
                    }

                    // Extract DNS
                    foreach (var dns in ipProps.DnsAddresses)
                    {
                        if (dns.AddressFamily == AddressFamily.InterNetwork)
                        {
                            adapter.DnsServers.Add(dns.ToString());
                        }
                    }

                    // Calculate throughput rates
                    long rxDelta = 0;
                    long txDelta = 0;

                    if (_lastRxBytes.ContainsKey(nic.Id))
                    {
                        rxDelta = Math.Max(0, stats.BytesReceived - _lastRxBytes[nic.Id]);
                        txDelta = Math.Max(0, stats.BytesSent - _lastTxBytes[nic.Id]);
                    }

                    _lastRxBytes[nic.Id] = stats.BytesReceived;
                    _lastTxBytes[nic.Id] = stats.BytesSent;

                    adapter.RxBytesPerSec = (long)(rxDelta / elapsedSeconds);
                    adapter.TxBytesPerSec = (long)(txDelta / elapsedSeconds);

                    totalRxSec += adapter.RxBytesPerSec;
                    totalTxSec += adapter.TxBytesPerSec;

                    snapshot.Adapters.Add(adapter);
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("Error querying network adapter statistics: " + ex.Message, "NetworkService");
            }

            _lastPollTime = now;
            snapshot.TotalRxBytesPerSec = totalRxSec;
            snapshot.TotalTxBytesPerSec = totalTxSec;

            return snapshot;
        }

        /// <summary>
        /// Validates that an IP address or Subnet is strictly private (RFC 1918 or RFC 3927).
        /// REJECTS all public internet IP ranges (PRD SX-006).
        /// </summary>
        public static bool IsPrivateIpAddress(string ipString)
        {
            if (string.IsNullOrEmpty(ipString)) return false;

            // Strip subnet mask if passed as 192.168.1.0/24
            var cleanIp = ipString.Split('/')[0].Trim();

            IPAddress ip;
            if (!IPAddress.TryParse(cleanIp, out ip))
            {
                return false;
            }

            if (ip.AddressFamily != AddressFamily.InterNetwork)
            {
                return false; // IPv4 only for local discovery scope
            }

            byte[] bytes = ip.GetAddressBytes();

            // 1. Loopback (127.0.0.0/8)
            if (bytes[0] == 127) return true;

            // 2. RFC 1918: 10.0.0.0/8 (10.0.0.0 to 10.255.255.255)
            if (bytes[0] == 10) return true;

            // 3. RFC 1918: 172.16.0.0/12 (172.16.0.0 to 172.31.255.255)
            if (bytes[0] == 172 && (bytes[1] >= 16 && bytes[1] <= 31)) return true;

            // 4. RFC 1918: 192.168.0.0/16 (192.168.0.0 to 192.168.255.255)
            if (bytes[0] == 192 && bytes[1] == 168) return true;

            // 5. RFC 3927: 169.254.0.0/16 Link-local
            if (bytes[0] == 169 && bytes[1] == 254) return true;

            return false; // Public IP -> strictly forbidden
        }

        public List<LocalDeviceItem> DiscoverAuthorizedLocalDevices(string targetSubnet, CancellationToken ct)
        {
            if (!IsPrivateIpAddress(targetSubnet))
            {
                throw new InvalidOperationException("SCOPE_REJECTED: Target '" + targetSubnet + "' is outside private RFC 1918/3927 local scope. Public IP scanning is strictly forbidden.");
            }

            var devices = new List<LocalDeviceItem>();
            var now = DateTime.UtcNow.ToString("o");

            // Read Windows local ARP table cache
            try
            {
                var psi = new ProcessStartInfo("arp", "-a")
                {
                    RedirectStandardOutput = true,
                    UseShellExecute = false,
                    CreateNoWindow = true
                };

                using (var proc = Process.Start(psi))
                {
                    if (proc != null)
                    {
                        var output = proc.StandardOutput.ReadToEnd();
                        proc.WaitForExit();

                        var lines = output.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
                        var arpRegex = new Regex(@"([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})\s+([0-9a-fA-F\-]{17})\s+(\w+)", RegexOptions.Compiled);

                        foreach (var line in lines)
                        {
                            if (ct.IsCancellationRequested) break;

                            var match = arpRegex.Match(line);
                            if (match.Success)
                            {
                                var ip = match.Groups[1].Value;
                                var mac = match.Groups[2].Value;
                                var type = match.Groups[3].Value;

                                // Filter only private range and exclude broadcast (255) / multicast (224-239)
                                if (IsPrivateIpAddress(ip) && !ip.EndsWith(".255") && !ip.StartsWith("224."))
                                {
                                    string hostname = "Local Device";
                                    try
                                    {
                                        // Quick reverse DNS resolution
                                        var hostEntry = Dns.GetHostEntry(ip);
                                        if (!string.IsNullOrEmpty(hostEntry.HostName))
                                        {
                                            hostname = hostEntry.HostName;
                                        }
                                    }
                                    catch { }

                                    devices.Add(new LocalDeviceItem
                                    {
                                        IpAddress = ip,
                                        Hostname = hostname,
                                        MacAddress = mac,
                                        VendorHint = "Local Network Interface",
                                        DiscoveryMethod = "ARP Cache (" + type + ")",
                                        Status = ComponentStatus.Enabled.ToString(),
                                        FirstSeenUtc = now,
                                        LastSeenUtc = now,
                                        UserLabel = ""
                                    });
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("ARP discovery warning: " + ex.Message, "NetworkService");
            }

            return devices;
        }
    }
}

