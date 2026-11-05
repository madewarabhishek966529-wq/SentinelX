# SentinelX – Requirements Traceability Matrix

| ID | Requirement | Stage | UI Module | Engine Component | Test ID | Status | Evidence / Notes |
|---|---|---:|---|---|---|---|---|
| **SX-001** | Protection status has source and timestamp | 2 | ProtectionView | ProtectionService | PROT-001 | Not started | Source attribution & timestamp model planned in Stage 2 |
| **SX-002** | Unknown differs from enabled/disabled | 2 | StatusBadge | ComponentStatus | PROT-002 | Passed | 7 explicit states defined in Stage 1 contracts & verified by `widget_test.dart` and `ContractSerializationTests` |
| **SX-003** | Process inventory handles PID reuse | 3 | ProcessTable | ProcessInspector | PROC-001 | Not started | StartTime + PID composite key planned in Stage 3 |
| **SX-004** | Startup coverage is documented as partial | 3 | StartupView | StartupEnumerator | START-001 | Implemented | Explicit partial coverage notice rendered on Startup screen |
| **SX-005** | Discovery requires opt-in and scope confirmation | 4 | NetworkDiscovery | DiscoveryEngine | NET-001 | Implemented | Opt-in toggle & subnet validation banner rendered on Network Devices screen |
| **SX-006** | Discovery rejects public ranges | 4 | NetworkDiscovery | SubnetValidator | NET-002 | Not started | RFC 1918 / 3927 validation planned in Stage 4 |
| **SX-007** | Integrity watches user-selected paths only | 5 | FileIntegrityView | FimWatcher | FILE-001 | Implemented | Explicit target list only; OS root excluded by default |
| **SX-008** | File contents are not stored/uploaded | 5 | FileIntegrityView | Sha256Hasher | PRIV-001 | Implemented | Streaming hash only; zero raw content storage |
| **SX-009** | Recommendations include evidence/limitations | 6 | RecommendationsView | RecommendationEngine | REC-001 | Implemented | Deterministic rule cards with limitation callouts rendered |
| **SX-010** | Reports list unavailable checks and scope | 6 | ReportsView | ReportGenerator | REP-001 | Implemented | Negative check inventory included in export schemas & audit disclosure |
| **SX-011** | IPC is local and protected | 1 | IpcClient | IpcServer | SEC-001 | Passed | Loopback 127.0.0.1, token auth, size limits, handshake. Tested by `SecurityBoundaryTests` & `HealthHandshakeTests` |
| **SX-012** | No prohibited offensive/stealth functionality | 1 | Architecture | Engine | SEC-002 | Passed | Documented boundaries & threat model in `docs/THREAT_MODEL_AND_DEFENSIVE_BOUNDARIES.md` |
| **SX-013** | Design system: dark graphite, clear typography, no fake scores | 1 | Theme / Shell | N/A | UX-001 | Passed | Dark graphite theme, Material 3, honest states. Verified by `widget_test.dart` |
| **SX-014** | Responsive shell & 12 navigation modules | 1 | Shell / Router | N/A | UX-002 | Passed | GoRouter + ShellRoute with all 12 modules. Built & verified on Windows desktop |
| **SX-015** | Graceful engine lifecycle & reconnection | 1 | EngineProvider | LifecycleManager | INT-001 | Passed | Bounded reconnect backoff, timeout, clean teardown. Verified in `IpcServer` |

*Status options: Not started / In progress / Blocked / Implemented / Passed / Failed / Deferred*
