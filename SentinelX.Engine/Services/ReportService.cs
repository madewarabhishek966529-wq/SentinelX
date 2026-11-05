using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class ReportService
    {
        private readonly StructuredLogger _logger;
        private readonly WindowsSecurityService _securityService;
        private readonly DeviceProcessService _deviceProcessService;
        private readonly NetworkService _networkService;
        private readonly RecommendationService _recommendationService;
        private readonly string _reportsDir;

        public ReportService(
            StructuredLogger logger,
            WindowsSecurityService securityService,
            DeviceProcessService deviceProcessService,
            NetworkService networkService,
            RecommendationService recommendationService)
        {
            _logger = logger;
            _securityService = securityService;
            _deviceProcessService = deviceProcessService;
            _networkService = networkService;
            _recommendationService = recommendationService;

            string appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            _reportsDir = Path.Combine(appData, "SentinelX", "Reports");
            Directory.CreateDirectory(_reportsDir);
        }

        public SystemReportData BuildSystemReport()
        {
            var report = new SystemReportData
            {
                ReportId = Guid.NewGuid().ToString("N").Substring(0, 12).ToUpperInvariant(),
                GeneratedAtUtc = DateTime.UtcNow.ToString("o"),
                MachineName = Environment.MachineName,
                OsVersion = Environment.OSVersion.VersionString,
                Posture = _securityService.GetPostureSnapshot(),
                Inventory = _deviceProcessService.GetDeviceInventory(),
                Network = _networkService.GetNetworkActivity(),
                Recommendations = _recommendationService.EvaluateRecommendations(),
                CompletedChecksSummary = "Windows Antivirus registration, 3-Profile Firewall states, UAC consent policies, Windows Update service, Authenticode startup binaries, Active local network adapters, User-specified FIM SHA-256 baselines.",
                UnavailableChecksSummary = "Memory injection scanning (anti-cheat/EDR scope), Kernel-level rootkit detection, Arbitrary external internet port probing, Network packet payload capture (strictly prohibited by defensive boundary).",
                Disclaimer = "SentinelX is a local-first defensive visibility and posture auditing tool. " +
                             "This report represents point-in-time observational state and does not guarantee the absence of unknown vulnerabilities or threats."
            };

            return report;
        }

        public string ExportReport(string format)
        {
            var data = BuildSystemReport();
            string timestamp = DateTime.UtcNow.ToString("yyyyMMdd_HHmmss");
            string filename = "SentinelX_Security_Report_" + timestamp;

            if (string.Equals(format, "csv", StringComparison.OrdinalIgnoreCase))
            {
                filename += ".csv";
                string fullPath = Path.Combine(_reportsDir, filename);
                string csv = BuildCsv(data);
                File.WriteAllText(fullPath, csv, Encoding.UTF8);
                return fullPath;
            }

            if (string.Equals(format, "markdown", StringComparison.OrdinalIgnoreCase) || string.Equals(format, "md", StringComparison.OrdinalIgnoreCase))
            {
                filename += ".md";
                string fullPath = Path.Combine(_reportsDir, filename);
                string md = BuildMarkdown(data);
                File.WriteAllText(fullPath, md, Encoding.UTF8);
                return fullPath;
            }

            // Default to JSON
            filename += ".json";
            string jsonPath = Path.Combine(_reportsDir, filename);
            string json = JsonHelper.Serialize(data);
            File.WriteAllText(jsonPath, json, Encoding.UTF8);
            return jsonPath;
        }

        private static string BuildCsv(SystemReportData data)
        {
            var sb = new StringBuilder();
            sb.AppendLine("ReportId,GeneratedAtUtc,MachineName,OsVersion");
            sb.AppendLine(string.Format("\"{0}\",\"{1}\",\"{2}\",\"{3}\"",
                data.ReportId, data.GeneratedAtUtc, data.MachineName, data.OsVersion));
            sb.AppendLine();

            sb.AppendLine("Section,Component,Status,Details,Source");
            if (data.Posture != null)
            {
                foreach (var av in data.Posture.AntivirusProviders)
                {
                    sb.AppendLine(string.Format("\"Posture\",\"Antivirus (Active: {0})\",\"{1}\",\"{2}\",\"{3}\"",
                        av.IsActive, av.Status, av.DisplayName, av.Source));
                }
                foreach (var fw in data.Posture.FirewallProfiles)
                {
                    sb.AppendLine(string.Format("\"Posture\",\"Firewall {0}\",\"{1}\",\"Inbound: {2} / Outbound: {3}\",\"{4}\"",
                        fw.ProfileName, fw.Status, fw.InboundAction, fw.OutboundAction, fw.Source));
                }
                sb.AppendLine(string.Format("\"Posture\",\"UAC (SecureDesktop: {0})\",\"{1}\",\"{2}\",\"{3}\"",
                    data.Posture.Uac.PromptOnSecureDesktop, data.Posture.Uac.Status, data.Posture.Uac.Summary, data.Posture.Uac.Source));
            }

            foreach (var rec in data.Recommendations)
            {
                sb.AppendLine(string.Format("\"Recommendation (Priority: {0})\",\"{1}\",\"{2}\",\"{3}\",\"{4}\"",
                    rec.Priority, rec.Title, rec.Status, rec.Evidence.Replace("\"", "\"\""), rec.Source));
            }

            return sb.ToString();
        }

        private static string BuildMarkdown(SystemReportData data)
        {
            var sb = new StringBuilder();
            sb.AppendLine("# SentinelX System Posture Audit Report");
            sb.AppendLine();
            sb.AppendLine("- **Report ID:** " + data.ReportId);
            sb.AppendLine("- **Generated (UTC):** " + data.GeneratedAtUtc);
            sb.AppendLine("- **Machine Name:** " + data.MachineName);
            sb.AppendLine("- **Operating System:** " + data.OsVersion);
            sb.AppendLine();
            sb.AppendLine("## 1. Defensive Posture Overview");
            if (data.Posture != null)
            {
                sb.AppendLine("- **Antivirus Registered:** " + (data.Posture.AntivirusProviders.Count > 0 ? data.Posture.AntivirusProviders[0].DisplayName : "None"));
                sb.AppendLine("- **Firewall Profiles:** " + data.Posture.FirewallProfiles.Count + " monitored");
                sb.AppendLine("- **UAC Configuration:** " + data.Posture.Uac.Summary);
                sb.AppendLine("- **Windows Update:** " + data.Posture.WindowsUpdate.Summary);
            }
            sb.AppendLine();
            sb.AppendLine("## 2. Evidence-Based Recommendations");
            foreach (var r in data.Recommendations)
            {
                sb.AppendLine(string.Format("### [{0}] {1}", r.Priority.ToUpperInvariant(), r.Title));
                sb.AppendLine("- **Category:** " + r.Category);
                sb.AppendLine("- **Evidence:** " + r.Evidence);
                sb.AppendLine("- **Source:** " + r.Source);
                sb.AppendLine("- **Limitations:** " + r.Limitations);
                sb.AppendLine("- **Suggested Action:** " + r.ActionLabel + " (`" + r.ActionUri + "`)");
                sb.AppendLine();
            }
            sb.AppendLine("## 3. Mandatory Audit Scope & Legal Disclosure (PRD SX-010)");
            sb.AppendLine("- **Completed Checks:** " + data.CompletedChecksSummary);
            sb.AppendLine("- **Excluded Checks:** " + data.UnavailableChecksSummary);
            sb.AppendLine("- **Disclaimer:** " + data.Disclaimer);
            sb.AppendLine();
            return sb.ToString();
        }
    }
}
