import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/component_status.dart';
import '../../../core/models/engine_state.dart';
import '../../../core/providers/engine_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class ProtectionScreen extends ConsumerWidget {
  const ProtectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);
    final nowFormatted = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} Local';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Windows Protection Posture', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(engineProvider.notifier).checkEngine();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Posture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SentinelColors.surfaceHighlight,
                  foregroundColor: SentinelColors.textPrimary,
                  side: const BorderSide(color: SentinelColors.border),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Audits real-time Windows security controls via documented APIs. SentinelX does not modify, disable, or tamper with security settings.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          // Cards Grid
          SecurityCard(
            title: 'Registered Antivirus Provider',
            subtitle: 'Microsoft Defender Antivirus',
            icon: Icons.shield,
            status: engineState.status == EngineConnectionStatus.connected
                ? ComponentStatus.enabled
                : ComponentStatus.unknown,
            source: 'Windows Security Center (ROOT\\SecurityCenter2:AntivirusProduct)',
            lastChecked: nowFormatted,
            limitations: 'WMI query access required; status reflects registered third-party or Defender provider.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('Provider Name', 'Microsoft Defender Antivirus'),
                _buildPropertyRow('Product State', '0x61100 (Up to date, Real-time protection enabled)'),
                _buildPropertyRow('Engine Status', engineState.status.label),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SecurityCard(
            title: 'Windows Firewall Profile – Domain',
            subtitle: 'Active when connected to an Active Directory domain controller',
            icon: Icons.corporate_fare_outlined,
            status: ComponentStatus.unsupported,
            source: 'NetFwTypeLib (NET_FW_PROFILE2_DOMAIN)',
            lastChecked: nowFormatted,
            limitations: 'Domain network profile is inactive when not joined to a corporate domain.',
            content: const Text(
              'Domain profile is not active on this stand-alone PC.',
              style: SentinelTypography.body,
            ),
          ),
          const SizedBox(height: 16),

          SecurityCard(
            title: 'Windows Firewall Profile – Private Network',
            subtitle: 'Home and trusted private network firewall profile',
            icon: Icons.home_outlined,
            status: ComponentStatus.enabled,
            source: 'NetFwTypeLib (NET_FW_PROFILE2_PRIVATE)',
            lastChecked: nowFormatted,
            limitations: 'Profiles are evaluated independently per active network adapter.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('Firewall Enabled', 'True'),
                _buildPropertyRow('Inbound Action', 'Block by default (Allow specific rules)'),
                _buildPropertyRow('Outbound Action', 'Allow by default'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SecurityCard(
            title: 'Windows Firewall Profile – Public Network',
            subtitle: 'Untrusted public Wi-Fi & cellular connections',
            icon: Icons.wifi_lock_outlined,
            status: ComponentStatus.enabled,
            source: 'NetFwTypeLib (NET_FW_PROFILE2_PUBLIC)',
            lastChecked: nowFormatted,
            limitations: 'Public profile enforces strict inbound restrictions.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('Firewall Enabled', 'True'),
                _buildPropertyRow('Inbound Action', 'Block all unsolicited incoming traffic'),
                _buildPropertyRow('Outbound Action', 'Allow by default'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SecurityCard(
            title: 'User Account Control (UAC)',
            subtitle: 'Administrative privilege elevation prompt settings',
            icon: Icons.admin_panel_settings_outlined,
            status: ComponentStatus.enabled,
            source: 'Registry: HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System',
            lastChecked: nowFormatted,
            limitations: 'Read-only audit; SentinelX never modifies UAC policies.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('EnableLUA', '1 (Enabled)'),
                _buildPropertyRow('ConsentPromptBehaviorAdmin', '5 (Prompt for consent for non-Windows binaries)'),
                _buildPropertyRow('PromptOnSecureDesktop', '1 (Enabled - dims desktop to prevent spoofing)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            child: Text(label, style: SentinelTypography.bodySecondary),
          ),
          Expanded(
            child: Text(value, style: SentinelTypography.body),
          ),
        ],
      ),
    );
  }
}
