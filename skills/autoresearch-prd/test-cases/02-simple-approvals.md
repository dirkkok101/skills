# Test Case: Approvals Queue

## Difficulty: Simple (single epic, small FR count, read-heavy module that delegates actions to other modules)

## Input — What the skill receives

```
Feature: Approvals Queue
Project: NxGN Identity Platform
Module Prefix: APPROVALS

Problem Context:
  Platform and org admins must navigate to separate module pages (Organizations →
  Members, Users → Pending) to find and act on pending approvals. No single view
  of all items awaiting attention, no badge count, no visibility of aging items.
  When SSO provisioning uses approval gating (provisioning_mode = Approval), new
  users get pending_member_requests rows requiring admin action — but no proactive
  signal.

Upstream: N/A (identified during PRD suite alignment review)
Discovery: PRD Suite Alignment Review
Scope: COMPREHENSIVE

Personas:
  - P1: Platform Admin — reviews and acts on pending approvals across all orgs
  - P2: Org Admin — reviews and acts on pending approvals within their org

Key Domain Concepts:
  - Single data source: pending_member_requests table (Organizations module)
  - Queue delegates to owning module endpoints (Users approve/reject)
  - Badge count on sidebar nav item
  - JWT tenant-scoped queries (no cross-org view)
  - Org switching via nxgn-data-filter header

Operations:
  Grid (paginated list), Action (approve/reject via owning module), Count (badge),
  Empty State, Sort, API endpoint, Portal nav integration

Dependencies: Organizations PRD, Users PRD, Portal PRD
```

## Expected Output — Files that should be generated

### Primary
- `docs/prd/approvals/prd.md`

## Ground Truth Location

```
~/nxgn.identity/main/docs/prd/approvals/prd.md
```

## Evaluation Checklist

### Structure (18 points)
- [ ] Metadata table with required fields
- [ ] Document History table
- [ ] Table of Contents
- [ ] Problem Statement with Impact list and Why now
- [ ] Goals section (4 items expected)
- [ ] Non-Goals section (6 items)
- [ ] Success Metrics table (3 rows)
- [ ] User Personas (P1, P2)
- [ ] Assumptions (numbered A1-A4)
- [ ] Constraints (numbered C1-C5)
- [ ] Risks table (5 rows)
- [ ] Open Questions table with resolution tracking
- [ ] Use Cases section (2 module-specific UCs)
- [ ] Functional Requirements (1 epic, 7 FRs)
- [ ] NFR section (5 NFRs)
- [ ] Integration Points
- [ ] MoSCoW Prioritisation with Dependency Graph
- [ ] Domain Validation with Coverage Matrix

### Pattern Compliance (12 points)
- [ ] FR IDs use FR-APPROVALS-* prefix
- [ ] NFR IDs use NFR-APPROVALS-* prefix
- [ ] FR IDs are descriptive (not sequential)
- [ ] FRs have user story format
- [ ] FRs have Given/When/Then criteria
- [ ] FRs have Priority and Complexity
- [ ] NFRs have measurable targets
- [ ] Assumptions numbered A1-An
- [ ] Constraints numbered C1-Cn
- [ ] No ambiguity words
- [ ] Error/edge case criteria present
- [ ] Personas referenced in user stories

### Content Quality (10 points)
- [ ] Delegated business logic pattern (queue delegates to owning module)
- [ ] Single data source pattern (pending_member_requests, not multiple tables)
- [ ] Badge count FR with graceful degradation (zero suppression, no badge on API failure)
- [ ] Empty state FR
- [ ] JWT tenant-scoping mentioned (no cross-org platform admin bypass)
- [ ] Cross-module dependency mapping in coverage matrix
- [ ] Rejection semantics addressed (OQ or explicit decision)
- [ ] SOC 2 audit trail mentioned in goals or criteria
- [ ] Portal nav integration as FR or integration point
- [ ] RLS boundary awareness in constraints
