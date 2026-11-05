import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class SecurityEventsScreen extends StatelessWidget {
  const SecurityEventsScreen({super.key});

  final List<Map<String, dynamic>> _events = const [
    {
      'id': '1116',
      'source': 'Microsoft-Windows-Windows Defender',
      'severity': ComponentStatus.enabled,
      'channel': 'Microsoft-Windows-Windows Defender/Operational',
      'timestamp': 'Today 21:40:12',
      'summary': 'Antimalware platform performed scheduled signature definition update.',
    },
    {
      'id': '4624',
      'source': 'Microsoft-Windows-Security-Auditing',
      'severity': ComponentStatus.enabled,
      'channel': 'Security',
      'timestamp': 'Today 21:05:00',
      'summary': 'An account was successfully logged on (Interactive User Session).',
    },
    {
      'id': '7036',
      'source': 'Service Control Manager',
      'severity': ComponentStatus.enabled,
      'channel': 'System',
      'timestamp': 'Today 20:12:33',
      'summary': 'The Windows Defender Antivirus Service entered the running state.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Windows Security Events', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Audits selected Windows Event Log channels using standard Windows Event Log interfaces. Events are summarized in clear, transparent language with raw event IDs and sources provided for verification.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

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
                  leading: const Icon(Icons.event_note_outlined, color: SentinelColors.primary, size: 22),
                  title: Row(
                    children: [
                      Text('Event ID ${ev['id']}', style: SentinelTypography.titleMedium),
                      const SizedBox(width: 10),
                      Text('• ${ev['source']}', style: SentinelTypography.bodySecondary),
                      const Spacer(),
                      StatusBadge(status: ev['severity'] as ComponentStatus),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(ev['summary'], style: SentinelTypography.body),
                      const SizedBox(height: 2),
                      Text('Channel: ${ev['channel']} • Timestamp: ${ev['timestamp']}', style: SentinelTypography.caption),
                    ],
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
