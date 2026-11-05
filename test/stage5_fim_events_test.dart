import 'package:flutter_test/flutter_test.dart';
import 'package:sentinelx/core/models/component_status.dart';
import 'package:sentinelx/core/models/ipc_contract.dart';
import 'package:sentinelx/core/providers/events_provider.dart';

void main() {
  group('Stage 5 File Integrity & Security Events Tests', () {
    test('FimTargetItem correctly maps SHA-256 and status', () {
      final json = {
        'TargetId': 'tgt_123',
        'CanonicalPath': r'C:\Windows\System32\drivers\etc\hosts',
        'UserLabel': 'Hosts File',
        'BaselineSha256': 'a1b2c3d4e5f6',
        'CurrentSha256': 'a1b2c3d4e5f6',
        'SizeBytes': 824,
        'CreatedAtUtc': '2026-11-05T12:00:00Z',
        'LastCheckedUtc': '2026-11-05T12:10:00Z',
        'Status': 'enabled',
        'HasChanged': false,
        'ChangeSummary': 'Integrity verified. Matches baseline hash.'
      };

      final target = FimTargetItem.fromJson(json);
      expect(target.targetId, 'tgt_123');
      expect(target.baselineSha256, 'a1b2c3d4e5f6');
      expect(target.hasChanged, isFalse);
      expect(target.status, ComponentStatus.enabled);
    });

    test('FimChangeEvent parses modification and deletion events', () {
      final json = {
        'EventId': 'ev_456',
        'TargetId': 'tgt_123',
        'CanonicalPath': r'C:\config.ini',
        'ChangeType': 'Modified',
        'OldHash': 'hash1',
        'NewHash': 'hash2',
        'DetectedAtUtc': '2026-11-05T12:30:00Z',
        'Severity': 'Warning'
      };

      final change = FimChangeEvent.fromJson(json);
      expect(change.changeType, 'Modified');
      expect(change.oldHash, 'hash1');
      expect(change.newHash, 'hash2');
      expect(change.severity, 'Warning');
    });

    test('SecurityEventItem parses access denied honestly (SX-008)', () {
      final json = {
        'RecordId': 0,
        'EventId': 0,
        'Channel': 'Security',
        'ProviderName': 'Windows Event Log Subsystem',
        'LevelDisplayName': 'Warning',
        'TimestampUtc': '2026-11-05T12:00:00Z',
        'Message': 'Access denied to channel Security.',
        'AccessDenied': true,
        'Status': 'access_denied'
      };

      final ev = SecurityEventItem.fromJson(json);
      expect(ev.accessDenied, isTrue);
      expect(ev.status, ComponentStatus.accessDenied);
      expect(ev.channel, 'Security');
    });

    test('EventsState filteredEvents filters by search query and channel', () {
      final ev1 = SecurityEventItem(
        recordId: 1,
        eventId: 1116,
        channel: 'Microsoft-Windows-Windows Defender/Operational',
        providerName: 'Defender',
        levelDisplayName: 'Warning',
        timestampUtc: '',
        message: 'Malware signature detected',
        accessDenied: false,
        status: ComponentStatus.enabled,
      );

      final ev2 = SecurityEventItem(
        recordId: 2,
        eventId: 7036,
        channel: 'System',
        providerName: 'Service Control Manager',
        levelDisplayName: 'Information',
        timestampUtc: '',
        message: 'Service started successfully',
        accessDenied: false,
        status: ComponentStatus.enabled,
      );

      final state = EventsState(
        events: [ev1, ev2],
        selectedChannel: 'Defender',
        lastRefreshed: DateTime.now(),
      );

      expect(state.filteredEvents.length, 1);
      expect(state.filteredEvents.first.eventId, 1116);
    });
  });
}

