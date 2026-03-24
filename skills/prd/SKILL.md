---
name: prd
description: >
  Generate a Product Requirements Document through structured dialogue with
  the user. Produces tiered output: Brief (1-page), Standard (full PRD), or
  Comprehensive (PRD + Cockburn use cases + security/compliance criteria).
  The agent co-authors with the user, pausing at key decision points rather
  than generating everything at once. Use when starting a business feature
  that needs requirements, when user says "write requirements", "create PRD",
  "define user stories", or after brainstorm/discovery approval.
argument-hint: "[feature name or brainstorm reference]"
---

# PRD: Problem → Formal Requirements

**Philosophy:** The best PRDs emerge from dialogue, not monologue. The agent drafts, the user validates, and together they surface edge cases, priorities, and assumptions that neither would find alone. A PRD separates product decisions (fixed) from implementation decisions (open for engineering). Every requirement traces back to a user pain and a business goal.

**Target duration:** BRIEF ~30 minutes, STANDARD ~1-2 hours, COMPREHENSIVE ~2-4 hours.
**Target length:** BRIEF ~1 page, STANDARD ~5-10 pages, COMPREHENSIVE ~10-20 pages.

## Why This Matters

A PRD that nobody reads is worse than no PRD — it creates false confidence. This skill produces PRDs that are:
- **Co-authored** — the user validates problem, personas, and priorities at each stage
- **Testable** — every acceptance criterion maps to a verifiable test
- **Bounded** — explicit assumptions, constraints, and non-goals prevent scope creep
- **Traceable** — stable FR IDs chain through design → plan → beads → tests → code

---

## Trigger Conditions

Run this skill when:
- User says "write requirements", "create PRD", "define user stories"
- After brainstorm approval for business features
- After discovery completion for complex features
- Starting a feature that needs formal requirements documentation

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

Determine mode from brainstorm scope classification or ask user:

| Mode | When | What You Get |
|------|------|-------------|
| **BRIEF** | Simple feature, 1-2 sprints, BRIEF scope | One-page: Problem, Goals, 3-5 stories with acceptance criteria |
| **STANDARD** | Typical feature, STANDARD scope | Full PRD: all sections, 8-15 stories, personas, NFRs, priorities |
| **COMPREHENSIVE** | Complex feature, COMPREHENSIVE scope | Full PRD + Cockburn use cases + security/compliance criteria |

If brainstorm exists, use its scope classification. Otherwise ask:
"How complex is this feature? [brief / standard / comprehensive]"

### Policy & Standards PRDs

Not every PRD maps to a single bounded module with its own aggregate root, personas, and CRUD operations. Some PRDs define **shared policies, standards, or cross-cutting concerns** that multiple modules consume (e.g., error handling contracts, data lifecycle rules, rate limiting policies).

These PRDs still follow the same structural conventions, but some sections may be lighter:

- **Personas:** May reference project-wide personas rather than defining new ones. Still use the `### P{n}:` format, but a 1-line "See [project personas doc]" reference is acceptable if personas are defined centrally.
- **Use Cases:** May have fewer use cases or none — policy PRDs define rules, not user flows. If there are no use cases, state "N/A — this PRD defines standards consumed by module PRDs" in the Use Cases section.
- **NFRs:** Aim for the minimum (6 for COMPREHENSIVE) but some policy PRDs may legitimately have fewer if the policies themselves are the non-functional constraints. Document why in a note if under the minimum.
- **Dependency Graph:** May show which modules consume the policies rather than FR-to-FR build order.

The structural conventions (heading formats, numbering, table columns) still apply without exception. Only the *depth* of content adapts.

---

## Collaborative Model

```
Phase 0: Prerequisites & Import
Phase 1: Document Setup
Phase 2: Problem & Business Context
Phase 3: User Personas (STANDARD+)
  ── PAUSE 1: "Problem, personas, and assumptions right?" ──
Phase 4: Assumptions, Constraints & Risks
Phase 5: Use Cases (COMPREHENSIVE only)
  ── PAUSE 2: "Review each use case individually." ──
Phase 6: Functional Requirements
  ── PAUSE 3: "Review each requirement individually." ──
Phase 7: Non-Functional Requirements
Phase 8: Prioritisation & Dependencies (STANDARD+)
  ── PAUSE 4: "Priorities right? Must Haves truly minimal?" ──
Phase 8b: Integration Points (COMPREHENSIVE only)
Phase 9: Domain Validation (COMPREHENSIVE only)
Phase 10: Self-Review & Approval
  ── PAUSE 5: "Targeted validation questions." ──
Phase 10b: Document Approval (COMPREHENSIVE only)
```

**BRIEF mode** skips: Personas (Phase 3), Use Cases (Phase 5), Prioritisation (Phase 8), Integration Points (Phase 8b), Domain Validation (Phase 9), Document Approval (Phase 10b). Uses the streamlined BRIEF template instead.

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

# Discovery glossary
cat "${PROJECT_ROOT}/docs/discovery/{feature}/glossary.md" 2>/dev/null

# Research brief
cat "${PROJECT_ROOT}/docs/research/{feature}/research-brief.md" 2>/dev/null
```

Import: problem statement, chosen approach, boundaries, scope classification, **kill criteria**, domain requirements, actor list, workflow maps, security analysis, compliance checkpoints, **glossary terms**.

**Step 0.3 — If No Upstream Exists:**

Ask user:
- "What is the feature name and core problem it solves?"
- "Who are the primary users?"
- "What scope? [brief / standard / comprehensive]"

---

### Phase 1: Document Setup

```markdown
# PRD: {Feature Name}

| Field | Value |
|---|---|
| Version | 0.1 |
| Date | {today} |
| Author | {user} |
| Status | Draft |
| Scope | {BRIEF / STANDARD / COMPREHENSIVE} |
| Brainstorm | {link or N/A} |
| Discovery | {link or N/A} |
| Depends On | {links to prerequisite PRDs, or N/A} |

## Document History

| Version | Date | Changes |
|---|---|---|
| 0.1 | {today} | Initial PRD |
```

Update the Document History table after each major revision — self-review rounds, user feedback incorporation, scope changes. This makes the PRD's evolution auditable.

**Step 1.2 — Table of Contents (COMPREHENSIVE, 10+ sections):**

For COMPREHENSIVE PRDs that grow beyond 10 sections, add a navigational TOC after the metadata table:

```markdown
## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Goals](#goals)
3. [User Personas](#user-personas)
4. [Assumptions & Constraints](#assumptions--constraints)
5. [Use Cases](#use-cases)
6. [Functional Requirements](#functional-requirements)
7. [Non-Functional Requirements](#non-functional-requirements)
8. [Integration Points](#integration-points)
9. [Prioritisation](#prioritisation-moscow)
10. [Domain Validation](#domain-validation)
11. [Document Approval](#document-approval)
```

Update the TOC as sections are added during drafting. This prevents the "scroll-hunting" problem that appears in PRDs exceeding 15 pages.

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
- {Quantified effect 1 — e.g., "23% of support tickets relate to X"}
- {Quantified effect 2}

Why now: {urgency, opportunity, strategic alignment}
```

Quality check: Does this explain the pain WITHOUT describing the solution?

**Step 2.2 — Goals (measurable outcomes, not features):**

```markdown
## Goals
- {Outcome 1 — "Reduce time-to-access from 4.2 days to <1 day"}
- {Outcome 2 — "Eliminate cross-system permission inconsistencies"}
```

3-5 goals maximum. Each must be measurable. If you can't measure it, it's an aspiration, not a goal.

**Step 2.3 — Non-Goals:**

```markdown
## Non-Goals
- {Explicit exclusion with rationale — "Mobile admin (admin tasks are desktop-only)"}
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

**STANDARD + COMPREHENSIVE only. BRIEF mode: 1-2 sentences per persona inline with stories.**

For each persona (2-4 max):

```markdown
## User Personas

### P1: {Name}, {Role} (Primary)
"{Archetype description — 'Sarah, IT Manager at a mid-tier mining company'}"
- **Goals:** {What they're trying to accomplish — 2-3 items}
- **Pain Points:** {What frustrates them today — 2-3 items}
- **Current Workaround:** {How they cope without this feature}
- **Success Criteria:** {How they know the feature is working for them}
- **Tech Level:** {Comfortable with admin UIs / developer / non-technical}
- **Frequency:** {How often they'd use this feature}
```

Import actor list from discovery brief if available. Personas inform assumptions and constraints in Phase 4 — a "non-technical" persona constrains UI complexity, a "developer" persona may allow CLI-only interfaces.

#### PAUSE 1: Validate problem, personas, and context (Guided Review — Pattern 5)

**Step 1 — Problem + Goals + Non-Goals:** Present the problem statement, goals, and non-goals as formatted markdown, then:

```
AskUserQuestion:
  question: "Does the problem statement accurately describe the pain? Are goals measurable and non-goals clear?"
  header: "Problem"
  multiSelect: false
  options:
    - label: "Approved"
      description: "Problem framing, goals, and non-goals are correct."
    - label: "Needs revision"
      description: "Something needs changing — I'll provide notes."
    - label: "Skip for now"
      description: "Come back to this section later."
```

If "Needs revision": collect notes, iterate on the section, then re-present and re-ask.

**Step 2 — Personas:** Present personas as formatted markdown, then:

```
AskUserQuestion:
  question: "Do these personas match real users? Are their pain points and success criteria accurate?"
  header: "Personas"
  multiSelect: false
  options:
    - label: "Approved"
      description: "Personas reflect real users and their needs."
    - label: "Needs revision"
      description: "Something needs changing — I'll provide notes."
    - label: "Skip for now"
      description: "Come back to this section later."
```

If "Needs revision": collect notes, iterate, re-present and re-ask.

Do not proceed until the user confirms the problem framing and personas are right. Everything downstream depends on this.

---

### Phase 4: Assumptions, Constraints & Risks

**All modes. This section prevents the most common PRD failures — undocumented assumptions that blow up later.**

**Step 4.1 — Assumptions:**

Things we're taking for granted. If any prove false, requirements may need to change. Assumptions should be informed by the personas from Phase 3.

```markdown
## Assumptions
- {Technical: "The existing API can handle the additional load"}
- {Business: "P1 persona (IT Manager) has admin access to configure this feature"}
- {Data: "Historical data exists for the past 12 months"}
- {Timeline: "Third-party integration API will be stable by Q2"}
```

**Step 4.2 — Constraints:**

Hard limits that shape what's possible.

```markdown
## Constraints
- {Technical: "Must work within existing database schema"}
- {Business: "Budget limited to current team capacity"}
- {Regulatory: "Must comply with POPIA data residency requirements"}
- {Timeline: "Must ship before contract renewal in Q3"}
```

**Step 4.3 — Risks & Open Questions:**

Track unknowns throughout the PRD process. Update this section as questions surface in later phases.

```markdown
## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {What could go wrong} | Low/Med/High | Low/Med/High | {How to reduce} |

## Open Questions

| # | Question | Context | Status | Decision | Owner |
|---|----------|---------|--------|----------|-------|
| 1 | {Question} | {Why it matters} | Open / Resolved | {Decision if resolved} | {Who decides} |
| 2 | {Question} | {Context} | Open | — | {Owner} |
```

**COMPREHENSIVE mode:** Open Questions become **decision gates** — questions that must be resolved before implementation. Track resolution status through PRD revisions. The AMPS PRD tracked 15 questions with resolution status across 4 versions; unresolved questions at implementation time caused rework.

---

### Phase 5: Use Cases (COMPREHENSIVE mode only)

**BRIEF/STANDARD modes skip this phase — user stories in Phase 6 are sufficient.**

**Use cases are standalone files**, not sections inside the PRD. Each use case is 3-15KB — manageable, reviewable, and referenceable independently.

For tier definitions (Tier 1/2/3), file structure, use case template, scenario table format, index table format, and traceability index: see [references/prd-conventions.md](references/prd-conventions.md#use-case-template--conventions).

**Step 5.1 — Identify Use Case Set:**

Map personas and workflows from discovery to 5-10 use cases. Each represents a complete user goal. Assign depth tiers (Tier 1 = full Cockburn, Tier 2 = standard, Tier 3 = index entry).

**Step 5.2 — Write Each Use Case:**

Save each to the appropriate location (feature-scoped: `docs/prd/{feature}/use-cases/`, cross-module: `docs/use-cases/`). Use the template from the conventions reference.

**Step 5.3 — Reference Use Cases in PRD:**

Add a use case index section to the PRD that links to the standalone files.

**Step 5.4 — Optional: Traceability Index (COMPREHENSIVE, 5+ use cases):**

For projects with 5+ use cases, create a traceability index mapping scenarios to implementation evidence. Save to `docs/prd/{feature}/use-cases/traceability-index.md`.

#### PAUSE 2: Review each use case (Guided Review — Pattern 5)

Review each use case individually with the user. For each UC:

**Step 1 — Present full detail:** Show the use case summary as formatted markdown — UC ID, goal, actor, trigger, scenario flow overview, postconditions, and failure paths.

**Step 2 — Ask for verdict:**

```
AskUserQuestion:
  question: "Review this use case."
  header: "UC Review"
  multiSelect: false
  options:
    - label: "Approve"
      description: "Use case is good as-is. Move to the next one."
    - label: "Revise"
      description: "Needs changes — I'll provide notes."
    - label: "Remove"
      description: "Drop this use case entirely."
    - label: "Skip for now"
      description: "Come back to this after reviewing the rest."
```

**Step 3 — Handle verdict:**
- **Approve:** Mark as approved, move to next UC.
- **Revise:** Collect the user's notes, revise the use case file, re-present it, and re-ask.
- **Remove:** Delete the UC file and remove it from the index table. Move to next UC.
- **Skip for now:** Queue for a second pass after all other UCs are reviewed.

**Step 4 — Second pass:** After all UCs have been reviewed, re-present any skipped use cases and repeat Steps 1-3 for each.

This per-use-case approach mirrors the FR review process (PAUSE 3) and ensures each scenario gets focused attention before downstream skills consume them.

---

### Phase 6: Functional Requirements

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

  Given {error condition}
  When {invalid action}
  Then {error handling behavior}
```

**Stable ID convention:** Use descriptive IDs based on feature area, not sequential numbers. `FR-APP-REGISTER` is more stable than `FR-APP-001` — it survives when requirements are added or removed. Downstream artifacts (design, plan, beads, tests) reference these IDs, so stability prevents cascade updates.

**COMPREHENSIVE mode adds Security and Compliance Criteria on applicable stories:**

```markdown
Security Criteria: (from discovery security analysis)
  - {Requirement — "Secrets hashed before storage"}
  - {Requirement — "Redirect URIs validated against exact match"}

Compliance Criteria: (from discovery compliance checkpoints)
  - POPIA: {Requirement — "Metadata includes processing purpose"}
  - SOC 2: {Requirement — "All CRUD operations logged with actor and timestamp"}
```

#### Systematic Edge Case Elicitation

After drafting requirements, probe Must Have FRs for edge cases across 6 categories (duplicates, boundaries, concurrency, permissions, state, lifecycle). See [references/prd-conventions.md](references/prd-conventions.md#systematic-edge-case-elicitation) for the full checklist.

#### Requirement Quality Check

Before presenting requirements, scan for ambiguity words, testability, and independence issues. See [references/prd-conventions.md](references/prd-conventions.md#fr-quality-checklist) for the complete quality check rules.

#### PAUSE 3: Validate requirements one at a time (Guided Review — Pattern 5)

Review each functional requirement individually. For each FR:

**Step 1 — Present full detail:** Show the single requirement as formatted markdown with full FR detail — user story, acceptance criteria, priority, and complexity.

**Step 2 — Ask for verdict:**

```
AskUserQuestion:
  question: "Review this requirement."
  header: "FR Review"
  multiSelect: false
  options:
    - label: "Approve"
      description: "Requirement is good as-is. Move to the next one."
    - label: "Revise"
      description: "Needs changes — I'll provide notes."
    - label: "Remove"
      description: "Drop this requirement entirely."
    - label: "Skip for now"
      description: "Come back to this after reviewing the rest."
```

**Step 3 — Handle verdict:**
- **Approve:** Record as approved, move to next FR.
- **Revise:** Collect the user's notes (from "Other" field or follow-up), revise the requirement, re-present it, and re-ask.
- **Remove:** Drop the FR from the document with a brief rationale note. Move to next FR.
- **Skip for now:** Queue for a second pass after all other FRs are reviewed.

**Step 4 — Second pass:** After all FRs have been reviewed, re-present any skipped requirements and repeat Steps 1-3 for each.

This per-requirement approach ensures focused review — the detail is immediately above the question, with no scrolling required.

---

### Phase 7: Non-Functional Requirements

**All modes. BRIEF: 2-3 NFRs. STANDARD: 4-6 NFRs. COMPREHENSIVE: 6-10 NFRs.**

```markdown
## Non-Functional Requirements

### NFR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}
Category: Performance / Security / Scalability / Data / Accessibility
Target: {Specific measurable target — "95th percentile < 200ms"}
Load Condition: {Context — "100 concurrent users per tenant"}
Measurement: {How to verify}
Rationale: {Why this target — trace to problem statement, success metrics, or persona needs}
```

5 categories to consider (Performance, Security, Scalability, Data, Accessibility), mandatory audit NFR for state-changing modules, and strict minimum counts by mode (BRIEF: 2-3, STANDARD: 4-6, COMPREHENSIVE: 6-10). See [references/prd-conventions.md](references/prd-conventions.md#nfr-categories--minimums) for full details.

---

### Phase 8: Prioritisation & Dependencies

**STANDARD + COMPREHENSIVE only.**

```markdown
## Prioritisation (MoSCoW)

### Must Have (MVP)
- FR-{MODULE}-{NAME}: {title}
{5-10 items. Without these, the feature doesn't solve the problem.}

### Should Have (v1)
- FR-{MODULE}-{NAME}: {title}
{Significant value but not blocking MVP. Could slip to v1.1.}

### Could Have (Future)
- {Enhancement idea}

### Won't Have (Yet)
- {Excluded item} — Reason: {why}
{Explicitly out of scope. Prevents scope creep.}

## Dependency Graph

  FR-REGISTER ──> FR-VALIDATE ──> FR-PROVISION
       |                              |
       +──> FR-CONFIGURE          FR-NOTIFY

{ASCII diagram using ──> arrows showing FR-to-FR dependencies.
 Always include this diagram — it makes implementation ordering visible.
 Show which FRs must be built before others can start.}
```

#### PAUSE 4: Validate priorities (Guided Review — Pattern 5)

**Step 1 — Review Must Haves:** Present the Must Have list as formatted markdown, then:

```
AskUserQuestion:
  question: "Which Must Have items could actually be Should Have? (Select items to downgrade)"
  header: "Priorities"
  multiSelect: true
  options:
    - label: "FR-{MODULE}-{NAME-1}"
      description: "{Title}"
    - label: "FR-{MODULE}-{NAME-2}"
      description: "{Title}"
    - label: "FR-{MODULE}-{NAME-3}"
      description: "{Title}"
```

For selected items, move them to Should Have. If no items selected, Must Haves are confirmed as-is.

**Step 2 — Review Should Haves:** Present the Should Have list as formatted markdown, then:

```
AskUserQuestion:
  question: "Should any of these be upgraded to Must Have? (Select items to upgrade)"
  header: "Upgrades"
  multiSelect: true
  options:
    - label: "FR-{MODULE}-{NAME-1}"
      description: "{Title}"
    - label: "FR-{MODULE}-{NAME-2}"
      description: "{Title}"
```

For selected items, move them to Must Have.

Priority decisions shape what gets built first. Getting them wrong means building the wrong thing.

---

### Phase 8b: Integration Points (COMPREHENSIVE only)

**For platform services that other systems consume.** If this feature exposes APIs, events, or data that downstream systems depend on, document the integration surface at the PRD level. This prevents the common failure mode where integration requirements are discovered during implementation rather than planning.

```markdown
## Integration Points

### Consumed Services
| Service | Purpose | Failure Impact |
|---------|---------|---------------|
| {Upstream service} | {What this feature needs from it} | {What happens if unavailable} |

### Exposed Services
| Interface | Consumers | Contract Stability |
|-----------|-----------|-------------------|
| {API/Event/Data this feature provides} | {Who depends on it} | {Stable / Evolving / Experimental} |

### Integration NFRs
- {Latency requirements for cross-service calls}
- {Retry/circuit-breaker expectations}
- {Data consistency guarantees across service boundaries}
```

This section feeds directly into the technical design's API surface and the plan's dependency graph. Mark Contract Stability clearly — "Stable" means downstream consumers can rely on it without coordination; "Evolving" means breaking changes require coordination.

---

### Phase 9: Domain Validation (COMPREHENSIVE only)

Verify discovery requirements are fully covered:

```markdown
## Domain Validation
- [ ] All IN SCOPE discovery requirements (DR-*) mapped to at least one FR?
- [ ] Security criteria present on all security-sensitive stories?
- [ ] Compliance criteria present where regulations apply?
- [ ] All integration points from discovery have corresponding NFRs?
- [ ] All actors from discovery have at least one use case (in docs/prd/{feature}/use-cases/ or docs/use-cases/)?
- [ ] All use case files cross-reference back to the PRD?

### Coverage Matrix
| Discovery Req | Mapped FR | Use Case | Status |
|--------------|-----------|----------|--------|
| DR-{MODULE}-{NAME} | FR-{MODULE}-{NAME} | UC-{MODULE}-{NNN} | Covered |
| DR-{MODULE}-{NAME} | — | — | Gap (deferred to v2) |
```

---

### Phase 10: Self-Review & Approval

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Known limitation:** Self-review is performed by the same agent that wrote the PRD. Mitigate by following themes strictly as a checklist, and by asking the user targeted questions where you're least confident.

#### Review Themes

1. **Completeness** — All personas covered? All stories have acceptance criteria? All must-haves prioritised? (COMPREHENSIVE: FR → UC → Persona chain complete? Discovery requirements covered?)
2. **Clarity & Testability** — Could a developer implement each FR without asking questions? Every criterion verifiable by a test? No ambiguity words?
3. **Scope Discipline** — Nothing exceeds brainstorm boundaries? Won't-Have items have reasoning? Must Have list truly minimal (≤10)?
4. **Assumptions & Risks** — All assumptions documented? Would any false assumption invalidate requirements? Open questions flagged, not silently decided?
5. **Edge Cases** — Failure paths considered for Must Have FRs? Concurrent access, empty states, permission boundaries probed?

#### Kill Criteria Check

Review brainstorm kill criteria against PRD findings. Has requirements writing revealed complexity that exceeds the brainstorm's budget? If any kill criterion is triggered, flag it:

"PRD finding {X} triggers kill criterion {Y} from the brainstorm. Options: (1) Adjust scope, (2) Adjust kill criteria, (3) Abandon."

#### Quality Scan

After thematic review, do a final scan for:
- Ambiguity words (see Phase 6 quality check list)
- Untestable criteria
- Open questions that are still unresolved (these should be flagged, not silently decided by the agent)
- Missing error paths in acceptance criteria
- NFR targets without rationale tracing to problem/metrics

#### PAUSE 5: User validation questions (Combined Gate — Pattern 4)

After self-review, ask all three validation questions simultaneously:

```
AskUserQuestion:
  questions:
    - question: "Which acceptance criteria are you LEAST confident about?"
      header: "Confidence"
      multiSelect: true
      options:
        - label: "FR-{MODULE}-{NAME-1}"
          description: "{Title} — most complex/risky FR"
        - label: "FR-{MODULE}-{NAME-2}"
          description: "{Title} — most complex/risky FR"
        - label: "FR-{MODULE}-{NAME-3}"
          description: "{Title} — most complex/risky FR"
    - question: "Are there assumptions that might not hold?"
      header: "Assumptions"
      multiSelect: false
      options:
        - label: "All assumptions valid (Recommended)"
          description: "No concerns about the documented assumptions."
        - label: "Some are risky"
          description: "One or more assumptions may not hold — I'll provide notes."
        - label: "Need to investigate"
          description: "We should validate specific assumptions before proceeding."
    - question: "Anything in Won't Have you're uncomfortable deferring?"  # STANDARD+ only — skip in BRIEF (no prioritisation section)
      header: "Deferrals"
      multiSelect: false
      options:
        - label: "All fine (Recommended)"
          description: "Won't Have items are correctly scoped out."
        - label: "Some should be reconsidered"
          description: "One or more Won't Have items may need to move into scope."
```

Select 3-4 of the most complex or risky FRs for the Confidence question options. For flagged items, dig deeper into specific concerns before finalizing.

---

### Phase 10b: Document Approval (COMPREHENSIVE only)

For COMPREHENSIVE PRDs with multiple stakeholders, add a formal approval section. This creates an auditable record of who signed off and prevents the "I thought you approved it" problem.

```markdown
## Document Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Product Owner | {name} | Approved / Pending | {date} |
| Tech Lead | {name} | Approved / Pending | {date} |
| Domain Expert | {name} | Approved / Pending | {date} |

**Approval means:** Requirements are correct and complete enough to begin technical design. It does NOT mean requirements are frozen — the Document History table tracks subsequent changes.
```

---

## BRIEF Mode Template

For BRIEF scope, skip Phases 3, 5, 8, 8b, 9, 10b. Produces a streamlined one-page PRD with: Problem, Goals, Non-Goals, Assumptions, 3-5 requirements with acceptance criteria, NFRs, and Open Questions.

See [references/prd-conventions.md](references/prd-conventions.md#brief-mode-template) for the complete template.

---

## PRD Output

Save to:
- `${PROJECT_ROOT}/docs/prd/{feature}/prd.md` — the PRD itself
- `${PROJECT_ROOT}/docs/prd/{feature}/use-cases/UC-{MODULE}-{NNN}-{slug}.md` — feature-scoped use cases (COMPREHENSIVE only)
- `${PROJECT_ROOT}/docs/use-cases/UC-{MODULE}-{NNN}-{slug}.md` — cross-module use cases that span features/aggregates
- `${PROJECT_ROOT}/docs/prd/{feature}/use-cases/traceability-index.md` — optional traceability index (COMPREHENSIVE, 5+ UCs)

The PRD follows the phase order:
Document History → Problem → Personas → Assumptions & Constraints → Use Case Index → FRs → NFRs → Prioritisation → Validation

Use cases are standalone files referenced by the PRD, not embedded in it. Feature-scoped use cases live alongside their PRD in `docs/prd/{feature}/use-cases/`; cross-module use cases that span multiple features or aggregate roots go in the shared `docs/use-cases/` folder. This keeps related artifacts colocated while the common folder signals cross-cutting concerns.

---

## Traceability Rules

- Every FR maps to at least one persona
- COMPREHENSIVE: every FR maps to at least one UC
- Every FR has testable acceptance criteria in Given/When/Then
- Security criteria on stories touching auth, PII, or destructive operations
- Compliance criteria on stories touching regulated data
- Stable FR IDs survive requirement additions/removals
- NFR targets trace to problem statement, success metrics, or persona needs

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

## Structural Conventions (Non-Negotiable)

Every PRD produced by this skill must follow these conventions exactly. Only content varies between PRDs — structure, naming, and formatting are fixed. Covers: mandatory H2 section order (15 sections for COMPREHENSIVE), naming/numbering conventions for all elements (Goals, FRs, NFRs, UCs, Personas, Epics), fixed heading levels, persona sub-fields, FR/NFR body structure templates, table column formats, MoSCoW headings, and 7 strict rules.

See [references/prd-conventions.md](references/prd-conventions.md#structural-conventions-non-negotiable) for the complete specification.

---

## Anti-Patterns

10 named anti-patterns covering common PRD failures: The Monologue, Solution-First, Vague Criteria, Happy Path Only, The Kitchen Sink, Silent Assumptions, Orphan Stories, Arbitrary NFR Targets, Monolith PRD, Undocumented Evolution. See [references/prd-conventions.md](references/prd-conventions.md#anti-patterns) for full descriptions.

---

## Living Document Convention

PRDs may outlive the sprint they were written in. When architecture changes or new learnings invalidate parts of the PRD, **add a Legacy Update notice** rather than silently rewriting history:

```markdown
> **Legacy Update ({date}):** {Section X} was revised because {reason}.
> Original requirement was {old}; updated to {new} based on {evidence}.
```

This preserves the decision trail — anyone reading the PRD can see what changed and why, which is critical for long-lived features that evolve across multiple releases.

---

*Skill Version: 3.7 — [Version History](VERSIONS.md)*
