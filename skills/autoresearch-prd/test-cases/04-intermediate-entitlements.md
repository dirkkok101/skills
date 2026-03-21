# Test Case: Entitlements

## Difficulty: Intermediate (phase 1/2 scoping, imperative command pattern, fail-closed semantics, materialization triggers, status resolution business rules)

## Input — What the skill receives

```
Feature: Entitlements
Project: NxGN Identity Platform
Module Prefix: ENT

Problem Context:
  Identity needs a mechanism to control which applications an organization can access.
  Without entitlements, any application registered on the platform is available to every
  org — no ability to enable/disable access per org, no way to gate auth flows by
  entitlement status, no audit trail for entitlement changes.

Upstream: brainstorm exists
Discovery: N/A
Scope: COMPREHENSIVE

Personas:
  - P1: Platform Admin — enables/disables application access per org
  - P2: App Developer — integrates with entitlement check APIs
  - (P3: Org Admin deferred to v2)

Key Domain Concepts:
  - Entitlement: org-application pair (OrganizationApplicationEntitlements table)
  - Imperative commands: Enable/Disable (not upsert pattern)
  - Fail-closed: deny access when entitlement state cannot be determined
  - Core apps: auto-materialized on org creation (core apps always entitled)
  - Non-core apps: materialized on entitlement enable
  - Status resolution: Core > Platform Inactive > Enabled > Disabled > Not Entitled
  - Materialization triggers: core on org creation, non-core on entitlement
  - Phase 1: entitlement CRUD + UI
  - Phase 2: auth flow enforcement (gate login by entitlement status) — separate design

Operations:
  Enable, Disable, List, CoreAutoMaterialize, CoreMaterialize,
  PlatformOverride, AuthGate (Phase 2), RoleGate (Phase 2),
  Audit, Cache (Phase 2), AppGrid, AppEntitlementsList

Dependencies: Applications, Organizations, Role Templates, Redis

Epics:
  1. Entitlement Lifecycle (enable/disable/list/core materialization)
  2. Auth Flow Enforcement (Phase 2)
  3. Audit & Cache
  4. Entitlement Management UI
```

## Expected Output — Files that should be generated

### Primary
- `docs/prd/entitlements/prd.md`

## Ground Truth Location

```
~/nxgn.identity/main/docs/prd/entitlements/prd.md
```

## Evaluation Checklist

### Structure (18 points)
- [ ] Metadata table with Design reference field
- [ ] Document History (multiple entries with alignment notes)
- [ ] Table of Contents
- [ ] Problem Statement with Impact list
- [ ] Goals (5 items: G1-G5)
- [ ] Non-Goals (5 items: NG1-NG5)
- [ ] Success Metrics table
- [ ] User Personas (P1, P2; P3 deferred noted)
- [ ] Assumptions (A1-A8)
- [ ] Constraints (C1-C3)
- [ ] Risks table
- [ ] Open Questions with resolution tracking
- [ ] Use Cases (cross-cutting + module-specific)
- [ ] Functional Requirements across 4 Epics
- [ ] NFR section (4+ NFRs)
- [ ] Integration Points
- [ ] MoSCoW Prioritisation with Dependency Graph
- [ ] Domain Validation

### Pattern Compliance (12 points)
- [ ] FR IDs use FR-ENT-* prefix with sub-scopes (CORE-, AUTH-, APP-)
- [ ] NFR IDs use NFR-ENT-* prefix
- [ ] Descriptive IDs
- [ ] FRs have user story format
- [ ] Given/When/Then acceptance criteria
- [ ] Priority and Complexity
- [ ] NFRs with measurable targets
- [ ] Numbered assumptions/constraints
- [ ] No ambiguity words
- [ ] Error paths covered
- [ ] Personas in user stories
- [ ] Phase 2 FRs explicitly marked as Should Have / deferred

### Content Quality (12 points)
- [ ] Imperative command pattern (Enable/Disable, not upsert) documented
- [ ] Fail-closed definition in assumptions
- [ ] Status resolution business rule documented (BR-ENT-STATUS or equivalent)
- [ ] Core vs non-core materialization distinction
- [ ] Materialization trigger points documented
- [ ] Phase 1 vs Phase 2 scoping explicit
- [ ] Reason field overwrite trade-off documented
- [ ] No RLS on entitlements table noted (cross-org operation)
- [ ] Concurrency acceptance criteria on enable/disable
- [ ] Re-enable scenario covered (disable then enable again)
- [ ] Partial failure handling for materialization
- [ ] Appendix marked as indicative (not prescriptive)
