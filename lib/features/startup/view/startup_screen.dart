import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  final List<Map<String, dynamic>> _startupApps = const [
    {
      'name': 'Windows Security Notification Icon',
      'publisher': 'Microsoft Windows Publisher',
      'source': 'HKLM Run Key',
      'status': ComponentStatus.enabled,
      'command': '%ProgramFiles%\\Windows Defender\\MSASCuiL.exe',
    },
    {
      'name': 'Realtek HD Audio Universal Service',
      'publisher': 'Realtek Semiconductor Corp.',
      'source': 'HKLM Run Key',
      'status': ComponentStatus.enabled,
      'command': '%ProgramFiles%\\Realtek\\Audio\\HDA\\RtkAudioService64.exe',
    },
    {
      'name': 'Local Development Daemon',
      'publisher': 'Unsigned / Self-Signed',
      'source': 'Startup Folder (shell:startup)',
      'status': ComponentStatus.unknown,
      'command': '%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\daemon.lnk',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Startup Applications', style: SentinelTypography.display),
          const SizedBox(height: 8),

          // Scope Limitation Notice (PRD requirement SX-004)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SentinelColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SentinelColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, size: 20, color: SentinelColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Partial Coverage Disclosure: This inventory inspects standard Run registry keys (HKLM & HKCU) and user Startup folders. Advanced persistence locations (services, drivers, scheduled tasks, WMI event subscriptions) are not exhaustive in this view. Read-only in initial release.',
                    style: SentinelTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _startupApps.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final app = _startupApps[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  leading: const Icon(Icons.rocket_launch_outlined, color: SentinelColors.primary, size: 22),
                  title: Row(
                    children: [
                      Text(app['name'], style: SentinelTypography.titleMedium),
                      const Spacer(),
                      StatusBadge(status: app['status'] as ComponentStatus),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Publisher: ${app['publisher']}', style: SentinelTypography.bodySecondary),
                      const SizedBox(height: 2),
                      Text('Location: ${app['source']}', style: SentinelTypography.caption),
                      const SizedBox(height: 2),
                      Text('Target: ${app['command']}', style: SentinelTypography.code),
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
