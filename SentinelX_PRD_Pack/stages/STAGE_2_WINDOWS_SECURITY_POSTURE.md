# Stage 2 – Windows Security Posture

## Outcome
Display real protection configuration and update status with source, timestamp and honest unknown/error states.

## Frontend tasks
1. Build Security Overview.
2. Build Protection Status detail page.
3. Add registered antivirus/provider status card.
4. Add separate Domain, Private and Public firewall cards.
5. Add Windows Update status where reliably available.
6. Add read-only UAC status.
7. Add SmartScreen status only if a reliable supported source exists.
8. Show source and last-checked time.
9. Add links to relevant Windows Security/settings pages.
10. Add refresh, stale and partial-result states.

## Engine tasks
1. Research supported Windows Security Center interfaces.
2. Read registered antivirus/provider status where supported.
3. Read firewall profile state through documented interfaces.
4. Read Windows Update status from reliable documented sources.
5. Read UAC configuration without changing it.
6. Read SmartScreen only where supported reliably.
7. Attach source, timestamp and permission state.
8. Throttle refresh and handle OS edition differences.
9. Never change or disable protections.

## Integration
1. Define typed protection contracts.
2. Render partial results if one provider is unavailable.
3. Explain each source and limitation.
4. Never map unknown to healthy.

## Tests/exit
Compare with Windows Security/configuration tools; test unavailable providers, disabled services, access denied and unsupported APIs. Verify no settings are modified. All displayed values must be traceable.
