import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/events_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class SecurityEventsScreen extends ConsumerWidget {
  const SecurityEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(eventsProvider);
    final events = state.filteredEvents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Windows Security Events', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : () => ref.read(eventsProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Events'),
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
            'Audits selected Windows Event Log channels (System, Defender, and Security) using standard Windows Event Log interfaces. Events are summarized in clear, transparent language with raw event IDs and sources provided for verification.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 16),

          // Channel Summary Bar (honest disclosure of channel elevation status)
          if (state.channelSummary.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SentinelColors.surfaceCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SentinelColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: SentinelColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Log Channels Status: ${state.channelSummary}',
                      style: SentinelTypography.caption.copyWith(color: SentinelColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Search and Filters Bar
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    onChanged: (val) => ref.read(eventsProvider.notifier).setSearchQuery(val),
                    style: SentinelTypography.body,
                    decoration: const InputDecoration(
                      isDense: true,
                      prefixIcon: Icon(Icons.search, size: 18),
                      hintText: 'Search by Event ID, Provider, or description...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: state.selectedChannel,
                dropdownColor: SentinelColors.surfaceCard,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Channels')),
                  DropdownMenuItem(value: 'System', child: Text('System')),
                  DropdownMenuItem(value: 'Defender', child: Text('Defender')),
                  DropdownMenuItem(value: 'Security', child: Text('Security')),
                ],
                onChanged: (val) {
                  if (val != null) ref.read(eventsProvider.notifier).setChannelFilter(val);
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: state.selectedSeverity,
                dropdownColor: SentinelColors.surfaceCard,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All Severities')),
                  DropdownMenuItem(value: 'Critical', child: Text('Critical')),
                  DropdownMenuItem(value: 'Error', child: Text('Error')),
                  DropdownMenuItem(value: 'Warning', child: Text('Warning')),
                  DropdownMenuItem(value: 'Information', child: Text('Information')),
                ],
                onChanged: (val) {
                  if (val != null) ref.read(eventsProvider.notifier).setSeverityFilter(val);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (events.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.event_busy, size: 40, color: SentinelColors.textSecondary),
                      SizedBox(height: 14),
                      Text('No Matching Events Found', style: SentinelTypography.titleLarge),
                      SizedBox(height: 6),
                      Text(
                        'No events match the current filter criteria or channel query results.',
                        style: SentinelTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: SentinelColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SentinelColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: SentinelColors.border),
                itemBuilder: (context, index) {
                  final ev = events[index];
                  final isAccessDenied = ev.accessDenied;

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isAccessDenied
                              ? Icons.lock_outline
                              : (ev.levelDisplayName == 'Error' || ev.levelDisplayName == 'Critical'
                                  ? Icons.error_outline
                                  : (ev.levelDisplayName == 'Warning' ? Icons.warning_amber_rounded : Icons.info_outline)),
                          color: isAccessDenied
                              ? SentinelColors.statusAccessDenied
                              : (ev.levelDisplayName == 'Error' || ev.levelDisplayName == 'Critical'
                                  ? SentinelColors.statusError
                                  : (ev.levelDisplayName == 'Warning' ? SentinelColors.statusUnknown : SentinelColors.primary)),
                          size: 22,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ev.eventId > 0 ? 'Event ID ${ev.eventId}' : 'Channel Audit',
                                    style: SentinelTypography.titleMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('• ${ev.providerName}', style: SentinelTypography.bodySecondary),
                                  const Spacer(),
                                  StatusBadge(status: ev.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(ev.message, style: SentinelTypography.body),
                              const SizedBox(height: 6),
                              Text(
                                'Channel: ${ev.channel}  |  Level: ${ev.levelDisplayName}  |  Logged: ${ev.timestampUtc}',
                                style: SentinelTypography.caption,
                              ),
                            ],
                          ),
                        ),
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
