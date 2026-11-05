import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/ipc_contract.dart';
import 'engine_provider.dart';

class DeviceProcessState {
  final bool isLoading;
  final DeviceInventorySnapshot? inventory;
  final List<ProcessItem> processes;
  final List<StartupItem> startupApps;
  final String? errorMessage;
  final DateTime lastRefreshed;

  const DeviceProcessState({
    this.isLoading = false,
    this.inventory,
    this.processes = const [],
    this.startupApps = const [],
    this.errorMessage,
    required this.lastRefreshed,
  });

  factory DeviceProcessState.initial() => DeviceProcessState(
        isLoading: true,
        lastRefreshed: DateTime.now(),
      );

  DeviceProcessState copyWith({
    bool? isLoading,
    DeviceInventorySnapshot? inventory,
    List<ProcessItem>? processes,
    List<StartupItem>? startupApps,
    String? errorMessage,
    DateTime? lastRefreshed,
  }) {
    return DeviceProcessState(
      isLoading: isLoading ?? this.isLoading,
      inventory: inventory ?? this.inventory,
      processes: processes ?? this.processes,
      startupApps: startupApps ?? this.startupApps,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

final deviceProcessProvider = NotifierProvider<DeviceProcessNotifier, DeviceProcessState>(DeviceProcessNotifier.new);

class DeviceProcessNotifier extends Notifier<DeviceProcessState> {
  final IpcClient _client = IpcClient();

  @override
  DeviceProcessState build() {
    ref.listen(engineProvider, (previous, next) {
      if (next.status.name == 'connected' && (previous?.status.name != 'connected' || state.inventory == null)) {
        refreshAll();
      }
    });

    Future.microtask(() => refreshAll());
    return DeviceProcessState.initial();
  }

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 1. Device Inventory
      final invResp = await _client.sendRequest<DeviceInventorySnapshot>(
        'get_device_inventory',
        {},
        fromData: (json) => DeviceInventorySnapshot.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      // 2. Processes
      final procResp = await _client.sendRequest<List<ProcessItem>>(
        'get_processes',
        {},
        fromData: (json) => (json as List)
            .map((e) => ProcessItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

      // 3. Startup Apps
      final startResp = await _client.sendRequest<List<StartupItem>>(
        'get_startup_apps',
        {},
        fromData: (json) => (json as List)
            .map((e) => StartupItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        inventory: invResp.data,
        processes: procResp.data ?? [],
        startupApps: startResp.data ?? [],
        errorMessage: null,
        lastRefreshed: DateTime.now(),
      );
    } catch (e) {
      debugPrint('[DeviceProcessNotifier] Failed loading data: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastRefreshed: DateTime.now(),
      );
    }
  }
}

