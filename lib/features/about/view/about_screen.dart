import 'package:flutter/material.dart';
import '../../../core/models/ipc_contract.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SentinelColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SentinelColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.shield, color: SentinelColors.primary, size: 32),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('SentinelX', style: SentinelTypography.display),
                  SizedBox(height: 2),
                  Text('Personal Cybersecurity Center for Windows 10/11', style: SentinelTypography.bodySecondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Application & Protocol Version', style: SentinelTypography.titleLarge),
                  const SizedBox(height: 12),
                  _buildRow('Application Version', '1.0.0 (Stage 1 Foundation Release)'),
                  _buildRow('IPC Contract Version', IpcContractConstants.version),
                  _buildRow('Flutter Engine', 'Flutter 3.47.9 / Dart 3.13.7 (Windows Desktop x64)'),
                  _buildRow('Native Engine', 'C# / .NET 10 Compatible Runtime'),
                  _buildRow('Storage Engine', 'SQLite Local-First Database'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Mandatory Defensive Safety Boundaries', style: SentinelTypography.titleLarge),
                  SizedBox(height: 12),
                  Text(
                    '• Defensive Monitoring Only: SentinelX is strictly designed to monitor the user\'s own computer and authorized local network.\n\n'
                    '• No Offensive Features: Absolutely no exploits, payload delivery, credential harvesting, keylogging, covert surveillance, persistence mechanisms, or security-tool disabling.\n\n'
                    '• Protection Preservation: SentinelX will never disable or bypass Windows Defender, Windows Firewall, UAC, or SmartScreen.\n\n'
                    '• Zero Payload Inspection: No packet payload sniffing, credentials, keystrokes, or private communications are ever captured.\n\n'
                    '• Honest Status: "Unknown" does not mean malicious. "Missing data" does not mean secure. No arbitrary 0-100 scores are used.',
                    style: SentinelTypography.body,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(label, style: SentinelTypography.bodySecondary)),
          Expanded(child: Text(value, style: SentinelTypography.body)),
        ],
      ),
    );
  }
}
