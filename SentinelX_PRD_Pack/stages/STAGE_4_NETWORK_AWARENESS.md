# Stage 4 – Network Awareness & Authorized Local Discovery

## Outcome
Provide passive network visibility and optional, explicitly authorized home-network device discovery.

## Frontend tasks
1. Build Network Activity dashboard.
2. Show adapter, status, local IP, gateway and DNS where available.
3. Show upload/download rates and charts.
4. Show active connection metadata where supported.
5. Build Network Devices page.
6. Keep discovery disabled until user opts in.
7. Show scope confirmation before discovery.
8. Require confirmation of private subnet or manually entered local device.
9. Show progress, cancellation and summary.
10. Label unknown devices as unknown.
11. Allow user-assigned device labels and clear history.

## Engine tasks
1. Enumerate adapters and metadata.
2. Calculate byte rates using elapsed counter deltas.
3. Read local address/gateway/DNS where available.
4. Enumerate connection metadata using documented interfaces.
5. Never inspect packet payloads/private communications.
6. Implement opt-in local discovery.
7. Validate private/local scope and reject public ranges.
8. Enforce rate limits, timeouts and cancellation.
9. Use benign discovery only.
10. Optional TCP connect checks limited to a small documented common-port set on a user-selected local device.
11. No exploit checks, brute force, credential attempts or vulnerability exploitation.
12. Store only necessary metadata locally.

## Integration
1. Handle adapter changes without restart.
2. Display exact discovery scope and methods.
3. Prevent silent scope expansion.
4. Timestamp results and show uncertainty.

## Tests/exit
Test Wi-Fi/Ethernet/VPN/multiple adapters, disconnect/reconnect, invalid subnet, public-range rejection, opt-in, cancellation and rate limits. Verify no payload capture and no scope escape.
