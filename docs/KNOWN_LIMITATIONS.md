# SentinelX – Known Limitations & Negative Scope Disclosure

This document explicitly details the intentional design boundaries, exclusions, and operational limitations of SentinelX in accordance with PRD requirements **SX-008**, **SX-010**, and **SX-012**.

---

## 1. Intentional Defensive Exclusions (By Design)

SentinelX is strictly a defensive visibility, posture auditing, and local alerting system. It does **not** include offensive capabilities or intrusive low-level hooks:

| Category | Excluded Capability | Rationale |
|---|---|---|
| **Malware Remediation** | Silent automatic file deletion or forced quarantine | To prevent accidental disruption or false-positive data loss. SentinelX notifies the user and provides native Windows Defender links. |
| **Process Control** | Unprompted process termination or thread injection | Modifying third-party address spaces violates defensive boundaries and causes system instability. |
| **Kernel Interception** | Kernel-mode drivers (EDR filter drivers, SSDT hooks) | SentinelX runs in user mode to guarantee host stability and avoid blue screens or driver conflicts. |
| **Packet Inspection** | Deep packet payload inspection, TLS interception, URL logging | Prohibited to protect user privacy and avoid proxy tampering. Throughput metrics are gathered strictly via interface counters. |
| **Network Probing** | Public internet port scanning, exploit payload delivery, banner grabbing | SentinelX hard-blocks any non-RFC 1918/3927 address ranges to prevent unauthorized remote scans. |
| **Persistence / Stealth** | Concealed execution, process hiding, service persistence, rootkit techniques | SentinelX operates transparently as a standard desktop application. |

---

## 2. Platform & Permission Limitations

### 2.1 Standard User (Least Privilege) vs Administrator
SentinelX is designed to run safely under standard non-administrative privileges. However, certain Windows security subsystems restrict standard user access:
- **Windows Security Event Log (`Security` channel)**: Reading the raw Security event log requires administrative elevation or membership in the *Event Log Readers* group. When executed under a standard user token, SentinelX honestly reports `AccessDenied` for this channel rather than failing or reporting false negatives.
- **WMI Antivirus Query (`ROOT\SecurityCenter2`)**: On certain enterprise-managed Windows installations, access to SecurityCenter2 namespaces may require elevation. SentinelX falls back to service query (`WinDefend`) when WMI access is restricted.
- **Digital Certificate Verification for System Folders**: Certain protected operating system directories require read permissions that are restricted to `TrustedInstaller`. Executables in these folders are reported with `Status = Unknown` or `AccessDenied`.

### 2.2 Startup Application Coverage
Startup apps are enumerated from:
- `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`
- `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`
- The user's `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup` directory.

**Exclusions**: Scheduled Tasks (`schtasks`), Windows Services, Active Setup, and Group Policy startup scripts are not enumerated in this version. The Startup screen explicitly notifies the user of this partial coverage.

### 2.3 Network Discovery Scope
- Discovery is limited to **IPv4 ARP cache interrogation** on the confirmed local private subnet (e.g. `192.168.1.0/24`).
- Devices configured with strict host firewalls that drop all ARP queries or that do not broadcast in the local ARP table may not appear in the discovery list.
- IPv6 neighbor discovery is deferred to future releases.

---

## 3. Mandatory Audit Disclaimer
> **SentinelX Posture Disclaimer**: SentinelX is a local-first defensive visibility and posture auditing tool. All reports and UI indicators represent point-in-time observational state of verifiable system configurations. SentinelX does not guarantee the absence of undiscovered vulnerabilities, zero-day exploits, or advanced persistent threats.

