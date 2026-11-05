import 'package:flutter/material.dart';
import '../../../core/models/component_status.dart';
import '../../../core/theme/sentinel_colors.dart';
import '../../../core/theme/sentinel_typography.dart';
import '../../../shared/widgets/status_badge.dart';

class NetworkDevicesScreen extends StatefulWidget {
  const NetworkDevicesScreen({super.key});

  @override
  State<NetworkDevicesScreen> createState() => _NetworkDevicesScreenState();
}

class _NetworkDevicesScreenState extends State<NetworkDevicesScreen> {
  bool _isOptedIn = false;
  bool _isScanning = false;

  final List<Map<String, dynamic>> _discoveredDevices = [
    {
      'ip': '192.168.1.1',
      'hostname': 'router.local',
      'vendor': 'Home Gateway / Router',
      'status': ComponentStatus.enabled,
      'discovery': 'ARP Cache / Gateway Query',
      'lastSeen': 'Just now',
    },
    {
      'ip': '192.168.1.105',
      'hostname': 'SENTINELX-PC (This Device)',
      'vendor': 'Local Host Machine',
      'status': ComponentStatus.enabled,
      'discovery': 'Local Host Interface',
      'lastSeen': 'Active',
    },
    {
      'ip': '192.168.1.142',
      'hostname': 'Unknown Device',
      'vendor': 'Unknown Vendor',
      'status': ComponentStatus.unknown,
      'discovery': 'Benign ICMP Echo',
      'lastSeen': '2 mins ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Network Devices (Authorized Discovery)', style: SentinelTypography.display),
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
                      value: _isOptedIn,
                      activeThumbColor: SentinelColors.primary,
                      onChanged: (val) {
                        setState(() => _isOptedIn = val);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discovery is OFF by default. It is strictly limited to your confirmed private home network subnet (e.g. 192.168.1.0/24 or RFC 1918 / RFC 3927). Public IP scanning, vulnerability exploits, credential attempts, and stealth techniques are strictly prohibited.',
                  style: SentinelTypography.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (!_isOptedIn)
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
                        'Enable the opt-in switch above to discover devices on your authorized local subnet.',
                        style: SentinelTypography.bodySecondary,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else ...[
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _isScanning = !_isScanning);
                  },
                  icon: Icon(_isScanning ? Icons.stop : Icons.search, size: 16),
                  label: Text(_isScanning ? 'Cancel Discovery' : 'Discover Subnet (192.168.1.0/24)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SentinelColors.primary,
                    side: const BorderSide(color: SentinelColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                if (_isScanning)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: SentinelColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _discoveredDevices.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, index) {
                  final dev = _discoveredDevices[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    leading: const Icon(Icons.devices, color: SentinelColors.primary, size: 22),
                    title: Row(
                      children: [
                        Text(dev['hostname'], style: SentinelTypography.titleMedium),
                        const SizedBox(width: 10),
                        Text('(${dev['ip']})', style: SentinelTypography.code),
                        const Spacer(),
                        StatusBadge(status: dev['status'] as ComponentStatus),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Vendor / Role: ${dev['vendor']}', style: SentinelTypography.bodySecondary),
                        const SizedBox(height: 2),
                        Text('Discovery: ${dev['discovery']} • Last seen: ${dev['lastSeen']}', style: SentinelTypography.caption),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
