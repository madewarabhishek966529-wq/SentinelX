using System;
using System.IO;
using System.Text.RegularExpressions;

namespace SentinelX.Engine.Logging
{
    public enum LogLevel
    {
        Debug = 0,
        Info = 1,
        Warning = 2,
        Error = 3
    }

    public class StructuredLogger
    {
        private static readonly object FileLock = new object();
        private readonly string _logFilePath;
        private readonly LogLevel _minLevel;

        // Regex pattern to redact potential secrets like tokens, keys, passwords
        private static readonly Regex TokenRedactionRegex = new Regex(
            @"(?i)(token|secret|password|key|auth|bearer)[\s=:""']+\s*([a-zA-Z0-9_\-\.]{8,})",
            RegexOptions.Compiled);

        public StructuredLogger(string logDirectory = null, LogLevel minLevel = LogLevel.Info)
        {
            _minLevel = minLevel;
            try
            {
                if (string.IsNullOrEmpty(logDirectory))
                {
                    var localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
                    logDirectory = Path.Combine(localAppData, "SentinelX", "Logs");
                }

                if (!Directory.Exists(logDirectory))
                {
                    Directory.CreateDirectory(logDirectory);
                }

                _logFilePath = Path.Combine(logDirectory, "engine_" + DateTime.UtcNow.ToString("yyyyMMdd") + ".log");
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine("[LOGGER-INIT-ERROR] " + ex.Message);
            }
        }

        public void Debug(string message, string source = "Engine") => Log(LogLevel.Debug, message, source);
        public void Info(string message, string source = "Engine") => Log(LogLevel.Info, message, source);
        public void Warning(string message, string source = "Engine") => Log(LogLevel.Warning, message, source);
        public void Error(string message, Exception ex = null, string source = "Engine")
        {
            var formatted = ex != null ? message + " | Exception: " + ex.GetType().Name + ": " + ex.Message : message;
            Log(LogLevel.Error, formatted, source);
        }

        public string Redact(string input)
        {
            if (string.IsNullOrEmpty(input)) return input;
            return TokenRedactionRegex.Replace(input, "$1=[REDACTED]");
        }

        public void Log(LogLevel level, string message, string source)
        {
            if (level < _minLevel) return;

            var safeMessage = Redact(message);
            var timestamp = DateTime.UtcNow.ToString("o");
            var line = string.Format("[{0}] [{1}] [{2}] {3}", timestamp, level.ToString().ToUpperInvariant(), source, safeMessage);

            // Write to console
            var originalColor = Console.ForegroundColor;
            switch (level)
            {
                case LogLevel.Debug: Console.ForegroundColor = ConsoleColor.DarkGray; break;
                case LogLevel.Info: Console.ForegroundColor = ConsoleColor.Cyan; break;
                case LogLevel.Warning: Console.ForegroundColor = ConsoleColor.Yellow; break;
                case LogLevel.Error: Console.ForegroundColor = ConsoleColor.Red; break;
            }
            Console.WriteLine(line);
            Console.ForegroundColor = originalColor;

            // Write to file with rotation/safety
            if (!string.IsNullOrEmpty(_logFilePath))
            {
                try
                {
                    lock (FileLock)
                    {
                        File.AppendAllText(_logFilePath, line + Environment.NewLine);
                    }
                }
                catch
                {
                    // Logging failure should never crash the application
                }
            }
        }
    }
}
