# Data Model & Contracts PRD

## Suggested SQLite tables
- `security_checks`: check_key, status, source, checked_at_utc, details_json, error_code
- `protection_status_snapshots`: defender_status, firewall_domain/private/public, update_status, uac_status, timestamp_utc
- `device_inventory`: component_type, display_name, manufacturer, model, properties_json, first_seen_utc, last_seen_utc
- `process_samples`: timestamp_utc, process_id, process_start_time, process_name, publisher_status, cpu_percent, memory_bytes
- `process_events`: event_type, process_id, process_name, timestamp_utc, source
- `startup_entries`: stable_key, display_name, executable_path, publisher, source_location, enabled_state
- `network_interfaces`: interface_name, status, local_address, gateway, dns_json, rx_bytes, tx_bytes
- `network_devices`: address, display_name, vendor_hint, discovery_method, first_seen_utc, last_seen_utc, user_label
- `file_integrity_targets`: user_label, canonical_path, baseline_hash, hash_algorithm, created_at_utc, last_verified_utc
- `file_integrity_events`: target_id, event_type, old_hash, new_hash, timestamp_utc
- `security_events`: source, event_id, severity, timestamp_utc, summary, details_json
- `recommendations`, `notifications`, `app_settings`, `report_metadata`

## IPC response envelope
`contractVersion`, `requestId`, `timestampUtc`, `status`, `data` or `error`.

Error fields: `errorCode`, `safeMessage`, `diagnosticId`.

Every status object includes value/status, source, checkedAtUtc, freshness and optional limitations.

## Rules
- Distinguish false, true, unknown, unsupported and access denied.
- Never expose arbitrary commands for the UI to execute.
- Paginate large lists.
- Support cancellation.
- Validate enum values and payload sizes.
