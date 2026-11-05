using System;
using System.Collections.Generic;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class FimService
    {
        private readonly StructuredLogger _logger;
        private readonly string _storagePath;
        private readonly List<FimTargetItem> _targets = new List<FimTargetItem>();
        private readonly List<FimChangeEvent> _recentChanges = new List<FimChangeEvent>();
        private readonly object _lock = new object();

        private static readonly HashSet<string> ExcludedPrefixes = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
        {
            @"C:\Windows\Temp",
            @"C:\Windows\Prefetch",
            @"C:\pagefile.sys",
            @"C:\swapfile.sys",
            @"C:\hiberfil.sys"
        };

        public FimService(StructuredLogger logger = null)
        {
            _logger = logger ?? new StructuredLogger(null, LogLevel.Info);
            string appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string dir = Path.Combine(appData, "SentinelX");
            Directory.CreateDirectory(dir);
            _storagePath = Path.Combine(dir, "fim_targets.json");

            LoadTargets();
        }

        public FimSnapshot GetSnapshot()
        {
            lock (_lock)
            {
                var snapshot = new FimSnapshot
                {
                    IsMonitoring = true,
                    SnapshotTimestampUtc = DateTime.UtcNow.ToString("o")
                };

                foreach (var t in _targets)
                {
                    snapshot.Targets.Add(CloneTarget(t));
                }

                foreach (var c in _recentChanges)
                {
                    snapshot.RecentChanges.Add(c);
                }

                return snapshot;
            }
        }

        public FimTargetItem AddTarget(string filePath, string label = null)
        {
            if (string.IsNullOrWhiteSpace(filePath))
            {
                throw new ArgumentException("File path cannot be empty", nameof(filePath));
            }

            string canonicalPath = Path.GetFullPath(filePath);

            // PRD Safety: Reject volatile OS directories & reparse loops
            foreach (var prefix in ExcludedPrefixes)
            {
                if (canonicalPath.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException("Path is in an excluded volatile OS directory: " + prefix);
                }
            }

            if (!File.Exists(canonicalPath))
            {
                throw new FileNotFoundException("Target file does not exist: " + canonicalPath);
            }

            // Check if file is a symlink / reparse point
            var attr = File.GetAttributes(canonicalPath);
            if ((attr & FileAttributes.ReparsePoint) != 0)
            {
                _logger.Warning("Target path is a reparse point: " + canonicalPath, "FimService");
            }

            string hash = ComputeSha256(canonicalPath);
            var fi = new FileInfo(canonicalPath);

            lock (_lock)
            {
                // Check if already monitored
                var existing = _targets.Find(t => string.Equals(t.CanonicalPath, canonicalPath, StringComparison.OrdinalIgnoreCase));
                if (existing != null)
                {
                    return existing;
                }

                var item = new FimTargetItem
                {
                    TargetId = Guid.NewGuid().ToString("N"),
                    CanonicalPath = canonicalPath,
                    UserLabel = string.IsNullOrWhiteSpace(label) ? Path.GetFileName(canonicalPath) : label,
                    BaselineSha256 = hash,
                    CurrentSha256 = hash,
                    SizeBytes = fi.Length,
                    CreatedAtUtc = DateTime.UtcNow.ToString("o"),
                    LastCheckedUtc = DateTime.UtcNow.ToString("o"),
                    Status = ComponentStatus.Enabled.ToString(),
                    HasChanged = false,
                    ChangeSummary = "Baseline created. Hashes match."
                };

                _targets.Add(item);
                SaveTargets();

                _recentChanges.Insert(0, new FimChangeEvent
                {
                    EventId = Guid.NewGuid().ToString("N"),
                    TargetId = item.TargetId,
                    CanonicalPath = item.CanonicalPath,
                    ChangeType = "Created",
                    OldHash = "",
                    NewHash = hash,
                    DetectedAtUtc = DateTime.UtcNow.ToString("o"),
                    Severity = "Info"
                });

                return item;
            }
        }

        public bool RemoveTarget(string targetId)
        {
            lock (_lock)
            {
                int index = _targets.FindIndex(t => string.Equals(t.TargetId, targetId, StringComparison.OrdinalIgnoreCase));
                if (index >= 0)
                {
                    _targets.RemoveAt(index);
                    SaveTargets();
                    return true;
                }
                return false;
            }
        }

        public FimTargetItem VerifyTarget(string targetId)
        {
            lock (_lock)
            {
                var target = _targets.Find(t => string.Equals(t.TargetId, targetId, StringComparison.OrdinalIgnoreCase));
                if (target == null)
                {
                    throw new KeyNotFoundException("Target ID not found: " + targetId);
                }

                target.LastCheckedUtc = DateTime.UtcNow.ToString("o");

                if (!File.Exists(target.CanonicalPath))
                {
                    target.Status = ComponentStatus.Disabled.ToString();
                    target.HasChanged = true;
                    target.CurrentSha256 = "FILE_MISSING";
                    target.ChangeSummary = "Target file has been deleted or moved.";

                    _recentChanges.Insert(0, new FimChangeEvent
                    {
                        EventId = Guid.NewGuid().ToString("N"),
                        TargetId = target.TargetId,
                        CanonicalPath = target.CanonicalPath,
                        ChangeType = "Deleted",
                        OldHash = target.BaselineSha256,
                        NewHash = "FILE_MISSING",
                        DetectedAtUtc = DateTime.UtcNow.ToString("o"),
                        Severity = "Critical"
                    });

                    SaveTargets();
                    return target;
                }

                try
                {
                    string currentHash = ComputeSha256(target.CanonicalPath);
                    var fi = new FileInfo(target.CanonicalPath);
                    target.SizeBytes = fi.Length;
                    target.CurrentSha256 = currentHash;

                    if (string.Equals(currentHash, target.BaselineSha256, StringComparison.OrdinalIgnoreCase))
                    {
                        target.Status = ComponentStatus.Enabled.ToString();
                        target.HasChanged = false;
                        target.ChangeSummary = "Integrity verified. Matches baseline hash.";
                    }
                    else
                    {
                        target.Status = ComponentStatus.Unknown.ToString();
                        target.HasChanged = true;
                        target.ChangeSummary = "Hash mismatch detected! Content modified.";

                        _recentChanges.Insert(0, new FimChangeEvent
                        {
                            EventId = Guid.NewGuid().ToString("N"),
                            TargetId = target.TargetId,
                            CanonicalPath = target.CanonicalPath,
                            ChangeType = "Modified",
                            OldHash = target.BaselineSha256,
                            NewHash = currentHash,
                            DetectedAtUtc = DateTime.UtcNow.ToString("o"),
                            Severity = "Warning"
                        });
                    }
                }
                catch (UnauthorizedAccessException)
                {
                    target.Status = ComponentStatus.AccessDenied.ToString();
                    target.ChangeSummary = "Access denied when attempting to verify file.";
                }
                catch (Exception ex)
                {
                    target.Status = ComponentStatus.Error.ToString();
                    target.ChangeSummary = "Verification error: " + ex.Message;
                }

                SaveTargets();
                return target;
            }
        }

        public FimTargetItem ResetBaseline(string targetId)
        {
            lock (_lock)
            {
                var target = _targets.Find(t => string.Equals(t.TargetId, targetId, StringComparison.OrdinalIgnoreCase));
                if (target == null)
                {
                    throw new KeyNotFoundException("Target ID not found: " + targetId);
                }

                if (!File.Exists(target.CanonicalPath))
                {
                    throw new FileNotFoundException("Cannot reset baseline; file does not exist: " + target.CanonicalPath);
                }

                string hash = ComputeSha256(target.CanonicalPath);
                target.BaselineSha256 = hash;
                target.CurrentSha256 = hash;
                target.Status = ComponentStatus.Enabled.ToString();
                target.HasChanged = false;
                target.ChangeSummary = "Baseline updated and re-verified.";
                target.LastCheckedUtc = DateTime.UtcNow.ToString("o");

                _recentChanges.Insert(0, new FimChangeEvent
                {
                    EventId = Guid.NewGuid().ToString("N"),
                    TargetId = target.TargetId,
                    CanonicalPath = target.CanonicalPath,
                    ChangeType = "ResetBaseline",
                    OldHash = target.BaselineSha256,
                    NewHash = hash,
                    DetectedAtUtc = DateTime.UtcNow.ToString("o"),
                    Severity = "Info"
                });

                SaveTargets();
                return target;
            }
        }

        public static string ComputeSha256(string filePath)
        {
            using (var stream = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            using (var sha = SHA256.Create())
            {
                byte[] hashBytes = sha.ComputeHash(stream);
                var sb = new StringBuilder(hashBytes.Length * 2);
                for (int i = 0; i < hashBytes.Length; i++)
                {
                    sb.Append(hashBytes[i].ToString("x2"));
                }
                return sb.ToString();
            }
        }

        private void LoadTargets()
        {
            try
            {
                if (File.Exists(_storagePath))
                {
                    string json = File.ReadAllText(_storagePath);
                    var list = JsonHelper.Deserialize<List<FimTargetItem>>(json);
                    if (list != null)
                    {
                        _targets.AddRange(list);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("Failed to load FIM targets: " + ex.Message, "FimService");
            }
        }

        private void SaveTargets()
        {
            try
            {
                string json = JsonHelper.Serialize(_targets);
                File.WriteAllText(_storagePath, json);
            }
            catch (Exception ex)
            {
                _logger.Error("Failed to save FIM targets: " + ex.Message, ex, "FimService");
            }
        }

        private static FimTargetItem CloneTarget(FimTargetItem src)
        {
            return new FimTargetItem
            {
                TargetId = src.TargetId,
                CanonicalPath = src.CanonicalPath,
                UserLabel = src.UserLabel,
                BaselineSha256 = src.BaselineSha256,
                CurrentSha256 = src.CurrentSha256,
                SizeBytes = src.SizeBytes,
                CreatedAtUtc = src.CreatedAtUtc,
                LastCheckedUtc = src.LastCheckedUtc,
                Status = src.Status,
                HasChanged = src.HasChanged,
                ChangeSummary = src.ChangeSummary
            };
        }
    }
}
