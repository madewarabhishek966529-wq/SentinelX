# SentinelX – Personal Cybersecurity Center
## PRD Pack

This pack defines SentinelX as a defensive, local-first Windows security visibility and hygiene application for a user's own PC and explicitly authorized home network.

### Seven stages
1. Foundation, UX and security boundaries
2. Windows security posture
3. Device, process and startup visibility
4. Network awareness and authorized local discovery
5. File integrity and security alerts
6. Recommendations, reports and safe response tools
7. Full QA, security validation and release

### Suggested technology
- Flutter + Dart Windows desktop UI
- C# / .NET 10 native engine (verify installed SDK and compatibility)
- SQLite local database
- Riverpod, GoRouter, fl_chart
- Documented Windows APIs, Windows Event Log, WMI/CIM where appropriate
- Named pipes preferred for local IPC; alternatively authenticated loopback-only HTTP
- Inno Setup or equivalent installer

### Safety boundaries
- Defensive monitoring of the user's own Windows device and explicitly authorized local network only.
- No exploits, payloads, credential harvesting, keylogging, stealth, evasion, persistence, privilege escalation or security-control bypass.
- Never disable Defender, Firewall, UAC or SmartScreen.
- No packet payload capture, passwords, tokens, keystrokes or private communications.
- Network discovery is opt-in, scoped to a confirmed private subnet or user-entered local device, rate-limited and cancellable.
- Unknown does not mean malicious. Missing data does not mean secure.
- No automatic quarantine, deletion, process termination or security configuration changes in the initial release.
- Local-only storage by default; no hidden telemetry.

Read `MASTER_DEVELOPMENT_PROMPT.md`, then implement stages in numerical order. Update the traceability sheet and pass each stage's exit criteria before proceeding.
