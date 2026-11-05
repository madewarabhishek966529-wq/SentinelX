using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Management;
using System.Security.Cryptography.X509Certificates;
using Microsoft.Win32;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class DeviceProcessService
    {
        private readonly StructuredLogger _logger;

        public DeviceProcessService(StructuredLogger logger)
        {
            _logger = logger;
        }

        public DeviceInventorySnapshot GetDeviceInventory()
        {
            var snapshot = new DeviceInventorySnapshot
            {
                OsVersion = Environment.OSVersion.VersionString,
                MachineName = Environment.MachineName,
                ProcessorCount = Environment.ProcessorCount,
                Manufacturer = "Generic PC",
                Model = "Standard Windows Device",
                SnapshotTimestampUtc = DateTime.UtcNow.ToString("o")
            };

            // Query computer system manufacturer and model safely
            try
            {
                using (var searcher = new ManagementObjectSearcher("SELECT Manufacturer, Model, TotalPhysicalMemory FROM Win32_ComputerSystem"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        using (obj)
                        {
                            snapshot.Manufacturer = obj["Manufacturer"]?.ToString() ?? "Generic PC";
                            snapshot.Model = obj["Model"]?.ToString() ?? "Standard Windows Device";
                            if (obj["TotalPhysicalMemory"] != null)
                            {
                                long.TryParse(obj["TotalPhysicalMemory"].ToString(), out long totalMem);
                                snapshot.TotalMemoryBytes = totalMem;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("Win32_ComputerSystem WMI query warning: " + ex.Message, "DeviceProcessService");
            }

            // Enumerate logical drives
            try
            {
                foreach (var drive in DriveInfo.GetDrives())
                {
                    var item = new DriveInfoItem
                    {
                        Name = drive.Name,
                        DriveType = drive.DriveType.ToString(),
                        IsReady = drive.IsReady
                    };

                    if (drive.IsReady)
                    {
                        try
                        {
                            item.TotalBytes = drive.TotalSize;
                            item.FreeBytes = drive.AvailableFreeSpace;
                        }
                        catch { }
                    }

                    snapshot.Drives.Add(item);
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("DriveInfo enumeration warning: " + ex.Message, "DeviceProcessService");
            }

            return snapshot;
        }

        public List<ProcessItem> GetProcesses()
        {
            var items = new List<ProcessItem>();
            Process[] processes;

            try
            {
                processes = Process.GetProcesses();
            }
            catch (Exception ex)
            {
                _logger.Error("Failed to enumerate running processes", ex, "DeviceProcessService");
                return items;
            }

            foreach (var proc in processes)
            {
                using (proc)
                {
                    var item = new ProcessItem
                    {
                        ProcessId = proc.Id,
                        ProcessName = proc.ProcessName
                    };

                    // Handle StartTime and PID reuse composite key
                    DateTime startTime = DateTime.MinValue;
                    try
                    {
                        startTime = proc.StartTime.ToUniversalTime();
                        item.StartTimeUtc = startTime.ToString("o");
                        item.CompositeKey = string.Format("{0}_{1}", proc.Id, item.StartTimeUtc);
                    }
                    catch
                    {
                        // Access denied on system process (e.g. System, Idle) or process exited
                        item.StartTimeUtc = "Unknown (Protected or Exited)";
                        item.CompositeKey = string.Format("{0}_unknown", proc.Id);
                    }

                    // Handle Memory Working Set
                    try
                    {
                        item.WorkingSetBytes = proc.WorkingSet64;
                    }
                    catch { }

                    // Handle Module path and Authenticode Publisher Verification
                    try
                    {
                        var path = proc.MainModule?.FileName;
                        item.ExecutablePath = path ?? "Protected Process";

                        if (!string.IsNullOrEmpty(path) && File.Exists(path))
                        {
                            var certInfo = InspectFileSignature(path);
                            item.Publisher = certInfo.Publisher;
                            item.PublisherStatus = certInfo.Status.ToString();
                        }
                        else
                        {
                            item.Publisher = "Windows Protected / System";
                            item.PublisherStatus = ComponentStatus.Unknown.ToString();
                        }
                    }
                    catch
                    {
                        // Access denied for protected or elevated processes
                        item.AccessDenied = true;
                        item.ExecutablePath = "Access Denied (System/Protected)";
                        item.Publisher = "Unverified / Protected";
                        item.PublisherStatus = ComponentStatus.AccessDenied.ToString();
                    }

                    items.Add(item);
                }
            }

            return items;
        }

        public struct SignatureInspection
        {
            public string Publisher;
            public ComponentStatus Status;
        }

        public static SignatureInspection InspectFileSignature(string filePath)
        {
            try
            {
                // Check Authenticode certificate
                var cert = X509Certificate.CreateFromSignedFile(filePath);
                if (cert != null)
                {
                    using (cert)
                    {
                        var subject = cert.Subject;
                        var cn = ExtractCommonName(subject);
                        return new SignatureInspection
                        {
                            Publisher = cn ?? subject,
                            Status = ComponentStatus.Enabled
                        };
                    }
                }
            }
            catch
            {
                // File is not digitally signed or self-signed
            }

            // Fallback: File Version Info (company name)
            try
            {
                var fvi = FileVersionInfo.GetVersionInfo(filePath);
                if (!string.IsNullOrEmpty(fvi.CompanyName))
                {
                    return new SignatureInspection
                    {
                        Publisher = fvi.CompanyName + " (Unsigned Authenticode)",
                        Status = ComponentStatus.Unknown // Unverified publisher != malicious
                    };
                }
            }
            catch { }

            return new SignatureInspection
            {
                Publisher = "Unverified Publisher",
                Status = ComponentStatus.Unknown
            };
        }

        private static string ExtractCommonName(string subject)
        {
            if (string.IsNullOrEmpty(subject)) return null;
            var parts = subject.Split(',');
            foreach (var part in parts)
            {
                var trimmed = part.Trim();
                if (trimmed.StartsWith("CN=", StringComparison.OrdinalIgnoreCase))
                {
                    return trimmed.Substring(3);
                }
            }
            return null;
        }

        public List<StartupItem> GetStartupEntries()
        {
            var results = new List<StartupItem>();

            // 1. HKLM Run
            ReadRegistryRunEntries(Registry.LocalMachine, @"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "HKLM Run Key", results);

            // 2. HKCU Run
            ReadRegistryRunEntries(Registry.CurrentUser, @"SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "HKCU Run Key", results);

            // 3. User Startup Folder
            try
            {
                var startupFolder = Environment.GetFolderPath(Environment.SpecialFolder.Startup);
                if (Directory.Exists(startupFolder))
                {
                    foreach (var file in Directory.GetFiles(startupFolder))
                    {
                        var fileName = Path.GetFileName(file);
                        results.Add(new StartupItem
                        {
                            StableKey = "Folder_" + fileName,
                            DisplayName = fileName,
                            ExecutablePath = file,
                            Publisher = "Local Startup Item",
                            SourceLocation = "Startup Folder (shell:startup)",
                            Status = ComponentStatus.Enabled.ToString()
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.Warning("Startup folder read warning: " + ex.Message, "DeviceProcessService");
            }

            return results;
        }

        private static void ReadRegistryRunEntries(RegistryKey rootKey, string subKeyPath, string sourceLabel, List<StartupItem> results)
        {
            try
            {
                using (var key = rootKey.OpenSubKey(subKeyPath))
                {
                    if (key != null)
                    {
                        foreach (var name in key.GetValueNames())
                        {
                            var command = key.GetValue(name)?.ToString();
                            var cleanPath = command != null ? command.Trim('"').Split(new[] { ".exe" }, StringSplitOptions.None)[0] + ".exe" : "";
                            
                            string publisher = "Unverified Publisher";
                            ComponentStatus status = ComponentStatus.Unknown;

                            if (File.Exists(cleanPath))
                            {
                                var sig = InspectFileSignature(cleanPath);
                                publisher = sig.Publisher;
                                status = sig.Status;
                            }

                            results.Add(new StartupItem
                            {
                                StableKey = sourceLabel + "_" + name,
                                DisplayName = name,
                                ExecutablePath = command,
                                Publisher = publisher,
                                SourceLocation = sourceLabel,
                                Status = status.ToString()
                            });
                        }
                    }
                }
            }
            catch { }
        }
    }
}

