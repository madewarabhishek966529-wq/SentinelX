import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/device_process_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class ProcessesScreen extends ConsumerStatefulWidget {
  const ProcessesScreen({super.key});

  @override
  ConsumerState<ProcessesScreen> createState() => _ProcessesScreenState();
}

class _ProcessesScreenState extends ConsumerState<ProcessesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deviceProcessProvider);
    final processes = state.processes;

    final filtered = processes.where((p) {
      final name = p.processName.toLowerCase();
      final publisher = p.publisher.toLowerCase();
      final pid = p.processId.toString();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || publisher.contains(q) || pid.contains(q);
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Process Visibility', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(deviceProcessProvider.notifier).refreshAll();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Processes'),
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
            'Read-only process inspector. Unverified publisher indicates the binary has no valid digital signature, not that it is malicious. Automatic process termination is disabled by design. PID reuse is handled with process start time keys.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 20),

          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search processes by name, publisher, or PID...',
                    prefixIcon: const Icon(Icons.search, size: 20, color: SentinelColors.textSecondary),
                    filled: true,
                    fillColor: SentinelColors.surfaceCard,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SentinelColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: SentinelColors.border),
                    ),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: SentinelColors.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SentinelColors.border),
                ),
                child: Text('Active Processes: ${filtered.length} / ${processes.length}', style: SentinelTypography.caption),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (state.isLoading && processes.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: SentinelColors.primary),
              ),
            )
          else if (filtered.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off, size: 36, color: SentinelColors.textSecondary),
                      const SizedBox(height: 10),
                      Text('No processes matching "$_searchQuery"', style: SentinelTypography.titleMedium),
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
                itemCount: filtered.length > 100 ? 100 : filtered.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final p = filtered[index];
                  final memMb = (p.workingSetBytes / (1024 * 1024)).toStringAsFixed(1);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                    leading: const Icon(Icons.memory, color: SentinelColors.primary, size: 22),
                    title: Row(
                      children: [
                        Text(p.processName, style: SentinelTypography.titleMedium),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: SentinelColors.surfaceHighlight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PID: ${p.processId}', style: SentinelTypography.code),
                        ),
                        const Spacer(),
                        StatusBadge(status: p.publisherStatus),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Publisher: ${p.publisher}', style: SentinelTypography.bodySecondary),
                        const SizedBox(height: 2),
                        Text('Path: ${p.executablePath}', style: SentinelTypography.caption, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text('Start Time: ${p.startTimeUtc} • Key: ${p.compositeKey}', style: SentinelTypography.caption),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('RAM: $memMb MB', style: SentinelTypography.caption),
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
