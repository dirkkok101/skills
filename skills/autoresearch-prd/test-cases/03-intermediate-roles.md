# Test Case: Roles & Permissions

## Difficulty: Intermediate (multi-epic with nested FR prefix families, dependency enforcement, effective permissions computation, CLI/MCP appendices)

## Input — What the skill receives

```
Feature: Roles & Permissions
Project: NxGN Identity Platform
Module Prefix: ROLE (roles), ROLE-PERM (permission types)

Problem Context:
  Identity requires a role-based access control (RBAC) system where Platform Admins
  define roles and permission types, Org Admins assign roles to users within their
  org, and the system computes effective permissions by merging role-based and direct
  permission assignments. Roles are either templated (from Role Templates), customized,
  or created from scratch. Permission types have dependencies (e.g., "edit" requires
  "view") that must be enforced.

Upstream: brainstorm exists
Discovery: N/A
Scope: COMPREHENSIVE

Personas:
  - P1: Platform Admin — defines roles, permission types, manages platform-wide config
  - P2: Org Admin — assigns roles to users, manages org-scoped role customization
  - P3: App Developer — integrates with permission APIs

Key Domain Concepts:
  - Role: aggregate with name, description, permissions; org-scoped via RLS
  - Permission Type: registry of all possible permissions; platform-wide
  - Direct Permission Assignment: per-user permission overrides
  - Effective Permissions: union of role-based + direct permissions
  - Dependency enforcement: permission types can require other permission types
  - Three role origins: templated, customized, created-from-scratch
  - Ceiling check philosophy: allow update of inherited roles without re-checking
  - RLS on Roles, RolePermissions, UserRoles tables (Users table has no RLS)

Operations:
  Roles: Save, Get, GridList, Delete, Lookup, AssignUser, UnassignUser, ListMembers
  PermTypes: Save, DependencyEnforcement, Batch, List, Lookup, Assign, Revoke, Delete
  Effective: Computation, API, ApiKeyIntersection

Dependencies: Applications, Organizations, Entitlements, Users PRDs

Epics:
  1. Role Aggregate CRUD
  2. Role Membership
  3. Permission Type Registry
  4. Direct Permission Assignment
  5. Effective Permissions
```

## Expected Output — Files that should be generated

### Primary
- `docs/prd/roles/prd.md`

## Ground Truth Location

```
~/nxgn.identity/main/docs/prd/roles/prd.md
```

## Evaluation Checklist

### Structure (20 points)
- [ ] Metadata table with Depends On field
- [ ] Document History table (multiple version entries)
- [ ] Table of Contents
- [ ] Problem Statement with Impact list
- [ ] Goals (5 items)
- [ ] Non-Goals (6 items)
- [ ] Success Metrics table (3 rows)
- [ ] User Personas (P1, P2, P3 with detection rules)
- [ ] Assumptions (10 items: A1-A10)
- [ ] Constraints (4 items: C1-C4)
- [ ] Risks table (3 rows)
- [ ] Open Questions table
- [ ] Use Cases (cross-cutting + module-specific)
- [ ] Functional Requirements across 5 Epics
- [ ] NFR section (5+ NFRs)
- [ ] Integration Points (consumed/exposed)
- [ ] MoSCoW Prioritisation with Dependency Graph
- [ ] Domain Validation with Coverage Matrix
- [ ] Document Approval section
- [ ] Appendices (API endpoints, CLI commands, MCP tools, Database tables)

### Pattern Compliance (15 points)
- [ ] Dual FR prefix: FR-ROLE-* and FR-ROLE-PERM-* (nested sub-module)
- [ ] NFR IDs use NFR-ROLE-* prefix
- [ ] Descriptive IDs throughout
- [ ] FRs have user story format
- [ ] Given/When/Then acceptance criteria
- [ ] Priority and Complexity on each FR
- [ ] NFRs with measurable targets
- [ ] Numbered assumptions and constraints
- [ ] No ambiguity words
- [ ] Error paths in acceptance criteria
- [ ] Personas referenced in user stories
- [ ] MoSCoW: Must Have ≤ 10 items
- [ ] Won't Have items with rationale
- [ ] UC IDs follow UC-ROLE-* pattern
- [ ] Security criteria on permission-modifying FRs

### Content Quality (12 points)
- [ ] Dependency enforcement as first-class FR (not just a note)
- [ ] Effective permissions computation documented (role + direct union)
- [ ] API Key intersection model (key permissions ∩ user permissions)
- [ ] Three role origins handled (templated, customized, scratch)
- [ ] RLS coverage documented per table
- [ ] Ceiling check philosophy documented
- [ ] Batch registration for permission types
- [ ] Removed FRs tracked as Constraints or Non-Goals (not silently dropped)
- [ ] CLI command appendix with naming convention
- [ ] MCP tools appendix with naming convention
- [ ] Cross-module integration (Entitlements gate, Application context)
- [ ] Audit NFR present
