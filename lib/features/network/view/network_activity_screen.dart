import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/component_status.dart';
import '../../../core/providers/network_provider.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class NetworkActivityScreen extends ConsumerWidget {
  const NetworkActivityScreen({super.key});

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String _formatRate(int bytesPerSec) {
    return '${_formatBytes(bytesPerSec)}/s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(networkProvider);
    final activity = state.activity;
    final adapters = activity?.adapters ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Network Activity & Interfaces', style: SentinelTypography.display),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(networkProvider.notifier).refreshActivity();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Refresh Adapters'),
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
            'Passive visibility into local network adapters, IP configuration, and interface throughput deltas. Packet payloads, URLs, and private communications are never captured or inspected.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 20),

          // Total Throughput Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SentinelColors.surfaceCard,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SentinelColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SentinelColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.download_rounded, color: SentinelColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Download (RX)', style: SentinelTypography.caption),
                          const SizedBox(height: 2),
                          Text(
                            _formatRate(activity?.totalRxBytesPerSec ?? 0),
                            style: SentinelTypography.titleLarge.copyWith(color: SentinelColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 48, color: SentinelColors.border),
                Expanded(
                  child: Row(
                    children: [
                      const SizedBox(width: 24),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SentinelColors.accentBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.upload_rounded, color: SentinelColors.accentBlue, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Upload (TX)', style: SentinelTypography.caption),
                          const SizedBox(height: 2),
                          Text(
                            _formatRate(activity?.totalTxBytesPerSec ?? 0),
                            style: SentinelTypography.titleLarge.copyWith(color: SentinelColors.accentBlue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 48, color: SentinelColors.border),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Interfaces', style: SentinelTypography.caption),
                        const SizedBox(height: 2),
                        Text(
                          '${adapters.where((a) => a.operationalStatus.toLowerCase() == 'up').length} of ${adapters.length} connected',
                          style: SentinelTypography.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (adapters.isEmpty && state.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (adapters.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SentinelColors.surfaceCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: SentinelColors.border),
              ),
              child: const Text('No active network adapters found on this machine.', style: SentinelTypography.bodySecondary),
            )
          else
            ...adapters.map((adapter) {
              final isUp = adapter.operationalStatus.toLowerCase() == 'up';
              final status = isUp ? ComponentStatus.enabled : ComponentStatus.disabled;
              final isWifi = adapter.interfaceType.toLowerCase().contains('wireless') ||
                  adapter.name.toLowerCase().contains('wi-fi') ||
                  adapter.description.toLowerCase().contains('wi-fi') ||
                  adapter.description.toLowerCase().contains('wireless');

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SecurityCard(
                  title: adapter.name,
                  subtitle: adapter.description,
                  icon: isWifi ? Icons.wifi : Icons.settings_ethernet,
                  status: status,
                  source: 'Windows IP Helper API (GetAdaptersAddresses)',
                  lastChecked: activity?.snapshotTimestampUtc.isNotEmpty == true ? activity!.snapshotTimestampUtc : 'Live Polling',
                  limitations: 'Passive throughput rate counter; no deep packet inspection or payload capture.',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow('Operational Status', '${adapter.operationalStatus} (${adapter.interfaceType})'),
                      _buildRow('IPv4 Address', adapter.ipv4Address),
                      if (adapter.subnetMask.isNotEmpty) _buildRow('Subnet Mask', adapter.subnetMask),
                      _buildRow('Default Gateway', adapter.gateway),
                      _buildRow('DNS Servers', adapter.dnsServers.isEmpty ? 'None' : adapter.dnsServers.join(', ')),
                      _buildRow(
                        'Live Throughput',
                        'RX: ${_formatRate(adapter.rxBytesPerSec)}  |  TX: ${_formatRate(adapter.txBytesPerSec)}',
                      ),
                      _buildRow(
                        'Cumulative Transferred',
                        'Received: ${_formatBytes(adapter.bytesReceived)}  |  Sent: ${_formatBytes(adapter.bytesSent)}',
                      ),
                    ],
                  ),
                ),
              );
            }),

          // Loopback and Security Boundary Card
          SecurityCard(
            title: 'Loopback Interface & IPC Isolation',
            subtitle: 'Localhost and Inter-Process Communication Boundary',
            icon: Icons.repeat,
            status: ComponentStatus.enabled,
            source: 'Windows TCP/IP Stack & Named Pipe Subsystem',
            lastChecked: 'Strictly Enforced',
            limitations: 'IPC server is hardcoded to 127.0.0.1 and protected by a random 256-bit session token.',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Loopback Interface', '127.0.0.1 (Strict IPC Binding Boundary)'),
                _buildRow('SentinelX IPC Port', '127.0.0.1:58421 [Authenticated via Session Token]'),
                _buildRow('Named Pipe IPC', r'\\.\pipe\SentinelX.Engine.Ipc [Direct Kernel IPC]'),
                _buildRow('External Exposure', 'Zero external sockets bound; external listening is forbidden'),
              ],
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 220, child: Text(label, style: SentinelTypography.bodySecondary)),
          Expanded(child: Text(value, style: SentinelTypography.body)),
        ],
      ),
    );
  }
}
