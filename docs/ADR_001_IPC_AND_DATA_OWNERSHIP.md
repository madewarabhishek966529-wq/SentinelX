# Architecture Decision Record (ADR-001)
## IPC Protocol and Data Ownership Boundaries

### Status
Accepted

### Context
SentinelX is composed of two primary runtime processes on Windows:
1. **Frontend Presentation**: Flutter Windows desktop UI responsible for layout, visualization, user controls, and navigation.
2. **Native Engine**: C# Windows service/daemon responsible for Windows Security Center integration, event subscriptions, process inspection, local network inventory, and file integrity baselining.

The application must ensure:
- The UI never calls raw Windows APIs directly or performs privileged operations.
- Inter-Process Communication (IPC) is strictly confined to the local machine (`localhost` only, or Windows Named Pipes) with authentication and rate limiting.
- Data ownership is local-first: no data leaves the user's computer, no telemetry, and file contents are never collected or stored.

### Decisions

#### 1. IPC Transport
- **Primary Transport**: Authenticated loopback HTTP/REST service bound exclusively to `127.0.0.1` on an ephemeral/configured local port (default: `58421`) and Windows Named Pipe (`\\.\pipe\SentinelX.Engine.Ipc`).
- **Mutual Authentication**: Upon engine startup, a cryptographically secure random session token (32-byte hexadecimal GUID/token) is generated and saved to `%LOCALAPPDATA%\SentinelX\session.json` with user-only ACLs. The Flutter client reads this token from the user profile and includes it in an `X-SentinelX-Token` header for every request.
- **Remote Access Prevention**: The engine rejects any connection attempt not originating from loopback `127.0.0.1`.
- **Payload Boundaries**: Maximum request payload is enforced at 1 MB. Malformed JSON, unexpected properties, or missing request IDs are rejected immediately with structured errors.
- **Request Envelope**:
  ```json
  {
    "contractVersion": "1.0.0",
    "requestId": "uuid",
    "action": "action_name",
    "timestampUtc": "2026-11-05T16:00:00Z",
    "parameters": {}
  }
  ```
- **Response Envelope**:
  ```json
  {
    "contractVersion": "1.0.0",
    "requestId": "uuid",
    "timestampUtc": "2026-11-05T16:00:00Z",
    "status": "success",
    "data": {},
    "error": null
  }
  ```

#### 2. Data Ownership and Storage
- **Database**: Embedded SQLite database located in `%LOCALAPPDATA%\SentinelX\sentinelx.db`.
- **Ownership**: The C# Native Engine exclusively writes to SQLite using parameterized queries and versioned migrations. The Flutter UI accesses historical snapshots and reports via IPC requests.
- **Zero Content Storage**: File integrity monitoring computes and stores SHA-256 hashes only. File contents, packet payloads, keystrokes, and credentials are never stored, cached, or transmitted.
- **Retention Controls**: Configurable history retention (default 30 days) with explicit "Clear History" and "Export History" controls in Settings.

#### 3. Status Semantics
To avoid misleading users, every status reported by the engine adheres to an explicit 7-value enum:
1. `Enabled` (Green)
2. `Disabled` (Slate / Red when abnormal)
3. `Unknown` (Amber)
4. `Unsupported` (Gray)
5. `AccessDenied` (Rose)
6. `Error` (Red)
7. `Stale` (Stone)

Missing data is never mapped to "Safe" or "Enabled". No artificial 0-100 "Security Score" is computed.

### Consequences
- Clean separation of UI and low-level Windows APIs.
- Predictable, testable contracts between Flutter and C#.
- Complete defense-in-depth against remote access or unauthorized local processes.
