import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/component_status.dart';
import '../../../core/providers/engine_provider.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class HardwareScreen extends ConsumerWidget {
  const HardwareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engineState = ref.watch(engineProvider);
    final nowFormatted = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} Local';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Device & Hardware Inventory', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Audits local hardware specifications, operating system version, and system identifiers. Serial numbers are strictly minimized to preserve privacy.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          SecurityCard(
            title: 'Operating System Environment',
            subtitle: 'Windows Kernel and Architecture',
            icon: Icons.computer_outlined,
            status: ComponentStatus.enabled,
            source: 'Windows Win32 System API',
            lastChecked: nowFormatted,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Operating System', Platform.operatingSystemVersion),
                _buildRow('Architecture', Platform.version.contains('x64') ? 'x64 (64-bit)' : 'ARM64'),
                _buildRow('Host Name', Platform.localHostname),
                _buildRow('Processors / Logical Cores', '${Platform.numberOfProcessors} Logical Cores'),
                if (engineState.health != null)
                  _buildRow('Engine Process ID', '${engineState.health!.processId} (Working set: ${(engineState.health!.memoryBytes / (1024 * 1024)).toStringAsFixed(1)} MB)'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SecurityCard(
            title: 'Removable Storage & External Devices',
            subtitle: 'USB Mass Storage Device Attachments',
            icon: Icons.usb_outlined,
            status: ComponentStatus.enabled,
            source: 'Windows Device Notification (WM_DEVICECHANGE)',
            lastChecked: nowFormatted,
            limitations: 'Tracks plug-and-play volume mount events in user session.',
            content: const Text(
              'No unverified external mass storage devices currently connected.',
              style: SentinelTypography.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 220, child: Text(label, style: SentinelTypography.bodySecondary)),
          Expanded(child: Text(value, style: SentinelTypography.body)),
        ],
      ),
    );
  }
}
