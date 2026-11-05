# Threat Model

## Assets
Windows security status, local event history, file baselines/paths, IPC secret, network metadata and application binaries.

## Trust boundaries
1. Flutter UI ↔ engine IPC.
2. Engine ↔ Windows APIs/event sources.
3. Engine ↔ SQLite.
4. User-selected files ↔ integrity scanner.
5. App ↔ explicitly authorized local network devices.
6. Installer/update ↔ installed binaries.

## Threats and mitigations
- IPC abuse: named-pipe ACL or loopback authenticated IPC, schema validation, bounded payloads and timeouts.
- Path traversal/reparse points: canonicalize, enforce allowed roots, define symlink policy and revalidate.
- False security claims: explicit unknown/unsupported/access-denied states, source metadata and tests.
- Network misuse: opt-in, private scope validation, explicit preview, rate limits and cancellation.
- Data leakage: minimization, redaction, report preview and local-only default.
- Dependency risk: review, pin versions, vulnerability and license checks.
- Destructive operations: initial release read-only; no quarantine/delete.

## Explicitly out of scope
Credential theft, keylogging, stealth/persistence/evasion, exploitation, security-tool bypass and unauthorized remote scanning.
