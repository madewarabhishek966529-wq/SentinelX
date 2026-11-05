import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/network_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class NetworkDevicesScreen extends ConsumerStatefulWidget {
  const NetworkDevicesScreen({super.key});

  @override
  ConsumerState<NetworkDevicesScreen> createState() => _NetworkDevicesScreenState();
}

class _NetworkDevicesScreenState extends ConsumerState<NetworkDevicesScreen> {
  final TextEditingController _subnetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final netState = ref.read(networkProvider);
    _subnetController.text = netState.confirmedSubnet;
  }

  @override
  void dispose() {
    _subnetController.dispose();
    super.dispose();
  }

  void _showLabelDialog(String ip, String currentLabel) {
    final controller = TextEditingController(text: currentLabel);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SentinelColors.surfaceCard,
        title: const Text('Set Device Label', style: SentinelTypography.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign a friendly, private label for $ip:', style: SentinelTypography.bodySecondary),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: SentinelTypography.body,
              decoration: const InputDecoration(
                hintText: 'e.g. My Laptop, Living Room AppleTV, NAS',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(networkProvider.notifier).updateDeviceLabel(ip, controller.text.trim());
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: SentinelColors.primary),
            child: const Text('Save Label'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(networkProvider);
    final devices = state.devices;

    if (_subnetController.text != state.confirmedSubnet && !_subnetController.text.contains('/')) {
      _subnetController.text = state.confirmedSubnet;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Network Devices (Authorized Discovery)', style: SentinelTypography.display),
              const Spacer(),
              if (state.isOptedIn) ...[
                ElevatedButton.icon(
                  onPressed: state.isDiscovering
                      ? () => ref.read(networkProvider.notifier).cancelDiscovery()
                      : () {
                          ref.read(networkProvider.notifier).setConfirmedSubnet(_subnetController.text);
                          ref.read(networkProvider.notifier).startDiscovery();
                        },
                  icon: Icon(state.isDiscovering ? Icons.stop_circle_outlined : Icons.radar_outlined, size: 16),
                  label: Text(state.isDiscovering ? 'Cancel Scan' : 'Scan Subnet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.isDiscovering ? SentinelColors.statusError : SentinelColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: devices.isEmpty ? null : () => ref.read(networkProvider.notifier).clearDevices(),
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SentinelColors.textSecondary,
                    side: const BorderSide(color: SentinelColors.border),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Mandatory Safety Banner (SX-005, SX-006)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SentinelColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SentinelColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: SentinelColors.primary, size: 22),
                    const SizedBox(width: 10),
                    const Text('Opt-in Local Subnet Discovery Policy', style: SentinelTypography.titleMedium),
                    const Spacer(),
                    Switch(
                      value: state.isOptedIn,
                      activeThumbColor: SentinelColors.primary,
                      onChanged: (val) {
                        ref.read(networkProvider.notifier).setOptIn(val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discovery is OFF by default. It is strictly limited to your confirmed private home network subnet (e.g. 192.168.1.0/24 or RFC 1918 / RFC 3927). Public IP scanning, vulnerability exploits, credential attempts, and stealth techniques are strictly prohibited.',
                  style: SentinelTypography.bodySecondary,
                ),
                if (state.isOptedIn) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Confirmed Private Scope: ', style: SentinelTypography.body),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 220,
                        height: 36,
                        child: TextField(
                          controller: _subnetController,
                          style: SentinelTypography.body,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(),
                            hintText: '192.168.1.0/24',
                          ),
                          onSubmitted: (val) {
                            ref.read(networkProvider.notifier).setConfirmedSubnet(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('(RFC 1918 / RFC 3927 enforced by engine)', style: SentinelTypography.caption),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Feedback alerts
          if (state.discoveryMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SentinelColors.surfaceHighlight,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SentinelColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  if (state.isDiscovering) ...[
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: SentinelColors.primary),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      state.discoveryMessage!,
                      style: SentinelTypography.bodySecondary.copyWith(color: SentinelColors.primary),
                    ),
                  ),
                ],
              ),
            ),

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

          if (!state.isOptedIn)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.lock_clock_outlined, size: 40, color: SentinelColors.textSecondary),
                      SizedBox(height: 14),
                      Text('Network Discovery is Disabled', style: SentinelTypography.titleLarge),
                      SizedBox(height: 6),
                      Text(
                        'Enable the policy switch above to discover active devices on your authorized local subnet using passive ARP inspection.',
                        style: SentinelTypography.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (devices.isEmpty && !state.isDiscovering)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.devices_other_outlined, size: 40, color: SentinelColors.textSecondary),
                      const SizedBox(height: 14),
                      const Text('No Discovered Devices', style: SentinelTypography.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        'Click "Scan Subnet" to perform benign ARP inspection of your confirmed scope (${state.confirmedSubnet}).',
                        style: SentinelTypography.bodySecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: SentinelColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SentinelColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(SentinelColors.surfaceHighlight),
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 56,
                  columns: const [
                    DataColumn(label: Text('IP Address', style: SentinelTypography.titleMedium)),
                    DataColumn(label: Text('Hostname / Label', style: SentinelTypography.titleMedium)),
                    DataColumn(label: Text('MAC Address', style: SentinelTypography.titleMedium)),
                    DataColumn(label: Text('Vendor Hint', style: SentinelTypography.titleMedium)),
                    DataColumn(label: Text('Discovery Method', style: SentinelTypography.titleMedium)),
                    DataColumn(label: Text('Status', style: SentinelTypography.titleMedium)),
                    DataColumn(label: Text('Actions', style: SentinelTypography.titleMedium)),
                  ],
                  rows: devices.map((dev) {
                    final displayLabel = dev.userLabel.isNotEmpty
                        ? '${dev.userLabel} (${dev.hostname})'
                        : dev.hostname;

                    return DataRow(
                      cells: [
                        DataCell(Text(dev.ipAddress, style: SentinelTypography.body)),
                        DataCell(
                          Row(
                            children: [
                              Text(displayLabel, style: SentinelTypography.body),
                              if (dev.userLabel.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(left: 6),
                                  child: Icon(Icons.bookmark, size: 14, color: SentinelColors.primary),
                                ),
                            ],
                          ),
                        ),
                        DataCell(Text(dev.macAddress.isEmpty ? 'Hidden / Masked' : dev.macAddress, style: SentinelTypography.bodySecondary)),
                        DataCell(Text(dev.vendorHint.isEmpty ? 'Unknown' : dev.vendorHint, style: SentinelTypography.bodySecondary)),
                        DataCell(Text(dev.discoveryMethod, style: SentinelTypography.caption)),
                        DataCell(StatusBadge(status: dev.status)),
                        DataCell(
                          IconButton(
                            icon: const Icon(Icons.edit_note, size: 18),
                            tooltip: 'Set friendly label',
                            onPressed: () => _showLabelDialog(dev.ipAddress, dev.userLabel),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
