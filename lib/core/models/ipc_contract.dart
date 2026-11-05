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
  final String status;
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

// Stage 4 Models
class NetworkAdapterInfo {
  final String id;
  final String name;
  final String description;
  final String operationalStatus;
  final String interfaceType;
  final String ipv4Address;
  final String subnetMask;
  final String gateway;
  final List<String> dnsServers;
  final int bytesReceived;
  final int bytesSent;
  final int rxBytesPerSec;
  final int txBytesPerSec;

  NetworkAdapterInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.operationalStatus,
    required this.interfaceType,
    required this.ipv4Address,
    required this.subnetMask,
    required this.gateway,
    required this.dnsServers,
    required this.bytesReceived,
    required this.bytesSent,
    required this.rxBytesPerSec,
    required this.txBytesPerSec,
  });

  factory NetworkAdapterInfo.fromJson(Map<String, dynamic> json) {
    return NetworkAdapterInfo(
      id: json['Id'] as String? ?? '',
      name: json['Name'] as String? ?? '',
      description: json['Description'] as String? ?? '',
      operationalStatus: json['OperationalStatus'] as String? ?? 'Unknown',
      interfaceType: json['InterfaceType'] as String? ?? '',
      ipv4Address: json['Ipv4Address'] as String? ?? 'Not assigned',
      subnetMask: json['SubnetMask'] as String? ?? '',
      gateway: json['Gateway'] as String? ?? 'None',
      dnsServers: (json['DnsServers'] as List?)?.map((e) => e.toString()).toList() ?? [],
      bytesReceived: (json['BytesReceived'] as num?)?.toInt() ?? 0,
      bytesSent: (json['BytesSent'] as num?)?.toInt() ?? 0,
      rxBytesPerSec: (json['RxBytesPerSec'] as num?)?.toInt() ?? 0,
      txBytesPerSec: (json['TxBytesPerSec'] as num?)?.toInt() ?? 0,
    );
  }
}

class LocalDeviceItem {
  final String ipAddress;
  final String hostname;
  final String macAddress;
  final String vendorHint;
  final String discoveryMethod;
  final ComponentStatus status;
  final String firstSeenUtc;
  final String lastSeenUtc;
  final String userLabel;

  LocalDeviceItem({
    required this.ipAddress,
    required this.hostname,
    required this.macAddress,
    required this.vendorHint,
    required this.discoveryMethod,
    required this.status,
    required this.firstSeenUtc,
    required this.lastSeenUtc,
    required this.userLabel,
  });

  factory LocalDeviceItem.fromJson(Map<String, dynamic> json) {
    return LocalDeviceItem(
      ipAddress: json['IpAddress'] as String? ?? '',
      hostname: json['Hostname'] as String? ?? 'Local Device',
      macAddress: json['MacAddress'] as String? ?? '',
      vendorHint: json['VendorHint'] as String? ?? '',
      discoveryMethod: json['DiscoveryMethod'] as String? ?? 'ARP',
      status: ComponentStatus.fromString(json['Status'] as String?),
      firstSeenUtc: json['FirstSeenUtc'] as String? ?? '',
      lastSeenUtc: json['LastSeenUtc'] as String? ?? '',
      userLabel: json['UserLabel'] as String? ?? '',
    );
  }
}

class NetworkActivitySnapshot {
  final List<NetworkAdapterInfo> adapters;
  final int totalRxBytesPerSec;
  final int totalTxBytesPerSec;
  final String snapshotTimestampUtc;

  NetworkActivitySnapshot({
    required this.adapters,
    required this.totalRxBytesPerSec,
    required this.totalTxBytesPerSec,
    required this.snapshotTimestampUtc,
  });

  factory NetworkActivitySnapshot.fromJson(Map<String, dynamic> json) {
    return NetworkActivitySnapshot(
      adapters: (json['Adapters'] as List?)
              ?.map((e) => NetworkAdapterInfo.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      totalRxBytesPerSec: (json['TotalRxBytesPerSec'] as num?)?.toInt() ?? 0,
      totalTxBytesPerSec: (json['TotalTxBytesPerSec'] as num?)?.toInt() ?? 0,
      snapshotTimestampUtc: json['SnapshotTimestampUtc'] as String? ?? '',
    );
  }
}

// Stage 5 Models
class FimTargetItem {
  final String targetId;
  final String canonicalPath;
  final String userLabel;
  final String baselineSha256;
  final String currentSha256;
  final int sizeBytes;
  final String createdAtUtc;
  final String lastCheckedUtc;
  final ComponentStatus status;
  final bool hasChanged;
  final String changeSummary;

  FimTargetItem({
    required this.targetId,
    required this.canonicalPath,
    required this.userLabel,
    required this.baselineSha256,
    required this.currentSha256,
    required this.sizeBytes,
    required this.createdAtUtc,
    required this.lastCheckedUtc,
    required this.status,
    required this.hasChanged,
    required this.changeSummary,
  });

  factory FimTargetItem.fromJson(Map<String, dynamic> json) {
    return FimTargetItem(
      targetId: json['TargetId'] as String? ?? '',
      canonicalPath: json['CanonicalPath'] as String? ?? '',
      userLabel: json['UserLabel'] as String? ?? '',
      baselineSha256: json['BaselineSha256'] as String? ?? '',
      currentSha256: json['CurrentSha256'] as String? ?? '',
      sizeBytes: (json['SizeBytes'] as num?)?.toInt() ?? 0,
      createdAtUtc: json['CreatedAtUtc'] as String? ?? '',
      lastCheckedUtc: json['LastCheckedUtc'] as String? ?? '',
      status: ComponentStatus.fromString(json['Status'] as String?),
      hasChanged: json['HasChanged'] as bool? ?? false,
      changeSummary: json['ChangeSummary'] as String? ?? '',
    );
  }
}

class FimChangeEvent {
  final String eventId;
  final String targetId;
  final String canonicalPath;
  final String changeType;
  final String oldHash;
  final String newHash;
  final String detectedAtUtc;
  final String severity;

  FimChangeEvent({
    required this.eventId,
    required this.targetId,
    required this.canonicalPath,
    required this.changeType,
    required this.oldHash,
    required this.newHash,
    required this.detectedAtUtc,
    required this.severity,
  });

  factory FimChangeEvent.fromJson(Map<String, dynamic> json) {
    return FimChangeEvent(
      eventId: json['EventId'] as String? ?? '',
      targetId: json['TargetId'] as String? ?? '',
      canonicalPath: json['CanonicalPath'] as String? ?? '',
      changeType: json['ChangeType'] as String? ?? 'Modified',
      oldHash: json['OldHash'] as String? ?? '',
      newHash: json['NewHash'] as String? ?? '',
      detectedAtUtc: json['DetectedAtUtc'] as String? ?? '',
      severity: json['Severity'] as String? ?? 'Warning',
    );
  }
}

class FimSnapshot {
  final List<FimTargetItem> targets;
  final List<FimChangeEvent> recentChanges;
  final bool isMonitoring;
  final String snapshotTimestampUtc;

  FimSnapshot({
    required this.targets,
    required this.recentChanges,
    required this.isMonitoring,
    required this.snapshotTimestampUtc,
  });

  factory FimSnapshot.fromJson(Map<String, dynamic> json) {
    return FimSnapshot(
      targets: (json['Targets'] as List?)
              ?.map((e) => FimTargetItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      recentChanges: (json['RecentChanges'] as List?)
              ?.map((e) => FimChangeEvent.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      isMonitoring: json['IsMonitoring'] as bool? ?? false,
      snapshotTimestampUtc: json['SnapshotTimestampUtc'] as String? ?? '',
    );
  }
}

class SecurityEventItem {
  final int recordId;
  final int eventId;
  final String channel;
  final String providerName;
  final String levelDisplayName;
  final String timestampUtc;
  final String message;
  final bool accessDenied;
  final ComponentStatus status;

  SecurityEventItem({
    required this.recordId,
    required this.eventId,
    required this.channel,
    required this.providerName,
    required this.levelDisplayName,
    required this.timestampUtc,
    required this.message,
    required this.accessDenied,
    required this.status,
  });

  factory SecurityEventItem.fromJson(Map<String, dynamic> json) {
    return SecurityEventItem(
      recordId: (json['RecordId'] as num?)?.toInt() ?? 0,
      eventId: (json['EventId'] as num?)?.toInt() ?? 0,
      channel: json['Channel'] as String? ?? '',
      providerName: json['ProviderName'] as String? ?? '',
      levelDisplayName: json['LevelDisplayName'] as String? ?? 'Information',
      timestampUtc: json['TimestampUtc'] as String? ?? '',
      message: json['Message'] as String? ?? '',
      accessDenied: json['AccessDenied'] as bool? ?? false,
      status: ComponentStatus.fromString(json['Status'] as String?),
    );
  }
}

class SecurityEventsSnapshot {
  final List<SecurityEventItem> events;
  final String channelSummary;
  final String snapshotTimestampUtc;

  SecurityEventsSnapshot({
    required this.events,
    required this.channelSummary,
    required this.snapshotTimestampUtc,
  });

  factory SecurityEventsSnapshot.fromJson(Map<String, dynamic> json) {
    return SecurityEventsSnapshot(
      events: (json['Events'] as List?)
              ?.map((e) => SecurityEventItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      channelSummary: json['ChannelSummary'] as String? ?? '',
      snapshotTimestampUtc: json['SnapshotTimestampUtc'] as String? ?? '',
    );
  }
}

// Stage 6 Models
class SecurityRecommendationItem {
  final String id;
  final String title;
  final String category;
  final String priority;
  final ComponentStatus status;
  final String evidence;
  final String source;
  final String timestampUtc;
  final String limitations;
  final String actionUri;
  final String actionLabel;

  SecurityRecommendationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    required this.status,
    required this.evidence,
    required this.source,
    required this.timestampUtc,
    required this.limitations,
    required this.actionUri,
    required this.actionLabel,
  });

  factory SecurityRecommendationItem.fromJson(Map<String, dynamic> json) {
    return SecurityRecommendationItem(
      id: json['Id'] as String? ?? '',
      title: json['Title'] as String? ?? '',
      category: json['Category'] as String? ?? 'Protection',
      priority: json['Priority'] as String? ?? 'Medium',
      status: ComponentStatus.fromString(json['Status'] as String?),
      evidence: json['Evidence'] as String? ?? '',
      source: json['Source'] as String? ?? '',
      timestampUtc: json['TimestampUtc'] as String? ?? '',
      limitations: json['Limitations'] as String? ?? '',
      actionUri: json['ActionUri'] as String? ?? '',
      actionLabel: json['ActionLabel'] as String? ?? 'Inspect',
    );
  }
}

class SystemReportData {
  final String reportId;
  final String generatedAtUtc;
  final String machineName;
  final String osVersion;
  final ProtectionPostureSnapshot? posture;
  final DeviceInventorySnapshot? inventory;
  final NetworkActivitySnapshot? network;
  final List<SecurityRecommendationItem> recommendations;
  final String completedChecksSummary;
  final String unavailableChecksSummary;
  final String disclaimer;

  SystemReportData({
    required this.reportId,
    required this.generatedAtUtc,
    required this.machineName,
    required this.osVersion,
    this.posture,
    this.inventory,
    this.network,
    this.recommendations = const [],
    required this.completedChecksSummary,
    required this.unavailableChecksSummary,
    required this.disclaimer,
  });

  factory SystemReportData.fromJson(Map<String, dynamic> json) {
    return SystemReportData(
      reportId: json['ReportId'] as String? ?? '',
      generatedAtUtc: json['GeneratedAtUtc'] as String? ?? '',
      machineName: json['MachineName'] as String? ?? '',
      osVersion: json['OsVersion'] as String? ?? '',
      posture: json['Posture'] != null
          ? ProtectionPostureSnapshot.fromJson(Map<String, dynamic>.from(json['Posture'] as Map))
          : null,
      inventory: json['Inventory'] != null
          ? DeviceInventorySnapshot.fromJson(Map<String, dynamic>.from(json['Inventory'] as Map))
          : null,
      network: json['Network'] != null
          ? NetworkActivitySnapshot.fromJson(Map<String, dynamic>.from(json['Network'] as Map))
          : null,
      recommendations: (json['Recommendations'] as List?)
              ?.map((e) => SecurityRecommendationItem.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      completedChecksSummary: json['CompletedChecksSummary'] as String? ?? '',
      unavailableChecksSummary: json['UnavailableChecksSummary'] as String? ?? '',
      disclaimer: json['Disclaimer'] as String? ?? '',
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
