using System;
using System.IO;
using System.Security.Cryptography;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Ipc
{
    public class SessionData
    {
        public int Port { get; set; }
        public string PipeName { get; set; }
        public string Token { get; set; }
        public int ProcessId { get; set; }
        public string ContractVersion { get; set; }
        public string StartedAtUtc { get; set; }
    }

    public class SessionManager : IDisposable
    {
        private readonly StructuredLogger _logger;
        private readonly string _sessionFilePath;
        public SessionData CurrentSession { get; private set; }

        public SessionManager(StructuredLogger logger, int port = ContractConstants.DefaultPort)
        {
            _logger = logger;
            var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            var sentinelDir = Path.Combine(localAppData, "SentinelX");
            if (!Directory.Exists(sentinelDir))
            {
                Directory.CreateDirectory(sentinelDir);
            }
            _sessionFilePath = Path.Combine(sentinelDir, "session.json");

            CurrentSession = new SessionData
            {
                Port = port,
                PipeName = ContractConstants.PipeName,
                Token = GenerateSecureToken(32),
                ProcessId = System.Diagnostics.Process.GetCurrentProcess().Id,
                ContractVersion = ContractConstants.CurrentVersion,
                StartedAtUtc = DateTime.UtcNow.ToString("o")
            };
        }

        public void SaveSession()
        {
            try
            {
                var json = JsonHelper.Serialize(CurrentSession);
                File.WriteAllText(_sessionFilePath, json);
                _logger.Info("IPC Session registered successfully at " + _sessionFilePath, "SessionManager");
            }
            catch (Exception ex)
            {
                _logger.Error("Failed to persist session metadata: " + ex.Message, ex, "SessionManager");
            }
        }

        private static string GenerateSecureToken(int length)
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                var bytes = new byte[length];
                rng.GetBytes(bytes);
                return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
            }
        }

        public void Dispose()
        {
            try
            {
                if (File.Exists(_sessionFilePath))
                {
                    File.Delete(_sessionFilePath);
                    _logger.Info("Session metadata cleaned up", "SessionManager");
                }
            }
            catch
            {
                // Best effort cleanup
            }
        }
    }
}
