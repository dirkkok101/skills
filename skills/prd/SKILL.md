---
name: prd
description: >
  Generate a Product Requirements Document with tiered depth: Brief (1-page),
  Standard (3-8 pages), or Comprehensive (full spec with Cockburn use cases,
  security criteria, and compliance checkpoints). Imports brainstorm boundaries
  and discovery brief when available. Use when starting a business feature that
  needs requirements, when user says "write requirements", "create PRD",
  "define user stories", or after brainstorm/discovery approval.
argument-hint: "[feature name or brainstorm reference]"
---

# PRD: Problem → Formal Requirements

**Philosophy:** A PRD is problem-first, evidence-driven, and boundary-defining. It separates product decisions (fixed) from implementation decisions (open for engineering). The best PRDs are read like blog posts — engaging narrative with precise acceptance criteria. Every requirement traces back to a user and a business goal.

## Core Principles

1. **Problem before solution** — establish "why" before "what"
2. **Tiered depth** — match document weight to feature complexity
3. **Domain-aware** — import discovery brief, add security/compliance criteria where needed
4. **Testable requirements** — every acceptance criterion is verifiable by a test
5. **Traceability** — FR-{MODULE}-{DESCRIPTIVE-NAME} IDs enable downstream tracing to design, tests, code

---

## Trigger Conditions

Run this skill when:
- User says "write requirements", "create PRD", "define user stories"
- After brainstorm approval for business features
- After discovery completion for complex features
- Starting a feature that needs formal requirements documentation

---

## Mode Selection

**Determine mode from brainstorm scope classification or ask user:**

| Mode | When | Sections | Output Size |
|------|------|----------|-------------|
| **BRIEF** | BRIEF scope, simple feature, 1-2 sprints | Problem, Goals, Non-Goals, 3-5 Stories, NFRs | ~50-100 lines |
| **STANDARD** | STANDARD scope, typical feature, 1-2 months | All sections, user stories (not full use cases) | ~200-300 lines |
| **COMPREHENSIVE** | COMPREHENSIVE scope, complex feature, quarter+ | All sections + Cockburn use cases + security/compliance criteria | ~400-500 lines |

If brainstorm exists, use its scope classification. Otherwise ask:
"How complex is this feature? [brief / standard / comprehensive]"

---

## Critical Sequence

### Phase 0: Prerequisites

**Step 0.1 — Resolve PROJECT_ROOT:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
mkdir -p "${PROJECT_ROOT}/docs/prd/{feature}"
```

**Step 0.2 — Import Upstream Artifacts:**

```bash
# Brainstorm output
cat "${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md" 2>/dev/null

# Discovery brief (COMPREHENSIVE mode)
cat "${PROJECT_ROOT}/docs/discovery/{feature}/discovery-brief.md" 2>/dev/null

# Research brief
cat "${PROJECT_ROOT}/docs/research/{feature}/research-brief.md" 2>/dev/null
```

Import: problem statement, chosen approach, boundaries, scope classification, domain requirements, actor list, workflow maps, security analysis, compliance checkpoints.

**Step 0.3 — If No Upstream Exists:**

Ask user:
- "What is the feature name and core problem it solves?"
- "Who are the primary users?"
- "What scope? [brief / standard / comprehensive]"

---

### Phase 1: Document Setup

```markdown
# PRD: {Feature Name}

**Status:** Draft | In Review | Approved
**Version:** 0.1
**Date:** {today}
**Author:** {user}
**Scope:** {BRIEF | STANDARD | COMPREHENSIVE}
**Brainstorm:** {link or N/A}
**Discovery:** {link or N/A}
```

---

### Phase 2: Problem & Business Context

**All modes — this is ALWAYS the first substantive section.**

**Step 2.1 — Problem Statement:**

```markdown
## Problem Statement
{2-3 sentences describing the user problem with specific evidence:
 metrics, support tickets, user research, competitive data.
 Import from brainstorm root problem.}

Impact:
- {Quantified effect 1 — e.g., "23% of support tickets"}
- {Quantified effect 2}

Why now: {urgency, opportunity, strategic alignment}
```

Quality check: Does this explain the pain WITHOUT describing the solution?

**Step 2.2 — Goals (measurable outcomes, not features):**

```markdown
## Goals
- {Outcome 1 — "Reduce time-to-access from 4.2 days to <1 day"}
- {Outcome 2 — "Eliminate cross-system permission inconsistencies"}
- {Outcome 3}
```

3-5 goals maximum. Each must be measurable.

**Step 2.3 — Non-Goals:**

```markdown
## Non-Goals
- {Explicit exclusion with rationale — "Mobile admin (admin tasks are desktop-only)"}
- {Another exclusion}
```

Import from brainstorm anti-requirements.

**Step 2.4 — Success Metrics (STANDARD + COMPREHENSIVE):**

```markdown
## Success Metrics
| Metric | Current | Target | By When | How Measured |
|--------|---------|--------|---------|--------------|
| {KPI} | {baseline} | {target} | {date} | {method} |
```

---

### Phase 3: User Personas

**STANDARD + COMPREHENSIVE only. BRIEF mode: 1-2 sentences per persona.**

For each persona (2-4 max), document:

```markdown
## User Personas

### P1: {Name}, {Role} (Primary)
"{Archetype description — 'Sarah, IT Manager at a mid-tier mining company'}"
- **Goals:** {What they're trying to accomplish — 2-3 items}
- **Pain Points:** {What frustrates them today — 2-3 items}
- **Current Workaround:** {How they cope without this feature}
- **Success Criteria:** {How they know the feature is working}
- **Tech Level:** {Comfortable with admin UIs / developer / non-technical}
- **Frequency:** {How often they'd use this feature}
```

Import actor list from discovery brief if available.

---

### Phase 4: Use Cases (COMPREHENSIVE mode only)

**BRIEF/STANDARD modes skip this phase — user stories in Phase 5 are sufficient.**

**COMPREHENSIVE mode: Cockburn fully-dressed format for primary use cases.**

```markdown
## Use Cases

### UC-{MODULE}-001: {Goal as Active Verb Phrase}

  Scope:           {System name}
  Level:           User Goal
  Primary Actor:   {Persona from Phase 3}
  Trigger:         {Event that starts this use case}

  Preconditions:
    - {State that must be true BEFORE the use case starts}

  Success End Condition:
    {Observable state of the world when goal is achieved}

  Minimal Guarantee (on failure):
    {What the system guarantees even if the use case fails —
     e.g., "No data corrupted, audit log records the attempt"}

  Main Success Scenario:
    1. {Actor} {action at user-intention level}
    2. System {validates/processes/displays}
    3. {Actor} {next action}
    ...
    N. System {confirms completion}

  Extensions:
    2a. {Condition — e.g., "Name already exists in tenant"}:
        2a1. System displays "{specific error message}"
        2a2. Actor corrects input, return to step 2
    3a. {Condition}:
        3a1. System {response}
        3a2. Use case ends in failure

  Business Rules:
    BR-{MODULE}-001: {Specific rule with parameters}
    BR-{MODULE}-002: {Another rule}

  Related:
    Priority: {Critical / High / Medium / Low}
    Frequency: {Expected usage}
    Performance: {Time target}
    Related UCs: {UC-XXX}
```

Guidelines:
- 3-9 steps in main success scenario
- Write at user-intention level, not UI-action level
- Every step that can fail gets an extension
- Extensions branch from specific step numbers (2a, 3a, not "if fails")
- 5-8 use cases for a typical feature

---

### Phase 5: Functional Requirements

**All modes. BRIEF: 3-5 stories. STANDARD: 8-15 stories. COMPREHENSIVE: 15-25 stories.**

```markdown
## Functional Requirements

### Epic: {Feature Area}

#### FR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}
Priority: Must / Should / Could / Won't
Complexity: S / M / L / XL
Related: UC-{MODULE}-001 (COMPREHENSIVE mode)

As a {persona from Phase 3},
I want to {action},
So that {benefit}.

Acceptance Criteria:
  Given {precondition}
  When {action}
  Then {expected result}

  Given {alternate precondition}
  When {alternate action}
  Then {alternate result}
```

**COMPREHENSIVE mode adds Security and Compliance Criteria on applicable stories:**

```markdown
Security Criteria: (from discovery security analysis)
  - {Requirement — "Client secrets hashed with BCrypt before storage"}
  - {Requirement — "Redirect URIs validated against exact match"}

Compliance Criteria: (from discovery compliance checkpoints)
  - POPIA: {Requirement — "Application metadata includes processing purpose"}
  - SOC 2: {Requirement — "All CRUD operations logged with actor and timestamp"}
```

**Traceability rules:**
- Every FR maps to at least one persona
- COMPREHENSIVE: every FR maps to at least one UC
- Every FR has testable acceptance criteria in Given/When/Then
- Security criteria on stories touching auth, PII, or destructive operations
- Compliance criteria on stories touching regulated data

**Stable ID convention:** Use descriptive IDs based on feature area, not sequential numbers. `FR-APP-REGISTER` is more stable than `FR-APP-001` — it survives renumbering when requirements are added or removed. Downstream artifacts (design, plan, beads, tests) reference these IDs, so stability prevents cascade updates.

---

### Phase 6: Non-Functional Requirements

**All modes. BRIEF: 2-3 NFRs. STANDARD: 4-6 NFRs. COMPREHENSIVE: 6-10 NFRs.**

```markdown
## Non-Functional Requirements

### NFR-{MODULE}-001: {Title}
Category: Performance / Security / Scalability / Data / Accessibility
Target: {Specific measurable target — "95th percentile < 200ms"}
Load Condition: {Context — "100 concurrent users per tenant"}
Measurement: {How to verify — "Application Insights P95 metric"}
Rationale: {Why this target matters}
```

Categories to consider:
1. **Performance** — API response time, page load, batch throughput
2. **Security** — Authentication, encryption, audit logging, rate limiting
3. **Scalability** — Concurrent users, data volume, geographic distribution
4. **Data** — Retention, backup, deletion, migration
5. **Accessibility** — WCAG 2.1 AA, keyboard navigation, screen readers

**Every NFR has a number, not an adjective.** "Fast" is not a requirement. "< 200ms P95" is.

---

### Phase 7: Prioritisation & Dependencies

**STANDARD + COMPREHENSIVE only.**

```markdown
## Prioritisation (MoSCoW)

### Must Have (MVP)
- FR-{MODULE}-{NAME}: {title}
- FR-{MODULE}-{NAME}: {title}
- NFR-{MODULE}-001: {title}
{5-10 items. Without these, the feature doesn't solve the problem.}

### Should Have (v1)
- FR-{MODULE}-{NAME}: {title}
{Significant value but not blocking MVP. Could slip to v1.1.}

### Could Have (Future)
- {Enhancement idea}
{Nice-to-have. No impact on core functionality.}

### Won't Have (Yet)
- {Excluded item} — Reason: {why}
{Explicitly out of scope. Prevents scope creep.}

## Dependency Graph

{ASCII diagram showing requirement dependencies}

  FR-REGISTER ──> FR-VALIDATE ──> FR-PROVISION
       |                              |
       +──> FR-CONFIGURE          FR-NOTIFY
       |
       +──> NFR-001
```

---

### Phase 8: Domain Validation (COMPREHENSIVE only)

**Verify that discovery requirements are fully covered:**

```markdown
## Domain Validation
- [ ] All IN SCOPE discovery requirements (DR-*) mapped to at least one FR?
- [ ] Security criteria present on all security-sensitive stories?
- [ ] Compliance criteria present where regulations apply?
- [ ] All integration points from discovery have corresponding NFRs?
- [ ] All actors from discovery have at least one use case?

### Coverage Matrix
| Discovery Req | Mapped FR | Status |
|--------------|-----------|--------|
| DR-{MODULE}-{NAME} | FR-{MODULE}-{NAME} | ✅ Covered |
| DR-{MODULE}-{NAME} | FR-{MODULE}-{NAME}, FR-{MODULE}-{NAME} | ✅ Covered |
| DR-{MODULE}-{NAME} | — | ⚠ Gap (deferred to v2) |
```

---

### Phase 9: Self-Review & Approval

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Known limitation:** Self-review is performed by the same agent that wrote the PRD. Mitigate by following themes strictly as a checklist, and inviting the user to spot-check the sections where you're least confident (typically edge cases and error flows in acceptance criteria).

**Review Themes:**

1. **Completeness** — All personas covered? All stories have acceptance criteria? All must-haves prioritised?
2. **Clarity** — Could a developer implement without asking questions? Criteria unambiguous?
3. **Testability** — Every criterion verifiable? Metrics measurable? Performance targets have units?
4. **Scope Discipline** — Nothing exceeds brainstorm boundaries? Won't-Have items have reasoning?
5. **Traceability** — FR → UC → Persona chain complete? (COMPREHENSIVE only)
6. **Domain Validation** — Discovery requirements fully covered? (COMPREHENSIVE only)

---

## PRD Output Template

Save to: `${PROJECT_ROOT}/docs/prd/{feature}/prd.md`

**See the detailed template structure in each phase above. The final document follows the phase order: Problem → Personas → Use Cases → FRs → NFRs → Prioritisation → Validation.**

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "prd approved" | PRD complete and ready | Proceed to /technical-design |
| "refine" | Gaps or clarity issues | Return to relevant phases |
| "park" | Save for later | Archive; user resumes later |
| "abandon" | Don't build this feature | Document decision rationale |

When exiting, update PRD metadata: Status, Next Step, Completion Date.

---

## Anti-Patterns

❌ **The Novel** — 50+ pages nobody reads → Use BRIEF/STANDARD modes
❌ **Solution-First** — Features before problem → Always write Phase 2 first
❌ **Vague Criteria** — "System should be fast" → Numbers on everything
❌ **Missing Error Cases** — Only happy path → Every extension becomes an AC
❌ **Orphan Stories** — Stories not linked to personas or use cases → Traceability check
❌ **Kitchen Sink** — v1 through v10 in one doc → Strict MoSCoW with Won't Have

---

*Skill Version: 2.0*
*Added in v2: Tiered modes, Cockburn use cases, security/compliance criteria, stable ID convention*
