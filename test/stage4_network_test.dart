import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelx/core/models/component_status.dart';
import 'package:sentinelx/core/models/ipc_contract.dart';
import 'package:sentinelx/core/providers/network_provider.dart';

void main() {
  group('Stage 4 Network Awareness & Authorized Discovery Tests', () {
    test('NetworkAdapterInfo serialization preserves IPv4 and throughput deltas', () {
      final json = {
        'Id': '{A1B2-C3D4}',
        'Name': 'Ethernet',
        'Description': 'Intel(R) Ethernet Connection I219-V',
        'OperationalStatus': 'Up',
        'InterfaceType': 'Ethernet',
        'Ipv4Address': '192.168.1.50',
        'SubnetMask': '255.255.255.0',
        'Gateway': '192.168.1.1',
        'DnsServers': ['192.168.1.1', '8.8.8.8'],
        'BytesReceived': 1048576,
        'BytesSent': 524288,
        'RxBytesPerSec': 12500,
        'TxBytesPerSec': 4200,
      };

      final adapter = NetworkAdapterInfo.fromJson(json);
      expect(adapter.name, 'Ethernet');
      expect(adapter.operationalStatus, 'Up');
      expect(adapter.ipv4Address, '192.168.1.50');
      expect(adapter.gateway, '192.168.1.1');
      expect(adapter.dnsServers.length, 2);
      expect(adapter.rxBytesPerSec, 12500);
      expect(adapter.txBytesPerSec, 4200);
    });

    test('LocalDeviceItem deserialization handles user labels and discovery methods', () {
      final json = {
        'IpAddress': '192.168.1.1',
        'Hostname': 'gateway.local',
        'MacAddress': 'AA:BB:CC:DD:EE:FF',
        'VendorHint': 'Netgear',
        'DiscoveryMethod': 'ARP Cache',
        'Status': 'enabled',
        'FirstSeenUtc': '2026-11-05T12:00:00Z',
        'LastSeenUtc': '2026-11-05T12:05:00Z',
        'UserLabel': 'Home Router',
      };

      final item = LocalDeviceItem.fromJson(json);
      expect(item.ipAddress, '192.168.1.1');
      expect(item.hostname, 'gateway.local');
      expect(item.userLabel, 'Home Router');
      expect(item.status, ComponentStatus.enabled);
      expect(item.discoveryMethod, 'ARP Cache');
    });

    test('NetworkState initial state enforces opt-in is false by default (SX-005)', () {
      final state = NetworkState.initial();
      expect(state.isOptedIn, isFalse);
      expect(state.isDiscovering, isFalse);
      expect(state.devices, isEmpty);
      expect(state.confirmedSubnet, '192.168.1.0/24');
    });
  });
}

