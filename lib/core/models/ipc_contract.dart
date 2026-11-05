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

// Stage 2 Models
class AntivirusInfo {
  final String displayName;
  final ComponentStatus status;
  final bool isActive;
  final bool isUpToDate;
  final String productStateHex;
  final String source;
  final String checkedAtUtc;
  final String limitations;

  AntivirusInfo({
    required this.displayName,
    required this.status,
    required this.isActive,
    required this.isUpToDate,
    required this.productStateHex,
    required this.source,
    required this.checkedAtUtc,
    required this.limitations,
  });

  factory AntivirusInfo.fromJson(Map<String, dynamic> json) {
    return AntivirusInfo(
      displayName: json['DisplayName'] as String? ?? 'Unknown Antivirus',
      status: ComponentStatus.fromString(json['Status'] as String?),
      isActive: json['IsActive'] as bool? ?? false,
      isUpToDate: json['IsUpToDate'] as bool? ?? false,
      productStateHex: json['ProductStateHex'] as String? ?? 'Unknown',
      source: json['Source'] as String? ?? 'Windows Security Center',
      checkedAtUtc: json['CheckedAtUtc'] as String? ?? '',
      limitations: json['Limitations'] as String? ?? '',
    );
  }
}

class FirewallProfileInfo {
  final String profileName;
  final ComponentStatus status;
  final bool isEnabled;
  final String inboundAction;
  final String outboundAction;
  final String source;
  final String checkedAtUtc;
  final String limitations;

  FirewallProfileInfo({
    required this.profileName,
    required this.status,
    required this.isEnabled,
    required this.inboundAction,
    required this.outboundAction,
    required this.source,
    required this.checkedAtUtc,
    required this.limitations,
  });

  factory FirewallProfileInfo.fromJson(Map<String, dynamic> json) {
    return FirewallProfileInfo(
      profileName: json['ProfileName'] as String? ?? '',
      status: ComponentStatus.fromString(json['Status'] as String?),
      isEnabled: json['IsEnabled'] as bool? ?? false,
      inboundAction: json['InboundAction'] as String? ?? 'Block',
      outboundAction: json['OutboundAction'] as String? ?? 'Allow',
      source: json['Source'] as String? ?? 'NetFwTypeLib',
      checkedAtUtc: json['CheckedAtUtc'] as String? ?? '',
      limitations: json['Limitations'] as String? ?? '',
    );
  }
}

class UacInfo {
  final ComponentStatus status;
  final bool isEnabled;
  final int consentPromptBehaviorAdmin;
  final bool promptOnSecureDesktop;
  final String summary;
  final String source;
  final String checkedAtUtc;
  final String limitations;

  UacInfo({
    required this.status,
    required this.isEnabled,
    required this.consentPromptBehaviorAdmin,
    required this.promptOnSecureDesktop,
    required this.summary,
    required this.source,
    required this.checkedAtUtc,
    required this.limitations,
  });

  factory UacInfo.fromJson(Map<String, dynamic> json) {
    return UacInfo(
      status: ComponentStatus.fromString(json['Status'] as String?),
      isEnabled: json['IsEnabled'] as bool? ?? false,
      consentPromptBehaviorAdmin: (json['ConsentPromptBehaviorAdmin'] as num?)?.toInt() ?? 5,
      promptOnSecureDesktop: json['PromptOnSecureDesktop'] as bool? ?? true,
      summary: json['Summary'] as String? ?? 'UAC Enabled',
      source: json['Source'] as String? ?? 'Registry',
      checkedAtUtc: json['CheckedAtUtc'] as String? ?? '',
      limitations: json['Limitations'] as String? ?? '',
    );
  }
}

class WindowsUpdateInfo {
  final ComponentStatus status;
  final bool isServiceRunning;
  final String serviceState;
  final String lastSearchSuccessDate;
  final String summary;
  final String source;
  final String checkedAtUtc;
  final String limitations;

  WindowsUpdateInfo({
    required this.status,
    required this.isServiceRunning,
    required this.serviceState,
    required this.lastSearchSuccessDate,
    required this.summary,
    required this.source,
    required this.checkedAtUtc,
    required this.limitations,
  });

  factory WindowsUpdateInfo.fromJson(Map<String, dynamic> json) {
    return WindowsUpdateInfo(
      status: ComponentStatus.fromString(json['Status'] as String?),
      isServiceRunning: json['IsServiceRunning'] as bool? ?? false,
      serviceState: json['ServiceState'] as String? ?? 'Unknown',
      lastSearchSuccessDate: json['LastSearchSuccessDate'] as String? ?? 'Unknown',
      summary: json['Summary'] as String? ?? '',
      source: json['Source'] as String? ?? 'Windows Update Service',
      checkedAtUtc: json['CheckedAtUtc'] as String? ?? '',
      limitations: json['Limitations'] as String? ?? '',
    );
  }
}

class SmartScreenInfo {
  final ComponentStatus status;
  final String settingValue;
  final String summary;
  final String source;
  final String checkedAtUtc;
  final String limitations;

  SmartScreenInfo({
    required this.status,
    required this.settingValue,
    required this.summary,
    required this.source,
    required this.checkedAtUtc,
    required this.limitations,
  });

  factory SmartScreenInfo.fromJson(Map<String, dynamic> json) {
    return SmartScreenInfo(
      status: ComponentStatus.fromString(json['Status'] as String?),
      settingValue: json['SettingValue'] as String? ?? 'Unknown',
      summary: json['Summary'] as String? ?? '',
      source: json['Source'] as String? ?? 'Registry',
      checkedAtUtc: json['CheckedAtUtc'] as String? ?? '',
      limitations: json['Limitations'] as String? ?? '',
    );
  }
}

class ProtectionPostureSnapshot {
  final List<AntivirusInfo> antivirusProviders;
  final List<FirewallProfileInfo> firewallProfiles;
  final UacInfo? uac;
  final WindowsUpdateInfo? windowsUpdate;
  final SmartScreenInfo? smartScreen;
  final String snapshotTimestampUtc;

  ProtectionPostureSnapshot({
    required this.antivirusProviders,
    required this.firewallProfiles,
    this.uac,
    this.windowsUpdate,
    this.smartScreen,
    required this.snapshotTimestampUtc,
  });

  factory ProtectionPostureSnapshot.fromJson(Map<String, dynamic> json) {
    return ProtectionPostureSnapshot(
      antivirusProviders: (json['AntivirusProviders'] as List?)
              ?.map((e) => AntivirusInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      firewallProfiles: (json['FirewallProfiles'] as List?)
              ?.map((e) => FirewallProfileInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      uac: json['Uac'] != null ? UacInfo.fromJson(Map<String, dynamic>.from(json['Uac'] as Map)) : null,
      windowsUpdate: json['WindowsUpdate'] != null
          ? WindowsUpdateInfo.fromJson(Map<String, dynamic>.from(json['WindowsUpdate'] as Map))
          : null,
      smartScreen: json['SmartScreen'] != null
          ? SmartScreenInfo.fromJson(Map<String, dynamic>.from(json['SmartScreen'] as Map))
          : null,
      snapshotTimestampUtc: json['SnapshotTimestampUtc'] as String? ?? '',
    );
  }
}

// Stage 3 Models
class DriveInfoItem {
  final String name;
  final String driveType;
  final int totalBytes;
  final int freeBytes;
  final bool isReady;

  DriveInfoItem({
    required this.name,
    required this.driveType,
    required this.totalBytes,
    required this.freeBytes,
    required this.isReady,
  });

  factory DriveInfoItem.fromJson(Map<String, dynamic> json) {
    return DriveInfoItem(
      name: json['Name'] as String? ?? '',
      driveType: json['DriveType'] as String? ?? 'Fixed',
      totalBytes: (json['TotalBytes'] as num?)?.toInt() ?? 0,
      freeBytes: (json['FreeBytes'] as num?)?.toInt() ?? 0,
      isReady: json['IsReady'] as bool? ?? false,
    );
  }
}

class DeviceInventorySnapshot {
  final String osVersion;
  final String machineName;
  final String manufacturer;
  final String model;
  final int processorCount;
  final int totalMemoryBytes;
  final List<DriveInfoItem> drives;
  final String snapshotTimestampUtc;

  DeviceInventorySnapshot({
    required this.osVersion,
    required this.machineName,
    required this.manufacturer,
    required this.model,
    required this.processorCount,
    required this.totalMemoryBytes,
    required this.drives,
    required this.snapshotTimestampUtc,
  });

  factory DeviceInventorySnapshot.fromJson(Map<String, dynamic> json) {
    return DeviceInventorySnapshot(
      osVersion: json['OsVersion'] as String? ?? '',
      machineName: json['MachineName'] as String? ?? '',
      manufacturer: json['Manufacturer'] as String? ?? 'Generic PC',
      model: json['Model'] as String? ?? 'Windows Device',
      processorCount: (json['ProcessorCount'] as num?)?.toInt() ?? 1,
      totalMemoryBytes: (json['TotalMemoryBytes'] as num?)?.toInt() ?? 0,
      drives: (json['Drives'] as List?)
              ?.map((e) => DriveInfoItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      snapshotTimestampUtc: json['SnapshotTimestampUtc'] as String? ?? '',
    );
  }
}

class ProcessItem {
  final int processId;
  final String processName;
  final String startTimeUtc;
  final String compositeKey;
  final String executablePath;
  final String publisher;
  final ComponentStatus publisherStatus;
  final int workingSetBytes;
  final double cpuPercent;
  final bool accessDenied;

  ProcessItem({
    required this.processId,
    required this.processName,
    required this.startTimeUtc,
    required this.compositeKey,
    required this.executablePath,
    required this.publisher,
    required this.publisherStatus,
    required this.workingSetBytes,
    required this.cpuPercent,
    required this.accessDenied,
  });

  factory ProcessItem.fromJson(Map<String, dynamic> json) {
    return ProcessItem(
      processId: (json['ProcessId'] as num?)?.toInt() ?? 0,
      processName: json['ProcessName'] as String? ?? '',
      startTimeUtc: json['StartTimeUtc'] as String? ?? '',
      compositeKey: json['CompositeKey'] as String? ?? '',
      executablePath: json['ExecutablePath'] as String? ?? '',
      publisher: json['Publisher'] as String? ?? 'Unverified Publisher',
      publisherStatus: ComponentStatus.fromString(json['PublisherStatus'] as String?),
      workingSetBytes: (json['WorkingSetBytes'] as num?)?.toInt() ?? 0,
      cpuPercent: (json['CpuPercent'] as num?)?.toDouble() ?? 0.0,
      accessDenied: json['AccessDenied'] as bool? ?? false,
    );
  }
}

class StartupItem {
  final String stableKey;
  final String displayName;
  final String executablePath;
  final String publisher;
  final String sourceLocation;
  final ComponentStatus status;

  StartupItem({
    required this.stableKey,
    required this.displayName,
    required this.executablePath,
    required this.publisher,
    required this.sourceLocation,
    required this.status,
  });

  factory StartupItem.fromJson(Map<String, dynamic> json) {
    return StartupItem(
      stableKey: json['StableKey'] as String? ?? '',
      displayName: json['DisplayName'] as String? ?? '',
      executablePath: json['ExecutablePath'] as String? ?? '',
      publisher: json['Publisher'] as String? ?? '',
      sourceLocation: json['SourceLocation'] as String? ?? '',
      status: ComponentStatus.fromString(json['Status'] as String?),
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
