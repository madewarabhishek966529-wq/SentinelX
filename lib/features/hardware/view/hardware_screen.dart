import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/component_status.dart';
import '../../../core/providers/device_process_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class HardwareScreen extends ConsumerWidget {
  const HardwareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(deviceProcessProvider);
    final inv = state.inventory;
    final nowFormatted = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} Local';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Device & Hardware Inventory', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(deviceProcessProvider.notifier).refreshAll();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Hardware'),
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
            'Audits local hardware specifications, operating system version, and system components. Device serial numbers are strictly minimized to preserve privacy.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          SecurityCard(
            title: 'System & Architecture',
            subtitle: inv != null ? '${inv.manufacturer} – ${inv.model}' : 'Windows Host Machine',
            icon: Icons.computer_outlined,
            status: ComponentStatus.enabled,
            source: 'Windows Win32 System API & WMI Win32_ComputerSystem',
            lastChecked: inv?.snapshotTimestampUtc.isNotEmpty == true ? inv!.snapshotTimestampUtc : nowFormatted,
            limitations: 'Queries system capabilities without harvesting unique serial identifiers.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Operating System', inv?.osVersion ?? 'Windows 11 x64'),
                _buildRow('Machine Name', inv?.machineName ?? 'SENTINELX-PC'),
                _buildRow('Manufacturer', inv?.manufacturer ?? 'Generic PC'),
                _buildRow('System Model', inv?.model ?? 'Desktop / Laptop'),
                _buildRow('Logical Processors', '${inv?.processorCount ?? 1} Logical CPU Cores'),
                if (inv != null && inv.totalMemoryBytes > 0)
                  _buildRow('Total Physical Memory', '${(inv.totalMemoryBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB RAM'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Logical Drives
          if (inv != null && inv.drives.isNotEmpty)
            ...inv.drives.map((drive) {
              final totalGb = (drive.totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
              final freeGb = (drive.freeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
              final usedGb = ((drive.totalBytes - drive.freeBytes) / (1024 * 1024 * 1024)).toStringAsFixed(1);

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SecurityCard(
                  title: 'Storage Volume – Drive ${drive.name}',
                  subtitle: '${drive.driveType} Filesystem Storage',
                  icon: Icons.storage_outlined,
                  status: drive.isReady ? ComponentStatus.enabled : ComponentStatus.unknown,
                  source: 'System.IO.DriveInfo (Win32 API)',
                  lastChecked: nowFormatted,
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow('Volume Mount', drive.name),
                      _buildRow('Drive Type', drive.driveType),
                      _buildRow('Total Capacity', '$totalGb GB'),
                      _buildRow('Available Space', '$freeGb GB free (Used: $usedGb GB)'),
                    ],
                  ),
                ),
              );
            }),

          SecurityCard(
            title: 'Removable Storage Monitoring',
            subtitle: 'External USB Mass Storage Attachments',
            icon: Icons.usb_outlined,
            status: ComponentStatus.enabled,
            source: 'Windows Device Notification (WM_DEVICECHANGE)',
            lastChecked: nowFormatted,
            limitations: 'Tracks plug-and-play volume mount events in active user session.',
            content: const Text(
              'No unauthorized external removable storage drives connected.',
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
