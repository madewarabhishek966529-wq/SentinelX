import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/component_status.dart';
import '../../../core/models/engine_state.dart';
import '../../../core/providers/engine_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);
    final nowFormatted = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}:${DateTime.now().second.toString().padLeft(2, '0')} Local';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Notice: Honest Security Visibility
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SentinelColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SentinelColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: SentinelColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: SentinelTypography.bodySecondary,
                      children: [
                        TextSpan(
                          text: 'Defensive Visibility Mode: ',
                          style: TextStyle(fontWeight: FontWeight.w600, color: SentinelColors.textPrimary),
                        ),
                        TextSpan(
                          text: 'SentinelX consolidates key Windows protection status, process, network, and file integrity data. Unknown does not mean malicious; missing data does not mean secure.',
                        ),
                      ],
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/about'),
                  child: const Text('Read Boundaries', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Posture Cards
          Text('Windows Security Posture', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SecurityCard(
                  title: 'Registered Antivirus Provider',
                  subtitle: 'Active antimalware solution reported to Windows',
                  icon: Icons.shield_outlined,
                  status: engineState.status == EngineConnectionStatus.connected
                      ? ComponentStatus.enabled
                      : ComponentStatus.unknown,
                  source: 'Windows Security Center (WSC)',
                  lastChecked: nowFormatted,
                  limitations: 'Third-party AV reporting depends on WSC provider registration.',
                  content: const Text(
                    'Microsoft Defender Antivirus is registered and active.',
                    style: SentinelTypography.body,
                  ),
                  onAction: () => context.go('/protection'),
                  actionLabel: 'Details',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SecurityCard(
                  title: 'Windows Firewall Profiles',
                  subtitle: 'Inspection of Domain, Private, and Public profiles',
                  icon: Icons.local_fire_department_outlined,
                  status: engineState.status == EngineConnectionStatus.connected
                      ? ComponentStatus.enabled
                      : ComponentStatus.unknown,
                  source: 'Windows Advanced Firewall API (INetFwPolicy2)',
                  lastChecked: nowFormatted,
                  limitations: 'Third-party firewalls may bypass or manage rules independently.',
                  content: const Text(
                    'Private & Public network firewall profiles are active.',
                    style: SentinelTypography.body,
                  ),
                  onAction: () => context.go('/protection'),
                  actionLabel: 'Details',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SecurityCard(
                  title: 'User Account Control (UAC)',
                  subtitle: 'Consent prompt configuration for elevated privileges',
                  icon: Icons.admin_panel_settings_outlined,
                  status: ComponentStatus.enabled,
                  source: 'Windows Registry (System\\CurrentControlSet)',
                  lastChecked: nowFormatted,
                  limitations: 'Read-only audit; SentinelX never modifies UAC settings.',
                  content: const Text(
                    'Always notify when apps make changes (Default level).',
                    style: SentinelTypography.body,
                  ),
                  onAction: () => context.go('/protection'),
                  actionLabel: 'Details',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SecurityCard(
                  title: 'Windows Update Service',
                  subtitle: 'Windows Update agent state and recent patch status',
                  icon: Icons.system_update_alt_outlined,
                  status: ComponentStatus.enabled,
                  source: 'Windows Update API (WUApiLib)',
                  lastChecked: nowFormatted,
                  limitations: 'Update detection requires active internet connectivity.',
                  content: const Text(
                    'Windows Update service is enabled and operational.',
                    style: SentinelTypography.body,
                  ),
                  onAction: () => context.go('/protection'),
                  actionLabel: 'Details',
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Activity & Visibility Quick Access
          Text('Activity & Hygiene Monitoring', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickCard(
                  context,
                  title: 'Process Visibility',
                  description: 'Track running processes, PID reuse, publishers, CPU & memory.',
                  icon: Icons.list_alt,
                  badgeText: 'Live Tracking',
                  route: '/processes',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickCard(
                  context,
                  title: 'File Integrity (FIM)',
                  description: 'Local SHA-256 baselines on user-selected files & directories.',
                  icon: Icons.folder_shared_outlined,
                  badgeText: 'Opt-in Targets',
                  route: '/file-integrity',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickCard(
                  context,
                  title: 'Network Activity',
                  description: 'Local adapters, throughput deltas, and private device discovery.',
                  icon: Icons.lan_outlined,
                  badgeText: 'Passive / Local',
                  route: '/network-activity',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required String badgeText,
    required String route,
  }) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: SentinelColors.primary),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: SentinelColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SentinelColors.border),
                    ),
                    child: Text(badgeText, style: SentinelTypography.caption),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: SentinelTypography.titleMedium),
              const SizedBox(height: 6),
              Text(description, style: SentinelTypography.bodySecondary, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Text('Open Module', style: TextStyle(fontSize: 12, color: SentinelColors.primary, fontWeight: FontWeight.w600)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: SentinelColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
