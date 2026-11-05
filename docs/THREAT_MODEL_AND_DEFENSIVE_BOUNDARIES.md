# Threat Model & Defensive Boundaries

## 1. System Mission & Boundaries
SentinelX is a defensive, local-first Windows security visibility and hygiene desktop application. Its mission is to consolidate security configuration status, process/hardware visibility, authorized network device awareness, and user-selected file integrity baselines.

### Prohibited Capabilities (Strictly Out of Scope)
- No exploit generation or payload execution.
- No credential harvesting, password dumping, or token theft.
- No keylogging, screen capturing, or covert surveillance.
- No persistence mechanisms (hidden registry keys, hidden scheduled tasks).
- No defense evasion, stealth, rootkit techniques, or antimalware disabling.
- No disabling or weakening of Windows Defender, Windows Firewall, UAC, or SmartScreen.
- No packet payload inspection, deep packet inspection (DPI), or reading of encrypted traffic.
- No automatic file deletion or process killing in initial releases.
- No scanning of public or unauthorized third-party networks.

## 2. Threat Analysis & Mitigations

| Threat | Risk Level | Mitigation Strategy |
|---|---|---|
| **Unauthorized IPC Access** | High | Bind strictly to `127.0.0.1` and Windows Named Pipes; require cryptographically random per-session token stored in `%LOCALAPPDATA%` with current-user ACL; reject non-loopback IP packets. |
| **Malformed / Denial of Service IPC Payloads** | Medium | Strict payload size limit (max 1 MB); JSON schema parsing with validation; explicit request timeouts (default 5s) and cancellation token support. |
| **Path Traversal / Reparse Point Abuse** | High | Canonicalize file paths (`Path.GetFullPath`); prevent directory traversal (`..`); deny monitoring of sensitive Windows OS directories by default; verify symlink targets. |
| **Misleading Security Claims (False Sense of Security)** | High | Forbid arbitrary 0-100 scores; status must be one of 7 explicit states (`Enabled`, `Disabled`, `Unknown`, `Unsupported`, `AccessDenied`, `Error`, `Stale`); provide clear source attribution and last-checked timestamps. |
| **Unauthorized Network Scanning** | High | Local discovery is strictly **OFF** by default; requires explicit user opt-in and subnet confirmation; rejects public IP addresses (RFC 1918 / RFC 3927 validation only); throttled rate limits; instant user cancellation. |
| **Data Privacy Leakage** | Medium | Compute SHA-256 locally; zero transmission or persistence of raw file contents; sanitize and redact structured logs; provide export and clear-history controls. |
| **Privilege Escalation** | High | Run as standard user; request elevation only at point of need with user explanation; avoid installing persistent system services without explicit user interaction. |

## 3. Honest Reporting Guidelines
- Label unverified executable publishers as **"Unverified publisher"**, never "Malicious".
- Label unknown devices discovered on the authorized home network as **"Unknown device"**, never "Intruder".
- Label modified monitored files as **"File changed"**, never "Infected".
- Label unavailable security checks as **"Check unavailable"**, never "System Secure".

