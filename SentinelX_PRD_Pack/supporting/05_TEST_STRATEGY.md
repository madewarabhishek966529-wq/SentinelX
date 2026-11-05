# Test Strategy

## Levels
1. Unit: status mapping, parsers, validation, rules and hash utilities.
2. Widget: Flutter states, tables, charts and accessibility.
3. Integration: Flutter↔engine IPC, engine↔Windows sources, engine↔SQLite.
4. Security: IPC isolation, path validation, network scope, redaction and privilege boundaries.
5. System: end-to-end journeys on real Windows machines.
6. Performance: idle overhead, polling, event bursts, hashing and long-run stability.
7. Installer: fresh install, upgrade, uninstall and reinstall.

## Test data
Use synthetic fixtures, dedicated test folders and only devices/networks controlled by the tester. Never use real secrets or personal files. Do not scan third-party networks.

## Evidence
Record test ID, requirement ID, app/engine version, Windows build, permission context, steps, expected/actual result, pass/fail, redacted evidence, tester and date.

## Severity
Critical: unsafe action, data loss, remote exposure or privacy leakage.
High: incorrect security status, scope escape or major core failure.
Medium: feature failure with workaround.
Low: cosmetic/minor usability issue.

## Release gate
No critical/high issue open. Deferred issues require owner, rationale, mitigation and release-owner approval.
