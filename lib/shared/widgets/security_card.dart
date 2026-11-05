import 'package:flutter/material.dart';
import '../../core/models/component_status.dart';
import '../../core/theme/sentinel_colors.dart';
import '../../core/theme/sentinel_typography.dart';
import 'status_badge.dart';

class SecurityCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final ComponentStatus status;
  final String source;
  final String? lastChecked;
  final String? limitations;
  final Widget? content;
  final VoidCallback? onAction;
  final String? actionLabel;

  const SecurityCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.status,
    required this.source,
    this.lastChecked,
    this.limitations,
    this.content,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SentinelColors.surfaceHighlight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SentinelColors.border),
                  ),
                  child: Icon(icon, color: SentinelColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: SentinelTypography.titleMedium),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: SentinelTypography.bodySecondary),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: status),
              ],
            ),
            if (content != null) ...[
              const SizedBox(height: 14),
              content!,
            ],
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.source_outlined, size: 14, color: SentinelColors.textMuted),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: Text(
                        'Source: $source',
                        style: SentinelTypography.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (lastChecked != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history, size: 14, color: SentinelColors.textMuted),
                      const SizedBox(width: 4),
                      Text('Checked: $lastChecked', style: SentinelTypography.caption),
                    ],
                  ),
                if (limitations != null)
                  Tooltip(
                    message: limitations!,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.info_outline, size: 14, color: SentinelColors.statusUnknown),
                        SizedBox(width: 4),
                        Text('Limitations', style: TextStyle(fontSize: 12, color: SentinelColors.statusUnknown)),
                      ],
                    ),
                  ),
                if (onAction != null && actionLabel != null)
                  TextButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: Text(actionLabel!, style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: SentinelColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
