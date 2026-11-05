import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/fim_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class FileIntegrityScreen extends ConsumerStatefulWidget {
  const FileIntegrityScreen({super.key});

  @override
  ConsumerState<FileIntegrityScreen> createState() => _FileIntegrityScreenState();
}

class _FileIntegrityScreenState extends ConsumerState<FileIntegrityScreen> {
  void _showAddDialog() {
    final pathController = TextEditingController();
    final labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SentinelColors.surfaceCard,
        title: const Text('Add Monitored File Target', style: SentinelTypography.titleLarge),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the full canonical path of the file you want to monitor for integrity modifications (e.g. hosts file, SSH config, critical documents):',
                style: SentinelTypography.bodySecondary,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: pathController,
                style: SentinelTypography.body,
                decoration: const InputDecoration(
                  labelText: 'File Path (Absolute)',
                  hintText: r'C:\Windows\System32\drivers\etc\hosts',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: labelController,
                style: SentinelTypography.body,
                decoration: const InputDecoration(
                  labelText: 'Friendly Label (Optional)',
                  hintText: 'e.g. System Hosts File',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final path = pathController.text.trim();
              final label = labelController.text.trim();
              if (path.isEmpty) return;

              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final success = await ref.read(fimProvider.notifier).addTarget(path, label);
              nav.pop();

              if (!success) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Failed to add target. Check path exists and is not volatile.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: SentinelColors.primary),
            child: const Text('Create Baseline'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fimProvider);
    final targets = state.targets;
    final changes = state.recentChanges;

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
                onPressed: state.isLoading ? null : () => ref.read(fimProvider.notifier).verifyAll(),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Verify All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SentinelColors.surfaceHighlight,
                  foregroundColor: SentinelColors.textPrimary,
                  side: const BorderSide(color: SentinelColors.border),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _showAddDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Target'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SentinelColors.primary,
                  foregroundColor: Colors.white,
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
          const SizedBox(height: 20),

          if (state.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SentinelColors.statusError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SentinelColors.statusError),
              ),
              child: Text(
                state.errorMessage!,
                style: SentinelTypography.bodySecondary.copyWith(color: SentinelColors.statusError),
              ),
            ),

          Text('Monitored Targets (${targets.length})', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),

          if (targets.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.description_outlined, size: 40, color: SentinelColors.textSecondary),
                      const SizedBox(height: 14),
                      const Text('No Monitored File Targets', style: SentinelTypography.titleLarge),
                      const SizedBox(height: 6),
                      const Text(
                        'Click "Add Target" to register a file for automated SHA-256 baseline verification.',
                        style: SentinelTypography.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add First Target'),
                        style: ElevatedButton.styleFrom(backgroundColor: SentinelColors.primary),
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
                itemCount: targets.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: SentinelColors.border),
                itemBuilder: (context, index) {
                  final target = targets[index];
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          target.hasChanged ? Icons.warning_amber_rounded : Icons.verified_outlined,
                          color: target.hasChanged ? SentinelColors.statusUnknown : SentinelColors.statusEnabled,
                          size: 24,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(target.userLabel, style: SentinelTypography.titleMedium),
                                  const SizedBox(width: 10),
                                  StatusBadge(status: target.status),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(target.canonicalPath, style: SentinelTypography.caption),
                              const SizedBox(height: 8),
                              SelectableText(
                                'Baseline SHA-256: ${target.baselineSha256}',
                                style: SentinelTypography.caption.copyWith(fontFamily: 'Consolas', color: SentinelColors.textSecondary),
                              ),
                              if (target.hasChanged) ...[
                                const SizedBox(height: 4),
                                SelectableText(
                                  'Current SHA-256:  ${target.currentSha256}',
                                  style: SentinelTypography.caption.copyWith(fontFamily: 'Consolas', color: SentinelColors.statusError),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(target.changeSummary, style: SentinelTypography.bodySecondary),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.refresh, size: 18),
                                  tooltip: 'Verify now',
                                  onPressed: () => ref.read(fimProvider.notifier).verifyTarget(target.targetId),
                                ),
                                if (target.hasChanged)
                                  IconButton(
                                    icon: const Icon(Icons.check, size: 18, color: SentinelColors.primary),
                                    tooltip: 'Accept changes (Reset baseline)',
                                    onPressed: () => ref.read(fimProvider.notifier).resetBaseline(target.targetId),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: SentinelColors.statusError),
                                  tooltip: 'Stop monitoring',
                                  onPressed: () => ref.read(fimProvider.notifier).removeTarget(target.targetId),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 28),

          Text('Integrity Change Timeline', style: SentinelTypography.titleLarge),
          const SizedBox(height: 12),

          if (changes.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SentinelColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SentinelColors.border),
              ),
              child: const Text('No integrity change events recorded.', style: SentinelTypography.bodySecondary),
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
                itemCount: changes.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: SentinelColors.border),
                itemBuilder: (context, index) {
                  final change = changes[index];
                  final isWarning = change.severity == 'Warning' || change.severity == 'Critical';
                  return ListTile(
                    leading: Icon(
                      isWarning ? Icons.warning_rounded : Icons.info_outline,
                      color: isWarning ? SentinelColors.statusError : SentinelColors.primary,
                    ),
                    title: Text('${change.changeType} – ${change.canonicalPath}', style: SentinelTypography.body),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detected: ${change.detectedAtUtc}  |  Severity: ${change.severity}', style: SentinelTypography.caption),
                        if (change.newHash.isNotEmpty)
                          Text('New Hash: ${change.newHash}', style: SentinelTypography.caption.copyWith(fontFamily: 'Consolas')),
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
