import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ipc/ipc_client.dart';
import '../models/engine_state.dart';

final engineProvider = NotifierProvider<EngineNotifier, EngineState>(EngineNotifier.new);

class EngineNotifier extends Notifier<EngineState> {
  final IpcClient _client = IpcClient();
  Timer? _pollingTimer;
  bool _isChecking = false;

  @override
  EngineState build() {
    ref.onDispose(() {
      _pollingTimer?.cancel();
    });
    _startPolling();
    return EngineState.initial();
  }

  void _startPolling() {
    Future.microtask(() => checkEngine());
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => checkEngine());
  }

  Future<void> checkEngine() async {
    if (_isChecking) return;
    _isChecking = true;

    final stopwatch = Stopwatch()..start();
    try {
      final running = await _client.ensureEngineRunning();
      if (!running && state.status == EngineConnectionStatus.connecting && state.reconnectAttempts > 3) {
        state = state.copyWith(
          status: EngineConnectionStatus.disconnected,
          errorMessage: 'Native engine is not running. Launch SentinelX.Engine.exe or start via settings.',
          lastChecked: DateTime.now(),
        );
        _isChecking = false;
        return;
      }

      final health = await _client.getHealth();
      stopwatch.stop();

      state = state.copyWith(
        status: EngineConnectionStatus.connected,
        health: health,
        latencyMs: stopwatch.elapsedMilliseconds,
        errorMessage: null,
        lastChecked: DateTime.now(),
        reconnectAttempts: 0,
      );
    } catch (e) {
      stopwatch.stop();
      final errStr = e.toString();
      debugPrint('[EngineNotifier] Health check error: $errStr');

      EngineConnectionStatus newStatus = EngineConnectionStatus.disconnected;
      if (errStr.contains('CONTRACT_MISMATCH')) {
        newStatus = EngineConnectionStatus.contractMismatch;
      }

      state = state.copyWith(
        status: newStatus,
        errorMessage: errStr,
        latencyMs: stopwatch.elapsedMilliseconds,
        lastChecked: DateTime.now(),
        reconnectAttempts: state.reconnectAttempts + 1,
      );
    } finally {
      _isChecking = false;
    }
  }
}
