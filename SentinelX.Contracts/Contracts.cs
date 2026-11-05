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

