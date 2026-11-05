using System;
using System.Collections.Generic;
using System.Diagnostics.Eventing.Reader;
using SentinelX.Contracts;
using SentinelX.Engine.Logging;

namespace SentinelX.Engine.Services
{
    public class WindowsEventLogService
    {
        private readonly StructuredLogger _logger;

        public WindowsEventLogService(StructuredLogger logger = null)
        {
            _logger = logger ?? new StructuredLogger(null, LogLevel.Info);
        }

        public SecurityEventsSnapshot GetSecurityEvents(int maxPerChannel = 30)
        {
            var snapshot = new SecurityEventsSnapshot();
            var channels = new[]
            {
                "System",
                "Microsoft-Windows-Windows Defender/Operational",
                "Security"
            };

            var channelStatuses = new List<string>();

            foreach (var channel in channels)
            {
                try
                {
                    var events = ReadChannelEvents(channel, maxPerChannel);
                    snapshot.Events.AddRange(events);
                    channelStatuses.Add(channel + ": " + events.Count + " events");
                }
                catch (UnauthorizedAccessException)
                {
                    _logger.Warning("Access denied reading channel: " + channel, "WindowsEventLogService");
                    channelStatuses.Add(channel + ": Access Denied (Standard user elevation required)");

                    snapshot.Events.Add(new SecurityEventItem
                    {
                        RecordId = 0,
                        EventId = 0,
                        Channel = channel,
                        ProviderName = "Windows Event Log Subsystem",
                        LevelDisplayName = "Warning",
                        TimestampUtc = DateTime.UtcNow.ToString("o"),
                        Message = "Access denied to channel '" + channel + "'. Reading requires administrative elevation.",
                        AccessDenied = true,
                        Status = ComponentStatus.AccessDenied.ToString()
                    });
                }
                catch (EventLogNotFoundException)
                {
                    channelStatuses.Add(channel + ": Log channel not found on this system");
                }
                catch (Exception ex)
                {
                    _logger.Warning("Error reading channel " + channel + ": " + ex.Message, "WindowsEventLogService");
                    channelStatuses.Add(channel + ": Error (" + ex.Message + ")");
                }
            }

            snapshot.ChannelSummary = string.Join(" | ", channelStatuses.ToArray());
            return snapshot;
        }

        private List<SecurityEventItem> ReadChannelEvents(string channelPath, int maxCount)
        {
            var list = new List<SecurityEventItem>();
            string query = "*";

            var logQuery = new EventLogQuery(channelPath, PathType.LogName, query)
            {
                ReverseDirection = true
            };

            using (var reader = new EventLogReader(logQuery))
            {
                EventRecord record;
                while ((record = reader.ReadEvent()) != null && list.Count < maxCount)
                {
                    using (record)
                    {
                        string levelStr = record.LevelDisplayName;
                        if (string.IsNullOrEmpty(levelStr))
                        {
                            switch (record.Level)
                            {
                                case 1: levelStr = "Critical"; break;
                                case 2: levelStr = "Error"; break;
                                case 3: levelStr = "Warning"; break;
                                case 4: levelStr = "Information"; break;
                                default: levelStr = "Information"; break;
                            }
                        }

                        string message = "";
                        try
                        {
                            message = record.FormatDescription();
                        }
                        catch
                        {
                            message = "Event " + record.Id + " from " + record.ProviderName;
                        }

                        if (string.IsNullOrEmpty(message))
                        {
                            message = "Event ID " + record.Id + " (No description available)";
                        }

                        // Truncate overly long descriptions
                        if (message.Length > 300)
                        {
                            message = message.Substring(0, 297) + "...";
                        }

                        var item = new SecurityEventItem
                        {
                            RecordId = record.RecordId.HasValue ? record.RecordId.Value : 0,
                            EventId = record.Id,
                            Channel = channelPath,
                            ProviderName = record.ProviderName ?? "Unknown",
                            LevelDisplayName = levelStr,
                            TimestampUtc = record.TimeCreated.HasValue ? record.TimeCreated.Value.ToUniversalTime().ToString("o") : DateTime.UtcNow.ToString("o"),
                            Message = message,
                            AccessDenied = false,
                            Status = ComponentStatus.Enabled.ToString()
                        };

                        list.Add(item);
                    }
                }
            }

            return list;
        }
    }
}
