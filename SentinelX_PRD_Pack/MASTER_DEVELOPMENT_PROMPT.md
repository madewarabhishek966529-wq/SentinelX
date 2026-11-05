# MASTER DEVELOPMENT PROMPT – SENTINELX
## Personal Cybersecurity Center for Windows 10/11

Act as a senior Windows desktop engineer, Flutter developer, .NET engineer, security-minded architect and QA lead. Build SentinelX as a real working defensive security visibility application, not a mockup.

## Mission
Consolidate key Windows security status, device/process/startup changes, network activity, user-selected file integrity monitoring and evidence-based recommendations into one local-first desktop app. SentinelX is not antivirus, EDR, malware removal or proof that a computer is malware-free.

## Stack
- Frontend: Flutter + Dart, Material 3, Riverpod, GoRouter, fl_chart.
- Native engine: C# / .NET 10 after verifying SDK/runtime compatibility.
- Windows integration: documented Windows APIs, Windows Security Center interfaces where supported, WMI/CIM where appropriate, Windows Event Log and device notifications.
- Database: SQLite with migrations and parameterized queries.
- IPC: named pipes preferred; otherwise authenticated HTTP bound only to 127.0.0.1.
- Packaging: Inno Setup or equivalent.

## Mandatory safety boundaries
Only build defensive monitoring and safe administration for the user's own PC and explicitly authorized home network. Do not build exploits, payload delivery, credential theft, keylogging, covert surveillance, stealth, persistence, evasion, privilege escalation, security-control bypass, packet payload capture, arbitrary internet scanning or security-tool disabling. Do not disable Defender, Firewall, UAC or SmartScreen. Network discovery must be opt-in, private/local-scope validated, rate-limited and cancellable. Do not scan third-party networks. Do not automatically quarantine/delete files or kill processes. Do not claim an unknown item is malware. Store data locally by default and do not add hidden telemetry.

## UX
Create a premium professional desktop interface: dark graphite surfaces, restrained cyan/blue accent, clear typography, subtle animation and accessible contrast. Every finding must show source, timestamp, status, limitations and recommended next step. Status values must distinguish Enabled, Disabled, Unknown, Unsupported, Access denied, Error and Stale.

Sidebar:
1. Security Overview
2. Protection Status
3. Device & Hardware
4. Processes
5. Startup Apps
6. Network Activity
7. Network Devices
8. File Integrity
9. Security Events
10. Recommendations
11. Reports
12. Settings

## Functional modules

### 1. Security Overview
Show registered antivirus/provider status, firewall profile status (Domain/Private/Public), Windows Update status where reliably available, UAC status, SmartScreen/reputation status only if a supported source exists, recent security events, removable-device events, file-integrity alerts and recommendations. Use real data only. Never infer enabled from missing data.

### 2. Protection Status
Read Windows Security Center provider status where supported; read firewall profiles using documented interfaces; read update status from reliable documented sources; show UAC read-only. Include source and last-checked timestamp. Do not change or disable protections.

### 3. Device Inventory
Show OS version/build, manufacturer/model, CPU, memory, drives and network adapters where available. Minimize unique serial-number collection.

### 4. Process Visibility
Show process name, PID, start time, publisher/signature status where available, path where permitted, CPU and memory. Unknown/unsigned publisher means unverified, not malware. Do not inject into processes or terminate automatically. If a later user-confirmed end-process feature is added, revalidate PID and process start time.

### 5. Startup Applications
Inventory supported Run registry keys and Startup folders. Clearly state coverage is partial. Show name, path, publisher and source. Initial release is read-only. Any later disable feature must be reversible, backed up and confirmed.

### 6. Network Activity
Show adapters, local IP, gateway, DNS, interface throughput and active connection metadata where documented interfaces support it. Do not inspect packet payloads, credentials, URLs or private communications.

### 7. Authorized Local Network Discovery
Off by default. Explain and confirm scope. Accept only a validated private/local subnet or manually entered local device. Rate-limit, time out and support cancellation. Use benign discovery only. Optional TCP connect checks must be limited to a small documented set of common ports on a user-selected local device. No exploit checks, brute force, credential attempts or vulnerability exploitation. Unknown device is not malicious.

### 8. File Integrity
Only monitor user-selected files/folders. Create local SHA-256 baselines with consent. Use filesystem notifications with periodic verification fallback. Record create/modify/delete/rename events. Do not store or upload file contents. Exclude OS/application directories by default. Explain that a file change is not proof of malware. No automatic quarantine or deletion.

### 9. Security Events
Read selected Windows Event Log channels using documented access. Show event ID, source, timestamp and careful plain-language summary. Handle missing channels/access denied. Do not invent interpretations.

### 10. Recommendations
Rules-based and explainable initially. Every recommendation includes evidence, source, timestamp, impact, confidence/limitations and user-controlled next step. Do not label compromise without a trusted detection source. Never automatically change security settings.

### 11. Reports
Export PDF, CSV and JSON. Include device/OS summary, checks performed, sources, timestamps, findings, unavailable checks and limitations. Preview before saving. Avoid unnecessary identifiers.

### 12. Notifications and Settings
Configurable categories, thresholds and quiet hours; deduplicate alerts. Settings include retention, privacy, export/clear history, refresh intervals and engine diagnostics.

## Architecture
Create:
- `sentinelx_app/` Flutter UI
- `SentinelX.Engine/` C# Windows integration
- `SentinelX.Contracts/` versioned DTOs
- `SentinelX.Tests/` automated tests
- `installer/` packaging
- `docs/` architecture, user guide and limitations

UI must not directly call Windows APIs. Engine is independently testable. IPC responses include contractVersion, requestId, timestampUtc, status and structured error/data. Use bounded payloads, timeouts, cancellation, structured logs and graceful shutdown.

## Data
Use SQLite tables for security_checks, protection_status_snapshots, device_inventory, process_samples, process_events, startup_entries, network_interfaces, network_devices, file_integrity_targets, file_integrity_events, security_events, recommendations, notifications, app_settings and report_metadata. Use UTC timestamps, migrations, indexes, retention and parameterized SQL. Do not store passwords, tokens, packet payloads or file contents.

## Performance and reliability
All long tasks asynchronous and cancellable. Avoid UI blocking. Bound queues and history. Dispose watchers/handles. Handle engine disconnect/restart with bounded retry. Show stale data. Keep background overhead low.

## Development order
1. Foundation, UX and security boundaries.
2. Windows security posture.
3. Device, process and startup visibility.
4. Network awareness and authorized local discovery.
5. File integrity and security alerts.
6. Recommendations, reports and safe response tools.
7. Full QA, security validation, hardening and release.

Implement one stage at a time. Do not create placeholder modules and claim they work. Run tests, update docs and traceability after each stage.

## Required testing
Unit, widget, integration, permission, IPC, path-validation, network-scope, privacy/log-redaction, Windows compatibility, long-run stability and installer lifecycle tests. Test only owned devices and authorized networks. Never claim tests passed unless actually run.

## Deliverables
Working Flutter app, C# engine, contracts, SQLite schema/migrations, automated tests/results, architecture docs, user guide, known limitations, Windows installer, checksums and reproducible build instructions.

Start with Stage 1 only: inspect the environment, create repository structure and architecture decisions, then implement and test the foundation.
