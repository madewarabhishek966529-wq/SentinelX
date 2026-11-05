# Architecture & Security PRD

## Components
- Flutter: presentation, navigation and user workflows.
- C# engine: Windows API access, event subscriptions and monitoring.
- Contracts: versioned DTOs and enums.
- SQLite: local history and settings.
- Installer: app/engine deployment and lifecycle.

## IPC
Prefer named pipes. If HTTP is used, bind only to 127.0.0.1, require a securely generated per-install secret, enforce payload limits/timeouts and never log secrets.

## Permissions
Standard user by default. Request elevation only at point of need, with explanation and consent. Never silently elevate or install hidden services/tasks.

## Windows integration
For every data source document API, permissions, supported OS versions, refresh interval, failure states and limitations.

## Security controls
Validate IPC inputs; normalize paths; prevent traversal; define reparse-point policy; use least privilege; parameterize SQL; redact logs; review dependencies/licenses; sign release binaries where practical.

## Privacy
Local-only default, no hidden telemetry, no packet payload capture, no credential/private communication collection. File contents are not stored; hashing is local. Provide retention/export/clear controls.

## Status semantics
Enabled, Disabled, Unknown, Unsupported, Access denied, Error, Stale. Never map missing data to safe.
