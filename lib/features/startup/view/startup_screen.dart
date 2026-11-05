import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/device_process_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class StartupScreen extends ConsumerWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceProcessProvider);
    final startupApps = state.startupApps;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Startup Applications', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(deviceProcessProvider.notifier).refreshAll();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Startup Items'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SentinelColors.surfaceHighlight,
                  foregroundColor: SentinelColors.textPrimary,
                  side: const BorderSide(color: SentinelColors.border),
                ),
              ),
            ],
          ),
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

          if (state.isLoading && startupApps.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: SentinelColors.primary),
              ),
            )
          else if (startupApps.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 36, color: SentinelColors.statusEnabled),
                      SizedBox(height: 10),
                      Text('No startup entries detected in standard Run locations.', style: SentinelTypography.titleMedium),
                    ],
                  ),
                ),
              ),
            )
          else
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: startupApps.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final app = startupApps[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    leading: const Icon(Icons.rocket_launch_outlined, color: SentinelColors.primary, size: 22),
                    title: Row(
                      children: [
                        Text(app.displayName, style: SentinelTypography.titleMedium),
                        const Spacer(),
                        StatusBadge(status: app.status),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Publisher: ${app.publisher}', style: SentinelTypography.bodySecondary),
                        const SizedBox(height: 2),
                        Text('Location: ${app.sourceLocation}', style: SentinelTypography.caption),
                        const SizedBox(height: 2),
                        Text('Command: ${app.executablePath}', style: SentinelTypography.code),
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
