# Stage 5 – File Integrity & Security Alerts

## Outcome
Users create local hash baselines for selected files/folders and receive transparent change alerts.

## Frontend tasks
1. Build File Integrity page and target picker.
2. Explain local hashing and data collection.
3. Add baseline creation confirmation.
4. Show targets and last verification.
5. Show create/modify/delete/rename events.
6. Add event details and old/new hash where appropriate.
7. Add pause/resume/remove and baseline reset.
8. Build Security Events timeline with filters.
9. Add alert preferences and deduplication view.

## Engine tasks
1. Implement streaming SHA-256.
2. Monitor user-selected roots only.
3. Exclude OS/application directories by default.
4. Define safe symlink/reparse-point policy.
5. Use filesystem notifications with periodic verification fallback.
6. Record event types and timestamps.
7. Revalidate file identity/path before reading.
8. Detect file changes during hashing.
9. Never store or upload file contents.
10. Add bounded queues and cancellation.
11. No automatic deletion/quarantine/remediation.

## Integration
1. Add baseline/event contracts.
2. Show monitoring and stale states.
3. Handle inaccessible paths and removed drives.
4. Support target removal and baseline reset.
5. Keep history local and user-controlled.

## Tests/exit
Test file modification, rename, deletion, large files, access denied, changed-during-hash, symlinks, removed drives, watcher fallback and alert deduplication. Verify file contents are not stored/uploaded.
