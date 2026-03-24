---
name: review-prd
description: >
  Adversarial PRD review against the /prd skill template and cross-cutting
  requirements. Checks structural completeness, content quality, and
  cross-cutting compliance. Every finding cites a specific template requirement,
  cross-cutting standard, or consistency rule. This is a DOCUMENT review
  (pre-implementation), distinct from /review which is a CODE review
  (post-implementation). Use before /technical-design, after /prd, when user
  says "review prd", "check requirements", or when PRD quality is uncertain.
argument-hint: "[module-name]"
---

# Review-PRD: Adversarial PRD Review

**Philosophy:** PRDs are the requirements contract. Every downstream artifact — design, plan, beads, tests, code — traces back to them. Reviewing a PRD before investing in technical design catches ambiguity, missing coverage, and untestable criteria at the cheapest possible point. Every finding must cite a specific /prd skill template section, cross-cutting requirement, or consistency rule. Opinions are not findings.

**Duration targets:** BRIEF ~15 minutes (structural check only), STANDARD ~30-60 minutes (full template compliance + cross-cutting), COMPREHENSIVE ~1-2 hours (+ adversarial depth on acceptance criteria, security, measurability).

## Why This Matters

A PRD that passes structural review but fails on content quality creates false confidence downstream. Design docs built on vague acceptance criteria produce ambiguous implementations. Plans built on unmeasurable NFRs produce untestable features. This skill catches those problems before they compound — when fixing them costs minutes of editing, not days of rework.

---

## Trigger Conditions

Run this skill when:
- After `/prd` completion, before `/technical-design`
- User says "review prd", "check requirements", "validate prd"
- PRD quality is uncertain or the PRD was written without the /prd skill
- Before investing in technical design for a complex feature

Do NOT use for:
- Reviewing code or implementation (use `/review`)
- Reviewing design documents (use `/review` with design-intent agent)
- Writing or generating PRD content (use `/prd`)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

## Shared References

Before starting any review, load these shared reference files:
- **CONVERGE loop & classification:** `../_shared/references/converge-mode.md`
- **Severity model & finding quality:** `../_shared/references/review-finding-taxonomy.md`

These define the CONVERGE mode behavior, MECHANICAL vs DECISION classification, authority hierarchy, PRE_EXISTING severity rules, and finding quality standards shared across all review skills. Skill-specific CONVERGE behavior (wave definitions, authority hierarchy overrides) is documented inline below.

---

## Mode Selection

| Mode | When | What You Get |
|------|------|--------------|
| **BRIEF** | Quick sanity check, small PRD, time-constrained | Structural completeness only — all sections present, IDs valid |
| **STANDARD** | Typical PRD review before technical design | Full template compliance + content quality + cross-cutting compliance |
| **COMPREHENSIVE** | Complex feature, high-stakes, multi-module | All STANDARD checks + adversarial depth on acceptance criteria, security, measurability, failure paths |
| **CONVERGE** | Fix all issues until 0 FAILs | STANDARD review + auto-fix loop |

If the user hasn't specified a mode, assess the PRD:
- BRIEF scope PRD or quick check requested → BRIEF
- STANDARD scope PRD → STANDARD
- COMPREHENSIVE scope PRD or high-stakes feature → COMPREHENSIVE
- User says "converge", "fix all issues", "autoresearch" → CONVERGE

### CONVERGE Mode

When selected, run the autoresearch convergence loop. CONVERGE can be combined with any review depth:

- `CONVERGE` alone → uses STANDARD depth
- `CONVERGE + COMPREHENSIVE` → uses COMPREHENSIVE depth (adversarial checks, deeper)
- `CONVERGE + BRIEF` → uses BRIEF depth (structural fixes only)

**CONVERGE changes to the normal review flow:**
- **Skip scope confirmation gate.** CONVERGE implies "just go."
- **Replace Phase 5 interactive walkthrough** with a summary table of all findings, classified as MECHANICAL / JUSTIFIED_DEVIATION / DECISION. No per-finding AskUserQuestion for FAILs — present in batch, fix mechanicals directly.
- **WARNs are listed** in the summary table but NOT presented interactively and NOT auto-fixed.

**Phase 1 chunking strategy:** For PRDs over 300 lines, split Phase 1 into three passes:
- Pass A: Metadata, Document History, Problem Statement, Goals, Non-Goals, Success Metrics, Personas
- Pass B: Assumptions & Constraints, Use Cases, Functional Requirements, NFRs
- Pass C: Prioritisation, Domain Validation, Document Approval
Record findings per pass. This reduces cognitive load on large PRDs.

**The loop:**

1. **Review** — Run the review at the selected depth using the chunking strategy above.
2. **Classify** findings:
   - **MECHANICAL** — wrong numbering prefix, stale count, missing section, format error, ambiguity word in acceptance criteria, internal contradiction where one side is clearly correct. Auto-fix these.
   - **JUSTIFIED_DEVIATION** — PRD deviates from a convention with explicit, documented rationale. Verify rationale is sound; if yes, mark as PASS.
   - **DECISION** — PRD contradicts cross-cutting PRD, persona references don't match, scope question requiring user judgment. Escalate to user via AskUserQuestion.
3. **Fix** mechanical findings using minimum changes. After fixing cross-cutting items (numbering, format), verify all sections of the PRD are internally consistent.
4. **Re-review** — Run the review again on the fixed PRD.
5. **Compare** — Did FAILs decrease? If increased, revert and stop. If same findings for 3 rounds, stop.
6. **Repeat** until FAILs = 0 or max 5 rounds.
7. **WARN triage** — After FAILs reach 0, present remaining WARNs to the user as a final batch via AskUserQuestion with "Fix / Accept as-is" options. This resolves WARNs that would otherwise sit in limbo.

**Severity alignment:** The review's own FAIL/WARN classification is authoritative. CONVERGE fixes FAILs only. WARNs are triaged after convergence.

**Authority hierarchy for mechanical fixes:**
```
/prd skill Structural Conventions > cross-cutting PRD > ADRs > project personas > the PRD being reviewed
```

**Convergence report template:**
```markdown
## CONVERGE Report: {Module} PRD

| Round | FAILs | Mechanical Fixes | Decisions | WARNs |
|-------|-------|-----------------|-----------|-------|
| 0 (baseline) | {n} | — | — | {n} |
| 1 | {n} | {n} fixed | {n} escalated | {n} |
| 2 | {n} | {n} fixed | — | {n} |

Changes: {file} ({change}), {file} ({change}).
Decisions: {finding} → {user choice}.
WARNs triaged: {n} fixed, {n} accepted.
```

For quick convergences (≤3 rounds, ≤10 findings), use compact format:
`{N} findings → {N} fixed in {N} rounds. {N} decisions escalated. WARNs: {N} (not fixed).`

---

## Important Rules

1. **READ-ONLY** (non-CONVERGE modes) — Do not modify any files. This skill audits; it does not fix. **Exception:** CONVERGE mode modifies the PRD directly to fix mechanical findings.
2. **Findings only** — Every finding cites a specific /prd template section or cross-cutting requirement. No opinions beyond documented standards.
3. **Do not read source code** — This reviews documents against documents. Code does not exist yet.
4. **Pattern docs and ADRs are constraints** — They are binding specifications, not suggestions.
5. **Skip passes silently** — Only present failures and warnings to the user. Passing checks are recorded in the summary table but not discussed.

---

## Critical Sequence

### Phase 0: Load Context

**Step 0.1 — Resolve PROJECT_ROOT and locate the PRD:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
```

Read the PRD file. Expected location: `${PROJECT_ROOT}/docs/prd/{module}/prd.md`

If the user provides a module name, use it. If not, search `docs/prd/` for available PRDs and ask which to review.

**Step 0.2 — Load reference documents:**

Read all of the following that exist. These are the standards the PRD is reviewed against:

| Document | Purpose | Path |
|----------|---------|------|
| Cross-cutting PRD | Shared requirements that apply to all modules | `docs/prd/cross-cutting/prd.md` |
| Personas | Project-level persona definitions | `docs/prd/cross-cutting/personas.md` or `docs/personas/` |
| Glossary | Domain term definitions | `docs/discovery/{module}/glossary.md` or `docs/glossary/` |
| ADRs | Architecture Decision Records | `docs/adr/*.md` |
| /prd skill spec | Template requirements | This skill references the /prd SKILL.md internally |
| Brainstorm | Upstream boundaries and kill criteria | `docs/brainstorm/{module}/brainstorm.md` |
| Discovery brief | Upstream domain requirements | `docs/discovery/{module}/discovery-brief.md` |

**Step 0.3 — Determine PRD scope:**

Read the PRD metadata table to identify its scope (BRIEF / STANDARD / COMPREHENSIVE). This determines which template sections are required.

**Step 0.4 — Confirm review mode:**

```
AskUserQuestion:
  question: "Which review depth for this PRD?"
  header: "Mode"
  multiSelect: false
  options:
    - label: "Standard (Recommended)"
      description: "Full template compliance + content quality + cross-cutting checks."
    - label: "Brief"
      description: "Quick structural completeness check only (~15 min)."
    - label: "Comprehensive"
      description: "All checks + adversarial depth on acceptance criteria, security, measurability (~1-2 hours)."
```

---

### Phase 1: Structural Completeness

Check every section the /prd skill template requires for the PRD's scope level. The /prd v3.7 Structural Conventions section defines exact formats — these are non-negotiable. For each check, record Pass / Warning / Fail.

**Note on Policy & Standards PRDs:** PRDs that define shared policies or cross-cutting concerns (rather than a single bounded module) may legitimately have lighter Personas, Use Cases, NFRs, and Dependency Graphs. If the PRD explicitly identifies itself as a policy/standards document, apply the exceptions noted in /prd v3.7 "Policy & Standards PRDs" section. The structural conventions (heading formats, numbering, table columns) still apply without exception.

**1.1 Metadata & Document History:**

| Check | Criteria | Severity |
|-------|----------|----------|
| H1 title format | `# PRD: {Name}` | Fail if wrong format |
| Metadata table present | `\| Field \| Value \|` format | Fail if missing |
| Required metadata fields | Version, Date, Author, Status, Scope | Fail per missing field |
| Recommended metadata fields | Brainstorm, Discovery, Depends On | Warning per missing field |
| Document History table | `\| Version \| Date \| Changes \|` with at least one entry | Fail if missing |
| Scope field valid | One of: BRIEF, STANDARD, COMPREHENSIVE | Fail if missing or invalid |
| TOC present (COMPREHENSIVE) | `## Table of Contents` section | Fail if missing for COMPREHENSIVE |

**1.2 Problem & Business Context (all modes):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Problem Statement` section | 2-3 sentences with specific evidence | Fail if missing |
| `Impact:` list | Bullet list starting with `Impact:` | Fail if missing |
| `Why now:` statement | Line starting with `Why now:` | Fail if missing |
| `## Goals` section | Present with `**G{n}:**` numbered items (3-5) | Fail if missing or unnumbered |
| `## Non-Goals` section | Present with `**NG{n}:**` numbered items, each with `Reason:` | Fail if missing or unnumbered |
| `## Success Metrics` table (STANDARD+) | Columns: Metric, Current, Target, By When, How Measured | Fail if missing for STANDARD+ |

**1.3 Personas (STANDARD+):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## User Personas` section | Present with `### P{n}: {Role Title}` headings | Fail if missing for STANDARD+ |
| Persona count | 2-4 personas defined | Warning if outside range |
| Mandatory sub-fields (per persona) | All 6 required: `**Goals:**`, `**Pain Points:**`, `**Current Workaround:**`, `**Success Criteria:**`, `**Tech Level:**`, `**Frequency:**` | Fail per missing sub-field |

**1.4 Assumptions, Constraints & Risks:**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Assumptions & Constraints` section | Present as H2 | Fail if missing |
| `### Assumptions` sub-heading | H3 under Assumptions & Constraints | Fail if missing |
| Assumption numbering | `**A{n}:**` format, at least 3 items | Fail if unnumbered, Warning if < 3 |
| `### Constraints` sub-heading (STANDARD+) | H3 under Assumptions & Constraints | Fail if missing for STANDARD+ |
| Constraint numbering | `**C{n}:**` format, at least 2 items | Fail if unnumbered, Warning if < 2 |
| `### Risks` sub-heading (STANDARD+) | H3 with table: Risk \| Likelihood \| Impact \| Mitigation | Fail if missing |
| `### Open Questions` sub-heading (STANDARD+) | H3 with table: # \| Question \| Context \| Status \| Decision \| Owner. If none, state "None — all resolved" | Fail if missing or wrong columns |

**1.5 Use Cases (COMPREHENSIVE only):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Use Cases` section | Index table linking to standalone UC files | Fail if missing for COMPREHENSIVE |
| UC files exist | Referenced files actually exist on disk | Fail per missing file |
| UC format (Tier 1) | Metadata, Scenario Flow, Postconditions, Failure Paths, Minimal Guarantee, Business Rules | Warning per missing section |
| UC format (Tier 2) | Metadata, Scenario Flow, Postconditions, Failure Paths | Warning per missing section |

**1.6 Functional Requirements (all modes):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Functional Requirements` section | Present as H2 | Fail if missing |
| Epic organisation | FRs grouped under `### Epic: {Name}` headings (H3) | Fail if no epics |
| FR heading format | `#### FR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}` (H4, descriptive ID) | Fail per wrong format |
| FR IDs not sequential | No `FR-{MODULE}-001` patterns | Fail per violation |
| FR body: Priority line | `Priority: Must / Should / Could / Won't` (one per line, no bold) | Fail per missing |
| FR body: Complexity line | `Complexity: S / M / L / XL` | Warning per missing |
| FR body: User story | `As a {persona} (P{n}), I want ..., So that ...` | Fail per missing story |
| FR body: Acceptance Criteria | `Acceptance Criteria:` header followed by indented (2 spaces) `Given / When / Then` | Fail per missing criteria |
| FR body: Security Criteria | `Security Criteria:` present on FRs that modify data, touch auth, or handle PII | Fail per missing (COMPREHENSIVE), Warning (STANDARD) |
| FR body: Compliance Criteria | `Compliance Criteria:` present on FRs touching regulated data | Warning per missing |
| FR count minimum | At least 3 (BRIEF), 8 (STANDARD), 10 (COMPREHENSIVE) | Warning if below minimum |

**1.7 Non-Functional Requirements (all modes):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Non-Functional Requirements` section | Present as H2 | Fail if missing |
| NFR heading format | `### NFR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}` (H3, descriptive ID) | Fail per wrong format |
| NFR IDs not sequential | No `NFR-{MODULE}-001` patterns | Fail per violation |
| NFR body: Category | `Category:` line present | Fail per missing |
| NFR body: Target | `Target:` line with a specific number (not adjectives) | Fail per missing or unmeasurable |
| NFR body: Measurement | `Measurement:` line present | Fail per missing |
| NFR body: Rationale | `Rationale:` line tracing to problem/metrics/persona | Fail per missing |
| NFR count minimum | At least 2 (BRIEF), 4 (STANDARD), 6 (COMPREHENSIVE) | Fail if below minimum |
| Mandatory audit NFR | `NFR-{MODULE}-AUDIT` or equivalent present for modules with state-changing operations. When fixing, use this template: `### NFR-{MODULE}-AUDIT: Lifecycle Audit Coverage` / `Category: Compliance` / `Target: 100% of create, update, delete, and status-change operations produce audit entries with actor ID, timestamp, entity ID, operation type, and event name ({entity_type}.{action})` / `Measurement: Integration tests verifying audit log entries for each mutation endpoint` / `Rationale: {trace to cross-cutting PRD audit requirements and SOC 2 compliance}` | Fail if missing |

**1.8 Integration Points (COMPREHENSIVE only):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Integration Points` section | Present as H2 | Fail if missing for COMPREHENSIVE |
| `### Consumed Services` sub-heading | H3 with service table | Fail if missing |
| `### Exposed Services` sub-heading | H3 with service table | Fail if missing |
| `### Integration NFRs` sub-heading | H3 with integration constraints | Warning if missing |

**1.9 Prioritisation (STANDARD+):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Prioritisation (MoSCoW)` section | Present as H2 | Fail if missing for STANDARD+ |
| `### Must Have (MVP)` heading | Exact H3 text | Fail if missing |
| `### Should Have (v1)` heading | Exact H3 text | Fail if missing |
| `### Could Have (Future)` heading | Exact H3 text | Fail if missing |
| `### Won't Have (Yet)` heading | Exact H3 text, each item has `Reason:` | Fail if missing |
| Must Have list bounded | 10 or fewer items | Warning if exceeded |
| `## Dependency Graph` section | ASCII diagram using `──>` arrows showing FR-to-FR build order | Fail if missing |

**1.10 Domain Validation (COMPREHENSIVE only):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Domain Validation` section | Present as H2 | Fail if missing |
| `### Coverage Matrix` | Table mapping requirements to FRs, UCs, and status | Fail if missing |
| Validation checklist | All items checked or annotated | Warning if incomplete |

**1.11 Document Approval (COMPREHENSIVE only):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Document Approval` section | Present as H2 | Fail if missing |
| Approval table format | Columns: Role \| Name \| Status \| Date (in that order) | Fail if wrong columns |
| Approval footer | "Approval means: ..." statement present | Warning if missing |

Record all results. Do not present passes to the user.

---

### Phase 2: Content Quality (STANDARD+)

Beyond structural presence, examine content substance. Each check produces a finding only when it fails.

**Acceptance Criteria Testability:**

For each FR's acceptance criteria:
- Is the Given/When/Then specific enough to write a test? ("Given valid data" is not specific — what data?)
- Does at least one criterion cover an error/edge case? (Happy path only = Warning)
- Are there ambiguity words? Flag: "appropriate", "reasonable", "quickly", "user-friendly", "intuitive", "properly", "sufficient", "as needed", "etc.", "and/or"

Citation: /prd Phase 6 — Requirement Quality Check, Ambiguity words list.

**NFR Measurability:**

For each NFR:
- Does the Target contain a specific number? ("should be fast" = Fail, "P95 < 200ms" = Pass)
- Is the Measurement method defined? (How would you verify this in production?)
- Does the Rationale trace to problem statement, success metrics, or persona needs?

Citation: /prd Phase 7 — "Every NFR has a number, not an adjective."

**Success Metrics Completeness:**

For each success metric:
- Are all columns populated: Current baseline, Target, By When, How Measured?
- Is the target actually different from current? (Same = Warning)
- Is "How Measured" actionable? ("We'll know" = Fail, "Datadog P95 dashboard" = Pass)

Citation: /prd Phase 2 Step 2.4.

**Use Case Completeness (COMPREHENSIVE):**

For each Tier 1 use case:
- Are preconditions specific? (Can you set up this state in a test?)
- Is the success guarantee observable? (Can you verify it happened?)
- Are failure paths enumerated for every step that can fail?
- Is the Minimal Guarantee defined?

Citation: /prd Phase 5 — Tier 1 use case format.

**Persona References:**

- Do FR user stories reference personas defined in the Personas section (or project persona doc)?
- Are all personas used by at least one FR? (Orphan persona = Warning)
- Are all Must Have FRs linked to a primary persona?

Citation: /prd Traceability Rules — "Every FR maps to at least one persona."

**Stable ID Convention:**

- Are FR IDs descriptive (`FR-APP-REGISTER`) not sequential (`FR-APP-001`)?
- Are NFR IDs descriptive (`NFR-APP-RESPONSE-TIME`) not sequential?

Citation: /prd Phase 6 — Stable ID convention.

**Naming Convention Consistency:**

- Do all goals use `**G{n}:**` format? Check every bullet in the Goals section.
- Do all non-goals use `**NG{n}:**` format with `— Reason:` suffix?
- Do all assumptions use `**A{n}:**` format?
- Do all constraints use `**C{n}:**` format?
- Are numbering sequences contiguous (no gaps like A1, A2, A5)?

Citation: /prd v3.7 Structural Conventions — Naming & Numbering Conventions.

**Heading Level Compliance:**

- Are all main sections H2? (## Problem Statement, ## Goals, etc.)
- Are epics H3? (### Epic: {Name})
- Are FRs H4? (#### FR-{MODULE}-{NAME}: {Title})
- Are NFRs H3? (### NFR-{MODULE}-{NAME}: {Title})
- Are personas H3? (### P{n}: {Role Title})

Citation: /prd v3.7 Structural Conventions — Heading Levels.

**Audit Coverage:**

- Does the PRD include an audit NFR (NFR-{MODULE}-AUDIT or equivalent)?
- Does the audit NFR specify: mutation coverage %, actor ID + timestamp + entity ID, and event type naming convention?
- For modules with state-changing operations, is audit logging addressed in Security Criteria on individual FRs?

Citation: /prd v3.7 Phase 7 — Mandatory NFR: Audit coverage.

---

### Phase 3: Cross-Cutting Compliance (STANDARD+)

Check the PRD against the cross-cutting PRD and project-wide standards. Each finding cites the specific cross-cutting requirement.

**Audit Logging:**

- Do state-changing FRs (create, update, delete, status transitions) include audit logging in their acceptance criteria or reference a cross-cutting audit requirement?
- Citation: Cross-cutting PRD audit logging requirements.

**Data Lifecycle:**

- Do FRs involving data creation address deletion/archival? (Soft delete, hard delete, retention?)
- Is there an FR or NFR covering data lifecycle for the module?
- Citation: Cross-cutting PRD data lifecycle requirements.

**Error Handling:**

- Do FRs specify error behavior, not just happy path?
- Do error criteria follow project error handling patterns?
- Citation: Cross-cutting PRD error handling patterns.

**Pagination & Filtering:**

- Do list/search FRs specify pagination behavior?
- Are default page sizes and maximum limits defined?
- Citation: Cross-cutting PRD pagination/filtering requirements.

**ADR Compliance:**

- Do FRs contradict any existing ADRs? (e.g., using string constants where ADR-0004 requires enums)
- Do NFRs align with architecture decisions?
- Citation: Specific ADR number and title.

---

### Phase 4: Adversarial Depth (COMPREHENSIVE only)

Go beyond compliance into adversarial analysis. Ask: "Could this PRD lead to a wrong implementation that still technically satisfies the requirements?"

**Phase 4 severity guide:**

| Finding Type | Severity | Example |
|-------------|----------|---------|
| AC cannot distinguish correct from incorrect implementation | **FAIL** | "Data is saved" — doesn't say where, in what format, with what constraints |
| Missing boundary values on Must Have FR | **WARN** | No max length on name field, no max items on list |
| Assumption with no documented impact if wrong | **WARN** | "API can handle load" — what breaks if it can't? |
| Non-goal too vague to enforce | **WARN** | "Won't over-engineer" vs "Won't support mobile" |
| Security criteria missing on data-modifying Must Have FR | **FAIL** | FR modifies PII with no auth/validation criteria |
| Failure path missing for critical UC step | **WARN** | No handling for concurrent modification |

**Acceptance Criteria Discrimination:**

For each Must Have FR:
- Can the acceptance criteria distinguish a correct implementation from an incorrect one?
- Could a malicious-compliance implementation pass all criteria while missing the intent?
- Are boundary values specified? (What's the maximum? Minimum? Empty case?)

Finding format: "FR-{ID}: Criteria accept both correct and incorrect implementations because {gap}."

**Failure Path Exhaustiveness:**

For each Tier 1 use case:
- Are ALL failure paths enumerated, not just the obvious ones?
- What about: network failure mid-operation, concurrent modification, partial state, timeout, authentication expiry during flow?

Finding format: "UC-{ID} Step {N}: Missing failure path for {scenario}."

**Assumption Impact Analysis:**

For each documented assumption:
- Is "impact if wrong" documented or inferable?
- If this assumption proves false, which FRs become invalid?
- Are high-impact assumptions flagged as risks?

Finding format: "Assumption '{text}': No documented impact if wrong. Affects FR-{IDs}."

**Non-Goal Effectiveness:**

For each non-goal:
- Does it actually prevent scope creep, or is it too vague to enforce?
- "We won't do mobile" is enforceable. "We won't over-engineer" is not.

Finding format: "Non-goal '{text}': Too vague to enforce. Suggestion: {specific rewording}."

**Security Coverage:**

- Do all FRs that modify data have security criteria?
- Are authorization checks specified? (Who can do this? What happens if they can't?)
- Are input validation rules specified for user-facing FRs?

Finding format: "FR-{ID}: Modifies data but has no security criteria. Needs: {specific criteria}."

---

### Phase 5: Present Findings

Present findings interactively. Skip passes. Present Fails first, then Warnings.

**Step 5.1 — Summary Statistics:**

Present a summary table before diving into individual findings:

```markdown
## PRD Review: {Module Name}

**Mode:** {BRIEF | STANDARD | COMPREHENSIVE}
**PRD Scope:** {BRIEF | STANDARD | COMPREHENSIVE}

| Category | Pass | Warning | Fail |
|----------|------|---------|------|
| Structural Completeness | {n} | {n} | {n} |
| Content Quality | {n} | {n} | {n} |
| Cross-Cutting Compliance | {n} | {n} | {n} |
| Adversarial Depth | {n} | {n} | {n} |
| **Total** | **{n}** | **{n}** | **{n}** |
```

**Step 5.2 — Present Fails (one at a time):**

For each Fail finding, present it as formatted markdown with the citation, then:

```markdown
### Finding F{N}: {Short title}

**Severity:** FAIL
**Category:** {Structural / Content Quality / Cross-Cutting / Adversarial}
**Citation:** {/prd Phase X, Step Y — specific requirement text} or {Cross-cutting: requirement} or {ADR-NNNN: title}
**Location:** {PRD section or FR/NFR/UC ID}
**Issue:** {What is wrong}
**Recommendation:** {Specific fix}
```

```
AskUserQuestion:
  question: "How should we handle this finding?"
  header: "Finding"
  multiSelect: false
  options:
    - label: "Fix per recommendation"
      description: "Accept the recommendation. Will be included in the revision list."
    - label: "Defer"
      description: "Acknowledged but not fixing now. Record for future."
    - label: "Accept as-is"
      description: "Disagree with finding or acceptable risk. No change needed."
    - label: "Needs investigation"
      description: "Can't decide without more information."
```

Record the user's decision for each finding.

**Step 5.3 — Present Warnings (batched):**

After all Fails are resolved, present Warnings in batches of up to 4 using Batch Review (Pattern 3):

Present the warning details as formatted markdown, then:

```
AskUserQuestion:
  question: "Which warnings should be addressed? (Unselected items are accepted as-is)"
  header: "Warnings"
  multiSelect: true
  options:
    - label: "W{N}: {short title}"
      description: "{Location} — {one-line issue summary}"
    - label: "W{N}: {short title}"
      description: "{Location} — {one-line issue summary}"
    ...up to 4 per batch
```

For selected warnings, record them as "Fix" in the decision log. Unselected warnings are recorded as "Accept as-is."

---

### Phase 6: Summary

**Step 6.1 — Decision Log:**

Present the complete decision log:

```markdown
## Decision Log

| # | Finding | Severity | Decision | Notes |
|---|---------|----------|----------|-------|
| F1 | {title} | Fail | Fix / Defer / Accept / Investigate | {user notes} |
| W1 | {title} | Warning | Fix / Accept | {notes} |
```

**Step 6.2 — Deferred Items:**

List all deferred findings as a trackable list:

```markdown
## Deferred Items

- [ ] {Finding title} — {reason for deferral}
```

**Step 6.3 — Verdict:**

```
AskUserQuestion:
  question: "PRD review complete. What next?"
  header: "Verdict"
  multiSelect: false
  options:
    - label: "Revise and re-review"
      description: "Fix the accepted findings, then run /review-prd again."
    - label: "Approved for design (Recommended)"
      description: "PRD is good enough to proceed to /technical-design."
    - label: "Needs major rework"
      description: "Too many issues. Return to /prd to revise substantially."
    - label: "Park"
      description: "Save findings for later. PRD is not ready."
```

---

## Anti-Patterns

**Rubber Stamp** — Accepting the PRD without actually reading it. Every section must be checked against the template requirements. If Phase 1 finds zero issues on a **first-draft** PRD, the review was not thorough enough. However, PRDs that have been through multiple revision cycles (v1.2+, prior adversarial reviews) may legitimately have few Phase 1 findings — this is a positive quality signal, not a sign of insufficient review depth. In that case, Phase 4 (adversarial depth) becomes the primary value-add.

**Scope Inflation** — Adding requirements the PRD does not need. The reviewer's job is to check what's there against what should be there, not to invent new features or requirements. If a section is intentionally absent (e.g., no Integration Points for a simple feature), that's fine — flag only what the template requires for the PRD's declared scope.

**Template Worship** — Inventing requirements the template doesn't ask for. The reviewer's job is to check what's there against the /prd skill's Structural Conventions — not to add new sections, suggest features, or impose preferences beyond the documented standard. If a section is intentionally absent because the PRD's scope doesn't require it (e.g., no Use Cases for STANDARD scope), that's correct — don't flag it. However, structural conventions (heading formats, numbering prefixes, table columns, heading levels) ARE enforced — these are non-negotiable per /prd v3.7.

**Opinion-as-Finding** — Personal preferences disguised as template violations. Every finding must cite a specific section of the /prd skill template, a cross-cutting requirement, or an ADR. "I think the acceptance criteria could be better" is not a finding. "FR-APP-REGISTER acceptance criteria uses ambiguity word 'appropriate' (/prd Phase 6 Quality Check)" is a finding.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "approved for design" | PRD passes review | Proceed to `/technical-design` |
| "revise and re-review" | Fixable issues found | Fix findings, then run `/review-prd` again |
| "needs major rework" | Fundamental gaps | Return to `/prd` for substantial revision |
| "park" | Not ready to proceed | Save findings for later |

When approved: **"PRD approved. Run /technical-design to begin the design phase."**

---

*Skill Version: 2.3 — [Version History](VERSIONS.md)*
