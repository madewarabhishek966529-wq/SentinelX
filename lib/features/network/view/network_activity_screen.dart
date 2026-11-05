import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/security_card.dart';

class NetworkActivityScreen extends StatelessWidget {
  const NetworkActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Network Activity & Interfaces', style: SentinelTypography.display),
          const SizedBox(height: 8),
          const Text(
            'Passive visibility into local network adapters, IP configuration, and interface throughput deltas. Packet payloads, URLs, and private communications are never captured or inspected.',
            style: SentinelTypography.bodySecondary,
          ),
          const SizedBox(height: 24),

          SecurityCard(
            title: 'Active Network Interface – Wi-Fi / Ethernet',
            subtitle: 'Primary Default Gateway Connection',
            icon: Icons.wifi,
            status: ComponentStatus.enabled,
            source: 'Windows IP Helper API (GetAdaptersAddresses)',
            lastChecked: 'Live Polling',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Interface Name', 'Wi-Fi (802.11ax Wireless Network Adapter)'),
                _buildRow('Operational Status', 'Up (Connected to Local Subnet)'),
                _buildRow('IPv4 Address', '192.168.1.105 / 24'),
                _buildRow('Default Gateway', '192.168.1.1'),
                _buildRow('DNS Servers', '192.168.1.1, 1.1.1.1'),
                _buildRow('Current RX / TX Rate', '34.2 KB/s down / 12.8 KB/s up'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SecurityCard(
            title: 'Virtual & Loopback Interfaces',
            subtitle: 'Localhost and Software Emulated Adapters',
            icon: Icons.repeat,
            status: ComponentStatus.enabled,
            source: 'Windows TCP/IP Stack',
            lastChecked: 'Live Polling',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow('Loopback Interface', '127.0.0.1 (Strict IPC Binding Boundary)'),
                _buildRow('SentinelX IPC Port', '127.0.0.1:58421 [Authenticated via Session Token]'),
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
        children: [
          SizedBox(width: 220, child: Text(label, style: SentinelTypography.bodySecondary)),
          Expanded(child: Text(value, style: SentinelTypography.body)),
        ],
      ),
    );
  }
}
