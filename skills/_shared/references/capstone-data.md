# Domain Reference: Data Platform (Capstone)

Load this reference when a feature involves data curation, modeling,
computed values, reporting, MCP integration, or analytics.

## Domain Checklist

### Data Modeling & Curation
- [ ] Model definition (entities, hierarchies, relationships)
- [ ] Computed values (formulas, dependencies, recalculation triggers)
- [ ] Data validation rules (type, range, cross-field)
- [ ] Data import (Excel, CSV, API ingestion)
- [ ] Data versioning / audit trail
- [ ] Multi-period data (time series, snapshots)

### Reporting & Visualization
- [ ] Report templates and layouts
- [ ] Dashboard configuration
- [ ] Chart types and rendering
- [ ] Export formats (PDF, Excel, CSV)
- [ ] Drill-down navigation
- [ ] Real-time vs. cached data

### MCP Integration
- [ ] MCP tool definitions (queries, mutations)
- [ ] Computed value retrieval via MCP
- [ ] Dashboard rendering via MCP
- [ ] Analysis workflow patterns
- [ ] Token/context management for MCP sessions

### Multi-Tenancy & Access
- [ ] Tenant-scoped data isolation
- [ ] Role-based report access
- [ ] Shared vs. tenant-specific models
- [ ] Data ownership and delegation

## Technical Patterns

_This section should be expanded as Capstone development produces learnings.
Use /compound with category `domain:capstone` to add patterns here._

### Computed Value Engine
- Dependency graph for recalculation ordering
- Caching strategy for expensive computations
- Change propagation when upstream values update

### Data Import Patterns
- Excel/CSV parsing with validation
- Preview → Validate → Confirm → Import workflow
- Error collection per row (don't fail batch on single row)
