import 'package:flutter/material.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Security Reports & Export', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Generate honest, comprehensive security posture reports in PDF, CSV, or JSON format. Every report explicitly lists completed checks, unavailable checks, timestamps, and known limitations.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Generate Local Security Report', style: SentinelTypography.titleLarge),
                  const SizedBox(height: 10),
                  const Text(
                    'Select export format. Reports are saved locally to your device and never transmitted over the network.',
                    style: SentinelTypography.bodySecondary,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildExportButton(context, 'Export PDF Report', Icons.picture_as_pdf_outlined, 'pdf'),
                      const SizedBox(width: 14),
                      _buildExportButton(context, 'Export CSV Data', Icons.table_chart_outlined, 'csv'),
                      const SizedBox(width: 14),
                      _buildExportButton(context, 'Export JSON Schema', Icons.data_object_outlined, 'json'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text('Report Audit Disclosure', style: SentinelTypography.titleLarge),
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
                    '• Included Checks: Registered Antivirus, Windows Firewall (Domain/Private/Public), UAC status, Windows Update status, Process publisher status, Run key startup inventory, Local network adapter configurations, User-selected file integrity SHA-256 baselines.\n\n• Unperformed / Excluded Checks: Memory injection scanning, kernel-mode rootkit detection, arbitrary outbound internet scanning, deep packet payload inspection, password hash auditing.\n\n• Legal / Operational Note: This report represents observable Windows configuration at the timestamp recorded. It does not certify that the host is free from all advanced malware or vulnerabilities.',
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

  Widget _buildExportButton(BuildContext context, String title, IconData icon, String format) {
    return ElevatedButton.icon(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title export initiated (Stage 6 module).')),
        );
      },
      icon: Icon(icon, size: 16),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: SentinelColors.surfaceHighlight,
        foregroundColor: SentinelColors.textPrimary,
        side: const BorderSide(color: SentinelColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

