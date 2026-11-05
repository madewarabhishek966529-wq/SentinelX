import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/ipc_contract.dart';
import 'engine_provider.dart';

class NetworkState {
  final bool isLoading;
  final bool isDiscovering;
  final bool isOptedIn;
  final String confirmedSubnet;
  final NetworkActivitySnapshot? activity;
  final List<LocalDeviceItem> devices;
  final String? errorMessage;
  final String? discoveryMessage;
  final DateTime lastRefreshed;

  const NetworkState({
    this.isLoading = false,
    this.isDiscovering = false,
    this.isOptedIn = false,
    this.confirmedSubnet = '192.168.1.0/24',
    this.activity,
    this.devices = const [],
    this.errorMessage,
    this.discoveryMessage,
    required this.lastRefreshed,
  });

  factory NetworkState.initial() => NetworkState(
        isLoading: true,
        lastRefreshed: DateTime.now(),
      );

  NetworkState copyWith({
    bool? isLoading,
    bool? isDiscovering,
    bool? isOptedIn,
    String? confirmedSubnet,
    NetworkActivitySnapshot? activity,
    List<LocalDeviceItem>? devices,
    String? errorMessage,
    String? discoveryMessage,
    DateTime? lastRefreshed,
  }) {
    return NetworkState(
      isLoading: isLoading ?? this.isLoading,
      isDiscovering: isDiscovering ?? this.isDiscovering,
      isOptedIn: isOptedIn ?? this.isOptedIn,
      confirmedSubnet: confirmedSubnet ?? this.confirmedSubnet,
      activity: activity ?? this.activity,
      devices: devices ?? this.devices,
      errorMessage: errorMessage ?? this.errorMessage,
      discoveryMessage: discoveryMessage ?? this.discoveryMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

final networkProvider = NotifierProvider<NetworkNotifier, NetworkState>(NetworkNotifier.new);

class NetworkNotifier extends Notifier<NetworkState> {
  final IpcClient _client = IpcClient();
  Timer? _pollingTimer;

  @override
  NetworkState build() {
    ref.listen(engineProvider, (previous, next) {
      if (next.status.name == 'connected' && (previous?.status.name != 'connected' || state.activity == null)) {
        refreshActivity();
      }
    });

    ref.onDispose(() {
      _pollingTimer?.cancel();
    });

    // Start passive periodic polling every 4 seconds for throughput deltas
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (state.activity != null && !state.isLoading) {
        refreshActivity(silent: true);
      }
    });

    Future.microtask(() => refreshActivity());
    return NetworkState.initial();
  }

  void setOptIn(bool optedIn) {
    state = state.copyWith(isOptedIn: optedIn);
  }

  void setConfirmedSubnet(String subnet) {
    state = state.copyWith(confirmedSubnet: subnet.trim());
  }

  Future<void> refreshActivity({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final resp = await _client.sendRequest<NetworkActivitySnapshot>(
        'get_network_activity',
        {},
        fromData: (json) => NetworkActivitySnapshot.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      // Auto-detect primary subnet if not set
      String detectedSubnet = state.confirmedSubnet;
      if (resp.data != null && resp.data!.adapters.isNotEmpty) {
        final primary = resp.data!.adapters.firstWhere(
          (a) => a.ipv4Address != 'Not assigned' && !a.ipv4Address.startsWith('127.'),
          orElse: () => resp.data!.adapters.first,
        );
        if (primary.ipv4Address != 'Not assigned' && primary.ipv4Address.contains('.')) {
          final parts = primary.ipv4Address.split('.');
          if (parts.length == 4) {
            detectedSubnet = '${parts[0]}.${parts[1]}.${parts[2]}.0/24';
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        activity: resp.data,
        confirmedSubnet: state.isOptedIn ? state.confirmedSubnet : detectedSubnet,
        errorMessage: null,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      if (!silent) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to retrieve network activity: $e',
          lastRefreshed: DateTime.now(),
        );
      }
    }
  }

  Future<void> startDiscovery() async {
    if (!state.isOptedIn) {
      state = state.copyWith(errorMessage: 'Network discovery requires explicit opt-in confirmation.');
      return;
    }

    state = state.copyWith(
      isDiscovering: true,
      errorMessage: null,
      discoveryMessage: 'Authorized subnet discovery in progress for ${state.confirmedSubnet}...',
    );

    try {
      final resp = await _client.sendRequest<List<LocalDeviceItem>>(
        'discover_local_devices',
        {'targetSubnet': state.confirmedSubnet},
        fromData: (json) => (json as List)
            .map((e) => LocalDeviceItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

      state = state.copyWith(
        isDiscovering: false,
        devices: resp.data ?? [],
        discoveryMessage: 'Discovered ${resp.data?.length ?? 0} active local device(s).',
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isDiscovering: false,
        discoveryMessage: null,
        errorMessage: 'Local device discovery failed: $e',
      );
    }
  }

  Future<void> cancelDiscovery() async {
    try {
      await _client.sendRequest<Map<String, dynamic>>('cancel_discovery', {});
      state = state.copyWith(
        isDiscovering: false,
        discoveryMessage: 'Discovery cancelled by user.',
      );
    } catch (e) {
      state = state.copyWith(isDiscovering: false);
    }
  }

  void updateDeviceLabel(String ip, String newLabel) {
    final updated = state.devices.map((d) {
      if (d.ipAddress == ip) {
        return LocalDeviceItem(
          ipAddress: d.ipAddress,
          hostname: d.hostname,
          macAddress: d.macAddress,
          vendorHint: d.vendorHint,
          discoveryMethod: d.discoveryMethod,
          status: d.status,
          firstSeenUtc: d.firstSeenUtc,
          lastSeenUtc: d.lastSeenUtc,
          userLabel: newLabel,
        );
      }
      return d;
    }).toList();

    state = state.copyWith(devices: updated);
  }

  void clearDevices() {
    state = state.copyWith(devices: [], discoveryMessage: null);
  }
}

