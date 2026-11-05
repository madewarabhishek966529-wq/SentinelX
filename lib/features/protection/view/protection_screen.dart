import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/component_status.dart';
import '../../../core/providers/protection_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class ProtectionScreen extends ConsumerWidget {
  const ProtectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final protectionState = ref.watch(protectionProvider);
    final snapshot = protectionState.snapshot;
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
                  ref.read(protectionProvider.notifier).refreshPosture();
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

          // Antivirus Providers
          if (snapshot != null && snapshot.antivirusProviders.isNotEmpty)
            ...snapshot.antivirusProviders.map((av) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SecurityCard(
                    title: 'Registered Antivirus Provider',
                    subtitle: av.displayName,
                    icon: Icons.shield,
                    status: av.status,
                    source: av.source,
                    lastChecked: av.checkedAtUtc.isNotEmpty ? av.checkedAtUtc : nowFormatted,
                    limitations: av.limitations,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPropertyRow('Provider Name', av.displayName),
                        _buildPropertyRow('Product State Bitmask', av.productStateHex),
                        _buildPropertyRow('Real-Time Protection', av.isActive ? 'Active' : 'Inactive'),
                        _buildPropertyRow('Definitions', av.isUpToDate ? 'Up to date' : 'Out of date'),
                      ],
                    ),
                  ),
                ))
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SecurityCard(
                title: 'Registered Antivirus Provider',
                subtitle: 'Microsoft Defender Antivirus',
                icon: Icons.shield,
                status: ComponentStatus.unknown,
                source: 'Windows Security Center (ROOT\\SecurityCenter2)',
                lastChecked: nowFormatted,
                limitations: 'WMI query access required; status reflects registered third-party or Defender provider.',
                content: const Text(
                  'Querying registered antimalware providers from Windows...',
                  style: SentinelTypography.body,
                ),
              ),
            ),

          // Firewall Profiles
          if (snapshot != null && snapshot.firewallProfiles.isNotEmpty)
            ...snapshot.firewallProfiles.map((fw) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SecurityCard(
                    title: 'Windows Firewall Profile – ${fw.profileName}',
                    subtitle: '${fw.profileName} profile configuration',
                    icon: fw.profileName == 'Domain'
                        ? Icons.corporate_fare_outlined
                        : (fw.profileName == 'Private' ? Icons.home_outlined : Icons.wifi_lock_outlined),
                    status: fw.status,
                    source: fw.source,
                    lastChecked: fw.checkedAtUtc.isNotEmpty ? fw.checkedAtUtc : nowFormatted,
                    limitations: fw.limitations,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPropertyRow('Firewall Enabled', fw.isEnabled ? 'True' : 'False'),
                        _buildPropertyRow('Inbound Traffic Action', fw.inboundAction),
                        _buildPropertyRow('Outbound Traffic Action', fw.outboundAction),
                      ],
                    ),
                  ),
                ))
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SecurityCard(
                title: 'Windows Firewall Profiles',
                subtitle: 'Domain, Private, and Public Network Profiles',
                icon: Icons.local_fire_department_outlined,
                status: ComponentStatus.unknown,
                source: 'NetFwTypeLib / Windows Registry',
                lastChecked: nowFormatted,
                limitations: 'Querying firewall state from Windows API...',
                content: const Text(
                  'Querying firewall profile configurations...',
                  style: SentinelTypography.body,
                ),
              ),
            ),

          // User Account Control (UAC)
          SecurityCard(
            title: 'User Account Control (UAC)',
            subtitle: 'Administrative privilege elevation prompt settings',
            icon: Icons.admin_panel_settings_outlined,
            status: snapshot?.uac?.status ?? ComponentStatus.enabled,
            source: snapshot?.uac?.source ?? 'Registry: HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Policies\\System',
            lastChecked: snapshot?.uac?.checkedAtUtc.isNotEmpty == true ? snapshot!.uac!.checkedAtUtc : nowFormatted,
            limitations: snapshot?.uac?.limitations ?? 'Read-only audit; SentinelX never modifies UAC policies.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('UAC Enabled (EnableLUA)', snapshot?.uac?.isEnabled == true ? '1 (Enabled)' : '0 (Disabled)'),
                _buildPropertyRow('Consent Prompt Behavior', '${snapshot?.uac?.consentPromptBehaviorAdmin ?? 5} (Standard prompt for elevation)'),
                _buildPropertyRow('Secure Desktop Prompting', snapshot?.uac?.promptOnSecureDesktop == true ? '1 (Enabled - desktop dimmed)' : '0 (Disabled)'),
                if (snapshot?.uac?.summary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(snapshot!.uac!.summary, style: SentinelTypography.caption),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Windows Update Service
          SecurityCard(
            title: 'Windows Update Service',
            subtitle: 'Local Windows Update Agent operational state',
            icon: Icons.system_update_alt_outlined,
            status: snapshot?.windowsUpdate?.status ?? ComponentStatus.enabled,
            source: snapshot?.windowsUpdate?.source ?? 'Windows Service Control Manager (wuauserv)',
            lastChecked: snapshot?.windowsUpdate?.checkedAtUtc.isNotEmpty == true ? snapshot!.windowsUpdate!.checkedAtUtc : nowFormatted,
            limitations: snapshot?.windowsUpdate?.limitations ?? 'Service state reflects local agent.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('Service State', snapshot?.windowsUpdate?.serviceState ?? 'Running'),
                _buildPropertyRow('Last Detection Time', snapshot?.windowsUpdate?.lastSearchSuccessDate ?? 'Recorded in registry'),
                if (snapshot?.windowsUpdate?.summary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(snapshot!.windowsUpdate!.summary, style: SentinelTypography.caption),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // SmartScreen
          SecurityCard(
            title: 'Windows Defender SmartScreen',
            subtitle: 'Application reputation and download verification',
            icon: Icons.security_update_good_outlined,
            status: snapshot?.smartScreen?.status ?? ComponentStatus.enabled,
            source: snapshot?.smartScreen?.source ?? 'Registry: HKLM\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer',
            lastChecked: snapshot?.smartScreen?.checkedAtUtc.isNotEmpty == true ? snapshot!.smartScreen!.checkedAtUtc : nowFormatted,
            limitations: snapshot?.smartScreen?.limitations ?? 'Read-only inspection of Explorer setting.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPropertyRow('Configuration Setting', snapshot?.smartScreen?.settingValue ?? 'Enabled'),
                if (snapshot?.smartScreen?.summary != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(snapshot!.smartScreen!.summary, style: SentinelTypography.caption),
                  ),
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
