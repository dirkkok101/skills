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

#### PAUSE: Validate with user

Present the problem statement, goals, and non-goals. Ask:

> "Does this accurately describe the problem? Are the goals measurable and realistic? Anything missing from non-goals?"

Do not proceed until the user confirms the problem framing is right. Everything downstream depends on this.

---

### Phase 3: Assumptions, Constraints & Risks

**All modes. This section prevents the most common PRD failures — undocumented assumptions that blow up later.**

**Step 3.1 — Assumptions:**

Things we're taking for granted. If any prove false, requirements may need to change.

```markdown
## Assumptions
- {Technical: "The existing API can handle the additional load"}
- {Business: "Users have admin access to configure this feature"}
- {Data: "Historical data exists for the past 12 months"}
- {Timeline: "Third-party integration API will be stable by Q2"}
```

**Step 3.2 — Constraints:**

Hard limits that shape what's possible.

```markdown
## Constraints
- {Technical: "Must work within existing database schema"}
- {Business: "Budget limited to current team capacity"}
- {Regulatory: "Must comply with POPIA data residency requirements"}
- {Timeline: "Must ship before contract renewal in Q3"}
```

**Step 3.3 — Risks & Open Questions:**

Track unknowns throughout the PRD process. Update this section as questions surface in later phases.

```markdown
## Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {What could go wrong} | Low/Med/High | Low/Med/High | {How to reduce} |

## Open Questions
- [ ] {Unresolved question — "How do existing users migrate?"}
- [ ] {Decision needed — "Should we support bulk operations in v1?"}
```

---

### Phase 4: User Personas

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

Import actor list from discovery brief if available.

#### PAUSE: Validate personas

> "Do these personas match real users you've seen? Is there a persona I'm missing? Does the primary persona feel right?"

Personas ground every requirement. Wrong personas produce wrong requirements.

---

### Phase 5: Use Cases (COMPREHENSIVE mode only)

**BRIEF/STANDARD modes skip this phase — user stories in Phase 6 are sufficient.**

Cockburn fully-dressed format for primary use cases (5-8 per feature):

```markdown
### UC-{MODULE}-001: {Goal as Active Verb Phrase}

  Scope:           {System name}
  Level:           User Goal
  Primary Actor:   {Persona from Phase 4}
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
    ...
    N. System {confirms completion}

  Extensions:
    2a. {Condition — e.g., "Name already exists in tenant"}:
        2a1. System displays "{specific error message}"
        2a2. Actor corrects input, return to step 2

  Business Rules:
    BR-{MODULE}-001: {Specific rule with parameters}
```

Guidelines:
- 3-9 steps in main success scenario — write at user-intention level, not UI-action level
- Every step that can fail gets an extension
- Extensions branch from specific step numbers (2a, 3a, not "if fails")

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

As a {persona from Phase 4},
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

After drafting the initial requirements, systematically probe for missing edge cases. For each FR, ask:

- **Duplicates:** What if the user does this twice? What if the same data already exists?
- **Boundaries:** What if the input is empty? Maximum length? Zero? Negative?
- **Concurrency:** What if two users do this simultaneously?
- **Permissions:** What if the user doesn't have access? What about partial access?
- **State:** What if a dependency is unavailable? What about stale data?
- **Lifecycle:** What about deletion? Archival? Migration of existing data?

Each discovered edge case becomes either a new acceptance criterion on an existing FR, or a new FR if it's significant enough.

#### Requirement Quality Check

Before presenting requirements to the user, scan for these quality issues:

**Ambiguity words** — flag any requirement containing: "appropriate", "reasonable", "quickly", "user-friendly", "intuitive", "properly", "sufficient", "as needed", "etc.", "and/or". These words mask undecided requirements. Replace each with a specific, testable statement.

**Testability** — every acceptance criterion must be verifiable by a test. "The system should handle errors gracefully" is not testable. "Given a network timeout, when the user submits, then a retry dialog appears within 2 seconds" is testable.

**Independence** — each FR should be deliverable and valuable on its own. If FR-X only makes sense with FR-Y, consider merging them or making the dependency explicit.

#### PAUSE: Validate requirements in batches

Present requirements in groups of 3-5, not all at once. For each batch:

> "Here are the next requirements. For each one:
> - Does the 'so that' reflect a real benefit?
> - Are the acceptance criteria specific enough to test?
> - What edge cases am I missing?"

This iterative approach surfaces better requirements than reviewing 20 stories at once.

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
Rationale: {Why this target matters}
```

Categories to consider:
1. **Performance** — API response time, page load, batch throughput
2. **Security** — Authentication, encryption, audit logging, rate limiting
3. **Scalability** — Concurrent users, data volume, geographic distribution
4. **Data** — Retention, backup, deletion, migration
5. **Accessibility** — WCAG 2.1 AA, keyboard navigation, screen readers

Every NFR has a number, not an adjective. "Fast" is not a requirement. "< 200ms P95" is.

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
{ASCII diagram showing requirement dependencies}

  FR-REGISTER ──> FR-VALIDATE ──> FR-PROVISION
       |                              |
       +──> FR-CONFIGURE          FR-NOTIFY
```

#### PAUSE: Validate priorities

> "Is the Must Have list truly minimal? Could any Must Haves be Should Haves? Are there Should Haves that are actually essential?"

Priority decisions shape what gets built first. Getting them wrong means building the wrong thing.

---

### Phase 9: Domain Validation (COMPREHENSIVE only)

Verify discovery requirements are fully covered:

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
| DR-{MODULE}-{NAME} | FR-{MODULE}-{NAME} | Covered |
| DR-{MODULE}-{NAME} | — | Gap (deferred to v2) |
```

---

### Phase 10: Self-Review & Approval

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Known limitation:** Self-review is performed by the same agent that wrote the PRD. Mitigate by following themes strictly as a checklist, and by asking the user targeted questions where you're least confident.

#### Review Themes

1. **Completeness** — All personas covered? All stories have acceptance criteria? All must-haves prioritised?
2. **Clarity** — Could a developer implement each FR without asking questions? Are criteria unambiguous?
3. **Testability** — Every criterion verifiable by a test? Metrics measurable? Performance targets have units?
4. **Scope Discipline** — Nothing exceeds brainstorm boundaries? Won't-Have items have reasoning?
5. **Assumptions** — Are all assumptions documented? Would any false assumption invalidate requirements?
6. **Edge Cases** — Have failure paths been considered for each FR? What about concurrent access, empty states, permission boundaries?
7. **Traceability** — FR → UC → Persona chain complete? (COMPREHENSIVE only)
8. **Domain Validation** — Discovery requirements fully covered? (COMPREHENSIVE only)

#### Quality Scan

After thematic review, do a final scan for:
- Ambiguity words (see Phase 6 quality check list)
- Untestable criteria
- Open questions that are still unresolved (these should be flagged, not silently decided by the agent)
- Missing error paths in acceptance criteria

#### PAUSE: User validation questions

After self-review, ask the user these targeted questions:

> 1. "Which acceptance criteria are you LEAST confident about? Those are where edge cases usually hide."
> 2. "Are there any assumptions I listed that might not hold?"
> 3. "Is there anything in the Won't Have list that you're uncomfortable deferring?"

---

## BRIEF Mode Template

For BRIEF scope, produce this streamlined one-page format:

```markdown
# PRD: {Feature Name} (Brief)

**Date:** {today} | **Scope:** BRIEF | **Status:** Draft

## Problem
{2-3 sentences — what's broken and for whom}

## Goals
- {Measurable outcome 1}
- {Measurable outcome 2}

## Non-Goals
- {What we're explicitly NOT doing}

## Assumptions
- {Key assumptions that could change scope if wrong}

## Requirements

### FR-{MODULE}-{NAME}: {Title} [Must]
As a {role}, I want {action}, so that {benefit}.
- Given {X}, When {Y}, Then {Z}
- Given {error}, When {invalid}, Then {handled}

### FR-{MODULE}-{NAME}: {Title} [Must]
...

{3-5 stories total}

## NFRs
- NFR-001: {target with number — e.g., "P95 response < 500ms"}

## Open Questions
- {Anything unresolved}
```

---

## PRD Output

Save to: `${PROJECT_ROOT}/docs/prd/{feature}/prd.md`

The final document follows the phase order:
Problem → Assumptions & Constraints → Personas → Use Cases → FRs → NFRs → Prioritisation → Validation

---

## Traceability Rules

- Every FR maps to at least one persona
- COMPREHENSIVE: every FR maps to at least one UC
- Every FR has testable acceptance criteria in Given/When/Then
- Security criteria on stories touching auth, PII, or destructive operations
- Compliance criteria on stories touching regulated data
- Stable FR IDs survive requirement additions/removals

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

**The Monologue** — Agent generates entire PRD, dumps it for approval. Instead, pause and validate at each phase. The user knows things the agent doesn't.

**Solution-First** — Writing features before establishing the problem. If Phase 2 doesn't hurt to read, you haven't described a real problem.

**Vague Criteria** — "System should be fast" or "handle errors appropriately". Every requirement needs a number or a specific behavior. Flag ambiguity words.

**Happy Path Only** — Acceptance criteria that only cover success. Every FR needs at least one error/edge case criterion. Use the edge case elicitation checklist.

**The Kitchen Sink** — v1 through v10 in one doc. Strict MoSCoW with Won't Have. If the Must Have list has more than 10 items, some of them aren't Must Haves.

**Silent Assumptions** — Taking things for granted without documenting them. If an assumption proves false and there's no record, nobody knows which requirements to revisit.

**Orphan Stories** — Stories not linked to personas or use cases. If you can't name the persona, the requirement may not solve a real problem.

---

*Skill Version: 3.0*
*v3: Collaborative dialogue model, assumptions/constraints/risks sections, edge case elicitation, requirement quality checks, BRIEF template, targeted user validation questions*
