using System;
using System.IO;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;
using SentinelX.Engine.Services;

namespace SentinelX.Tests.Tests
{
    public static class RecommendationAndReportTests
    {
        public static void RunAll()
        {
            Console.WriteLine("[TEST] RecommendationAndReportTests starting...");

            TestRecommendationEvaluation();
            TestReportGenerationAndExport();

            Console.WriteLine("[PASS] RecommendationAndReportTests passed.");
        }

        private static void TestRecommendationEvaluation()
        {
            var logger = new StructuredLogger(null, LogLevel.Info);
            var secService = new WindowsSecurityService(logger);
            var devService = new DeviceProcessService(logger);
            var fimService = new FimService(logger);

            var recService = new RecommendationService(logger, secService, devService, fimService);
            var recs = recService.EvaluateRecommendations();

            if (recs == null || recs.Count == 0)
            {
                throw new Exception("Recommendation service returned null or empty list.");
            }

            foreach (var rec in recs)
            {
                if (string.IsNullOrEmpty(rec.Title))
                    throw new Exception("Recommendation missing Title.");
                if (string.IsNullOrEmpty(rec.Category))
                    throw new Exception("Recommendation missing Category.");
                if (string.IsNullOrEmpty(rec.Priority))
                    throw new Exception("Recommendation missing Priority.");
                if (string.IsNullOrEmpty(rec.Evidence))
                    throw new Exception("Recommendation missing Evidence.");
                if (string.IsNullOrEmpty(rec.ActionUri))
                    throw new Exception("Recommendation missing ActionUri.");
                if (string.IsNullOrEmpty(rec.ActionLabel))
                    throw new Exception("Recommendation missing ActionLabel.");
            }

            Console.WriteLine("    [LOG] Evaluated " + recs.Count + " evidence-based recommendations successfully.");
        }

        private static void TestReportGenerationAndExport()
        {
            var logger = new StructuredLogger(null, LogLevel.Info);
            var secService = new WindowsSecurityService(logger);
            var devService = new DeviceProcessService(logger);
            var netService = new NetworkService(logger);
            var fimService = new FimService(logger);
            var recService = new RecommendationService(logger, secService, devService, fimService);

            var reportService = new ReportService(logger, secService, devService, netService, recService);
            var report = reportService.BuildSystemReport();

            if (report == null)
            {
                throw new Exception("BuildSystemReport returned null.");
            }

            if (string.IsNullOrEmpty(report.Disclaimer) || !report.Disclaimer.Contains("SentinelX"))
            {
                throw new Exception("Report missing mandatory PRD SX-010 legal disclaimer.");
            }

            if (string.IsNullOrEmpty(report.CompletedChecksSummary))
            {
                throw new Exception("Report missing CompletedChecksSummary disclosure.");
            }

            if (string.IsNullOrEmpty(report.UnavailableChecksSummary))
            {
                throw new Exception("Report missing UnavailableChecksSummary disclosure.");
            }

            // Test Exports (JSON, CSV, Markdown)
            string jsonPath = reportService.ExportReport("json");
            if (!File.Exists(jsonPath) || new FileInfo(jsonPath).Length == 0)
            {
                throw new Exception("JSON export failed or generated empty file.");
            }

            string csvPath = reportService.ExportReport("csv");
            if (!File.Exists(csvPath) || new FileInfo(csvPath).Length == 0)
            {
                throw new Exception("CSV export failed or generated empty file.");
            }

            string mdPath = reportService.ExportReport("markdown");
            if (!File.Exists(mdPath) || new FileInfo(mdPath).Length == 0)
            {
                throw new Exception("Markdown export failed or generated empty file.");
            }

            Console.WriteLine("    [LOG] Successfully generated reports in JSON (" + jsonPath + "), CSV, and Markdown.");
        }
    }
}
