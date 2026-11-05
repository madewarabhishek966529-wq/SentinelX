import 'package:flutter/material.dart';
import '../theme/sentinel_colors.dart';
import 'ipc_contract.dart';

enum EngineConnectionStatus {
  connecting,
  connected,
  disconnected,
  degraded,
  contractMismatch;

  String get label {
    switch (this) {
      case EngineConnectionStatus.connecting:
        return 'Connecting to Engine...';
      case EngineConnectionStatus.connected:
        return 'Engine Connected';
      case EngineConnectionStatus.disconnected:
        return 'Engine Offline';
      case EngineConnectionStatus.degraded:
        return 'Engine Degraded';
      case EngineConnectionStatus.contractMismatch:
        return 'Contract Mismatch';
    }
  }

  Color get color {
    switch (this) {
      case EngineConnectionStatus.connected:
        return SentinelColors.statusEnabled;
      case EngineConnectionStatus.connecting:
        return SentinelColors.statusUnknown;
      case EngineConnectionStatus.degraded:
        return SentinelColors.statusUnknown;
      case EngineConnectionStatus.disconnected:
        return SentinelColors.statusError;
      case EngineConnectionStatus.contractMismatch:
        return SentinelColors.statusAccessDenied;
    }
  }

  IconData get icon {
    switch (this) {
      case EngineConnectionStatus.connected:
        return Icons.link;
      case EngineConnectionStatus.connecting:
        return Icons.sync;
      case EngineConnectionStatus.disconnected:
        return Icons.link_off;
      case EngineConnectionStatus.degraded:
        return Icons.warning_amber_rounded;
      case EngineConnectionStatus.contractMismatch:
        return Icons.gpp_bad_outlined;
    }
  }
}

class EngineState {
  final EngineConnectionStatus status;
  final EngineHealthData? health;
  final int latencyMs;
  final String? errorMessage;
  final DateTime lastChecked;
  final int reconnectAttempts;

  const EngineState({
    required this.status,
    this.health,
    this.latencyMs = 0,
    this.errorMessage,
    required this.lastChecked,
    this.reconnectAttempts = 0,
  });

  factory EngineState.initial() {
    return EngineState(
      status: EngineConnectionStatus.connecting,
      lastChecked: DateTime.now(),
    );
  }

  EngineState copyWith({
    EngineConnectionStatus? status,
    EngineHealthData? health,
    int? latencyMs,
    String? errorMessage,
    DateTime? lastChecked,
    int? reconnectAttempts,
  }) {
    return EngineState(
      status: status ?? this.status,
      health: health ?? this.health,
      latencyMs: latencyMs ?? this.latencyMs,
      errorMessage: errorMessage ?? this.errorMessage,
      lastChecked: lastChecked ?? this.lastChecked,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
    );
  }
}
