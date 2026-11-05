import 'package:flutter/material.dart';
import '../../core/models/component_status.dart';
import '../../core/theme/sentinel_colors.dart';
import '../../core/theme/sentinel_typography.dart';
import 'status_badge.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final ComponentStatus? status;
  final VoidCallback? onRetry;
  final String? retryLabel;

  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.status,
    this.onRetry,
    this.retryLabel,
  });

  factory EmptyStateView.accessDenied({VoidCallback? onElevate}) {
    return EmptyStateView(
      title: 'Administrator Access Required',
      description: 'This Windows security check requires elevated administrator privileges to query directly from the operating system.',
      icon: Icons.admin_panel_settings_outlined,
      status: ComponentStatus.accessDenied,
      onRetry: onElevate,
      retryLabel: 'Elevate with Prompt',
    );
  }

  factory EmptyStateView.unsupported({String? reason}) {
    return EmptyStateView(
      title: 'Check Not Supported',
      description: reason ?? 'This provider is not supported on this Windows build or hardware configuration.',
      icon: Icons.browser_not_supported_outlined,
      status: ComponentStatus.unsupported,
    );
  }

  factory EmptyStateView.engineOffline({VoidCallback? onReconnect}) {
    return EmptyStateView(
      title: 'Native Engine Offline',
      description: 'SentinelX Native C# Engine is not reachable at 127.0.0.1. Verify that SentinelX.Engine.exe is running.',
      icon: Icons.power_off_outlined,
      status: ComponentStatus.error,
      onRetry: onReconnect,
      retryLabel: 'Retry Connection',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SentinelColors.surfaceHighlight,
                shape: BoxShape.circle,
                border: Border.all(color: SentinelColors.border),
              ),
              child: Icon(icon, size: 36, color: status != null ? status!.color : SentinelColors.textSecondary),
            ),
            const SizedBox(height: 18),
            Text(title, style: SentinelTypography.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(
                description,
                style: SentinelTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
            if (status != null) ...[
              const SizedBox(height: 14),
              StatusBadge(status: status!),
            ],
            if (onRetry != null && retryLabel != null) ...[
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(retryLabel!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: SentinelColors.primary,
                  side: const BorderSide(color: SentinelColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

