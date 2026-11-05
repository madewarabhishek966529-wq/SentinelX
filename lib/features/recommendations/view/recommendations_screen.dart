import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  final List<Map<String, dynamic>> _recommendations = const [
    {
      'title': 'Verify Windows Defender Security Intelligence Definitions',
      'category': 'Antivirus Hygiene',
      'priority': 'Routine Maintenance',
      'status': ComponentStatus.enabled,
      'evidence': 'Signature definition is updated regularly; last check occurred within 24 hours.',
      'limitations': 'Relies on Windows Update and Microsoft Defender cloud delivery status.',
      'action': 'Open Windows Security App',
    },
    {
      'title': 'Review Unsigned Startup Items',
      'category': 'Startup Hygiene',
      'priority': 'Low Priority',
      'status': ComponentStatus.unknown,
      'evidence': 'One startup item located in user Startup folder does not bear a verified digital signature.',
      'limitations': 'Unverified signature does not mean malicious. In-house or open-source tools frequently omit commercial Authenticode certificates.',
      'action': 'Inspect Startup Apps Module',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Evidence-Based Recommendations', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Explainable, rules-based recommendations derived strictly from verifiable system checks. SentinelX never changes system settings, disables tools, or modifies configurations automatically.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recommendations.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final rec = _recommendations[index];
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
                          Expanded(child: Text(rec['title'], style: SentinelTypography.titleMedium)),
                          StatusBadge(status: rec['status'] as ComponentStatus),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Evidence', rec['evidence']),
                      const SizedBox(height: 6),
                      _buildInfoRow('Limitations', rec['limitations'], isMuted: true),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text('Category: ${rec['category']} • ${rec['priority']}', style: SentinelTypography.caption),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Action: ${rec['action']}')),
                              );
                            },
                            icon: const Icon(Icons.arrow_forward, size: 14),
                            label: Text(rec['action'], style: const TextStyle(fontSize: 12)),
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

  Widget _buildInfoRow(String label, String value, {bool isMuted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isMuted ? SentinelColors.statusUnknown : SentinelColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: isMuted ? SentinelTypography.bodySecondary : SentinelTypography.body,
          ),
        ),
      ],
    );
  }
}
