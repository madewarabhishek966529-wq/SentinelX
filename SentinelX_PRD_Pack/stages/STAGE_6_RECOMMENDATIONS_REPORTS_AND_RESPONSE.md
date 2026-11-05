# Stage 6 – Recommendations, Reports & Safe Response Tools

## Outcome
Turn evidence into explainable recommendations and exportable reports without automatically changing security settings.

## Frontend tasks
1. Build Recommendations page.
2. Show evidence, source, timestamp, impact and limitations.
3. Add priority/category filters.
4. Link safe next steps to Windows settings.
5. Build Reports page and date-range selector.
6. Add PDF, CSV and JSON export.
7. Add report preview and destination selection.
8. Build notification center and quiet-hour settings.
9. Add deduplication and dismiss controls.
10. State report scope and checks not performed.

## Logic tasks
1. Implement deterministic rules with evidence requirements.
2. Distinguish warning from confirmed detection.
3. Never infer malware from unknown publisher/path/device alone.
4. Examples: firewall profile off, provider status unavailable, monitored file changed, unexpected startup entry.
5. Provide user-guided next steps only.
6. Do not kill processes, quarantine/delete files, block IPs or disable protections automatically.
7. Generate reports from actual checks/events.
8. Include source, timestamps, unavailable checks and limitations.
9. Export documented CSV/JSON schemas and readable PDF.
10. Add notification deduplication and retention.

## Integration
1. Link each recommendation to supporting evidence.
2. Synchronize notifications and recommendation state.
3. Run exports off UI thread.
4. Show progress/errors and preview.

## Tests/exit
Test rules with fixtures and real data, unknown states, empty/partial reports, export formats, invalid paths, low disk and notification deduplication. Verify no automatic remediation.
