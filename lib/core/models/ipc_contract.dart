import 'component_status.dart';

class IpcContractConstants {
  static const String version = '1.0.0';
  static const int defaultPort = 58421;
  static const String pipeName = 'SentinelX.Engine.Ipc';
}

class IpcError {
  final String errorCode;
  final String safeMessage;
  final String diagnosticId;

  IpcError({
    required this.errorCode,
    required this.safeMessage,
    required this.diagnosticId,
  });

  factory IpcError.fromJson(Map<String, dynamic> json) {
    return IpcError(
      errorCode: json['errorCode'] as String? ?? 'UNKNOWN_ERROR',
      safeMessage: json['safeMessage'] as String? ?? 'An unexpected error occurred.',
      diagnosticId: json['diagnosticId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'errorCode': errorCode,
    'safeMessage': safeMessage,
    'diagnosticId': diagnosticId,
  };
}

class IpcRequest {
  final String contractVersion;
  final String requestId;
  final String action;
  final String timestampUtc;
  final Map<String, dynamic> parameters;

  IpcRequest({
    this.contractVersion = IpcContractConstants.version,
    required this.requestId,
    required this.action,
    required this.timestampUtc,
    this.parameters = const {},
  });

  Map<String, dynamic> toJson() => {
    'contractVersion': contractVersion,
    'requestId': requestId,
    'action': action,
    'timestampUtc': timestampUtc,
    'parameters': parameters,
  };
}

class IpcResponse<T> {
  final String contractVersion;
  final String requestId;
  final String timestampUtc;
  final String status; // 'success', 'error', 'partial'
  final T? data;
  final IpcError? error;

  IpcResponse({
    required this.contractVersion,
    required this.requestId,
    required this.timestampUtc,
    required this.status,
    this.data,
    this.error,
  });

  bool get isSuccess => status == 'success';

  factory IpcResponse.fromJson(Map<String, dynamic> json, T? Function(dynamic dataJson)? fromDataJson) {
    return IpcResponse<T>(
      contractVersion: json['contractVersion'] as String? ?? '',
      requestId: json['requestId'] as String? ?? '',
      timestampUtc: json['timestampUtc'] as String? ?? '',
      status: json['status'] as String? ?? 'error',
      data: json['data'] != null && fromDataJson != null ? fromDataJson(json['data']) : null,
      error: json['error'] != null ? IpcError.fromJson(Map<String, dynamic>.from(json['error'] as Map)) : null,
    );
  }
}

class EngineHealthData {
  final String engineVersion;
  final String contractVersion;
  final int processId;
  final String startedAtUtc;
  final String osVersion;
  final bool isElevated;
  final String status;
  final int memoryBytes;
  final List<String> supportedActions;

  EngineHealthData({
    required this.engineVersion,
    required this.contractVersion,
    required this.processId,
    required this.startedAtUtc,
    required this.osVersion,
    required this.isElevated,
    required this.status,
    required this.memoryBytes,
    required this.supportedActions,
  });

  factory EngineHealthData.fromJson(Map<String, dynamic> json) {
    return EngineHealthData(
      engineVersion: json['engineVersion'] as String? ?? '1.0.0',
      contractVersion: json['contractVersion'] as String? ?? '1.0.0',
      processId: (json['processId'] as num?)?.toInt() ?? 0,
      startedAtUtc: json['startedAtUtc'] as String? ?? '',
      osVersion: json['osVersion'] as String? ?? '',
      isElevated: json['isElevated'] as bool? ?? false,
      status: json['status'] as String? ?? 'unknown',
      memoryBytes: (json['memoryBytes'] as num?)?.toInt() ?? 0,
      supportedActions: (json['supportedActions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class StatusSnapshot {
  final String componentKey;
  final ComponentStatus status;
  final String source;
  final String checkedAtUtc;
  final int freshnessSeconds;
  final String limitations;
  final Map<String, dynamic> details;

  StatusSnapshot({
    required this.componentKey,
    required this.status,
    required this.source,
    required this.checkedAtUtc,
    required this.freshnessSeconds,
    required this.limitations,
    required this.details,
  });

  factory StatusSnapshot.fromJson(Map<String, dynamic> json) {
    return StatusSnapshot(
      componentKey: json['componentKey'] as String? ?? '',
      status: ComponentStatus.fromString(json['status'] as String?),
      source: json['source'] as String? ?? 'Windows API',
      checkedAtUtc: json['checkedAtUtc'] as String? ?? '',
      freshnessSeconds: (json['freshnessSeconds'] as num?)?.toInt() ?? 60,
      limitations: json['limitations'] as String? ?? '',
      details: json['details'] != null ? Map<String, dynamic>.from(json['details'] as Map) : {},
    );
  }
}

class SessionMetadata {
  final int port;
  final String pipeName;
  final String token;
  final int processId;
  final String contractVersion;
  final String startedAtUtc;

  SessionMetadata({
    required this.port,
    required this.pipeName,
    required this.token,
    required this.processId,
    required this.contractVersion,
    required this.startedAtUtc,
  });

  factory SessionMetadata.fromJson(Map<String, dynamic> json) {
    return SessionMetadata(
      port: (json['port'] as num?)?.toInt() ?? IpcContractConstants.defaultPort,
      pipeName: json['pipeName'] as String? ?? IpcContractConstants.pipeName,
      token: json['token'] as String? ?? '',
      processId: (json['processId'] as num?)?.toInt() ?? 0,
      contractVersion: json['contractVersion'] as String? ?? '1.0.0',
      startedAtUtc: json['startedAtUtc'] as String? ?? '',
    );
  }
}

