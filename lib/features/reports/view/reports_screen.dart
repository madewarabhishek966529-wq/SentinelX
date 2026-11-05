import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/recommendation_report_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  void _openFileLocation(String filePath) {
    if (Platform.isWindows && filePath.isNotEmpty) {
      Process.run('explorer.exe', ['/select,', filePath]);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationReportProvider);
    final report = state.lastGeneratedReport;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Security Reports & Export', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : () => ref.read(recommendationReportProvider.notifier).generateReport(),
                icon: const Icon(Icons.analytics_outlined, size: 16),
                label: const Text('Generate Full Audit Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SentinelColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate honest, comprehensive security posture reports in Markdown, CSV, or JSON format. Every report explicitly lists completed checks, unavailable checks, timestamps, and known limitations.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 20),

          // Export Actions Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Local Report Export Formats', style: SentinelTypography.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'Reports are compiled on this device and saved locally into %LOCALAPPDATA%\\SentinelX\\Reports\\. Raw telemetry is never transmitted externally.',
                    style: SentinelTypography.bodySecondary,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: state.isExporting ? null : () => ref.read(recommendationReportProvider.notifier).exportReport('markdown'),
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('Export Markdown (.md)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SentinelColors.surfaceHighlight,
                          foregroundColor: SentinelColors.textPrimary,
                          side: const BorderSide(color: SentinelColors.border),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.isExporting ? null : () => ref.read(recommendationReportProvider.notifier).exportReport('csv'),
                        icon: const Icon(Icons.table_chart_outlined, size: 16),
                        label: const Text('Export Tabular CSV (.csv)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SentinelColors.surfaceHighlight,
                          foregroundColor: SentinelColors.textPrimary,
                          side: const BorderSide(color: SentinelColors.border),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: state.isExporting ? null : () => ref.read(recommendationReportProvider.notifier).exportReport('json'),
                        icon: const Icon(Icons.data_object_outlined, size: 16),
                        label: const Text('Export Raw JSON (.json)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SentinelColors.surfaceHighlight,
                          foregroundColor: SentinelColors.textPrimary,
                          side: const BorderSide(color: SentinelColors.border),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Export feedback pill
          if (state.lastExportedPath != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SentinelColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SentinelColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.file_download_done, color: SentinelColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Report Exported Successfully', style: SentinelTypography.titleMedium),
                        const SizedBox(height: 2),
                        SelectableText(state.lastExportedPath!, style: SentinelTypography.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openFileLocation(state.lastExportedPath!),
                    icon: const Icon(Icons.folder_open, size: 14),
                    label: const Text('Show in Explorer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SentinelColors.primary,
                      side: const BorderSide(color: SentinelColors.border),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Generated Report Audit Details (if generated)
          if (report != null) ...[
            Text('Generated Posture Report Preview (ID: ${report.reportId})', style: SentinelTypography.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Machine: ${report.machineName}', style: SentinelTypography.titleMedium),
                        const Spacer(),
                        Text('Generated: ${report.generatedAtUtc}', style: SentinelTypography.caption),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Operating System: ${report.osVersion}', style: SentinelTypography.bodySecondary),
                    const Divider(height: 24),
                    const Text('Completed Defensive Checks:', style: SentinelTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text(report.completedChecksSummary, style: SentinelTypography.bodySecondary),
                    const SizedBox(height: 14),
                    const Text('Explicitly Excluded / Unavailable Checks:', style: SentinelTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text(report.unavailableChecksSummary, style: SentinelTypography.bodySecondary),
                    const SizedBox(height: 14),
                    const Text('Active Recommendations Count:', style: SentinelTypography.titleMedium),
                    const SizedBox(height: 4),
                    Text('${report.recommendations.length} evidence-based action items evaluated.', style: SentinelTypography.bodySecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Mandatory Report Disclaimer (SX-010)
          Text('Report Audit Disclosure & Technical Disclaimer', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Mandatory Report Disclaimer (PRD SX-010):',
                    style: TextStyle(fontWeight: FontWeight.w600, color: SentinelColors.textPrimary),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Included Checks: Registered Antivirus (WSC & WinDefend service), Windows Firewall profiles (Domain, Private, Public), User Account Control (UAC) policy, Windows Update service state, Authenticode certificate publisher verification of startup items, Local network adapter configurations, User-selected file integrity SHA-256 baselines.\n\n• Unperformed / Excluded Checks: Memory injection scanning, kernel-mode rootkit detection, arbitrary outbound internet scanning, deep packet payload inspection, password hash auditing.\n\n• Legal / Operational Note: This report represents observable Windows configuration at the timestamp recorded. It does not certify that the host is free from all advanced malware or vulnerabilities.',
                    style: SentinelTypography.bodySecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
