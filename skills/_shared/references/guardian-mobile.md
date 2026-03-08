# Domain Reference: Mobile / EHS (Guardian)

Load this reference when a feature involves mobile applications, offline-first
patterns, field inspections, safety observations, or sync operations.

## Domain Checklist

### Offline-First
- [ ] Offline data storage (SQLite / IndexedDB)
- [ ] Sync strategy (queue-based, conflict resolution)
- [ ] Offline form submission and queuing
- [ ] Data freshness indicators
- [ ] Connectivity detection and recovery

### Inspections & Observations
- [ ] Inspection templates and checklists
- [ ] Observation capture (text, photo, GPS, timestamp)
- [ ] Severity classification
- [ ] Corrective action workflow
- [ ] Due date tracking and escalation

### Field Operations
- [ ] GPS location capture
- [ ] Camera/photo integration
- [ ] Barcode/QR scanning
- [ ] Signature capture
- [ ] Push notifications for field workers

### Sync & Conflict Resolution
- [ ] Upload queue management
- [ ] Conflict detection (server vs. local edits)
- [ ] Conflict resolution strategy (last-write-wins, manual merge)
- [ ] Attachment upload (photos, documents)
- [ ] Bandwidth-aware sync (compress, batch, retry)

### Compliance & Reporting
- [ ] Regulatory compliance checklists (MHSA, OHS Act)
- [ ] Incident reporting workflow
- [ ] Statistical safety reporting
- [ ] Audit trail for field actions

## Technical Patterns

_This section should be expanded as Guardian development produces learnings.
Use /compound with category `domain:guardian` to add patterns here._

### Mobile Framework Patterns
- Native bridge plugins for device features (camera, GPS, filesystem)
- Local database storage for offline data (SQLite or equivalent)
- Background sync service
- Platform-specific UI considerations (iOS vs. Android)

### Sync Patterns
- Queue-based upload with retry
- Optimistic local-first updates
- Server reconciliation on reconnect
- Attachment chunked upload for large files
