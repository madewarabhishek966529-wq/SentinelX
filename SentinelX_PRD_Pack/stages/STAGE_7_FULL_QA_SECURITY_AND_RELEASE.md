# Stage 7 – Full QA, Security Validation & Release

## Outcome
A release candidate with accurate claims, safe permissions, privacy controls, documented limitations and working installer.

## Frontend completion
1. Audit every screen against PRDs.
2. Remove misleading placeholders/fake threat counts.
3. Verify enabled/disabled/unknown/unsupported/access-denied/error/stale states.
4. Verify keyboard navigation, focus, contrast and text scaling.
5. Verify charts include units, legends and timestamps.
6. Verify every button performs its advertised action.
7. Verify confirmation dialogs describe exact action/scope.
8. Verify notifications, export and clear-history workflows.

## Engine completion
1. Audit Windows API calls and permissions.
2. Audit IPC authentication/isolation/payload limits.
3. Audit network scope enforcement.
4. Audit path validation and reparse-point handling.
5. Audit file hashing and watcher disposal.
6. Audit event filtering and data minimization.
7. Audit SQLite migrations/retention/parameterized queries.
8. Audit log redaction, cancellation and retries.
9. Review dependency versions and licenses.

## Functional test matrix
- Protection: Defender/provider active/disabled/unavailable/unknown; firewall profiles separately; update/UAC states; unsupported APIs.
- Device/process/startup: inventory, process exit races, publisher states, startup sources, USB events and permissions.
- Network: Wi-Fi/Ethernet/VPN, opt-in discovery, private-scope validation, public-range rejection, rate limits and cancellation.
- File/events: baseline, modify/rename/delete, large files, access denied, symlink policy, event-log access.
- Reports: empty/partial/full reports, PDF/CSV/JSON, notification deduplication and retention.

## Security/privacy test matrix
1. IPC cannot be accessed remotely.
2. Malformed/oversized messages rejected.
3. Secrets not logged.
4. Path traversal rejected.
5. Reparse-point policy enforced.
6. Discovery cannot leave confirmed local scope.
7. No public-range scanning through UI or engine.
8. No packet payload or credential collection.
9. No hidden telemetry or unexpected outbound traffic.
10. No security control disabled/bypassed.
11. No automatic quarantine/deletion.
12. Data export/deletion works.
13. Dependency vulnerability/license review completed.

## Performance/reliability
- Measure cold/warm startup and idle CPU/RAM.
- Run event monitoring for 8 hours.
- Test file integrity on representative folders.
- Test event bursts and bounded queues.
- Test engine crash/restart and sleep/resume.
- Test database growth, retention, low disk and low memory.
- Check leaks, deadlocks and UI jank.

## Compatibility
Test supported Windows 10/11 builds, standard/admin accounts, Defender/provider availability, Wi-Fi/Ethernet/VPN, removable storage and restricted API permissions. Record OS build, versions, permission context, test ID and evidence.

## Installer/release
1. Build from clean environment.
2. Verify app/engine/runtime dependencies.
3. Test fresh install, upgrade, uninstall and reinstall.
4. Verify data retention choice.
5. Verify shortcuts, metadata and version.
6. Sign binaries where available.
7. Generate SHA-256 checksums.
8. Publish release notes, test results and known limitations.

## Exit criteria
No critical/high defects; no fake security claims; defensive boundaries verified; security/privacy/compatibility tests pass; installer lifecycle passes; docs and sign-offs complete.
