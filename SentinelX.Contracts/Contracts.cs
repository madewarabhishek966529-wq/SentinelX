using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace SentinelX.Contracts
{
    public static class ContractConstants
    {
        public const string CurrentVersion = "1.0.0";
        public const int DefaultPort = 58421;
        public const string PipeName = "SentinelX.Engine.Ipc";
        public const long MaxPayloadBytes = 1048576; // 1 MB limit
    }

    public enum ComponentStatus
    {
        Enabled,
        Disabled,
        Unknown,
        Unsupported,
        AccessDenied,
        Error,
        Stale
    }

    public class StatusSnapshot
    {
        public string ComponentKey { get; set; }
        public string Status { get; set; } // ComponentStatus string representation
        public string Source { get; set; }
        public string CheckedAtUtc { get; set; }
        public int FreshnessSeconds { get; set; }
        public string Limitations { get; set; }
        public Dictionary<string, object> Details { get; set; }

        public StatusSnapshot()
        {
            Details = new Dictionary<string, object>();
            CheckedAtUtc = DateTime.UtcNow.ToString("o");
            Status = ComponentStatus.Unknown.ToString();
        }
    }

    public class IpcError
    {
        public string ErrorCode { get; set; }
        public string SafeMessage { get; set; }
        public string DiagnosticId { get; set; }

        public IpcError() { }

        public IpcError(string errorCode, string safeMessage, string diagnosticId = null)
        {
            ErrorCode = errorCode;
            SafeMessage = safeMessage;
            DiagnosticId = diagnosticId ?? Guid.NewGuid().ToString("N");
        }
    }

    public class IpcRequest
    {
        public string ContractVersion { get; set; }
        public string RequestId { get; set; }
        public string Action { get; set; }
        public string TimestampUtc { get; set; }
        public Dictionary<string, object> Parameters { get; set; }

        public IpcRequest()
        {
            ContractVersion = ContractConstants.CurrentVersion;
            RequestId = Guid.NewGuid().ToString();
            TimestampUtc = DateTime.UtcNow.ToString("o");
            Parameters = new Dictionary<string, object>();
        }
    }

    public class IpcResponse<T>
    {
        public string ContractVersion { get; set; }
        public string RequestId { get; set; }
        public string TimestampUtc { get; set; }
        public string Status { get; set; } // "success", "error", "partial"
        public T Data { get; set; }
        public IpcError Error { get; set; }

        public IpcResponse()
        {
            ContractVersion = ContractConstants.CurrentVersion;
            TimestampUtc = DateTime.UtcNow.ToString("o");
            Status = "success";
        }

        public static IpcResponse<T> CreateSuccess(string requestId, T data)
        {
            return new IpcResponse<T>
            {
                RequestId = requestId,
                Status = "success",
                Data = data,
                Error = null
            };
        }

        public static IpcResponse<T> CreateError(string requestId, string errorCode, string safeMessage, string diagnosticId = null)
        {
            return new IpcResponse<T>
            {
                RequestId = requestId,
                Status = "error",
                Data = default(T),
                Error = new IpcError(errorCode, safeMessage, diagnosticId)
            };
        }
    }

    public class EngineHealthData
    {
        public string EngineVersion { get; set; }
        public string ContractVersion { get; set; }
        public int ProcessId { get; set; }
        public string StartedAtUtc { get; set; }
        public string OsVersion { get; set; }
        public bool IsElevated { get; set; }
        public string Status { get; set; } // "healthy", "degraded"
        public long MemoryBytes { get; set; }
        public List<string> SupportedActions { get; set; }

        public EngineHealthData()
        {
            SupportedActions = new List<string>();
        }
    }

    // ==========================================
    // STAGE 2: Protection Posture Contracts
    // ==========================================

    public class AntivirusInfo
    {
        public string DisplayName { get; set; }
        public string Status { get; set; }
        public bool IsActive { get; set; }
        public bool IsUpToDate { get; set; }
        public string ProductStateHex { get; set; }
        public string Source { get; set; }
        public string CheckedAtUtc { get; set; }
        public string Limitations { get; set; }
    }

    public class FirewallProfileInfo
    {
        public string ProfileName { get; set; }
        public string Status { get; set; }
        public bool IsEnabled { get; set; }
        public string InboundAction { get; set; }
        public string OutboundAction { get; set; }
        public string Source { get; set; }
        public string CheckedAtUtc { get; set; }
        public string Limitations { get; set; }
    }

    public class UacInfo
    {
        public string Status { get; set; }
        public bool IsEnabled { get; set; }
        public int ConsentPromptBehaviorAdmin { get; set; }
        public bool PromptOnSecureDesktop { get; set; }
        public string Summary { get; set; }
        public string Source { get; set; }
        public string CheckedAtUtc { get; set; }
        public string Limitations { get; set; }
    }

    public class WindowsUpdateInfo
    {
        public string Status { get; set; }
        public bool IsServiceRunning { get; set; }
        public string ServiceState { get; set; }
        public string LastSearchSuccessDate { get; set; }
        public string Summary { get; set; }
        public string Source { get; set; }
        public string CheckedAtUtc { get; set; }
        public string Limitations { get; set; }
    }

    public class SmartScreenInfo
    {
        public string Status { get; set; }
        public string SettingValue { get; set; }
        public string Summary { get; set; }
        public string Source { get; set; }
        public string CheckedAtUtc { get; set; }
        public string Limitations { get; set; }
    }

    public class ProtectionPostureSnapshot
    {
        public List<AntivirusInfo> AntivirusProviders { get; set; }
        public List<FirewallProfileInfo> FirewallProfiles { get; set; }
        public UacInfo Uac { get; set; }
        public WindowsUpdateInfo WindowsUpdate { get; set; }
        public SmartScreenInfo SmartScreen { get; set; }
        public string SnapshotTimestampUtc { get; set; }

        public ProtectionPostureSnapshot()
        {
            AntivirusProviders = new List<AntivirusInfo>();
            FirewallProfiles = new List<FirewallProfileInfo>();
            SnapshotTimestampUtc = DateTime.UtcNow.ToString("o");
        }
    }

    // ==========================================
    // STAGE 3: Device, Process & Startup Contracts
    // ==========================================

    public class DriveInfoItem
    {
        public string Name { get; set; }
        public string DriveType { get; set; }
        public long TotalBytes { get; set; }
        public long FreeBytes { get; set; }
        public bool IsReady { get; set; }
    }

    public class DeviceInventorySnapshot
    {
        public string OsVersion { get; set; }
        public string MachineName { get; set; }
        public string Manufacturer { get; set; }
        public string Model { get; set; }
        public int ProcessorCount { get; set; }
        public long TotalMemoryBytes { get; set; }
        public List<DriveInfoItem> Drives { get; set; }
        public string SnapshotTimestampUtc { get; set; }

        public DeviceInventorySnapshot()
        {
            Drives = new List<DriveInfoItem>();
            SnapshotTimestampUtc = DateTime.UtcNow.ToString("o");
        }
    }

    public class ProcessItem
    {
        public int ProcessId { get; set; }
        public string ProcessName { get; set; }
        public string StartTimeUtc { get; set; }
        public string CompositeKey { get; set; }
        public string ExecutablePath { get; set; }
        public string Publisher { get; set; }
        public string PublisherStatus { get; set; }
        public long WorkingSetBytes { get; set; }
        public double CpuPercent { get; set; }
        public bool AccessDenied { get; set; }
    }

    public class StartupItem
    {
        public string StableKey { get; set; }
        public string DisplayName { get; set; }
        public string ExecutablePath { get; set; }
        public string Publisher { get; set; }
        public string SourceLocation { get; set; }
        public string Status { get; set; }
    }

    // ==========================================
    // STAGE 4: Network Awareness & Discovery Contracts
    // ==========================================

    public class NetworkAdapterInfo
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string OperationalStatus { get; set; }
        public string InterfaceType { get; set; }
        public string Ipv4Address { get; set; }
        public string SubnetMask { get; set; }
        public string Gateway { get; set; }
        public List<string> DnsServers { get; set; }
        public long BytesReceived { get; set; }
        public long BytesSent { get; set; }
        public long RxBytesPerSec { get; set; }
        public long TxBytesPerSec { get; set; }

        public NetworkAdapterInfo()
        {
            DnsServers = new List<string>();
        }
    }

    public class LocalDeviceItem
    {
        public string IpAddress { get; set; }
        public string Hostname { get; set; }
        public string MacAddress { get; set; }
        public string VendorHint { get; set; }
        public string DiscoveryMethod { get; set; }
        public string Status { get; set; } // ComponentStatus
        public string FirstSeenUtc { get; set; }
        public string LastSeenUtc { get; set; }
        public string UserLabel { get; set; }
    }

    public class NetworkActivitySnapshot
    {
        public List<NetworkAdapterInfo> Adapters { get; set; }
        public long TotalRxBytesPerSec { get; set; }
        public long TotalTxBytesPerSec { get; set; }
        public string SnapshotTimestampUtc { get; set; }

        public NetworkActivitySnapshot()
        {
            Adapters = new List<NetworkAdapterInfo>();
            SnapshotTimestampUtc = DateTime.UtcNow.ToString("o");
        }
    }

    public static class JsonHelper
    {
        private static readonly JavaScriptSerializer Serializer = new JavaScriptSerializer
        {
            MaxJsonLength = int.MaxValue,
            RecursionLimit = 100
        };

        public static string Serialize(object obj)
        {
            if (obj == null) return "null";
            return Serializer.Serialize(obj);
        }

        public static T Deserialize<T>(string json)
        {
            if (string.IsNullOrEmpty(json)) return default(T);
            return Serializer.Deserialize<T>(json);
        }

        public static Dictionary<string, object> DeserializeMap(string json)
        {
            if (string.IsNullOrEmpty(json)) return new Dictionary<string, object>();
            return Serializer.Deserialize<Dictionary<string, object>>(json);
        }
    }
}
