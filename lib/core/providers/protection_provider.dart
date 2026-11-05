import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/ipc_contract.dart';
import 'engine_provider.dart';

class ProtectionState {
  final bool isLoading;
  final ProtectionPostureSnapshot? snapshot;
  final String? errorMessage;
  final DateTime lastRefreshed;

  const ProtectionState({
    this.isLoading = false,
    this.snapshot,
    this.errorMessage,
    required this.lastRefreshed,
  });

  factory ProtectionState.initial() => ProtectionState(
        isLoading: true,
        lastRefreshed: DateTime.now(),
      );

  ProtectionState copyWith({
    bool? isLoading,
    ProtectionPostureSnapshot? snapshot,
    String? errorMessage,
    DateTime? lastRefreshed,
  }) {
    return ProtectionState(
      isLoading: isLoading ?? this.isLoading,
      snapshot: snapshot ?? this.snapshot,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRefreshed: lastRefreshed ?? this.lastRefreshed,
    );
  }
}

final protectionProvider = NotifierProvider<ProtectionNotifier, ProtectionState>(ProtectionNotifier.new);

class ProtectionNotifier extends Notifier<ProtectionState> {
  final IpcClient _client = IpcClient();

  @override
  ProtectionState build() {
    // Listen to engine connection changes
    ref.listen(engineProvider, (previous, next) {
      if (next.status.name == 'connected' && (previous?.status.name != 'connected' || state.snapshot == null)) {
        refreshPosture();
      }
    });

    Future.microtask(() => refreshPosture());
    return ProtectionState.initial();
  }

  Future<void> refreshPosture() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final resp = await _client.sendRequest<ProtectionPostureSnapshot>(
        'get_protection_posture',
        {},
        fromData: (json) => ProtectionPostureSnapshot.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      if (resp.isSuccess && resp.data != null) {
        state = state.copyWith(
          isLoading: false,
          snapshot: resp.data,
          errorMessage: null,
          lastRefreshed: DateTime.now(),
        );
      } else {
        final msg = resp.error?.safeMessage ?? 'Unable to query protection posture from engine.';
        state = state.copyWith(
          isLoading: false,
          errorMessage: msg,
          lastRefreshed: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('[ProtectionNotifier] Failed to load posture: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        lastRefreshed: DateTime.now(),
      );
    }
  }
}

