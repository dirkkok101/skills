---
name: technical-design
description: >
  Transform approved PRD requirements into a technical design through
  structured dialogue. Explores alternatives and trade-offs BEFORE
  committing to detailed design. Produces architecture diagrams, data
  models, API/interface specs, operational design, and work decomposition.
  The agent co-authors with the user, pausing after key decisions rather
  than generating everything at once. Use when user says "design the
  system", "create technical spec", "API design", "architecture", or
  after PRD approval. Also use for technical improvements after brainstorm.
argument-hint: "[feature name or PRD reference]"
---

# Technical Design: Requirements → Architecture & Specifications

**Philosophy:** The value of a design doc is in the decisions it records, not the solution it describes. If the solution is obvious enough that there are no trade-offs, you probably don't need a design doc. Explore alternatives first, commit to an approach, then detail the solution. The document should still be useful 6 months later when someone asks "why did we build it this way?"

**Duration targets:** BRIEF ~20-30 minutes, STANDARD ~45-90 minutes, COMPREHENSIVE ~2-3 hours. These are guidelines — complex domains may need more time in Phase 2 (alternatives), but if you're spending most of the time on Phases 4-8 (detailed design), the balance is wrong. The thinking should be front-loaded.

## Why This Matters

A design doc that just describes the solution is a spec sheet — useful but not valuable. This skill produces designs that are:
- **Decision-driven** — alternatives explored and trade-offs made explicit before detailed design
- **Collaborative** — the user validates key decisions at each stage
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

---

## Mode Selection

Determine mode from brainstorm scope classification or ask user:

| Mode | When | Sections | Output |
|------|------|----------|--------|
| **BRIEF** | Simple feature, BRIEF scope, 1-2 files changed | Constraints, decisions, API sketch, work decomposition | Single `design.md` |
| **STANDARD** | Typical feature, STANDARD scope | All core phases, selected diagrams | `design.md` + diagram files |
| **COMPREHENSIVE** | Complex feature, COMPREHENSIVE scope, multi-service | All phases including security, operational design, deployment | Full file set |

BRIEF mode produces a single concise design document (~50-100 lines). Skip diagram selection — include inline diagrams only where they clarify something prose cannot. For BRIEF mode, follow the phase structure but apply skip markers noted in each phase. The BRIEF template at the end shows the expected output format.

---

## Collaborative Model

This skill uses PAUSE points where the agent stops and waits for user input. Decisions made at PAUSE points shape all downstream design work.

```
Phase 0: Import & Understand
Phase 1: Constraints, Assumptions & Kill Criteria Check
  ── PAUSE 1: "Are these constraints correct? Anything missing?" ──
Phase 2: Key Decisions & Alternatives
  ── Diagram Selection (informed by decisions) ──
  ── PAUSE 2: "Here are the options. Which approach for each?" ──
Phase 3: System Architecture + Data Model
  ── Architecture Self-Review (catch structural issues early) ──
  ── PAUSE 3: "Architecture and data model — does this look right?" ──
Phases 4-6: Detailed Design (API, sequences, UI)
Phase 7: Security & Privacy (if applicable)
Phase 8: Operational Design (informed by security decisions)
Phase 9: Testing Strategy
Phase 10: Work Decomposition
Phase 11: Self-Review
  ── PAUSE 4: "Design complete. Review and approve?" ──
```

---

## Critical Sequence

### Phase 0: Prerequisites

**Step 0.1 — Resolve and Import:**

Import upstream artifacts into the design workspace:
- **PRD** — `docs/prd/{feature}/prd.md` (requirements, acceptance criteria, NFRs)
- **Discovery brief** — `docs/discovery/{feature}/discovery-brief.md` (domain analysis, risk assessment)
- **Brainstorm output** — `docs/brainstorm/{feature}/brainstorm.md` (chosen approach, scope, kill criteria)
- **Existing architecture docs** — `docs/architecture/` (current system context)
- **Learnings** — `docs/learnings/` (relevant compound learnings from past work)

Create the output directory: `docs/designs/{feature}/`

Do not re-interview the user for context that exists in these artifacts. Import it, reference it, build on it.

**Step 0.2 — Load References:**

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

**PAUSE 1:** Present constraints and assumptions to the user.
"Here are the constraints and assumptions I've identified. Are these correct? Anything missing that would change the design approach?"

Response options:
- **Accept** — constraints are correct, proceed to alternatives
- **Modify** — correct or add constraints (specify which)
- **Escalate** — constraints reveal a fundamental problem; return to PRD or brainstorm

---

### Phase 2: Key Decisions & Alternatives

**This is the most important phase.** Explore the design space before committing. The research shows that writing alternatives first forces you to consider the full solution space rather than anchoring on the first idea.

**Step 2.1 — Identify Decisions:**

List every significant decision this design requires:
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

**Step 2.3 — ADR Extraction:**

If any decision establishes a precedent or constrains future projects beyond this feature, extract it as a standalone ADR:

```
"Decision {N} about {topic} affects more than this feature — it sets a pattern
for {broader scope}. Extract as ADR? [yes / no]"
```

If yes, create `docs/adr/NNNN-{decision-title}.md` using the project's ADR template.

**Step 2.4 — Diagram Selection (STANDARD + COMPREHENSIVE):**

Now that decisions are made, select which diagrams to generate based on the chosen approaches:

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
  [ ] UI Mockups:
      IF feature has a user interface
      → populated, empty, error states per screen
  [ ] Deployment Diagram:
      ONLY IF infrastructure changes are required

NEVER GENERATE:
  [ ] C4 Level 4 (Code) — use IDE for this
```

Present checklist to user: "Based on the decisions above, I plan to generate: {list}. Any additions or removals?"

**PAUSE 2:** Present all decisions with alternatives and recommendations.
"Here are the key design decisions with alternatives. Which approach do you prefer for each? Any decisions I missed?"

Response options:
- **Accept** — agree with all recommendations
- **Choose** — select different approaches for specific decisions (specify which)
- **Add** — identify missing decisions that need alternatives explored
- **Escalate** — decisions reveal that the approach from brainstorm won't work; return upstream

The user's choices here determine the entire detailed design that follows.

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

**PAUSE 3:** Present architecture diagrams and data model together.
"Here's the system architecture and data model based on the decisions above. Does this look right before I detail the APIs and sequences?"

Response options:
- **Accept** — architecture and data model are sound, proceed to detailed design
- **Modify** — adjust specific aspects (specify which)
- **Rethink** — fundamental concerns; revisit Phase 2 decisions

---

### Phase 4: API / Interface Specification (IF feature has interfaces)

**Step 4.1 — Determine Interface Style:**

The interface style should follow existing project patterns. Check project CLAUDE.md for conventions.

**Step 4.2 — Specify Each Endpoint/Operation:**

For each interface point, document:

```markdown
### {METHOD} /api/v1/{resource}
Maps to: FR-{MODULE}-{NAME}
Auth: {authentication/authorization requirement}

Request:
  { name: string, description: string?, parentId: uuid? }

Validation:
  name: required, max 200 chars, unique within tenant
  description: max 2000 chars

Success Response ({status code}):
  { id: uuid, name: string, createdAt: timestamp }

Error Responses:
  400 — validation failure (field-level errors)
  401 — not authenticated
  403 — missing required permission
  409 — name already exists within scope
  422 — business rule violation
```

Adapt the format to match the project's API style (REST, GraphQL, gRPC, event-driven, etc.). The key information is the same regardless of style: inputs, validation, outputs, errors, auth, and which FR it implements.

**Step 4.3 — Shared Types:**

Document any DTOs, value objects, or shared types that appear across multiple interfaces.

Output: `api-spec.md`

---

### Phase 5: Sequence & Workflow Diagrams (IF selected)

**Step 5.1 — Sequence Diagrams:**

One ASCII sequence diagram per critical flow. Use conventions from `ascii-conventions.md`.

Generate for:
- Each write flow (create, update, delete)
- Primary read flow (list with filtering)
- Primary error recovery flow

Rules: 3-5 participants max, label messages with actual endpoint/method names, show request AND response, use ALT blocks for error paths, width under 100 characters.

**Step 5.2 — Workflow / Process Diagrams (IF selected):**

ASCII workflow diagrams for business processes with decision points. Include swimlanes when multiple actors/systems are involved.

**Step 5.3 — Data Flow Diagrams (IF selected):**

Context diagram + Level 0 DFD. Useful for security threat modelling (STRIDE input) and integration documentation.

Output: `sequences.md`, `workflows.md`, `data-flows.md` (as applicable)

---

### Phase 6: UI Mockups (IF feature has UI)

ASCII mockups using conventions from `ascii-conventions.md`.

For each screen, generate SEPARATE mockups for:
1. **Populated** — normal operation with realistic data
2. **Empty** — no data yet, include call-to-action
3. **Error** — validation errors, server errors

Per mockup: component hierarchy, form fields mapped to API inputs, validation rules (client-side vs. server-side), action buttons mapped to API calls.

Output: `ui-mockups.md`

---

### Phase 7: Security & Privacy (IF applicable)

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

### Phase 8: Operational Design (STANDARD + COMPREHENSIVE)

This phase covers how the system runs in production — not just how it's built. These concerns are first-class design decisions, not afterthoughts. Security decisions from Phase 7 inform this phase.

**Step 8.1 — Deployment & Rollout:**

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

**Step 8.2 — Failure Modes:**

```markdown
### Failure Modes
| Component | Failure Mode | Impact | Mitigation |
|-----------|-------------|--------|------------|
| {service} | {what can go wrong} | {blast radius} | {circuit breaker, retry, fallback} |
| {database} | {connection failure} | {impact} | {connection pooling, read replicas} |
| {external dep} | {unavailable} | {impact} | {graceful degradation, cached response} |
```

**Step 8.3 — Observability:**

```markdown
### Observability
- **Metrics:** {Key metrics to track — latency, error rate, throughput}
- **Logging:** {What to log, structured logging fields, log levels}
- **Alerting:** {What conditions trigger alerts, who gets paged}
- **Dashboards:** {What should be visible at a glance}
- **Audit trail:** {Security-relevant events from Phase 7}
```

Output: included in `design.md`

---

### Phase 9: Testing Strategy

```markdown
## Testing Strategy

### Unit Tests
- {Key business logic to test}
- {Complex validation rules}
- {Domain service methods}

### Integration Tests
- Contract tests for each interface (request/response shapes, status codes)
- Data layer integration tests for complex queries
- Auth policy tests (verify correct permissions enforced)

### E2E Tests
- Critical user paths: {from use cases}
- Cross-system flows: {from workflows}

### Performance Tests (if NFRs require)
- Load target: {from NFRs}
- Key scenarios: {which flows under load}
```

Output: included in `design.md`

---

### Phase 10: Work Decomposition Preview

**This section feeds directly into /plan.**

```markdown
## Work Decomposition

### Component Breakdown
| Component | Scope | Complexity | Risk | Implements |
|-----------|-------|------------|------|-----------|
| Data Model | Entities, migrations, config | M | Low | FR-{NAME}, FR-{NAME} |
| Write Path | Create/Update/Delete logic | L | Medium | FR-{NAME} through FR-{NAME} |
| Read Path | List/Get/Search logic | S | Low | FR-{NAME}, FR-{NAME} |
| Interfaces | Endpoints/operations, auth | M | Low | All FRs |
| UI | Forms, lists, detail views | L | Medium | All FRs |
| Integration | External system wiring | M | High | FR-{NAME} |

### Dependency Graph
  Data Model ──> Write Path ──> Interfaces ──> UI
      |              |
      +──> Read Path─+
      |
      +──> Integration

### Suggested Execution Order
1. Data Model — everything depends on this
2. Write Path + Validation
3. Read Path
4. Interfaces — expose to clients
5. UI — consume the interfaces
6. Integration — external systems
```

Output: included in `design.md`

---

### Phase 11: Self-Review

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Review Themes:**

1. **Decisions Documented** — Every significant decision has alternatives? Trade-offs explicit?
2. **Architecture Soundness** — Follows existing patterns? Consistent with project conventions?
3. **Interface Completeness** — Every FR has an interface point? Input/output types defined? Error codes specific?
4. **Data Model Integrity** — ER matches interface needs? Relationships correct? Migrations safe?
5. **Diagram Accuracy** — Sequences match interfaces? Flows match use cases?
6. **Operational Readiness** — Deployment strategy? Failure modes covered? Observability defined?
7. **Traceability** — Every interface maps to FR? Every FR covered?
8. **Proportionality** — Detail depth matches irreversibility? Not over-designing internals?

**Known limitation:** Self-review is performed by the same agent that wrote the design. Mitigate by following themes strictly as a checklist. Invite the user to spot-check areas where you're least confident (typically failure modes and edge cases).

**Step 11.1 — Open Questions:**

Before presenting, list any unresolved items:

```markdown
## Open Questions
| # | Question | Impact | Owner | Due |
|---|----------|--------|-------|-----|
| 1 | {unresolved technical question} | {what's blocked} | {who decides} | {when} |
```

If the project uses an issue tracker, create tracked items for open questions that need resolution before implementation can begin: "These open questions need resolution. Want me to create tracked issues for them?"

If there are no open questions, state "None — all design decisions resolved." This forces explicit acknowledgment rather than silently hoping everything is covered.

**PAUSE 4:** Present completed design with summary.

```markdown
## Technical Design Complete

**Feature:** {name}
**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**Architecture docs:** {count} files in docs/designs/{feature}/
**Diagrams generated:** {list of diagram types}
**Key decisions:** {count} decisions with {total} alternatives explored
**Interfaces defined:** {count}
**Entities defined:** {count}

Ready for review:
1. "Accept" / "design approved" → Proceed to /plan
2. "Modify {section}" → Iterate on specific section
3. "Park" → Save for later
4. "Abandon" → Document decision rationale
```

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
Reference existing patterns from the codebase. — from Phase 3}

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

```
${PROJECT_ROOT}/docs/designs/{feature}/
├── design.md            # Constraints, decisions, alternatives, security, operations, testing, decomposition
├── architecture.md      # C4 diagrams + data model (STANDARD+)
├── data-model.md        # ER diagram + entity definitions + migration (if applicable)
├── api-spec.md          # Interface specification (if applicable)
├── sequences.md         # Sequence diagrams (if selected)
├── workflows.md         # Workflow diagrams (if selected)
├── data-flows.md        # DFDs (if selected)
├── ui-mockups.md        # Mockups with multiple states (if selected)
└── progress.md          # Phase tracking
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

**The Implementation Spec** — Line-by-line pseudocode that belongs in the codebase. Design docs operate at a higher level of abstraction. Describe WHAT components do and HOW they interact, not the code inside them. If you're writing function bodies, you've gone too deep.

**Scope Confusion** — Re-arguing product requirements in the technical design. The TDD accepts the PRD's requirements as given. If a requirement seems wrong, feed that back to the PRD, don't silently change scope. The right action is to escalate, not to quietly design around it.

**Missing Operations** — No deployment strategy, no failure modes, no monitoring. These aren't afterthoughts — they're first-class design concerns that affect architecture decisions. If you design the system without thinking about how it fails, the first production incident will reveal the gaps.

**Premature Future-Proofing** — Designing for 100x scale when current load is trivial. Design for what you know, document assumptions about growth, and note where the design would need to change at scale. The design doc captures these assumptions so future engineers know when to revisit.

---

## Reference Files

For project-specific patterns: check project CLAUDE.md for pattern reference files
For domain-specific patterns: `_shared/references/{domain}.md`
For ASCII diagram conventions: `_shared/references/ascii-conventions.md`

---

*Skill Version: 3.1*
*v3.1: Duration targets, kill criteria check at Phase 1, prose-based artifact import (no hardcoded shell), diagram selection moved after Phase 2 decisions, data model merged into Phase 3 for joint architecture validation, architecture self-review before PAUSE 3, security before operations (Phase 7→8), structured PAUSE response options, conditional issue tracker for open questions, BRIEF template references phases with skip markers, anti-patterns explain WHY*
