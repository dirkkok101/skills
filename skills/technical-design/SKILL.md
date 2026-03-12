---
name: technical-design
description: >
  Transform approved PRD requirements into a technical design through
  structured dialogue. Explores alternatives and trade-offs BEFORE
  committing to detailed design. Produces architecture diagrams, data
  models, per-feature API/implementation specs with test plans, operational
  design, and work decomposition. The agent co-authors with the user,
  pausing after key decisions rather than generating everything at once.
  Use when user says "design the system", "create technical spec", "API
  design", "architecture", or after PRD approval. Also use for technical
  improvements after brainstorm.
argument-hint: "[feature name or PRD reference]"
---

# Technical Design: Requirements → Architecture & Specifications

**Philosophy:** The value of a design doc is in the decisions it records, not the solution it describes. If the solution is obvious enough that there are no trade-offs, you probably don't need a design doc. Explore alternatives first, commit to an approach, then detail the solution. The document should still be useful 6 months later when someone asks "why did we build it this way?"

**Duration targets:** BRIEF ~20-30 minutes, STANDARD ~45-90 minutes, COMPREHENSIVE ~2-3 hours. These are guidelines — complex domains may need more time in Phase 2 (alternatives), but if you're spending most of the time on Phases 4-7 (detailed design), the balance is wrong. The thinking should be front-loaded.

## Why This Matters

A design doc that just describes the solution is a spec sheet — useful but not valuable. This skill produces designs that are:
- **Decision-driven** — alternatives explored and trade-offs made explicit before detailed design
- **Collaborative** — the user validates key decisions at each stage
- **Feature-oriented** — each feature area gets focused docs that serve one reader doing one job
- **Proportional** — detail depth matches irreversibility (deep for APIs and schemas, light for internals)
- **Operational** — deployment, failure modes, and observability are first-class concerns, not afterthoughts
- **Durable** — explains WHY, not just WHAT, so future engineers understand the reasoning

---

## Trigger Conditions

Run this skill when:
- After PRD approval (business features)
- After brainstorm (technical improvements that skip PRD)
- User needs architecture, API specs, or data models
- User says "design the API", "what's the architecture", "create technical spec"
- Before /plan for any medium-to-large change

## Stage Gate Reference
For interactive stage gate patterns used at PAUSE points: `../_shared/references/stage-gates.md`
If `AskUserQuestion` is unavailable, fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

Determine mode from brainstorm scope classification or ask user:

| Mode | When | Sections | Output |
|------|------|----------|--------|
| **BRIEF** | Simple feature, BRIEF scope, 1-2 files changed | Constraints, decisions, API sketch, work decomposition | Single `design.md` |
| **STANDARD** | Typical feature, STANDARD scope | All core phases, selected diagrams, per-feature docs | `design.md` + feature docs + diagrams |
| **COMPREHENSIVE** | Complex feature, COMPREHENSIVE scope, multi-service | All phases including security, operational design, deployment | Full file set with feature decomposition |

BRIEF mode produces a single concise design document (~50-100 lines). Skip diagram selection — include inline diagrams only where they clarify something prose cannot. For BRIEF mode, follow the phase structure but apply skip markers noted in each phase. The BRIEF template at the end shows the expected output format.

---

## Collaborative Model

This skill uses PAUSE points where the agent stops and waits for user input. Decisions made at PAUSE points shape all downstream design work.

```
Phase 0: Import & Understand
Phase 1: Constraints, Assumptions & Kill Criteria Check
  ── PAUSE 1: "Are these constraints correct? Anything missing?" ──
Phase 2: Key Decisions & Alternatives
  ── PAUSE 2: "Here are the options. Which approach for each?" ──
  ── Diagram Selection (informed by confirmed decisions) ──
Phase 3: System Architecture + Data Model
  ── Architecture Self-Review (catch structural issues early) ──
  ── PAUSE 3: "Architecture and data model — does this look right?" ──
Phase 4: Feature Design (per-feature api-surface, ui-mockup, test-plan, browser-e2e-plan)
Phase 5: Cross-Cutting Diagrams (sequences, workflows, data flows)
Phase 6: Security & Privacy (if applicable)
Phase 7: Operational Design (informed by security decisions)
Phase 8: Work Decomposition
Phase 9: Assembly & Self-Review
  ── PAUSE 4: "Design complete. Review and approve?" ──
```

---

## Critical Sequence

### Phase 0: Prerequisites

**Step 0.1 — Resolve and Import:**

Import upstream artifacts into the design workspace:
- **PRD** — `docs/prd/{feature}/prd.md` (requirements, acceptance criteria, NFRs)
- **Use cases** — `docs/prd/{feature}/use-cases/` (feature-scoped scenario flows, failure paths, business rules) and `docs/use-cases/` (cross-module use cases that span features). Read the PRD's use case index table to identify which UCs exist and their depth tiers. **Tier 1 UCs are critical** — their scenario flows, failure paths, and business rules directly inform API design, error handling, and test plans.
- **Discovery brief** — `docs/discovery/{feature}/discovery-brief.md` (domain analysis, risk assessment)
- **Brainstorm output** — `docs/brainstorm/{feature}/brainstorm.md` (chosen approach, scope, kill criteria)
- **Discovery glossary** — `docs/discovery/{feature}/glossary.md` (term disambiguation)
- **Architecture docs** — `docs/architecture/` (system context, service topology, infrastructure constraints). These describe the world the design must fit into.
- **Project patterns** — `docs/patterns/` (established patterns, conventions, and reusable approaches adopted by the project). Scan for patterns relevant to this feature's domain — data access patterns, API conventions, UI component patterns, testing patterns. The design should follow existing patterns unless there's a documented reason to diverge.
- **ADRs** — `docs/adr/` (prior architectural decisions). Read ADR titles and scan any that relate to this feature's domain. Existing ADRs are **constraints** — the design must respect prior decisions unless it explicitly proposes superseding one (which requires a new ADR).
- **Learnings** — `docs/learnings/` (relevant compound learnings from past work)

Create the output directory: `docs/designs/{feature}/`

Do not re-interview the user for context that exists in these artifacts. Import it, reference it, build on it.

**Design from first principles, not existing implementation.** The design's inputs are the PRD, upstream artifacts (brainstorm, discovery, use cases), and project knowledge (architecture docs, patterns, ADRs, learnings). Do NOT read existing source code to inform the design — an existing implementation may be wrong, poorly structured, or anchoring. The design should emerge from requirements and established project patterns, evaluated with best current knowledge. If a prior design exists in `docs/designs/{feature}/`, treat it as superseded — produce a fresh design from the upstream artifacts. The only exception is reading codebase files explicitly referenced in `docs/patterns/` or `docs/architecture/` as canonical examples of a project pattern.

**Step 0.2 — Inherit Glossary:**

If the discovery phase produced a glossary, copy it into the design directory as `glossary.md`. This becomes the ubiquitous language for the design. Update it throughout design phases as new technical terms emerge (e.g., entity names, command names, pattern names that didn't exist during discovery).

If no discovery glossary exists but the feature introduces domain terms that could be confused (e.g., "Client" vs "Application", "Role" vs "Permission"), create a glossary proactively.

**Step 0.3 — Identify Sibling Designs:**

Check for other design directories under `docs/designs/`. If this project has multiple designs (e.g., `01-language-management/`, `02-workflow-configuration/`), document the relationships in design.md:

```markdown
## Documentation Foundation

### Sibling Designs

| Design | Relationship to {This Feature} |
|--------|-------------------------------|
| [{sibling-name}](../{sibling-dir}/README.md) | {How it relates — provides data, consumes events, shares entities, etc.} |
```

This cross-referencing is critical for multi-design projects where features interact. Each design should document which sibling designs it depends on and what it provides to others.

**Step 0.4 — Load References:**

Read ASCII conventions: `_shared/references/ascii-conventions.md`
Read project-specific patterns: check project CLAUDE.md for pattern references
Read domain patterns: `_shared/references/{domain}.md` (from discovery domain classification)

---

### Phase 1: Constraints, Assumptions & Context

Before designing anything, document what constrains the design space. This prevents wasted effort exploring approaches that won't work.

**Step 1.1 — Kill Criteria Check:**

Review kill criteria from brainstorm output. Before investing in detailed design, verify they still hold:
- Are any kill criteria at risk given what we now know from the PRD and discovery?
- Do the technical constraints we're about to document threaten any kill criteria?

If a kill criterion is violated or at serious risk, stop and escalate: "Kill criterion '{criterion}' appears to be at risk because {reason}. Recommend returning to brainstorm to reassess the approach before investing in detailed design."

**Step 1.2 — Document Constraints:**

```markdown
## Constraints

### Technical Constraints
- {Existing infrastructure or technology choices that are fixed}
- {Performance requirements from NFRs — "P95 < 200ms"}
- {Data volume or scale requirements}

### Organisational Constraints
- {Team expertise, timeline, budget}
- {Compliance or regulatory requirements}
- {Dependencies on other teams or systems}

## Assumptions

| # | Assumption | Impact if Wrong | How to Validate |
|---|-----------|----------------|-----------------|
| 1 | {assumption} | {consequence} | {validation approach} |
| 2 | {assumption} | {consequence} | {validation approach} |

## Context

### Current State
{How does the system work today? What exists that this feature builds on?}

### Problem Being Solved
{Brief — reference the PRD for full problem statement. The TDD accepts the PRD's
requirements as given inputs. Do not re-argue what to build, only how.}
```

**PAUSE 1:** Present constraints and assumptions for batch review.

**Step 1:** Present all constraints and assumptions as formatted markdown with full detail — rationale, source (PRD, tech stack, team), and impact on design approach.

**Step 2:** Use `AskUserQuestion` with **Batch Review** (Pattern 3) — multi-select to flag items needing correction. Unselected items are confirmed as-is. Max 4 options per batch; repeat if more constraints exist.

```
AskUserQuestion:
  question: "Which constraints or assumptions need correction? (Unselected items are confirmed)"
  header: "Constraints"
  multiSelect: true
  options:
    - label: "{Constraint 1 short name}"
      description: "{Brief summary — source, impact on design}"
    - label: "{Constraint 2 short name}"
      description: "{Brief summary — source, impact on design}"
    - label: "{Assumption 1 short name}"
      description: "{Brief summary — what it assumes, what breaks if wrong}"
    - label: "{Assumption 2 short name}"
      description: "{Brief summary — what it assumes, what breaks if wrong}"
```

For items flagged for correction, ask a follow-up or read the user's notes from "Other" to understand what needs changing. If corrections reveal a fundamental problem, escalate back to PRD or brainstorm.

---

### Phase 2: Key Decisions & Alternatives

**This is the most important phase.** Explore the design space before committing. The research shows that writing alternatives first forces you to consider the full solution space rather than anchoring on the first idea.

**Step 2.0 — Check Existing ADRs and Patterns:**

Before identifying new decisions, review what's already decided:

1. Scan `docs/adr/` for ADRs related to this feature's domain (data access, API conventions, auth, integration, etc.)
2. Scan `docs/patterns/` for established patterns that apply to this feature area
3. List relevant prior decisions and patterns as **constraints** on the current design:

```markdown
## Prior Decisions & Established Patterns

| Source | Title | Implication for This Design |
|--------|-------|-----------------------------|
| ADR-{NNNN} | {title} | {How it constrains this design} |
| Pattern: {name} | {summary} | {How this design should follow it} |
```

If a design decision would conflict with an existing ADR or pattern, flag it explicitly — the alternative must include a proposal to supersede the ADR (with a new ADR) or document why the pattern doesn't apply here.

**Step 2.1 — Identify Decisions:**

List every significant decision this design requires. Exclude decisions already settled by ADRs or patterns from Step 2.0 — those are constraints, not open questions.

- Architecture approach (monolith vs. service, sync vs. async)
- Data storage (SQL vs. NoSQL, schema design approach)
- API style (REST, GraphQL, gRPC, event-driven)
- Integration pattern (direct call, message queue, webhook)
- Auth approach (if feature touches auth)
- Caching strategy (if performance-sensitive)
- Any decision that constrains future choices or is hard to reverse

**Step 2.2 — Explore Alternatives:**

For each decision:

```markdown
## Key Decisions

### Decision 1: {What's being decided}

**Context:** {Why this decision matters. What constraints apply.}

| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| A: {Name} | {How it works} | {Benefits} | {Drawbacks} |
| B: {Name} | {How it works} | {Benefits} | {Drawbacks} |
| C: {Name} | {How it works} | {Benefits} | {Drawbacks} |

**Recommendation:** Approach {X} because {specific reasoning tied to constraints}.
**Trade-off accepted:** {What we're giving up and why it's acceptable}.
```

**Quality checks:**
- Minimum 2-3 genuine alternatives per major decision. No straw-man options.
- If you can't think of alternatives, the decision may not need a design doc — it's obvious.
- This section should be one of the longest. If it's shorter than the architecture section, you haven't explored enough.
- Alternatives should be genuinely viable, not obviously bad options included to make the chosen approach look good.

**Step 2.3 — Decision Records:**

Decisions that are **feature-scoped** (apply only within this design) are co-located in `docs/designs/{feature}/decisions/`:

```
"Decision {N} about {topic} — is this feature-specific or does it set a
precedent across the project? [feature / project-wide]"
```

- **Feature-scoped** → `docs/designs/{feature}/decisions/{decision-slug}.md` (co-located with the design)
- **Project-wide** → `docs/adr/NNNN-{decision-title}.md` (global ADR directory)

Feature-scoped decision records are lightweight — context, research/comparison, decision, consequences. They answer "why did we do it this way?" when someone reads the design 6 months later.

**PAUSE 2:** Present architectural alternatives using **Comparison Gate** (Pattern 2).

**Step 1:** Present the full comparison matrix as formatted markdown — all decisions, alternatives, pros/cons, and recommendations. This gives the user the complete picture before they choose.

**Step 2:** Use `AskUserQuestion` for each major decision point. Use `preview` fields to show each approach's details side-by-side. One question per decision area (the UI renders options on the left, preview content on the right).

```
AskUserQuestion:
  question: "Which approach for {decision area}?"
  header: "{area}"       # max 12 chars
  multiSelect: false
  options:
    - label: "{Approach A} (Recommended)"
      description: "{One-line summary}. {Complexity level}."
      preview: |
        ### {Approach A}
        **Core idea:** {what this approach does}
        **Pros:** {key advantages}
        **Cons:** {key disadvantages}
        **Complexity:** {Low | Medium | High}
        **Biggest risk:** {primary risk}
    - label: "{Approach B}"
      description: "{One-line summary}. {Complexity level}."
      preview: |
        ### {Approach B}
        **Core idea:** {what this approach does}
        **Pros:** {key advantages}
        **Cons:** {key disadvantages}
        **Complexity:** {Low | Medium | High}
        **Biggest risk:** {primary risk}
    - label: "Do Less"
      description: "{Minimal-change approach if viable}."
      preview: |
        ### Do Less
        **Core idea:** {extend existing system}
        **When right:** {conditions where this is sufficient}
        **Pros:** {advantages}
        **Cons:** {limitations}
```

Repeat for each major decision point. If decisions reveal that the brainstorm approach won't work, escalate upstream. The user's choices here determine the entire detailed design that follows.

**Step 2.4 — Diagram Selection (STANDARD + COMPREHENSIVE):**

Now that decisions are confirmed, select which diagrams to generate based on the chosen approaches:

```
ALWAYS GENERATE (STANDARD+):
  [x] C4 Level 1 — System Context
  [x] C4 Level 2 — Container Diagram

CONDITIONAL — check each:
  [ ] C4 Level 3 (Component):
      IF feature modifies internal structure of an existing container
  [ ] Sequence Diagrams:
      IF multi-component interaction (2+ services involved)
      → one per critical flow (command, query, error recovery)
  [ ] Data Model / ER Diagram:
      IF feature adds or changes database entities
  [ ] Data Flow Diagram:
      IF feature moves data across system boundaries
      IF security threat model is needed (STRIDE input)
  [ ] Workflow / Process Map:
      IF feature has business process with decisions or approvals
  [ ] Deployment Diagram:
      ONLY IF infrastructure changes are required

NEVER GENERATE:
  [ ] C4 Level 4 (Code) — use IDE for this
```

Note: UI mockups are not selected here — they are generated per-feature in Phase 4 for any feature area that has a user interface.

Present checklist to user: "Based on the confirmed decisions above, I plan to generate: {list}. Any additions or removals?"

---

### Phase 3: System Architecture & Data Model

**STANDARD + COMPREHENSIVE. BRIEF mode: skip or include a single inline diagram.**

**Step 3.1 — C4 Level 1: System Context**

ASCII diagram showing the system under design (double border) with external actors and systems. Use conventions from `ascii-conventions.md`.

Rules: 3-7 elements max. One diagram, one story. Label every connection with protocol and data description.

**Step 3.2 — C4 Level 2: Container Diagram**

ASCII diagram showing major technology pieces within the system. Each container includes: name, technology choice, port/protocol. Every connection labelled.

**Step 3.3 — C4 Level 3: Component Diagram (IF selected)**

Internal components of ONE container — the container being modified by this feature.

**Step 3.4 — Data Model (IF feature changes data)**

Move data model into this phase so architecture and data are validated together.

*Entity-Relationship Diagram:*

ASCII ER diagram using class diagram conventions from `ascii-conventions.md`. Show ALL new/changed entities with properties, types, constraints, relationships.

```
+------------------+        +------------------+
|  Account         |        |  AccountRole     |
+------------------+        +------------------+
| + Id: UUID PK    |        | + AccountId: FK  |
| + TenantId: UUID |  1---* | + RoleId: FK     |
| + Name: string   |--------| + GrantedAt: ts  |
| + Email: string  |        +------------------+
| + IsActive: bool |
| + CreatedAt: ts  |
+------------------+
| + Suspend()      |
| + Activate()     |
+------------------+
```

*Entity Definitions:*

For each entity: all properties with types and constraints, relationships, ORM/storage notes (indexes, unique constraints, query filters), soft delete strategy if applicable.

*Migration Strategy:*

- New tables or collections needed
- Columns/fields added to existing structures
- Data migration requirements
- Seed data needs
- **Rollback approach** — how to undo the migration safely

**Architecture Self-Review:**

Before presenting to the user, review the architecture + data model against these checks:
- Do the diagrams reflect the decisions made in Phase 2?
- Does the data model support all interfaces implied by the requirements?
- Are there circular dependencies or coupling concerns?
- Would a senior engineer on the team have obvious objections?

If issues are found, fix them before presenting. This catches structural problems before investing in detailed design phases.

Output: `architecture.md`, `data-model.md`

**PAUSE 3:** Walk through architecture and data model using **Guided Review** (Pattern 5).

Instead of presenting everything at once, walk the user through each section sequentially so nothing gets missed.

**Step 1 — System Architecture:** Present system architecture diagram(s) and component overview as formatted markdown.

```
AskUserQuestion:
  question: "Does the system architecture look right? Components, boundaries, and connections."
  header: "Architecture"
  multiSelect: false
  options:
    - label: "Approved"
      description: "System context, containers, and component boundaries are correct."
    - label: "Needs revision"
      description: "Something needs changing — I'll provide notes."
    - label: "Skip for now"
      description: "Come back to this section later."
```

If "Needs revision": collect notes, iterate on architecture before proceeding.

**Step 2 — Data Model:** Present data model (entities, relationships, key fields) as formatted markdown.

```
AskUserQuestion:
  question: "Does the data model support all required operations? Entities, relationships, constraints."
  header: "Data Model"
  multiSelect: false
  options:
    - label: "Approved"
      description: "Entities, relationships, and constraints are correct."
    - label: "Needs revision"
      description: "Something needs changing — I'll provide notes."
    - label: "Skip for now"
      description: "Come back to this section later."
```

If "Needs revision": collect notes, iterate on data model before proceeding.

**Step 3 — Key Interfaces/APIs:** Present key interfaces and API boundaries between components as formatted markdown.

```
AskUserQuestion:
  question: "Are the key interfaces and API boundaries between components correct?"
  header: "Interfaces"
  multiSelect: false
  options:
    - label: "Approved"
      description: "Interfaces and boundaries are well-defined. Proceed to feature design."
    - label: "Needs revision"
      description: "Something needs changing — I'll provide notes."
    - label: "Skip for now"
      description: "Come back to this section later."
```

If "Needs revision": collect notes, iterate. If any section was skipped, circle back before proceeding to Phase 4. If fundamental concerns arise, revisit Phase 2 decisions.

---

### Phase 4: Feature Design

**STANDARD + COMPREHENSIVE. BRIEF mode: include interface changes inline in design.md.**

This phase produces **per-feature documentation** — focused docs that serve one reader doing one job. The structure depends on how many distinct feature areas the design covers.

**Step 4.1 — Identify Feature Areas:**

Identify distinct feature areas from the PRD's FR groupings (Epics) and the data model's entity boundaries. Each feature area typically corresponds to an aggregate root or a distinct user-facing capability.

| Feature Area Count | Structure |
|--------------------|-----------|
| 1-2 feature areas | Flat files: `api-surface.md`, `ui-mockup.md`, `test-plan.md` |
| 3+ feature areas | Per-feature: `features/{sub-feature}/api-surface.md`, `ui-mockup.md`, `test-plan.md` |

Feature areas are NOT arbitrary decomposition — they should align with how the codebase will be structured (e.g., `Features/Applications/`, `Features/Clients/`, `Features/RoleTemplates/`).

**Backend separation decision:** By default, backend implementation guidance (command flow, mapper logic, queries) is merged into `api-surface.md` — one doc per feature that covers endpoints through to persistence. However, for features with **5+ commands/queries** or complex backend patterns (workflow engines, interceptor chains, background services), a separate `backend.md` per feature may be cleaner. The AMPS actions project uses 4 docs per feature (`api-surface.md + backend.md + ui-mockup.md + test-plan.md`) successfully because each feature has 6+ commands with rich pseudocode. Ask the user if backend complexity warrants separation.

**Step 4.2 — API Surface & Implementation (per feature area):**

For each feature area, produce `api-surface.md` (or `features/{sub-feature}/api-surface.md` when decomposed). This document serves the developer implementing the feature end-to-end: endpoints, contracts, backend flow, and queries.

**Use case integration (COMPREHENSIVE mode):** Before designing endpoints, read the use cases mapped to this feature area. Use case artifacts inform the API surface in specific ways:
- **Scenario flows** → endpoint sequence and orchestration (the UC steps reveal which API calls happen in what order)
- **Failure paths** → error response codes and error detail contracts (each UC failure path becomes a specific error response)
- **Business rules (BR-*)** → validation rules and protection rules (BR thresholds/limits become validator constraints)
- **Postconditions** → response body design (what the caller needs to confirm the operation succeeded)
- **Preconditions** → required request context (auth, tenant, prior state that must exist)

Reference the source UC in the api-surface doc where design decisions derive from use case content.

```markdown
# {Feature Area}: API Surface

## Endpoints

| Verb | Route | Purpose |
|------|-------|---------|
| `POST` | `/api/v1/{resource}` | Save (upsert) |
| `GET` | `/api/v1/{resource}/{id}` | Get detail |
| `POST` | `/api/v1/{resource}/grid` | Get grid list |
| `DELETE` | `/api/v1/{resource}` | Delete (bulk) |

All endpoints require `{Policy}` policy.
Maps to: FR-{MODULE}-{NAME}, FR-{MODULE}-{NAME}
Use cases: UC-{MODULE}-{NNN} (steps {X.X–X.X})

## Response Codes

| Operation | Success Code | Body |
|-----------|-------------|------|
| Save (new) | 201 Created | `Save{Resource}Response { Id }` |
| Save (update) | 200 OK | `Save{Resource}Response { Id }` |
| Get | 200 OK | `{Resource}DTO` |
| Delete | 204 No Content | None |

### Error Responses (from UC failure paths)

| Error Scenario | Code | Detail | Source |
|----------------|------|--------|--------|
| {UC failure path description} | {400/409/422} | {Specific error message} | UC-{MODULE}-{NNN} |

## Contracts

{DTO definitions — use the project's language (C#, TypeScript, etc.)}

Writable fields: {list}
Read-only fields (populated by mapper, ignored on save): {list}

## Validation Rules

{Validator rules and where each is enforced (validator vs command).
Note which validations are synchronous vs require DB lookup.
Reference BR-* IDs from use case business rules where applicable.}

## Protection Rules (if applicable)

| Action | {Condition A} | {Condition B} | {Condition C} |
|--------|--------------|--------------|--------------|
| Save | Blocked (400) | Allowed | Allowed |
| Delete | Blocked (400) | Blocked (400) | Allowed |

{Enforcement mechanism: how and where protection is applied.}

## Backend

### Directory Structure

{Expected directory/file layout for this feature area.}

### Command Flow

{Pseudocode showing the command's algorithm — not line-by-line code,
but the logical flow of create-or-update, validation, persistence.
This is the right level of abstraction: algorithmic intent, not
function bodies.}

### Mapper Logic

{Entity mapper: how DTOs map to entities (new vs update classification).
DTO mapper: how entities map back to DTOs (what gets populated, what gets computed).}

### Queries

| Query | Returns | Notes |
|-------|---------|-------|
| `Get{Resource}Query` | `{Resource}?` | Includes {navigations}. {Special notes.} |
| `Get{Resource}GridListQuery` | `IList<GridItem>` | Pagination, AsNoTracking |
| `Get{Resource}CountQuery` | `int` | For grid total |
```

The backend section uses **command flow pseudocode** — this is algorithmic intent, not implementation code. It shows the decision tree (create vs update, protection checks, cascade operations) without dictating syntax. The developer follows codebase patterns for the actual implementation; the design doc tells them WHAT the algorithm does and WHY.

**Step 4.3 — UI Mockups (per feature area, if feature has UI):**

For each feature area with a user interface, produce `ui-mockup.md` (or `features/{sub-feature}/ui-mockup.md`).

ASCII mockups using conventions from `ascii-conventions.md`.

For each screen, generate SEPARATE mockups for:
1. **Populated** — normal operation with realistic data
2. **Empty** — no data yet, include call-to-action
3. **Error** — validation errors, server errors

Per mockup: component hierarchy, form fields mapped to API inputs, validation rules (client-side vs. server-side), action buttons mapped to API calls, navigation flows between screens.

Features without a UI skip this document.

**Step 4.4 — Test Plan (per feature area):**

For each feature area, produce `test-plan.md` (or `features/{sub-feature}/test-plan.md`). Test plans are first-class design documents, not an afterthought section in design.md.

**Use case integration (COMPREHENSIVE mode):** Use cases are the primary source for test scenarios. Each UC scenario flow step that can succeed or fail generates at least one test case. Each UC failure path entry generates a negative test case. This ensures test coverage traces back to documented user goals, not just API surface.

```markdown
# {Feature Area}: Test Plan

## API Tests

### {Operation Name}

| # | Test Case | Method | Expected | Source |
|---|-----------|--------|----------|--------|
| 1 | {Happy path scenario} | {HTTP method + route} | {Status code, body} | UC-{MODULE}-{NNN} step {X.X} |
| 2 | {Validation failure} | {method} | {400, error detail} | UC-{MODULE}-{NNN} failure path |
| 3 | {Auth failure} | {method} | {401/403} | FR-{MODULE}-{NAME} |
| 4 | {Business rule violation} | {method} | {400, specific error} | BR-{MODULE}-{NNN} |
| 5 | {Edge case} | {method} | {expected behavior} | UC-{MODULE}-{NNN} deferred edge |

### {Next Operation}
...

## UI Tests (if applicable)

| # | Test Case | Component | Expected | Source |
|---|-----------|-----------|----------|--------|
| N | {Scenario} | {ComponentName} | {Expected behavior} | UC-{MODULE}-{NNN} step {X.X} |
```

Aim for 25-35 test cases per feature area covering: happy paths, validation failures, auth failures, business rule violations, edge cases (duplicates, boundaries, empty states, protection rules). In COMPREHENSIVE mode, verify that every Tier 1 UC scenario step and every failure path has at least one corresponding test case.

**Step 4.5 — Browser E2E Test Plan (per feature area, if feature has UI):**

For each feature area with a user interface, produce a browser E2E test plan. These are **journey-level tests** that validate complete user flows through the browser using [agent-browser](https://github.com/vercel-labs/agent-browser) — distinct from the API-level test plans in Step 4.4. They translate UC scenario flows into browser actions using the UI mockup's components.

Save to: `${PROJECT_ROOT}/docs/browser-e2e-plans/{feature-name}.md`

Features without a UI skip this document.

**Inputs:**
- **UC scenario flows** (COMPREHENSIVE) → step sequences and failure paths (what the user does). In STANDARD mode, derive scenarios from FRs and UI mockups instead.
- **UI mockups** → component names, form fields, navigation structure (what to interact with)
- **API surface** → expected responses and state changes (what to verify)
- **Existing project docs** → check for `docs/browser-e2e-plans/selector-reference.md` and `docs/browser-e2e-plans/gotchas.md`. If they exist, use them as authoritative sources — reference them, don't duplicate their content.

**Step 4.5.1 — Shared Docs (first feature only):**

If `docs/browser-e2e-plans/selector-reference.md` doesn't exist yet, create it. This is a **shared document** across all feature E2E plans — the single source of truth for how to target the project's UI components in the browser. Organize by component library, then navigation, then feedback elements. For each component, document: the root selector, the inner interactive element (custom components are often not directly interactive — you must target the inner `input`, `button`, etc.), label-based selection for disambiguation, and error/validation selectors.

If `docs/browser-e2e-plans/gotchas.md` doesn't exist yet, seed it with known interaction pitfalls discovered during UI mockup design. This is a **living document** — it grows as teams discover new pitfalls during test execution. Each gotcha follows the pattern: **Symptom** (what goes wrong), **Cause** (why — DOM structure, async rendering, framework behavior), **Solution** (specific workaround).

Seed gotchas from these common categories that emerge from the UI mockup analysis:
- **Async rendering** — grids, lazy-loaded sections. Wait for content selectors, not just container selectors.
- **Custom component targeting** — wrapper components where the outer element is not interactive. Document which inner element to target.
- **Hidden DOM elements** — parent-child route patterns where hidden content stays in DOM. Selector may match the wrong (hidden) element. Use index-based selection or visibility checks.
- **Dropdown/overlay rendering** — dropdowns that append options to `<body>` rather than inside the component DOM tree.
- **Modal animation timing** — confirmation dialogs with fade-in animations. Wait for visibility, not just DOM presence.
- **Signal/reactive rendering** — framework effects that update DOM asynchronously after state changes. Wait for the expected DOM change, not a fixed timeout.
- **Multiple instances** — same component rendered multiple times on one page (e.g., multiple grids, nested capture pages). Scope selectors by parent component.

**Step 4.5.2 — Feature Test Plan:**

Each feature test plan has five sections:

1. **Preamble** — Base URL where the app runs, the full login flow as browser steps (navigation to login page, credential entry, intermediate steps like tenant selection or MFA, verification that auth succeeded), and the expected bootstrap state (seed data, configuration, running services).

2. **Selector Reference** — For small modules (< 15 unique selectors), include an inline table. For larger modules or when a shared `selector-reference.md` exists, reference it and only list module-specific selectors.

3. **Test Scenarios** — The core of the document. Group scenarios by page or flow area (Grid Page, New Form, Edit Form, Settings, Cross-Cutting UX). Each group maps to a UC or distinct user goal. Each scenario has:
   - **Prerequisites** — auth state, seed data (show exact API requests if data must be created), starting page
   - **Numbered steps** — at user-intention level with wait points after navigation or async actions
   - **Screenshot markers** — `[Screenshot N]` at verification points, numbered sequentially across the entire plan
   - **Visual assertions** — observable DOM state: what must be true, what must NOT be present. Specific selectors and expected text content, not vague "looks correct"

4. **Test Data Cleanup** — API calls to delete every test entity created. List predictable slugs/names. Identify data that must NEVER be deleted (bootstrap/system data).

5. **Screenshot Evidence Summary** — Table mapping screenshot numbers to test IDs and descriptions.

**Patterns for writing scenarios:**

- **Test ID convention:** `BT-{MODULE}-{NNN}` (Browser Test). Group by flow area with number gaps between groups (Grid: 001-009, New: 010-029, Edit: 030-039) to allow inserting tests without renumbering.
- **User-intention level** — "Fill in the application name" not "type into the third input element". Selectors and agent-browser commands are execution hints alongside the step, not the step itself.
- **One scenario per UC or UC phase** (COMPREHENSIVE) or **one scenario per FR group** (STANDARD) — keep scenarios independently runnable. Don't combine multiple user goals into one test.
- **Verify postconditions explicitly** — don't just check that an action completed, verify the observable state the UC postconditions describe (new row in grid, updated status, navigation to detail page, persisted data after reload).
- **Test both empty and populated states** separately — matching the UI mockup variants from Step 4.3.
- **Wait strategies over fixed timeouts** — wait for specific selectors or text to appear. Async-rendered content (grids, lazy sections) needs explicit waits for content elements, not just container elements.
- **Failure scenarios** derive from UC failure paths (COMPREHENSIVE) or FR error acceptance criteria (STANDARD) — each failure entry should have a corresponding browser E2E scenario testing the visible error behavior (inline validation, disabled buttons, error banners, blocked actions).
- **Cleanup is mandatory** — every test entity created must be deletable. Never leave test data behind.

---

### Phase 5: Cross-Cutting Diagrams (IF selected)

**Step 5.1 — Sequence Diagrams:**

One ASCII sequence diagram per critical flow. Use conventions from `ascii-conventions.md`.

Generate for:
- Each write flow (create, update, delete)
- Primary read flow (list with filtering)
- Primary error recovery flow

**Use case integration (COMPREHENSIVE mode):** Derive sequence diagrams from Tier 1 UC scenario flows. The UC phase structure maps directly to diagram segments — each UC phase becomes a named section, and UC steps become messages between participants. UC failure paths become ALT blocks. Reference the source UC ID in the diagram title.

Rules: 3-5 participants max, label messages with actual endpoint/method names, show request AND response, use ALT blocks for error paths, width under 100 characters.

**Step 5.2 — Workflow / Process Diagrams (IF selected):**

ASCII workflow diagrams for business processes with decision points. Include swimlanes when multiple actors/systems are involved.

**Step 5.3 — Data Flow Diagrams (IF selected):**

Context diagram + Level 0 DFD. Useful for security threat modelling (STRIDE input) and integration documentation.

Output: `diagrams/` subdirectory with `sequences.md`, `workflows.md`, `data-flows.md` as applicable. Co-locating diagrams in a subdirectory keeps the design directory scannable when feature decomposition produces many files.

---

### Phase 6: Security & Privacy (IF applicable)

From discovery security analysis, specify technical mitigations:

- Authentication/authorization changes (policies, claims, guards)
- Data classification (which fields are PII, which are sensitive)
- Encryption (at rest: which fields/tables; in transit: TLS configuration)
- Audit logging (which events, retention, tamper protection)
- Rate limiting (which endpoints, per-tenant or global)
- Input validation (injection prevention, parameterised queries)

Security decisions made here feed into operational design — deployment strategy must account for encryption key management, observability must include audit log monitoring, failure modes must consider security-related failures.

Output: included in `design.md`

---

### Phase 7: Operational Design (STANDARD + COMPREHENSIVE)

This phase covers how the system runs in production — not just how it's built. These concerns are first-class design decisions, not afterthoughts. Security decisions from Phase 6 inform this phase.

**Step 7.1 — Deployment & Rollout:**

```markdown
## Operational Design

### Deployment Strategy
- {How will this be deployed? Feature flags, canary, blue-green, big-bang?}
- {Migration sequence if multiple services change}
- {Rollback plan — what to do if deployment fails}
- {Security-specific deployment concerns — key rotation, certificate provisioning}

### Feature Flags (if applicable)
- {Which behaviours are gated?}
- {When can flags be removed?}
```

**Step 7.2 — Failure Modes:**

```markdown
### Failure Modes
| Component | Failure Mode | Impact | Mitigation |
|-----------|-------------|--------|------------|
| {service} | {what can go wrong} | {blast radius} | {circuit breaker, retry, fallback} |
| {database} | {connection failure} | {impact} | {connection pooling, read replicas} |
| {external dep} | {unavailable} | {impact} | {graceful degradation, cached response} |
```

**Step 7.3 — Observability:**

```markdown
### Observability
- **Metrics:** {Key metrics to track — latency, error rate, throughput}
- **Logging:** {What to log, structured logging fields, log levels}
- **Alerting:** {What conditions trigger alerts, who gets paged}
- **Dashboards:** {What should be visible at a glance}
- **Audit trail:** {Security-relevant events from Phase 6}
```

Output: included in `design.md`

---

### Phase 8: Work Decomposition Preview

**This section feeds directly into /plan.**

```markdown
## Work Decomposition

### Component Breakdown
| Component | Scope | Complexity | Risk | Implements |
|-----------|-------|------------|------|-----------|
| Data Model | Entities, migrations, config | M | Low | FR-{NAME}, FR-{NAME} |
| {Feature A} | Save/Delete/Get/Grid + backend + tests | L | Medium | FR-{NAME} through FR-{NAME} |
| {Feature B} | Endpoints + backend + tests | M | Low | FR-{NAME} |
| Frontend | Components, navigation, forms | L | Medium | All FRs |
| Integration | External system wiring | M | High | FR-{NAME} |

### Dependency Graph
  Data Model ──> {Feature A} ──> Frontend
      |              |
      +──> {Feature B}─+
      |
      +──> Integration

### Suggested Execution Order
1. Shared infrastructure — everything depends on this
2. {Feature A} — highest risk, validate early
3. {Feature B} — builds on {Feature A}
4. Frontend — consumes all backend APIs
5. Integration — external systems
```

Output: included in `design.md`

---

### Phase 8b: Consolidated Feature Specifications (COMPREHENSIVE only, 3+ feature areas)

**Optional but recommended for COMPREHENSIVE designs with 10+ use cases.** Produces per-feature-area specs that tie together UCs, endpoints, UI mockups, plan tasks, and test counts into a single cross-reference. These serve as the implementation-time "map" — a developer picks up a feature spec and sees everything related to their domain area in one place.

Save to: `${PROJECT_ROOT}/docs/designs/{feature}/features/`

```markdown
# Feature Specifications — Overview

> Per-feature consolidated documentation tying together UI mockups, flows,
> test cases, and endpoint mappings for {project name}.

## Feature Area Map

{ASCII diagram showing feature areas with UC counts and test counts}

## Test Case ID Convention

| Prefix | Type | Format | Example |
|--------|------|--------|---------|
| `UT` | Unit test | `UT-{UC#}-{seq}` | `UT-01-03` — CreateAction validator, missing title |
| `IT` | Integration test | `IT-{UC#}-{seq}` | `IT-04-05` — Full lifecycle transition |
| `EC` | Edge case / negative | `EC-{UC#}-{seq}` | `EC-07-02` — Upload with spoofed MIME type |

## Coverage Matrix

| UC | Title | Feature Spec | UI Mockup | Endpoints | Plan Tasks | Tests |
|----|-------|-------------|-----------|-----------|------------|-------|
| UC-{MODULE}-{NNN} | {title} | [{spec}]({link}) | {mockup ref} | {routes} | {plan refs} | {count} |

## Summary Statistics

| Metric | Count |
|--------|-------|
| Feature spec documents | {N} |
| Use cases covered | {N} |
| Named test cases (total) | {N} |
```

For each feature area, produce `docs/designs/{feature}/features/{NN}-{feature-name}.md`:

```markdown
# Feature: {Feature Name}

## Overview

{2-3 sentences: what this feature covers, which actors use it, how many
UCs and endpoints it spans.}

Key design decisions:
- {Decision 1 — from design's decisions/ directory}
- {Decision 2}

## Use Cases

Use case files: [feature-scoped](../prd/{feature}/use-cases/) | [cross-module](../use-cases/)

| UC | Title | Actors | Plan Tasks | Endpoints |
|----|-------|--------|------------|-----------|

## Endpoints

| Route | Method | UC | Permission Scope | Request DTO | Response DTO | Plan Task |
|-------|--------|----|-----------------|-------------|-------------|-----------|

## UI Mockups

{Inline key mockups from the design's ui-mockup.md, or reference links}

## Cross-References

| Document | Location | Relationship |
|----------|----------|-------------|
| Design | {link} | Architecture + diagrams |
| PRD | {link} | Requirements source |
| Plan | {link} | Implementation plan |
| Browser E2E | {link to docs/browser-e2e-plans/{feature}.md} | End-to-end test scenarios |
```

These specs consolidate information that already exists in design, PRD, and plan documents — they DON'T create new content. Their value is as an index that eliminates cross-document navigation during implementation.

---

### Phase 9: Assembly & Self-Review

**Step 9.1 — Generate README (IF design directory has 5+ files):**

When the design directory contains 5 or more files (including subdirectories), generate a `README.md` as a navigable index:

```markdown
# {Feature Name} — Design Documentation

> {1-2 sentence purpose statement.}

## Design Overview

- **[design.md](design.md)** — Master design: constraints, decisions, architecture overview, security, operational design, work decomposition

## Feature Documentation

### {Feature Area A} ({Relationship — e.g., "Aggregate Root"})

| Document | Contents |
|----------|----------|
| [features/{a}/api-surface.md](...) | Endpoints, contracts, validation, backend flow |
| [features/{a}/ui-mockup.md](...) | ASCII mockups: {screen list} |
| [features/{a}/test-plan.md](...) | {N} test cases (API + UI) |

### {Feature Area B} ({Relationship})

| Document | Contents |
|----------|----------|
| ... | ... |

## Diagrams

| Document | Contents |
|----------|----------|
| [architecture.md](architecture.md) | C4 context + container diagrams |
| [data-model.md](data-model.md) | ER diagram, entity definitions, migration |
| [diagrams/sequences.md](...) | {Flow names} |

## Decisions

| Document | Decision |
|----------|----------|
| [decisions/{slug}.md](...) | {What was decided and why} |

## Research (if co-located)

| Document | Topic |
|----------|-------|
| [research/{slug}.md](...) | {What was investigated} |
```

The README is the entry point for anyone encountering the design directory. It should be scannable in 30 seconds.

**Step 9.2 — Co-Locate Research (IF research was done):**

If a research brief exists at `docs/research/{feature}/`, create symlinks or cross-references from `docs/designs/{feature}/research/` so research is discoverable alongside the design. Research that was done specifically for this design should be co-located; research that serves multiple features stays in the central `docs/research/` directory.

**Step 9.3 — Self-Review:**

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Review Themes:**

1. **Decisions Documented** — Every significant decision has alternatives? Trade-offs explicit?
2. **Architecture Soundness** — Consistent with `docs/patterns/` and `docs/architecture/`? Respects all relevant ADRs from `docs/adr/`? Any divergence explicitly justified with a superseding ADR proposal?
3. **Feature Completeness** — Every FR has an api-surface entry? Input/output types defined? Error codes specific? Test cases cover happy path, validation, auth, and edge cases? Features with UI have browser E2E plans with scenarios tracing to UC flows?
4. **Data Model Integrity** — ER matches interface needs? Relationships correct? Migrations safe?
5. **Diagram Accuracy** — Sequences match interfaces? Flows match use cases? (COMPREHENSIVE: each Tier 1 UC scenario flow has a corresponding sequence diagram?)
6. **Operational Readiness** — Deployment strategy? Failure modes covered? Observability defined?
7. **Traceability** — Every interface maps to FR? Every FR covered by at least one feature area? (COMPREHENSIVE: every Tier 1 UC failure path mapped to an error response? Every BR-* mapped to a validation rule? Test cases trace back to UC steps and failure paths?)
8. **Proportionality** — Detail depth matches irreversibility? Not over-designing internals?
9. **Navigability** — Can someone find the right document in <30 seconds? README index accurate? Cross-references working?

**Known limitation:** Self-review is performed by the same agent that wrote the design. Mitigate by following themes strictly as a checklist. Invite the user to spot-check areas where you're least confident (typically failure modes and edge cases).

**Step 9.4 — Self-Review Log:**

Record each review round with specific issues found and fixes applied. This makes the self-review process auditable and shows the design stabilised through iteration.

```markdown
## Self-Review Log

### Round 1
**Issues Found:** {count}
- [{Theme}] {Description of issue}
  → Fix: {what was changed}
- [{Theme}] {Description}
  → Fix: {what was changed}

### Round 2
**Issues Found:** {count}
- [{Theme}] {Description}
  → Fix: {what was changed}

### Round 3
**Issues Found:** 0
Design stable.
```

Append the self-review log to the bottom of `design.md`.

**Step 9.5 — Open Questions:**

Before presenting, list any unresolved items:

```markdown
## Open Questions
| # | Question | Impact | Owner | Due |
|---|----------|--------|-------|-----|
| 1 | {unresolved technical question} | {what's blocked} | {who decides} | {when} |
```

If the project uses an issue tracker, create tracked items for open questions that need resolution before implementation can begin: "These open questions need resolution. Want me to create tracked issues for them?"

If there are no open questions, state "None — all design decisions resolved." This forces explicit acknowledgment rather than silently hoping everything is covered.

**PAUSE 4:** Present completed design with summary, then use **Decision Gate** (Pattern 1).

Present the design summary as formatted markdown:

```markdown
## Technical Design Complete

**Feature:** {name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Architecture docs:** {count} files in docs/designs/{feature}/
**Feature areas:** {count} with {docs per area} docs each
**Diagrams generated:** {list of diagram types}
**Key decisions:** {count} decisions with {total} alternatives explored
**Test cases:** {total across all feature areas}
**Self-review:** {N} rounds, stable
```

Then use `AskUserQuestion`:

```
AskUserQuestion:
  question: "Is the design complete and ready for planning?"
  header: "Approval"
  multiSelect: false
  options:
    - label: "Design approved (Recommended)"
      description: "Architecture, data model, and feature specs are sound. Proceed to /plan."
    - label: "Refine specific section"
      description: "Most of the design is good but a specific section needs iteration."
    - label: "Park for later"
      description: "Save current state. Design can be resumed in a future session."
```

If "Refine specific section": ask which section needs work and iterate. If "Park for later": update design metadata with Status: Parked and Next Step note.

---

## BRIEF Mode Output Format

For BRIEF mode, produce a single `design.md` following this structure. Content comes from the same phases (with skip markers noted above) — this template shows the expected output format:

```markdown
# Technical Design: {Feature Name}

**Status:** Draft
**PRD:** {link}
**Date:** {today}

## Constraints
{2-3 bullet points — from Phase 1}

## Key Decisions

### {Decision 1}
| Approach | Pros | Cons |
|----------|------|------|
| A ← chosen | {pros} | {cons} |
| B | {pros} | {cons} |
**Rationale:** {why A}

## Design

{Brief description with inline diagrams if helpful.
Follow established patterns from docs/patterns/ and docs/architecture/. — from Phase 3}

## Interface Changes
{New or modified endpoints/operations with inputs, outputs, errors — from Phase 4}

## Work Decomposition
| Step | What | Complexity |
|------|------|-----------|
| 1 | {task} | S |
| 2 | {task} | M |

---
*Design created: {date}*
```

---

## Output Structure

### Flat Design (1-2 feature areas)

```
${PROJECT_ROOT}/docs/designs/{feature}/
├── README.md            # Index (only if 5+ files)
├── design.md            # Constraints, decisions, security, operations, decomposition, self-review log
├── glossary.md          # Term disambiguation (if needed)
├── architecture.md      # C4 diagrams + data model (STANDARD+)
├── data-model.md        # ER diagram + entity definitions + migration (if applicable)
├── api-surface.md       # Endpoints, contracts, validation, backend flow
├── ui-mockup.md         # Mockups with multiple states (if applicable)
├── test-plan.md         # Numbered test cases
├── decisions/           # Feature-scoped decision records (as needed)
│   └── {decision}.md
├── research/            # Co-located research (if applicable)
│   └── {topic}.md
└── diagrams/            # Cross-cutting diagrams (STANDARD+)
    ├── sequences.md
    ├── workflows.md
    └── data-flows.md
```

### Decomposed Design (3+ feature areas)

```
${PROJECT_ROOT}/docs/designs/{feature}/
├── README.md            # Index — REQUIRED for decomposed designs
├── design.md            # Constraints, decisions, security, operations, sibling refs, decomposition, self-review log
├── glossary.md          # Term disambiguation (if needed)
├── architecture.md      # C4 diagrams (STANDARD+)
├── data-model.md        # ER diagram + entity definitions + migration
├── features/
│   ├── {feature-a}/
│   │   ├── api-surface.md   # Endpoints, contracts, validation, backend flow
│   │   ├── backend.md       # OPTIONAL: separate when 5+ commands/queries (see Phase 4.1)
│   │   ├── ui-mockup.md     # ASCII mockups (if feature has UI)
│   │   └── test-plan.md     # Numbered test cases
│   ├── {feature-b}/
│   │   ├── api-surface.md
│   │   ├── ui-mockup.md
│   │   └── test-plan.md
│   └── {feature-c}/
│       ├── api-surface.md
│       └── test-plan.md     # No UI for this feature
├── decisions/
│   └── {decision}.md
├── research/
│   └── {topic}.md
└── diagrams/
    ├── sequences.md
    └── workflows.md
```

### Feature Specifications (COMPREHENSIVE, 3+ feature areas, optional)

```
${PROJECT_ROOT}/docs/designs/{feature}/features/
├── overview.md              # Coverage matrix, test ID conventions, cross-references
├── 01-{feature-name}.md     # Consolidated spec: UCs, endpoints, UI, plan tasks
├── 02-{feature-name}.md
└── ...
```

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "design approved" / "accept" | Design complete | Proceed to /plan |
| "refine" / "modify" | Gaps or issues | Return to relevant phase |
| "park" | Save for later | Archive; user resumes later |
| "abandon" | Don't build this | Document decision rationale |

When exiting, update design metadata: Status, Next Step, Completion Date.

**On approval:** "Design approved. Run /plan to create implementation plan."

---

## Anti-Patterns

**The Solution Monologue** — Agent generates entire design without pausing. The collaborative model exists because the user's domain knowledge catches problems early that cost 10x more to fix in detailed design. Every PAUSE point is a chance to course-correct before investing further effort.

**Straw-Man Alternatives** — Listing obviously bad options to make the chosen approach look good. Reviewers see through this immediately. Every alternative should be genuinely viable — if you can't make a case for an option without hedging, it's a straw man. Remove it and find a real alternative.

**The Monolith API Spec** — Putting all endpoints into one massive `api-spec.md` when the feature has 3+ distinct areas. Each feature area should have its own `api-surface.md` so a developer working on "application clients" reads only the application clients doc, not the entire feature's endpoint list. The trigger for decomposition is 3+ feature areas identified from the PRD's FR groupings.

**Pseudocode as Line-By-Line Code** — Design docs should include **command flow pseudocode** showing algorithmic intent (create-or-update logic, protection checks, cascade operations). This is the right level of abstraction. What they should NOT include is line-by-line implementation code with exact syntax, imports, and error handling — that belongs in the codebase. The test is: does this pseudocode tell the developer WHAT the algorithm does, or does it tell them HOW to type it? The former is design; the latter is implementation.

**Scope Confusion** — Re-arguing product requirements in the technical design. The TDD accepts the PRD's requirements as given. If a requirement seems wrong, feed that back to the PRD, don't silently change scope. The right action is to escalate, not to quietly design around it.

**Missing Operations** — No deployment strategy, no failure modes, no monitoring. These aren't afterthoughts — they're first-class design concerns that affect architecture decisions. If you design the system without thinking about how it fails, the first production incident will reveal the gaps.

**Premature Future-Proofing** — Designing for 100x scale when current load is trivial. Design for what you know, document assumptions about growth, and note where the design would need to change at scale. The design doc captures these assumptions so future engineers know when to revisit.

**Orphaned Research and Decisions** — Storing research in `docs/research/` and decisions in `docs/adr/` where nobody finds them when reading the design. Feature-scoped research and decisions should be co-located with the design directory so they're discoverable in context. Only project-wide ADRs belong in the central `docs/adr/` directory.

**Testing as Afterthought** — Treating the testing strategy as a paragraph in design.md. Test plans are first-class design documents with numbered test cases per feature area. If you can't write specific test cases, the API surface and validation rules aren't detailed enough — fix the design, then the test plan follows naturally.

**Implementation Anchoring** — Reading existing source code to "understand" how to design the feature, then producing a design that mirrors the current implementation. This defeats the purpose of design — especially on re-runs where the existing code may be wrong or poorly structured. Design from the PRD, upstream artifacts, and project knowledge (patterns, architecture, ADRs). The only codebase files you should read are those explicitly referenced in `docs/patterns/` or `docs/architecture/` as canonical examples of an established pattern.

**Ignoring Prior ADRs** — Making decisions that contradict existing ADRs in `docs/adr/` without acknowledging the conflict. Prior ADRs are constraints. If this design needs to diverge, it must propose superseding the ADR with a new one — not silently make the opposite choice.

---

## Living Document Convention

When architecture changes invalidate earlier design documents (e.g., a messaging system is removed, an approach is replaced), add a **Legacy Update** notice at the top of affected docs rather than rewriting them:

```markdown
> **Legacy Update ({date}):** This document contains historical references to
> {removed/changed architecture}. For current authoritative scope, follow
> `{path to current doc}`.
```

This preserves the reasoning that led to the original design while directing readers to current decisions. Do not silently remove content — the decision history has value.

---

## Reference Files

**Project knowledge (read as design inputs):**
- Project patterns: `docs/patterns/` (established conventions and reusable approaches)
- Architecture context: `docs/architecture/` (system topology, service boundaries, infrastructure)
- Prior decisions: `docs/adr/` (architectural decision records — constraints on the design)

**Skill references (internal to the skill):**
- Project-specific patterns: check project CLAUDE.md for pattern reference files
- Domain-specific patterns: `_shared/references/{domain}.md`
- ASCII diagram conventions: `_shared/references/ascii-conventions.md`

---

*Skill Version: 3.5*
*v3.5: UC integration — Phase 0 imports use cases from `docs/prd/{feature}/use-cases/` and `docs/use-cases/`, Step 4.2 maps UC artifacts to API surface (scenario flows→endpoints, failure paths→errors, BR-*→validation), Step 4.4 adds Source column tracing tests to UCs, Phase 5.1 derives sequences from Tier 1 UC flows. ADR/pattern imports — Phase 0 imports `docs/patterns/`, `docs/adr/`, strengthened `docs/architecture/`; Step 2.0 checks prior ADRs/patterns as constraints before identifying new decisions. First-principles directive — design from upstream artifacts, not existing source code. Browser E2E test plans — Step 4.5 generates `docs/browser-e2e-plans/{feature}.md` with pattern-driven guidance, shared selector-reference and gotchas docs. STANDARD-mode fallback guidance for browser E2E when UCs don't exist. Step 2.4 Diagram Selection moved after PAUSE 2 (depends on confirmed decisions). BRIEF template fixed to reference `docs/patterns/` instead of "codebase". `ui-mockup.md` naming standardized. Phase 8b feature spec relative paths corrected. New anti-patterns: Implementation Anchoring, Ignoring Prior ADRs. Collaborative model updated to include browser-e2e-plan. Stage gate reference path corrected.*
*v3.4: AskUserQuestion stage gates at all four PAUSE points. PAUSE 1 uses Batch Review (Pattern 3) for constraints/assumptions. PAUSE 2 uses Comparison Gate (Pattern 2) with preview fields for architectural alternatives. PAUSE 3 uses Guided Review (Pattern 5) walking through architecture, data model, and interfaces sequentially. PAUSE 4 uses Decision Gate (Pattern 1) for final approval. Fallback to prose-based patterns when AskUserQuestion is unavailable.*
*v3.3: Sibling design cross-references in Phase 0 for multi-design projects. Optional separate backend.md per feature when 5+ commands/queries (4-doc variant). Consolidated feature specifications (`docs/features/`) for COMPREHENSIVE mode with 10+ UCs — coverage matrix tying UCs to endpoints, UI, plan tasks, and tests. Legacy Update notice convention for evolving docs. All patterns validated against AMPS actions project (151 files, 5 numbered designs).*
*v3.2: Feature-first decomposition (3+ feature areas get per-feature api-surface, ui-mockup, test-plan docs). Co-located decisions/ and research/ directories. README.md index for designs with 5+ files. Glossary inheritance from discovery. Backend implementation guidance (command flow pseudocode, mapper logic, queries) merged into api-surface.md. Test plans as first-class per-feature documents with numbered test cases. Self-review log with specific issues/fixes per round. Revised "Implementation Spec" anti-pattern to distinguish algorithmic intent from line-by-line code. New anti-patterns: Monolith API Spec, Orphaned Research, Testing as Afterthought. Phase renumbering: old Phases 4+6 merged into new Phase 4 (Feature Design), UI mockups moved into per-feature docs, testing strategy replaced by per-feature test plans.*
