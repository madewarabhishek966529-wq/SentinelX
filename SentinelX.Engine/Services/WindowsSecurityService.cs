using System;
using System.Collections.Generic;
using System.Management;
using System.Reflection;
using System.ServiceProcess;
using Microsoft.Win32;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class WindowsSecurityService
    {
        private readonly StructuredLogger _logger;

        public WindowsSecurityService(StructuredLogger logger)
        {
            _logger = logger;
        }

        public ProtectionPostureSnapshot GetPostureSnapshot()
        {
            var snapshot = new ProtectionPostureSnapshot
            {
                AntivirusProviders = QueryAntivirusProviders(),
                FirewallProfiles = QueryFirewallProfiles(),
                Uac = QueryUacStatus(),
                WindowsUpdate = QueryWindowsUpdateStatus(),
                SmartScreen = QuerySmartScreenStatus(),
                SnapshotTimestampUtc = DateTime.UtcNow.ToString("o")
            };

            return snapshot;
        }

        public List<AntivirusInfo> QueryAntivirusProviders()
        {
            var results = new List<AntivirusInfo>();
            var now = DateTime.UtcNow.ToString("o");

            try
            {
                using (var searcher = new ManagementObjectSearcher(@"root\SecurityCenter2", "SELECT * FROM AntivirusProduct"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        using (obj)
                        {
                            var name = obj["displayName"]?.ToString() ?? "Unknown Antivirus";
                            var stateObj = obj["productState"];
                            uint productState = 0;
                            if (stateObj != null)
                            {
                                uint.TryParse(stateObj.ToString(), out productState);
                            }

                            // Microsoft WSC productState bitmask:
                            // State byte 2 (bits 12-15): 0x1000 = Enabled/Active, 0x0000 = Disabled
                            // State byte 1 (bits 4-7): 0x00 = Up to date, 0x10 = Out of date
                            var hex = "0x" + productState.ToString("X");
                            var isActive = (productState & 0x1000) != 0;
                            var isUpToDate = (productState & 0x10) == 0;

                            string statusStr = isActive ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString();

                            results.Add(new AntivirusInfo
                            {
                                DisplayName = name,
                                Status = statusStr,
                                IsActive = isActive,
                                IsUpToDate = isUpToDate,
                                ProductStateHex = hex,
                                Source = @"ROOT\SecurityCenter2:AntivirusProduct",
                                CheckedAtUtc = now,
                                Limitations = "Query reflects registered Windows Security Center providers."
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("WMI Antivirus query error: " + ex.Message, "WindowsSecurityService");
            }

            // Fallback: If WMI returned 0 providers, check if WinDefend service is running
            if (results.Count == 0)
            {
                results.Add(CheckDefenderServiceFallback(now));
            }

            return results;
        }

        private AntivirusInfo CheckDefenderServiceFallback(string now)
        {
            try
            {
                using (var sc = new ServiceController("WinDefend"))
                {
                    var isRunning = sc.Status == ServiceControllerStatus.Running;
                    return new AntivirusInfo
                    {
                        DisplayName = "Microsoft Defender Antivirus (Service Check)",
                        Status = isRunning ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                        IsActive = isRunning,
                        IsUpToDate = true,
                        ProductStateHex = isRunning ? "Running" : "Stopped",
                        Source = "Windows Service Control Manager (WinDefend)",
                        CheckedAtUtc = now,
                        Limitations = "Fallback check via service controller because SecurityCenter2 returned no providers."
                    };
                }
            }
            catch (Exception ex)
            {
                return new AntivirusInfo
                {
                    DisplayName = "Antivirus Status Query",
                    Status = ComponentStatus.Unknown.ToString(),
                    IsActive = false,
                    IsUpToDate = false,
                    ProductStateHex = "Unknown",
                    Source = "Windows Security Center / ServiceController",
                    CheckedAtUtc = now,
                    Limitations = "Unable to determine provider state: " + ex.Message
                };
            }
        }

        public List<FirewallProfileInfo> QueryFirewallProfiles()
        {
            var profiles = new List<FirewallProfileInfo>();
            var now = DateTime.UtcNow.ToString("o");

            // Query via INetFwPolicy2 COM interface using Reflection
            bool comSucceeded = false;
            try
            {
                var type = Type.GetTypeFromProgID("HNetCfg.FwPolicy2");
                if (type != null)
                {
                    var fwPolicy2 = Activator.CreateInstance(type);
                    if (fwPolicy2 != null)
                    {
                        // Profile types: 1 = Domain, 2 = Private, 4 = Public
                        bool domainEnabled = (bool)type.InvokeMember("FirewallEnabled", BindingFlags.GetProperty | BindingFlags.InvokeMethod, null, fwPolicy2, new object[] { 1 });
                        bool privateEnabled = (bool)type.InvokeMember("FirewallEnabled", BindingFlags.GetProperty | BindingFlags.InvokeMethod, null, fwPolicy2, new object[] { 2 });
                        bool publicEnabled = (bool)type.InvokeMember("FirewallEnabled", BindingFlags.GetProperty | BindingFlags.InvokeMethod, null, fwPolicy2, new object[] { 4 });

                        profiles.Add(new FirewallProfileInfo
                        {
                            ProfileName = "Domain",
                            IsEnabled = domainEnabled,
                            Status = domainEnabled ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                            InboundAction = "Block by default",
                            OutboundAction = "Allow by default",
                            Source = "INetFwPolicy2 COM Interface (Domain)",
                            CheckedAtUtc = now,
                            Limitations = "Active only when host is joined to an Active Directory domain."
                        });

                        profiles.Add(new FirewallProfileInfo
                        {
                            ProfileName = "Private",
                            IsEnabled = privateEnabled,
                            Status = privateEnabled ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                            InboundAction = "Block by default",
                            OutboundAction = "Allow by default",
                            Source = "INetFwPolicy2 COM Interface (Private)",
                            CheckedAtUtc = now,
                            Limitations = "Applies to trusted private/home networks."
                        });

                        profiles.Add(new FirewallProfileInfo
                        {
                            ProfileName = "Public",
                            IsEnabled = publicEnabled,
                            Status = publicEnabled ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                            InboundAction = "Block all unsolicited inbound",
                            OutboundAction = "Allow by default",
                            Source = "INetFwPolicy2 COM Interface (Public)",
                            CheckedAtUtc = now,
                            Limitations = "Applies to public networks (e.g. Wi-Fi hotspots)."
                        });

                        comSucceeded = true;
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("COM Firewall query error: " + ex.Message + ", falling back to Registry", "WindowsSecurityService");
            }

            // Fallback: Registry query
            if (!comSucceeded)
            {
                profiles.Clear();
                profiles.Add(ReadFirewallRegistryProfile("Domain", @"SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile", now));
                profiles.Add(ReadFirewallRegistryProfile("Private", @"SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile", now));
                profiles.Add(ReadFirewallRegistryProfile("Public", @"SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile", now));
            }

            return profiles;
        }

        private FirewallProfileInfo ReadFirewallRegistryProfile(string name, string subKey, string now)
        {
            try
            {
                using (var key = Registry.LocalMachine.OpenSubKey(subKey))
                {
                    if (key != null)
                    {
                        var enabledVal = key.GetValue("EnableFirewall");
                        var isEnabled = enabledVal != null && Convert.ToInt32(enabledVal) == 1;

                        return new FirewallProfileInfo
                        {
                            ProfileName = name,
                            IsEnabled = isEnabled,
                            Status = isEnabled ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                            InboundAction = "Block unsolicited inbound",
                            OutboundAction = "Allow by default",
                            Source = @"HKLM\" + subKey,
                            CheckedAtUtc = now,
                            Limitations = "Read from Windows Registry FirewallPolicy configuration."
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("Registry firewall read error: " + ex.Message, "WindowsSecurityService");
            }

            return new FirewallProfileInfo
            {
                ProfileName = name,
                IsEnabled = false,
                Status = ComponentStatus.Unknown.ToString(),
                InboundAction = "Unknown",
                OutboundAction = "Unknown",
                Source = @"HKLM\" + subKey,
                CheckedAtUtc = now,
                Limitations = "Firewall key could not be opened or read."
            };
        }

        public UacInfo QueryUacStatus()
        {
            var now = DateTime.UtcNow.ToString("o");
            try
            {
                using (var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"))
                {
                    if (key != null)
                    {
                        var enableLua = Convert.ToInt32(key.GetValue("EnableLUA", 1));
                        var consentBehavior = Convert.ToInt32(key.GetValue("ConsentPromptBehaviorAdmin", 5));
                        var secureDesktop = Convert.ToInt32(key.GetValue("PromptOnSecureDesktop", 1));

                        var isEnabled = enableLua == 1;
                        var promptSecure = secureDesktop == 1;

                        string summary;
                        if (!isEnabled)
                        {
                            summary = "UAC is completely disabled (EnableLUA = 0). Applications can run elevated without consent.";
                        }
                        else if (consentBehavior == 5)
                        {
                            summary = "Standard UAC Level: Prompt for consent for non-Windows binaries on Secure Desktop.";
                        }
                        else if (consentBehavior == 2)
                        {
                            summary = "Highest UAC Level: Always notify and require credentials/consent.";
                        }
                        else
                        {
                            summary = string.Format("UAC is enabled (ConsentPromptBehaviorAdmin = {0}, SecureDesktop = {1}).", consentBehavior, secureDesktop);
                        }

                        return new UacInfo
                        {
                            Status = isEnabled ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                            IsEnabled = isEnabled,
                            ConsentPromptBehaviorAdmin = consentBehavior,
                            PromptOnSecureDesktop = promptSecure,
                            Summary = summary,
                            Source = @"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
                            CheckedAtUtc = now,
                            Limitations = "Read-only inspection. SentinelX does not modify UAC settings."
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("UAC registry query error: " + ex.Message, "WindowsSecurityService");
            }

            return new UacInfo
            {
                Status = ComponentStatus.Unknown.ToString(),
                IsEnabled = false,
                Summary = "Unable to read UAC configuration from registry.",
                Source = @"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
                CheckedAtUtc = now,
                Limitations = "Access denied or key missing."
            };
        }

        public WindowsUpdateInfo QueryWindowsUpdateStatus()
        {
            var now = DateTime.UtcNow.ToString("o");
            try
            {
                using (var sc = new ServiceController("wuauserv"))
                {
                    var isRunning = sc.Status == ServiceControllerStatus.Running;
                    var stateStr = sc.Status.ToString();

                    string lastSuccess = "Unknown";
                    try
                    {
                        using (var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\Results\Detect"))
                        {
                            if (key != null)
                            {
                                var lastTime = key.GetValue("LastSuccessTime");
                                if (lastTime != null)
                                {
                                    lastSuccess = lastTime.ToString();
                                }
                            }
                        }
                    }
                    catch { }

                    return new WindowsUpdateInfo
                    {
                        Status = isRunning ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                        IsServiceRunning = isRunning,
                        ServiceState = stateStr,
                        LastSearchSuccessDate = lastSuccess,
                        Summary = string.Format("Windows Update Agent service is {0}. Last search: {1}", stateStr, lastSuccess),
                        Source = "Windows Service Control Manager (wuauserv) & WindowsUpdate Registry",
                        CheckedAtUtc = now,
                        Limitations = "Update history reflects the local Windows Update Agent state."
                    };
                }
            }
            catch (Exception ex)
            {
                return new WindowsUpdateInfo
                {
                    Status = ComponentStatus.Unknown.ToString(),
                    IsServiceRunning = false,
                    ServiceState = "Unknown",
                    Summary = "Unable to query Windows Update Agent: " + ex.Message,
                    Source = "ServiceController (wuauserv)",
                    CheckedAtUtc = now,
                    Limitations = "ServiceController query error."
                };
            }
        }

        public SmartScreenInfo QuerySmartScreenStatus()
        {
            var now = DateTime.UtcNow.ToString("o");
            try
            {
                using (var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer"))
                {
                    if (key != null)
                    {
                        var val = key.GetValue("SmartScreenEnabled")?.ToString();
                        var isEnabled = !string.IsNullOrEmpty(val) && !string.Equals(val, "Off", StringComparison.OrdinalIgnoreCase);

                        return new SmartScreenInfo
                        {
                            Status = isEnabled ? ComponentStatus.Enabled.ToString() : ComponentStatus.Disabled.ToString(),
                            SettingValue = val ?? "Default",
                            Summary = isEnabled ? "Windows Defender SmartScreen is enabled." : "SmartScreen is turned off.",
                            Source = @"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SmartScreenEnabled",
                            CheckedAtUtc = now,
                            Limitations = "Read-only inspection of Windows Explorer reputation check setting."
                        };
                    }
                }
            }
            catch { }

            return new SmartScreenInfo
            {
                Status = ComponentStatus.Unknown.ToString(),
                SettingValue = "Unknown",
                Summary = "SmartScreen registry setting is unconfigured or managed via Group Policy.",
                Source = @"HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer",
                CheckedAtUtc = now,
                Limitations = "System does not expose a global non-managed registry key for SmartScreen."
            };
        }
    }
}
