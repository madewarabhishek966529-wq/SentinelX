import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/recommendation_report_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  void _launchSetting(BuildContext context, String uri, String label) {
    if (Platform.isWindows && uri.startsWith('ms-settings:')) {
      Process.run('cmd', ['/c', 'start', '', uri]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Launched $label ($uri)')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Target: $label ($uri)')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recommendationReportProvider);
    final recommendations = state.recommendations;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Evidence-Based Recommendations', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: state.isLoading ? null : () => ref.read(recommendationReportProvider.notifier).refreshAll(),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Re-evaluate'),
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
            'Explainable, rules-based recommendations derived strictly from verifiable system checks. SentinelX never changes system settings, disables tools, or modifies configurations automatically.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 20),

          // Safe Response Tooling Policy Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: SentinelColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SentinelColors.border),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield_outlined, size: 20, color: SentinelColors.primary),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Safe Response Tooling Policy (PRD SX-009): Recommendations provide objective evidence, source telemetry, and official Windows Settings deep-links. Automatic destructive actions (e.g. silent quarantine or unprompted termination) are strictly prevented.',
                    style: SentinelTypography.bodySecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (recommendations.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.check_circle_outline, size: 40, color: SentinelColors.statusEnabled),
                      SizedBox(height: 14),
                      Text('No Active Recommendations', style: SentinelTypography.titleLarge),
                      SizedBox(height: 6),
                      Text(
                        'All audited components are currently operating within baseline parameters.',
                        style: SentinelTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rec = recommendations[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline, color: SentinelColors.primary, size: 22),
                            const SizedBox(width: 12),
                            Expanded(child: Text(rec.title, style: SentinelTypography.titleMedium)),
                            const SizedBox(width: 8),
                            StatusBadge(status: rec.status),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Evidence', rec.evidence),
                        const SizedBox(height: 6),
                        _buildInfoRow('Source', rec.source),
                        const SizedBox(height: 6),
                        _buildInfoRow('Limitations', rec.limitations, isMuted: true),
                        const SizedBox(height: 14),
                        const Divider(),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Category: ${rec.category}  |  Priority: ${rec.priority}',
                              style: SentinelTypography.caption,
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: () => _launchSetting(context, rec.actionUri, rec.actionLabel),
                              icon: const Icon(Icons.open_in_new, size: 14),
                              label: Text(rec.actionLabel, style: const TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: SentinelColors.primary,
                                side: const BorderSide(color: SentinelColors.border),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value, {bool isMuted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: isMuted ? SentinelTypography.caption : SentinelTypography.bodySecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: isMuted
                ? SentinelTypography.caption.copyWith(color: SentinelColors.textMuted)
                : SentinelTypography.body,
          ),
        ),
      ],
    );
  }
}
