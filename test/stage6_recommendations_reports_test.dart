import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelx/core/models/component_status.dart';
import 'package:sentinelx/core/models/ipc_contract.dart';

void main() {
  group('Stage 6 Recommendations & Reports Tests', () {
    test('SecurityRecommendationItem contains explainable evidence and action URIs (SX-009)', () {
      final json = {
        'Id': 'REC_AV_INACTIVE',
        'Title': 'Enable Antivirus Protection',
        'Category': 'Protection',
        'Priority': 'High',
        'Status': 'unknown',
        'Evidence': 'No active registered antivirus detected.',
        'Source': 'Windows Security Center',
        'TimestampUtc': '2026-11-05T12:00:00Z',
        'Limitations': 'Third-party unregistered tools not detected.',
        'ActionUri': 'ms-settings:windowsdefender',
        'ActionLabel': 'Open Windows Security'
      };

      final rec = SecurityRecommendationItem.fromJson(json);
      expect(rec.id, 'REC_AV_INACTIVE');
      expect(rec.priority, 'High');
      expect(rec.actionUri, 'ms-settings:windowsdefender');
      expect(rec.status, ComponentStatus.unknown);
      expect(rec.evidence, contains('No active registered antivirus'));
    });

    test('SystemReportData includes mandatory completed/unavailable checks and disclaimer (SX-010)', () {
      final json = {
        'ReportId': 'REP_A1B2C3',
        'GeneratedAtUtc': '2026-11-05T12:00:00Z',
        'MachineName': 'TEST-PC',
        'OsVersion': 'Windows 11',
        'CompletedChecksSummary': 'Firewall, AV, UAC, Startup',
        'UnavailableChecksSummary': 'No memory injection, no payload sniffing',
        'Disclaimer': 'SentinelX is a local-first defensive visibility tool. Reports represent point-in-time observational state.',
        'Recommendations': []
      };

      final report = SystemReportData.fromJson(json);
      expect(report.reportId, 'REP_A1B2C3');
      expect(report.completedChecksSummary, contains('Firewall'));
      expect(report.unavailableChecksSummary.toLowerCase(), contains('no payload sniffing'));
      expect(report.disclaimer, contains('SentinelX'));
    });
  });
}
