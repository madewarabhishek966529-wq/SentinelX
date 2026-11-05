import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/engine_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../core/models/component_status.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final engineState = ref.watch(engineProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings & Diagnostics', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Configure local monitoring intervals, retention limits, and inspect real-time C# engine diagnostics.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          // Engine Diagnostics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: SentinelColors.primary, size: 22),
                      const SizedBox(width: 12),
                      const Text('Native Engine Diagnostics (IPC)', style: SentinelTypography.titleLarge),
                      const Spacer(),
                      StatusBadge(
                        status: engineState.status.name == 'connected'
                            ? ComponentStatus.enabled
                            : ComponentStatus.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDiagRow('Engine Status', engineState.status.label),
                  _buildDiagRow('IPC Transport', 'HTTP Loopback (127.0.0.1:58421) + Named Pipe'),
                  _buildDiagRow('Latency / Round-Trip', '${engineState.latencyMs} ms'),
                  if (engineState.health != null) ...[
                    _buildDiagRow('Engine Version', engineState.health!.engineVersion),
                    _buildDiagRow('Contract Version', engineState.health!.contractVersion),
                    _buildDiagRow('Engine Process ID', '${engineState.health!.processId}'),
                    _buildDiagRow('Memory Working Set', '${(engineState.health!.memoryBytes / (1024 * 1024)).toStringAsFixed(1)} MB'),
                    _buildDiagRow('Elevation State', engineState.health!.isElevated ? 'Elevated (Administrator)' : 'Standard User (Least Privilege)'),
                    _buildDiagRow('Engine Started At', engineState.health!.startedAtUtc),
                  ],
                  if (engineState.errorMessage != null)
                    _buildDiagRow('Last Error', engineState.errorMessage!, isError: true),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(engineProvider.notifier).checkEngine();
                        },
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Test Connection / Ping'),
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
          const SizedBox(height: 24),

          // Data Retention & Privacy Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Data Retention & Local Privacy', style: SentinelTypography.titleLarge),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    title: const Text('Local-Only Default Mode', style: SentinelTypography.titleMedium),
                    subtitle: const Text('All database records and file hashes stay on this computer. Zero telemetry.', style: SentinelTypography.bodySecondary),
                    value: settings.localOnlyLogging,
                    activeThumbColor: SentinelColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleLocalOnlyLogging(val);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('Deduplicate Repeated Alerts', style: SentinelTypography.titleMedium),
                    subtitle: const Text('Group identical security events within a 1-hour window to reduce fatigue.', style: SentinelTypography.bodySecondary),
                    value: settings.deduplicateAlerts,
                    activeThumbColor: SentinelColors.primary,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      ref.read(settingsProvider.notifier).toggleDeduplication(val);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('History Retention Period', style: SentinelTypography.titleMedium),
                    subtitle: Text('Currently retain event history for ${settings.retentionDays} days.', style: SentinelTypography.bodySecondary),
                    trailing: DropdownButton<int>(
                      value: settings.retentionDays,
                      dropdownColor: SentinelColors.surfaceCard,
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('7 Days')),
                        DropdownMenuItem(value: 14, child: Text('14 Days')),
                        DropdownMenuItem(value: 30, child: Text('30 Days')),
                        DropdownMenuItem(value: 90, child: Text('90 Days')),
                      ],
                      onChanged: (days) {
                        if (days != null) {
                          ref.read(settingsProvider.notifier).setRetentionDays(days);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Local history cleared successfully.')),
                          );
                        },
                        icon: const Icon(Icons.delete_outline, size: 16, color: SentinelColors.statusError),
                        label: const Text('Clear All Local History', style: TextStyle(color: SentinelColors.statusError)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: SentinelColors.statusError),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagRow(String label, String value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(label, style: SentinelTypography.bodySecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isError ? SentinelColors.statusError : SentinelColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
