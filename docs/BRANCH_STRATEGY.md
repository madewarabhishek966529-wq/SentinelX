# SentinelX – Repository & Branch Strategy

## Branch Hierarchy
- `main`: Production-ready, passing all QA gates, reproducible release builds only.
- `develop`: Integration branch for verified stage deliverables.
- `feature/stage-<N>-<name>`: Scoped development branches corresponding to the PRD Pack stages:
  - `feature/stage-1-foundation`
  - `feature/stage-2-windows-security-posture`
  - `feature/stage-3-device-process-startup`
  - `feature/stage-4-network-awareness`
  - `feature/stage-5-file-integrity-alerts`
  - `feature/stage-6-recommendations-reports`
  - `feature/stage-7-qa-security-release`

## Merge Requirements
1. Flutter analysis: `flutter analyze` must pass with 0 errors and 0 warnings.
2. Flutter unit/widget tests: `flutter test` must pass 100%.
3. C# Engine build: Roslyn/MSBuild compilation with zero warnings/errors.
4. C# Engine unit tests: All IPC contract, security boundary, and serialization tests must pass.
5. Traceability matrix: Updated in `docs/REQUIREMENTS_TRACEABILITY.md` before merging each stage.
6. Defensive boundaries check: No offensive capabilities, no fake metrics, no bypasses.
