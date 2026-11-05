# SentinelX – User Guide & Architecture Documentation

## 1. Introduction
**SentinelX** is a local-first, privacy-respecting Windows desktop cybersecurity center designed for Windows 10 and 11. It provides honest, explainable visibility into host security controls, processes, startup items, authorized network interfaces, file integrity baselines, and Windows security events.

SentinelX adheres to strict defensive boundaries:
- **Zero Telemetry**: All data stays on your machine.
- **No Exploits / No Stealth**: SentinelX does not perform offensive scanning, payload delivery, or bypass security tools.
- **Honest Semantic States**: 7 explicit states (`Enabled`, `Disabled`, `Unknown`, `Unsupported`, `AccessDenied`, `Error`, `Stale`). Missing data is never mapped to "safe", and arbitrary 0–100 scores are rejected.

---

## 2. System Architecture

```
┌────────────────────────────────────────────────────────┐
│           SentinelX Flutter Desktop UI (M3)           │
│   (State Management: Riverpod 3 | Navigation: GoRouter) │
└───────────────────────────▲────────────────────────────┘
                            │
               Loopback HTTP (127.0.0.1:58421)
               / Named Pipe IPC Transport
               (Session Token Auth Header)
                            │
┌───────────────────────────▼────────────────────────────┐
│              SentinelX.Engine (.NET 4.8)               │
│  - WindowsSecurityService (WMI SecurityCenter2, COM)   │
│  - DeviceProcessService (Win32, Authenticode, RunKeys) │
│  - NetworkService (IP Helper, RFC 1918/3927 Validator)  │
│  - FimService (Streaming SHA-256 Hasher)               │
│  - WindowsEventLogService (EventLogReader API)         │
│  - RecommendationService (Deterministic Rules Engine)  │
│  - ReportService (Markdown, CSV, JSON Exporters)       │
└────────────────────────────────────────────────────────┘
```

---

## 3. Core Modules & Usage

### 3.1 Security Overview
- High-level overview of active Windows security controls.
- Provides immediate status on Antivirus, Firewall profiles, and UAC without artificial gamified scores.

### 3.2 Protection Status
- Audits registered antivirus providers via Windows Security Center (`ROOT\SecurityCenter2:AntivirusProduct`).
- Inspects all 3 Windows Firewall profiles: **Domain**, **Private**, and **Public**.
- Checks User Account Control (UAC) elevation consent and secure desktop policies.
- Audits Windows Update agent readiness and SmartScreen status.

### 3.3 Device & Hardware Inventory
- Identifies OS build, CPU cores, physical RAM, and mounted storage drives.
- **Privacy Minimization**: Unique hardware serial numbers are not harvested.

### 3.4 Processes
- Safe process inventory with CPU and memory working set metrics.
- Uses composite keys (`PID_StartTimeUtc`) to eliminate PID-reuse race conditions.
- Verifies Authenticode digital signatures on running executables.

### 3.5 Startup Apps
- Audits registry Run keys (`HKLM` and `HKCU`) and the user Startup folder.
- Explicitly documents partial startup coverage.
- Validates publisher certificate signatures.

### 3.6 Network Activity
- Passive visibility into active network interfaces and IP configurations.
- Displays live receive (RX) and transmit (TX) throughput deltas.
- Prohibits packet payload sniffing and URL harvesting.

### 3.7 Network Devices (Authorized Discovery)
- **Disabled by default**: Requires explicit user opt-in.
- Strictly limited to confirmed private subnets (RFC 1918 / RFC 3927). Public IP scanning is hard-blocked.
- Benign ARP cache inspection for active subnet hosts. Allows user-friendly private labeling.

### 3.8 File Integrity Monitoring (FIM)
- Create cryptographic baselines for user-selected critical files (e.g. hosts, configs, scripts).
- Uses streaming SHA-256 hashing.
- File contents are never stored or uploaded.
- Detects modifications, deletions, and creations. Allows baseline re-baselining.

### 3.9 Windows Security Events
- Audits `System`, `Microsoft-Windows-Windows Defender/Operational`, and `Security` event logs.
- Displays structured event summaries with native Event IDs.
- Degrades gracefully if standard user lacks administrator privileges for the `Security` log.

### 3.10 Evidence-Based Recommendations
- Deterministic, rules-based actionable guidance.
- Every recommendation specifies Priority, Evidence, Authoritative Source, and Limitations.
- Provides direct deep-links to native Windows Settings panels (e.g. `ms-settings:windowsdefender`).

### 3.11 Reports & Export
- Generates point-in-time security audit reports in **Markdown (.md)**, **CSV (.csv)**, and **JSON (.json)**.
- Stored locally in `%LOCALAPPDATA%\SentinelX\Reports\`.
- Includes mandatory audit disclosure and technical disclaimer.

### 3.12 Settings & Diagnostics
- Real-time engine health diagnostics (PID, working set, latency, elevation state).
- Alert deduplication window configuration (1-hour anti-fatigue policy).
- History retention controls and one-click local history wipe.

---

## 4. Running & Building SentinelX

### Prerequisites
- Windows 10 (1809+) or Windows 11 (64-bit).
- Flutter SDK 3.13+ (or 3.47+).
- MSBuild / Visual Studio Build Tools with .NET Framework 4.8 targeting pack.

### Compiling Native Engine
```powershell
MSBuild SentinelX.sln /p:Configuration=Release /p:UseSharedCompilation=false
```

### Running Automated Test Suite
```powershell
.\SentinelX.Tests\bin\Release\SentinelX.Tests.exe
flutter test
```

### Building Release Desktop App
```powershell
flutter build windows --release
```
Release executable is generated at:
`build\windows\x64\runner\Release\sentinelx.exe`

