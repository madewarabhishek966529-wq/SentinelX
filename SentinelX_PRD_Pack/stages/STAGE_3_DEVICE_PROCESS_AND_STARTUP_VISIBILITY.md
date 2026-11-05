# Stage 3 – Device, Process & Startup Visibility

## Outcome
Inspect device inventory, process metadata, supported startup entries and removable-device events.

## Frontend tasks
1. Build Device & Hardware inventory.
2. Show OS, manufacturer/model, CPU, memory, drives and adapters where available.
3. Build Process Manager table: name, PID, start time, publisher status, CPU and memory.
4. Add search, sorting, filters and detail drawer.
5. Build Startup Apps table with path, publisher, source and state.
6. Label unknown publisher as unverified, not malicious.
7. Build removable-device event timeline and filters.
8. Add loading, permission and partial-result states.
9. Keep process termination and startup modification out of initial release.

## Engine tasks
1. Enumerate device inventory using documented interfaces.
2. Minimize serial-number collection.
3. Enumerate processes and process start times.
4. Collect CPU/memory with documented definitions.
5. Retrieve executable path and signature/publisher status where permitted.
6. Track process start/exit events where feasible.
7. Enumerate supported Run registry keys and Startup folders.
8. Document startup coverage is not exhaustive.
9. Subscribe to removable-device notifications.
10. Handle access denied and process-exit races.
11. Do not terminate processes or modify startup entries.

## Integration
1. Paginate process/event lists.
2. Debounce search.
3. Handle PID reuse using start time.
4. Refresh device inventory on demand.
5. Avoid exposing unnecessary unique identifiers.

## Tests/exit
Test large process lists, PID reuse, inaccessible paths, publisher states, supported startup sources, USB attach/removal and standard-user permissions. Verify no process/startup modification occurs.
