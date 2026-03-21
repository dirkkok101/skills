# Test Case: Portal (Application Shell)

## Difficulty: Boss (Glossary, Architecture Context, Kill Criteria, 15 Edge Cases with IDs, 3 coverage matrices, Validation Rules section, system diagrams, frontend-only module — exercises every structural pattern)

## Input — What the skill receives

```
Feature: Portal (Application Shell)
Project: NxGN Identity Platform
Module Prefix: PORTAL

Problem Context:
  The Identity admin portal needs an application shell that provides consistent
  navigation, tenant switching, session bootstrap, route guarding, and error pages.
  Currently there is no shared shell — each admin page manages its own nav, auth
  checks, and tenant context independently. This creates inconsistency, duplicated
  logic, and security gaps (unguarded routes, stale tenant context).

Upstream: brainstorm/portal/brainstorm.md exists
Discovery: N/A
Scope: COMPREHENSIVE

Personas:
  - P1: Platform Admin — uses the portal daily for identity management
  - P2: Org Admin — uses portal for org-scoped admin tasks (indirect user)

Key Domain Concepts:
  - Application Shell: Angular standalone component hosting sidebar + navbar + content area
  - Sidebar: collapsible nav with permission-filtered items and badge counts
  - Navbar: tenant switcher, user menu, brand mark
  - Session Bootstrap: parallel API loading on app init (me, tenants, nav items, preferences)
  - Route Guard: 100% route coverage, permission-based access control
  - Tenant Switching: modal blocking for unsaved changes, cross-tab sync via BroadcastChannel
  - User Preferences: sidebar collapse state, last active tenant
  - Cross-Tab Sync: BroadcastChannel for tenant/logout events with graceful degradation
  - Error Pages: 403, 404, 500, offline with consistent layout

Glossary Terms (14):
  Application Shell, Brand Mark, NavItem, Navigation PermissionType, Content Projection,
  Session Bootstrap, Tenant Context, Active Tenant, nxgn-data-filter, Route Guard,
  BroadcastChannel, Cross-Tab Sync, Sidebar Collapse State, Error Boundary

Architecture:
  - Portal owns: shell layout, nav rendering, route guards, preference storage, bootstrap
  - Portal does NOT own: module content (projected), auth flows (Authentication module), user data (Users module)
  - System diagram: Shell → [Sidebar | Navbar | Content Area] with data flow arrows

Kill Criteria (5):
  1. Initial load > 4 seconds
  2. Tenant switch requires full page reload
  3. Less than 100% of admin routes have route guards
  4. Sidebar nav exceeds 100 items (performance cliff)
  5. Shell bundle > 500KB gzipped

Edge Cases (15):
  EC-PORTAL-001 through EC-PORTAL-015 covering: expired session mid-navigation,
  tenant deleted while active, simultaneous tab tenant switch, 0 tenants available,
  nav permissions revoked mid-session, deep link to guarded route, browser back to
  stale context, localStorage quota exceeded, BroadcastChannel unsupported browser,
  modal dismiss during tenant switch, sidebar collapse with 0 nav items, concurrent
  preference writes, 500 error during bootstrap, offline detection, stale tenant cache

Validation Rules:
  - Sidebar collapse: stored as stringified boolean ("true"/"false")
  - Tenant switcher: search debounce, minimum 2 chars
  - Route guard: redirect to 403 vs login based on auth state
  - Bootstrap endpoints: parallel loading with fallback on partial failure

Operations:
  Shell (layout + content projection), Sidebar (nav + collapse + badge),
  Navbar (tenant switcher + user menu + brand), Session Bootstrap (parallel API init),
  Route Guard (permission check + redirect), Preferences (sidebar state + last tenant),
  Tenant Search (debounced), Cross-Tab Sync (BroadcastChannel),
  Context Endpoints (/me, /tenants, /nav-items), Error Pages (403/404/500/offline)

Dependencies: Authentication PRD, Users PRD, Organizations PRD, Sessions PRD, Roles PRD

Epics:
  1. Shell & Layout
  2. Navigation & Sidebar
  3. Session & Context
  4. Route Protection & Error Handling
```

## Expected Output — Files that should be generated

### Primary
- `docs/prd/portal/prd.md`

## Ground Truth Location

```
~/nxgn.identity/main/docs/prd/portal/prd.md
```

## Evaluation Checklist

### Structure (25 points)
- [ ] Metadata table (with Module field, MoSCoW, FR/NFR prefixes, Brainstorm link)
- [ ] Document History table
- [ ] Table of Contents
- [ ] **Glossary section** with 10+ term definitions
- [ ] **Architecture Context section** with ownership model table
- [ ] Problem Statement with Impact list and Why now
- [ ] Goals section
- [ ] Non-Goals section
- [ ] Success Metrics table
- [ ] User Personas (P1, P2)
- [ ] Assumptions with impact assessment (numbered)
- [ ] Constraints (Technical T1-Tn + Organizational O1-On)
- [ ] Risks table (6+ items)
- [ ] Open Questions table
- [ ] **Kill Criteria section** (5 explicit termination conditions)
- [ ] Use Cases section
- [ ] Functional Requirements across 4 Epics (10 FRs)
- [ ] **Edge Cases section** with IDs (EC-PORTAL-001 through EC-PORTAL-015)
- [ ] NFR section (6 NFRs)
- [ ] **Validation Rules section** (4 subsections)
- [ ] Integration Points
- [ ] MoSCoW Prioritisation
- [ ] Domain Validation with **3 coverage matrices** (FR-to-Persona, FR-to-UC, FR-to-Edge Case)
- [ ] Dependencies section (upstream/downstream)
- [ ] Document Approval

### Pattern Compliance (15 points)
- [ ] FR IDs use FR-PORTAL-* prefix
- [ ] NFR IDs use NFR-PORTAL-* prefix
- [ ] Edge Case IDs use EC-PORTAL-* format
- [ ] Descriptive IDs throughout
- [ ] FRs have user story format
- [ ] Given/When/Then acceptance criteria
- [ ] Priority and Complexity
- [ ] NFRs with measurable targets (specific ms, %, KB values)
- [ ] Numbered assumptions/constraints
- [ ] No ambiguity words
- [ ] Error paths in acceptance criteria
- [ ] Personas in user stories
- [ ] Kill criteria are specific and measurable (numbers, not adjectives)
- [ ] Validation rules have specific values/thresholds
- [ ] Constraint type prefixes (T for technical, O for organizational)

### Content Quality (15 points)
- [ ] Glossary defines domain-specific terms (not generic web terms)
- [ ] Architecture ownership model explicit (Portal owns X, does NOT own Y)
- [ ] Kill criteria include performance thresholds and security coverage
- [ ] BroadcastChannel for cross-tab sync with graceful degradation
- [ ] Modal blocking on tenant switch for unsaved changes
- [ ] Parallel API loading on bootstrap (not sequential)
- [ ] Route guard 100% coverage as explicit requirement
- [ ] Sidebar collapse state stored as stringified boolean
- [ ] Badge count integration with other modules (Approvals)
- [ ] Error pages with consistent layout (403, 404, 500, offline)
- [ ] 3 coverage matrices present (FR-Persona, FR-UC, FR-EdgeCase)
- [ ] Edge cases cover browser limitations (localStorage quota, BroadcastChannel unsupported)
- [ ] Dependency matrix (upstream/downstream PRD references)
- [ ] Bundle size constraint as NFR or kill criterion
- [ ] Frontend-specific NFRs (initial load time, tenant switch latency, accessibility)
