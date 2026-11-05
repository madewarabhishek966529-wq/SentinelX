# Stage 1 – Foundation, UX & Security Boundaries

## Outcome
Buildable Flutter Windows shell, C# engine skeleton, contracts, design system and documented defensive-use boundaries.

## Product/repository tasks
1. Create repository and branch strategy.
2. Verify Flutter Windows toolchain and .NET SDK.
3. Create app, engine, contracts, tests, installer and docs folders.
4. Add formatting, linting and CI build checks.
5. Record IPC and data ownership architecture decisions.
6. Record threat model and prohibited capabilities.

## Frontend tasks
1. Create Flutter Windows app and configure metadata/window size.
2. Define dark security design tokens and typography.
3. Build title bar and collapsible sidebar.
4. Add routes for all planned modules.
5. Build reusable status card, event row, data table and alert badge.
6. Build loading, empty, stale, unknown, unsupported and access-denied states.
7. Build Settings and About screens.
8. Add Riverpod providers and GoRouter.
9. Add keyboard navigation and focus states.
10. Ensure no fake security score or threat counter is displayed.

## Engine tasks
1. Create C# engine and contracts projects.
2. Add dependency injection and structured logging.
3. Define versioned request/response DTOs.
4. Implement health/version handshake.
5. Implement named-pipe or authenticated loopback IPC.
6. Add bounded payloads, timeout and cancellation.
7. Implement graceful shutdown and configuration validation.
8. Add unit test project.

## Integration tasks
1. Start engine from Flutter in development.
2. Display connected/disconnected/degraded status.
3. Add bounded reconnect/backoff.
4. Ensure app close does not orphan engine.
5. Handle incompatible contract versions.

## Tests and exit criteria
- Flutter and engine build.
- IPC handshake works; malformed requests rejected.
- All routes render without overflow.
- Engine unavailable state is clear.
- App closes cleanly.
- No fake security status appears.
