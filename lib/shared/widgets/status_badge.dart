import 'package:flutter/material.dart';
import '../../core/models/component_status.dart';

/// Reusable status pill widget displaying one of the 7 honest statuses.
/// Tooltip explains exact meaning so users are never misled.
class StatusBadge extends StatelessWidget {
  final ComponentStatus status;
  final bool showDescriptionTooltip;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDescriptionTooltip = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: fontSize + 2, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: status.color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );

    if (!showDescriptionTooltip) return badge;

    return Tooltip(
      message: status.description,
      child: badge,
    );
  }
}
