using System;
using System.Collections.Generic;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class RecommendationService
    {
        private readonly StructuredLogger _logger;
        private readonly WindowsSecurityService _securityService;
        private readonly DeviceProcessService _deviceProcessService;
        private readonly FimService _fimService;

        public RecommendationService(
            StructuredLogger logger,
            WindowsSecurityService securityService,
            DeviceProcessService deviceProcessService,
            FimService fimService)
        {
            _logger = logger;
            _securityService = securityService;
            _deviceProcessService = deviceProcessService;
            _fimService = fimService;
        }

        public List<SecurityRecommendationItem> EvaluateRecommendations()
        {
            var list = new List<SecurityRecommendationItem>();

            try
            {
                var posture = _securityService.GetPostureSnapshot();
                var startupApps = _deviceProcessService.GetStartupEntries();
                var fimSnapshot = _fimService != null ? _fimService.GetSnapshot() : null;

                // Rule 1: Antivirus Status
                if (posture.AntivirusProviders.Count == 0 || !posture.AntivirusProviders.Exists(av => av.IsActive))
                {
                    list.Add(new SecurityRecommendationItem
                    {
                        Id = "REC_AV_INACTIVE",
                        Title = "Enable and Update Antivirus Protection",
                        Category = "Protection",
                        Priority = "High",
                        Status = ComponentStatus.Unknown.ToString(),
                        Evidence = "No active registered real-time antivirus product was reported by Windows Security Center.",
                        Source = "ROOT\\SecurityCenter2:AntivirusProduct / WinDefend Service",
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Limitations = "Third-party EDR/AV solutions not registered with Windows Security Center may not be detected.",
                        ActionUri = "ms-settings:windowsdefender",
                        ActionLabel = "Open Windows Security"
                    });
                }
                else
                {
                    list.Add(new SecurityRecommendationItem
                    {
                        Id = "REC_AV_ACTIVE",
                        Title = "Maintain Antivirus Signature Freshness",
                        Category = "Protection",
                        Priority = "Info",
                        Status = ComponentStatus.Enabled.ToString(),
                        Evidence = "Active antivirus provider detected: " + posture.AntivirusProviders[0].DisplayName,
                        Source = posture.AntivirusProviders[0].Source,
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Limitations = "Definition freshness relies on scheduled update checks.",
                        ActionUri = "ms-settings:windowsdefender",
                        ActionLabel = "Open Windows Security"
                    });
                }

                // Rule 2: Firewall Profiles
                bool allFirewallsEnabled = true;
                string disabledProfiles = "";
                foreach (var fw in posture.FirewallProfiles)
                {
                    if (!fw.IsEnabled)
                    {
                        allFirewallsEnabled = false;
                        disabledProfiles += fw.ProfileName + " ";
                    }
                }

                if (!allFirewallsEnabled)
                {
                    list.Add(new SecurityRecommendationItem
                    {
                        Id = "REC_FW_DISABLED",
                        Title = "Enable Inactive Windows Firewall Profiles",
                        Category = "Protection",
                        Priority = "High",
                        Status = ComponentStatus.Disabled.ToString(),
                        Evidence = "The following firewall profiles are currently disabled: " + disabledProfiles.Trim(),
                        Source = "Windows Firewall COM / Registry Policy",
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Limitations = "Hardware or third-party router firewalls are outside host firewall scope.",
                        ActionUri = "ms-settings:network",
                        ActionLabel = "Open Network Security"
                    });
                }
                else
                {
                    list.Add(new SecurityRecommendationItem
                    {
                        Id = "REC_FW_ENABLED",
                        Title = "Firewall Profiles Fully Active",
                        Category = "Protection",
                        Priority = "Info",
                        Status = ComponentStatus.Enabled.ToString(),
                        Evidence = "All active Windows Firewall profiles (Domain, Private, Public) are enforcing inbound packet filtering.",
                        Source = "Windows Firewall Policy",
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Limitations = "Does not inspect internal switch or VLAN configurations.",
                        ActionUri = "ms-settings:network",
                        ActionLabel = "View Network Settings"
                    });
                }

                // Rule 3: UAC Configuration
                if (!posture.Uac.IsEnabled || !posture.Uac.PromptOnSecureDesktop)
                {
                    list.Add(new SecurityRecommendationItem
                    {
                        Id = "REC_UAC_WEAK",
                        Title = "Strengthen User Account Control (UAC)",
                        Category = "Account",
                        Priority = "Medium",
                        Status = ComponentStatus.Unknown.ToString(),
                        Evidence = "UAC prompt on secure desktop is disabled or elevation consent is weakened.",
                        Source = "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System",
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Limitations = "Registry policy check; group policy overrides may apply.",
                        ActionUri = "ms-settings:privacy",
                        ActionLabel = "Adjust Security Settings"
                    });
                }

                // Rule 4: Startup Apps Publisher Verification
                int unverifiedCount = 0;
                foreach (var app in startupApps)
                {
                    if (string.Equals(app.Status, ComponentStatus.Unknown.ToString(), StringComparison.OrdinalIgnoreCase))
                    {
                        unverifiedCount++;
                    }
                }

                if (unverifiedCount > 0)
                {
                    list.Add(new SecurityRecommendationItem
                    {
                        Id = "REC_STARTUP_UNVERIFIED",
                        Title = "Audit Unsigned Startup Items (" + unverifiedCount + " Found)",
                        Category = "Device",
                        Priority = "Low",
                        Status = ComponentStatus.Unknown.ToString(),
                        Evidence = unverifiedCount + " startup item(s) in registry Run keys or Startup folder do not carry a verifiable digital signature.",
                        Source = "Win32 Authenticode Certificate Verification",
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Limitations = "Unverified signatures do not imply malicious intent; open-source and script tools frequently omit commercial certificates.",
                        ActionUri = "ms-settings:startupapps",
                        ActionLabel = "Inspect Startup Apps"
                    });
                }

                // Rule 5: File Integrity Verification
                if (fimSnapshot != null)
                {
                    var changedTargets = fimSnapshot.Targets.FindAll(t => t.HasChanged);
                    if (changedTargets.Count > 0)
                    {
                        list.Add(new SecurityRecommendationItem
                        {
                            Id = "REC_FIM_MODIFIED",
                            Title = "Review Modified Monitored File Baselines (" + changedTargets.Count + " Changed)",
                            Category = "Integrity",
                            Priority = "High",
                            Status = ComponentStatus.Unknown.ToString(),
                            Evidence = changedTargets.Count + " file(s) have cryptographic SHA-256 hashes that differ from the established baseline.",
                            Source = "SentinelX FIM Engine (SHA-256 Streaming Hasher)",
                            TimestampUtc = DateTime.UtcNow.ToString("o"),
                            Limitations = "Legitimate software updates will alter file hashes. User verification is required before accepting new baselines.",
                            ActionUri = "sentinelx:fim",
                            ActionLabel = "Inspect FIM Module"
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("Error evaluating recommendations: " + ex.Message, "RecommendationService");
            }

            return list;
        }
    }
}
