import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class FileIntegrityScreen extends StatefulWidget {
  const FileIntegrityScreen({super.key});

  @override
  State<FileIntegrityScreen> createState() => _FileIntegrityScreenState();
}

class _FileIntegrityScreenState extends State<FileIntegrityScreen> {
  final List<Map<String, dynamic>> _targets = [
    {
      'label': 'SSH User Configuration',
      'path': r'C:\Users\madew\.ssh\config',
      'status': ComponentStatus.enabled,
      'baselineHash': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      'lastVerified': '10 mins ago',
    },
    {
      'label': 'Local Environment Variables',
      'path': r'C:\Users\madew\Desktop\Git Project\Flutter Projects git\sentinelx\.env.example',
      'status': ComponentStatus.enabled,
      'baselineHash': '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
      'lastVerified': '10 mins ago',
    },
  ];

  final List<Map<String, dynamic>> _events = [
    {
      'target': 'SSH User Configuration',
      'eventType': 'Baseline Verified',
      'status': ComponentStatus.enabled,
      'timestamp': 'Today 22:15',
      'description': 'SHA-256 match confirmed against baseline. No unexpected modification.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('File Integrity Monitoring (FIM)', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Target picker will be connected in Stage 5.')),
                  );
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Monitored Path'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SentinelColors.surfaceHighlight,
                  foregroundColor: SentinelColors.textPrimary,
                  side: const BorderSide(color: SentinelColors.border),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Privacy & Safety Disclosure (SX-007, SX-008)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SentinelColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SentinelColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, size: 20, color: SentinelColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Local-Only Integrity Verification: SentinelX computes streaming SHA-256 cryptographic baselines for user-selected paths only. Raw file contents are never stored, transmitted, or uploaded. A file modification notification is an integrity alert, not proof of malware.',
                    style: SentinelTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Monitored Targets', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _targets.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final target = _targets[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: const Icon(Icons.insert_drive_file_outlined, color: SentinelColors.primary, size: 22),
                  title: Row(
                    children: [
                      Text(target['label'], style: SentinelTypography.titleMedium),
                      const Spacer(),
                      StatusBadge(status: target['status'] as ComponentStatus),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Path: ${target['path']}', style: SentinelTypography.bodySecondary),
                      const SizedBox(height: 2),
                      Text('Baseline SHA-256: ${target['baselineHash']}', style: SentinelTypography.code),
                      const SizedBox(height: 2),
                      Text('Last verified: ${target['lastVerified']}', style: SentinelTypography.caption),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 28),

          Text('Integrity Event Log', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _events.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final ev = _events[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: const Icon(Icons.verified_outlined, color: SentinelColors.statusEnabled, size: 22),
                  title: Row(
                    children: [
                      Text(ev['target'], style: SentinelTypography.titleMedium),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: SentinelColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(ev['eventType'], style: SentinelTypography.caption),
                      ),
                      const Spacer(),
                      Text(ev['timestamp'], style: SentinelTypography.caption),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(ev['description'], style: SentinelTypography.bodySecondary),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
