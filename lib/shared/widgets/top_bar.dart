import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/engine_state.dart';
import '../../core/providers/engine_provider.dart';
import '../../core/theme/sentinel_colors.dart';
import '../../core/theme/sentinel_typography.dart';

class TopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;

  const TopBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: SentinelColors.surface,
        border: Border(bottom: BorderSide(color: SentinelColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: SentinelTypography.titleMedium,
          ),
          const Spacer(),
          // Engine connection pill
          _buildEnginePill(context, ref, engineState),
          const SizedBox(width: 12),
          // Refresh button
          IconButton(
            tooltip: 'Refresh Statuses',
            icon: const Icon(Icons.refresh, size: 18, color: SentinelColors.textSecondary),
            onPressed: () {
              ref.read(engineProvider.notifier).checkEngine();
            },
          ),
          const SizedBox(width: 4),
          // Settings shortcut
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.tune, size: 18, color: SentinelColors.textSecondary),
            onPressed: () => context.go('/settings'),
          ),
          // About shortcut
          IconButton(
            tooltip: 'About SentinelX & Boundaries',
            icon: const Icon(Icons.shield_outlined, size: 18, color: SentinelColors.textSecondary),
            onPressed: () => context.go('/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnginePill(BuildContext context, WidgetRef ref, EngineState state) {
    String label;
    if (state.status == EngineConnectionStatus.connected) {
      label = 'Engine: Connected (${state.latencyMs}ms)';
    } else {
      label = state.status.label;
    }

    final tooltip = state.health != null
        ? 'Engine PID: ${state.health!.processId}\nOS: ${state.health!.osVersion}\nElevated: ${state.health!.isElevated}\nUptime since: ${state.health!.startedAtUtc}'
        : (state.errorMessage ?? state.status.label);

    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          ref.read(engineProvider.notifier).checkEngine();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: state.status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: state.status.color.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: state.status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: state.status.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
