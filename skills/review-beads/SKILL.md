---
name: review-beads
description: >
  Adversarial bead compliance review against ALL upstream artifacts — PRD, design,
  architecture, patterns, ADRs, use cases, and plans. Beads are the last checkpoint
  before code is written. If a bead is wrong, the implementation will be wrong.
  Reviews 11 categories: FR coverage, UC coverage, design compliance, architecture
  compliance, API patterns, web patterns, test coverage, stage gates, bead quality,
  backwards compatibility, cross-module dependencies, and granularity. Use when
  beads are created (/beads completed), user says "review beads", or before /execute.
argument-hint: "[feature-name] or [epic-id]"
---

# Review Beads: Adversarial Bead Compliance Review

**Philosophy:** "If I hand this bead to an agent with no other context, will it build the software correctly?" Every finding must pass a second filter: "Am I sure this is actually wrong, or does it just look different from what I expected?" False positives erode trust faster than missed defects.

**Duration targets:** BRIEF ~15-20 minutes (single entity, <15 beads), STANDARD ~30-60 minutes (typical module, 15-60 beads), COMPREHENSIVE ~60-120 minutes (multi-module or full platform). Most time is Phase 3 (granularity decomposition) and Phase 4 (bead-by-bead deep review).

## Why This Matters

Beads are the contract between planning and execution. A defective bead produces defective code — and the executing agent has no way to know, because the bead IS its source of truth. Upstream docs (PRD, design, architecture) encode decisions that took hours to reach. If beads don't faithfully carry those decisions forward, the entire pipeline from requirements to code breaks silently. This review catches the break before it costs implementation time.

---

## Trigger Conditions

Run this skill when:
- Beads have been created (`/beads` completed)
- User says "review beads", "check beads", "bead review"
- Before starting `/execute` on a new set of beads
- After significant bead modifications or re-planning

Do NOT use for:
- Reviewing code (use `/review`)
- Reviewing plans before beads exist (use `/review-plan`)
- Reviewing PRD requirements (use `/review-prd`)
- Reviewing designs (use `/review-design`)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Scope |
|------|------|-------|
| **BRIEF** | Single entity/feature, <15 beads | Skip batch execution section, abbreviated matrices |
| **STANDARD** | Typical module, 15-60 beads | Full review, single reviewer |
| **COMPREHENSIVE** | Multi-module, 60+ beads, or critical path | Full review + batch execution across modules |
| **CONVERGE** | Fix all issues until 0 FAILs | Selected depth + auto-fix loop |

### CONVERGE Mode

When the user says "converge", "fix all issues", or selects CONVERGE mode, run the autoresearch convergence loop. CONVERGE can be combined with any review depth:

- `CONVERGE` alone → uses STANDARD depth
- `CONVERGE + COMPREHENSIVE` → uses COMPREHENSIVE depth

**CONVERGE changes to the normal review flow:**
- **Skip all interactive stage gates.** CONVERGE implies "just go."
- **Replace interactive findings presentation** with a summary table classified as MECHANICAL / JUSTIFIED_DEVIATION / DECISION.
- **WARNs are listed** but NOT auto-fixed. Trivial WARNs (additive-only, <10 lines) may be auto-fixed.
- **READ-ONLY does not apply** — beads are modified directly to fix MECHANICAL findings.

**The loop:**

1. **Review** — Run at the selected depth. Use progressive loading:
   - Wave 1: Plan overview + bead list (catches coverage gaps)
   - Wave 2: Design docs + pattern docs for specific beads with findings
   - Wave 3: Agents for broad ADR/architecture surveys
2. **Classify** findings:
   - **MECHANICAL** — wrong FR reference, stale dependency, missing context file, count error. Auto-fix.
   - **JUSTIFIED_DEVIATION** — bead deviates from pattern with documented rationale. Verify and PASS.
   - **DECISION** — design contradiction, scope question, architectural choice. Escalate via AskUserQuestion.
3. **Fix** MECHANICAL findings. **Cascade check:** after fixing a bead, grep all beads for related terms.
4. **Re-review** — Run again on fixed beads.
5. **Compare** — Did FAILs decrease? If increased, revert and stop.
6. **Repeat** until 0 FAILs or max 5 rounds.

**Authority hierarchy for mechanical fixes:**
```
ADRs > Pattern docs > Architecture docs > PRD > Design (api-surface, data-model) > Plan (overview, sub-plans) > Beads
```

**Same-session detection:** If beads were generated in the current conversation, flag as same-session. Increase spot-checks to 5 minimum. Phase 2 confidence is LOW.

**Non-greenfield bead review:** If the plan's Implementation Status shows >70% "Exists":
- Verification beads ("verify X matches design") may omit Failure Criteria — the success criteria checklist IS the constraint
- "Modify" beads should specify WHAT needs to change, not just the endpoint/entity name
- Do NOT flag verification beads as incomplete because they lack implementation guidance

**Do NOT delegate finding generation to Explore agents.** Agents cannot call `br show` to read actual bead text — they guess at content and produce 80%+ false positive rates. Generate findings in the main context where `br show` is available. Use agents only for loading upstream docs (PRD, design, ADRs), not for reviewing bead content.

**Verification Mode Phase 3 shortcut:** For >90% exists, skip the greenfield decomposition tables (entity × bead types). Instead: verify bead count matches plan task count, check for over-combined tasks against grouping rules. The plan already determined appropriate granularity.

**Non-CRUD granularity method:** For infrastructure/shell modules (no entities to CRUD), count expected beads from: services, guards, interceptors, initializers, layout components, utility components. Map these to bead expectations instead of entity decomposition tables.

**Compact report for 0-FAIL results:** When Round 1 produces 0 FAILs, use the compact format by default. The full report template (FR matrix, UC matrix, stage gate analysis) is only needed when there are unresolved FAILs or DECISION items.

**False positive log:** Include a `## False Positives Dismissed` section in the review report documenting which findings were dismissed and why. This makes review quality auditable and helps calibrate future reviews.

**Auto-downgrade:** COMPREHENSIVE on a single module automatically uses STANDARD depth regardless of bead count. Batch execution sections only apply to multi-module reviews. Apply this downgrade BEFORE document loading begins.

**Verification Module fast path (>90% exists, any bead count):** Skip Phase 2 (FR/UC coverage inherited from plan) and Phase 3 (greenfield decomposition tables irrelevant). Go straight to Phase 4 (bead-by-bead) + Phase 5 (cross-bead consistency). Use compact report by default. The bead count threshold (was ≤10) is removed — what matters is that >90% of design elements exist, not how many beads there are.

**Wave 1 only for non-greenfield (>70% exists):** Load bead file + design API surfaces first. Only load PRD/UCs/mockups if Wave 1 reveals coverage gaps. This cuts document loading by ~60% for modification-only bead sets.

**Category applicability by bead type:** Not all 11 categories apply to all bead types:
- **Implementation beads:** All 11 categories apply
- **Verification beads:** Categories 1-2 (coverage), 7b (gates), 8 (quality), 10 (cross-module) apply. Skip 3-6 (design/pattern compliance for new code), 9 (backwards compat), 11 (granularity).
- **Test beads:** Categories 7b (gates), 8 (quality) apply. Skip most others.
- **Gate beads:** Category 7b only.

**br comments pattern:** Bead creators may use `br comments add` for detailed descriptions (br has no long description field). When reviewing, check BOTH the description field AND comments. The beads.md file is the authoritative source — br comments may be abbreviated or corrections appended.

**Token budget:** COMPREHENSIVE reviews with 50+ beads read 30-60 documents. Models with <200K context may need two-pass approach.

**Report:** For quick convergences (≤3 rounds, ≤10 findings), use compact format:
`{N} findings → {N} fixed in {N} rounds. {N} decisions escalated. WARNs: {N}.`

---

## Finding Quality Standards

These standards are non-negotiable. Every finding must meet ALL of them:

1. **Re-read the bead** (via `br show <bead-id>`) before writing any finding — do not flag based on cached/stale reads
2. **Quote the specific defect** from the bead text — "the bead says X" or "the bead omits X"
3. **Check both description AND wired dependencies** — a finding about missing dependencies must verify `br dep list <bead-id>`
4. **Verify against the authoritative source doc**, not the plan — plans are lower trust than designs (see Trust Hierarchy in `/beads` skill)
5. **The issue must cause a concrete problem during execution** — "an agent executing this bead would produce [wrong outcome]" or "an agent would have to guess about [ambiguous thing]"

### What NOT to Flag

- **Missing ADR references that CLAUDE.md already covers** — CLAUDE.md is always loaded; referencing ADRs it already mandates is redundant
- **Missing global pattern references** — i18n, toast notifications, error handling patterns that are project-wide conventions agents already follow
- **Redundant transitive dependencies** — if A depends on B and B depends on C, A does not need to explicitly depend on C
- **Description style preferences** — ordering of sections, wording choices, formatting variations
- **Issues in upstream docs** — tag as `UPSTREAM_DOC` and list separately; these are not bead defects

---

## Trust Hierarchy

When reviewing beads, verify against sources in this order (highest trust first):

1. **ADRs & Pattern docs** — architectural intent, non-negotiable
2. **PRD** — business requirements, Must-Have FRs
3. **Design docs** (api-surface, data-model, ui-mockup) — technical specification
4. **Use cases** — actor workflows, extension/alternative flows
5. **Plans & Sub-plans** — implementation breakdown (lower trust — may have drifted)
6. **Beads** — must conform to everything above

If a bead contradicts a higher-trust source, the bead is wrong. If a plan contradicts the design, cite the design, not the plan.

---

## Finding Classification

Every finding has a **class** (what's wrong) and a **severity** (FAIL or WARN):

| Class | Meaning | Default Severity |
|-------|---------|-----------------|
| `MISSING_BEAD` | Required bead does not exist | **FAIL** |
| `WRONG_CONTENT` | Bead exists but description is incorrect | **FAIL** |
| `WRONG_DEPENDENCY` | Dependency wiring is incorrect | **FAIL** |
| `EMPTY_GATE` | Gate bead has no scope or verification commands | **FAIL** |
| `ORPHANED_GATE` | Gate bead exists but nothing depends on it | **WARN** |
| `WRONG_TYPE` | Bead type is incorrect | **WARN** |
| `GRANULARITY` | Bead is too coarse or too fine | **WARN** |
| `STALE_REF` | Context reference points to wrong/missing file | **FAIL** (MECHANICAL — auto-fixable) |
| `CROSS_MODULE` | Cross-module dependency not wired | **FAIL** |
| `UPSTREAM_DOC` | Issue is in the upstream doc, not the bead | **WARN** (not a bead defect — note separately) |

**Severity model alignment:** This skill uses FAIL/WARN to match review-prd, review-design, and review-plan. FAIL = blocks /execute. WARN = quality improvement, doesn't block.

---

## Severity Calibration

**Every finding gets a severity. Calibrate carefully — inflation kills trust.** CRITICAL and HIGH map to FAIL; MEDIUM and LOW map to WARN.

For concrete examples of each severity level (CRITICAL, HIGH, MEDIUM, LOW) with bead-specific scenarios, see: `references/review-checklists.md#severity-calibration`

For the shared FAIL/WARN severity model and finding quality standards, see: `../_shared/references/review-finding-taxonomy.md`

---

## Critical Sequence

### Phase 1: Document Loading

**Load every upstream document before reviewing any bead.** Do not start reviewing beads until all source material is loaded.

**Step 1.1 — Identify the feature and bead set:**

```bash
br list --status open --json   # or filter by epic
br dep tree <epic-id>          # dependency visualization
```

Record: epic ID, bead count, feature name.

**Step 1.2 — Load upstream documents:**

Read ALL of the following that exist (use the project's doc structure):

| Document | Path Pattern | Purpose |
|----------|-------------|---------|
| PRD | `docs/prd/{feature}/prd.md` | FR definitions, acceptance criteria, priorities |
| Design — API surface | `docs/designs/{feature}/**/api-surface.md` | Endpoints, shapes, HTTP methods, error responses |
| Design — Data model | `docs/designs/{feature}/**/data-model.md` | Entities, properties, constraints, relationships |
| Design — UI mockup | `docs/designs/{feature}/**/ui-mockup.md` | Screens, components, interactions, states |
| Design — Test plan | `docs/designs/{feature}/**/test-plan.md` | Test scenarios, coverage matrix |
| Design — Overview | `docs/designs/{feature}/design.md` | Problem statement, constraints, chosen approach |
| Use cases | `docs/use-cases/UC-*.md` | Actor workflows, extension flows, error conditions |
| Plan overview | `docs/plans/{feature}/overview.md` | Task summary, dependency graph, FR coverage |
| Sub-plans | `docs/plans/{feature}/[0-9]*.md` | Per-task intent, scope, criteria |
| Pattern docs | `docs/patterns/**/*.md` | Pattern keys referenced by beads |
| ADRs | `docs/adr/*.md` | Architectural decisions |
| Architecture docs | `docs/architecture/*.md` | Multi-tenancy, auth, CQRS context |
| Learnings | `docs/learnings/*.md` | Past gotchas and corrections |

**Step 1.3 — Build the source index:**

For each document loaded, record what it provides:

```markdown
## Source Index

| Source | Key Content | Trust Level |
|--------|------------|-------------|
| PRD | 12 FRs (8 Must, 3 Should, 1 Could), 2 NFRs | 2 (high) |
| API Surface | 14 endpoints across 3 entities | 3 (design) |
| Data Model | 3 entities, 2 enums, 5 relationships | 3 (design) |
| UI Mockup | 2 list pages, 2 capture pages, 1 embedded list | 3 (design) |
| ADR-0004 | Enums over string constants | 1 (highest) |
| ADR-0005 | EnumDTO/NamedDTO for UI binding | 1 (highest) |
```

---

### Phase 2: FR/UC Gap Analysis

**Step 2.1 — Build FR Coverage Matrix:**

For each FR in the PRD, identify which bead(s) implement it. Check bead descriptions for `## Implements` sections and FR tags.

**Acceptance criteria depth check:** For each Must-Have FR, read the PRD's Given/When/Then acceptance criteria. Verify each criterion maps to at least one bead's success criteria. An FR is "Full" only if ALL acceptance criteria are addressed. If 2 of 4 criteria are missing from any bead, the FR is "Partial" — flag as FAIL.

```markdown
## FR Coverage Matrix

| FR ID | Priority | Description | Bead(s) | Coverage |
|-------|----------|-------------|---------|----------|
| FR-ROLE-CREATE | Must | Create new role | bd-006 (SaveCommand), bd-012 (Save Endpoint) | Full |
| FR-ROLE-LIST | Must | List roles with grid | bd-009 (GridQuery), bd-014 (Grid Endpoint), bd-020 (List Page) | Full |
| FR-ROLE-DELETE | Must | Delete role | — | MISSING |
| FR-ROLE-ASSIGN | Should | Assign role to user | bd-008 (Lifecycle) | Partial — no UI bead |
```

**Coverage statuses:**
- **Full** — all backend + frontend + test beads exist
- **Partial** — some beads exist but gaps remain (specify what's missing)
- **MISSING** — no beads at all (CRITICAL if Must-Have)
- **Deferred** — explicitly out of scope per PRD (Should/Could only)

**Step 2.2 — Build UC Coverage Matrix:**

For each use case, trace the main scenario steps and extension/alternative flows to beads.

```markdown
## UC Coverage Matrix

| UC ID | Step/Flow | Description | Bead(s) | Coverage |
|-------|-----------|-------------|---------|----------|
| UC-001 | Main.1 | Admin navigates to roles list | bd-020 (List Page), bd-022 (Routing) | Full |
| UC-001 | Main.2 | Admin clicks "New Role" | bd-021 (Capture Page) | Full |
| UC-001 | Main.3 | Admin fills form and saves | bd-006 (SaveCommand), bd-012 (Save Endpoint) | Full |
| UC-001 | Ext.3a | Duplicate name error | bd-011 (Validators) | Full |
| UC-001 | Ext.3b | Server error during save | — | MISSING — no error handling bead |
| UC-001 | Alt.1 | Admin cancels without saving | bd-021 (Capture Page) | Implicit in canDeactivate |
```

**Step 2.3 — Flag gaps:**

Any Must-Have FR with coverage status `MISSING` or `Partial` is a CRITICAL finding of class `MISSING_BEAD`. Any UC main scenario step with `MISSING` coverage is HIGH.

---

### Phase 3: Granularity Decomposition

**This is the most important phase.** Count the expected beads from the design documents, then compare against actual beads. Mismatches reveal missing beads, over-combined beads, or unnecessary beads.

**Step 3.1 — Count expected beads from design:**

Read the design docs and derive what the bead set SHOULD contain. Use the decomposition tables (data model, API surface, UI mockup, stage gates) from: `references/review-checklists.md#granularity-decomposition-tables-phase-3`

**Step 3.2 — Derive expected bead count:**

Use the expected bead count template from: `references/review-checklists.md#expected-bead-count-template`

**Step 3.3 — Identify decomposition mismatches:**

For each delta, determine whether it's:
- **Missing bead** (`MISSING_BEAD`) — expected bead doesn't exist
- **Over-combined** (`GRANULARITY`) — expected bead is merged into a larger bead
- **Correctly grouped** — per grouping exceptions in `/beads` skill
- **Extra bead** — bead exists but design doesn't warrant it (flag for verification)

**Step 3.4 — Write decomposition specs for splits:**

For each `GRANULARITY` finding that recommends splitting, provide a concrete decomposition:

```markdown
### Decomposition: bd-005 "Role Mappers" → 2 beads

**Current bead:** Combines EntityMapper and DTOMapper
**Violation:** EntityMapper (DTO→Entity) and DTOMapper (Entity→DTO) are opposite data flows — never combine per bead size heuristic

**Split into:**
1. `{Entity} EntityMapper` — Pattern: `entity-mapper`, depends on: Entity + Contracts beads
2. `{Entity} DTOMapper` — Pattern: `dto-mapper`, depends on: Entity + Contracts beads

**Dependencies to rewire:**
- SaveCommand should depend on EntityMapper (not the combined bead)
- GetQuery should depend on DTOMapper (not the combined bead)
```

**Step 3.5 — Finding verification:**

Before recording any finding from this phase, **re-read the bead** via `br show <bead-id>`. Verify:
- The bead actually says what you think it says
- The dependency wiring is actually wrong (check `br dep list`)
- The issue causes a concrete execution problem

---

### Phase 4: Bead-by-Bead Deep Review

For each bead, review against all 11 categories. Not every category applies to every bead — skip inapplicable checks.

For the full checklist for each category, see: `references/review-checklists.md#category-checklists-phase-4-bead-by-bead-deep-review`

**Categories summary:**

| # | Category | Key Focus |
|---|----------|-----------|
| 1 | FR Coverage | Every Must-Have FR has beads; acceptance criteria map to success criteria |
| 2 | UC Coverage | Main/extension/alternative flows covered; actor behavior preserved |
| 3 | Design Compliance | API surface, data model, UI mockup alignment (shapes, methods, properties) |
| 4 | Architecture Compliance | ADR adherence, multi-tenancy/RLS, authorization, CQRS separation |
| 5 | API Pattern Compliance | Vertical slices, endpoint patterns (save/get/grid/delete/lookup), contracts placement |
| 6 | Web Pattern Compliance | Component library, signals, standalone components, zoneless, routing |
| 7 | Test Coverage | Test plan traceability, executable commands, negative/RLS cases |
| 7b | Test & Verification Gates | Gate policy (no /review or /simplify gates), cadence, wiring, executability |
| 8 | Bead Quality | Objective clarity, context refs, testable criteria, decision-traced failure criteria |
| 9 | No Backwards Compatibility | No shims, no adapters, cleanup beads exist, no migration beads |
| 10 | Cross-Module Dependencies | Wired links match, no hidden assumptions, shared contracts ordered |
| 11 | Granularity | One-bead-per-artifact rules, never-combine list, grouping exceptions |

---

### Phase 5: Cross-Bead Consistency

After reviewing individual beads, check cross-cutting concerns:

**Dependency graph integrity:**
- [ ] No circular dependencies (`br dep cycles`)
- [ ] Dependency graph is a DAG
- [ ] First bead(s) have zero dependencies and are ready to execute
- [ ] Epic depends on `verify({module}): module complete` gate (last bead)
- [ ] No `/review` or `/simplify` gate beads exist between implementation beads (these break future beads by deleting preparatory code)

**Naming consistency:**
- [ ] Entity names consistent across all beads (same casing, same abbreviation)
- [ ] Enum values consistent between entity beads and contracts beads
- [ ] Property names consistent between data model design and bead descriptions

**Pattern reference consistency:**
- [ ] Same pattern doc referenced by same bead type across entities (e.g., all SaveCommand beads reference `commands` pattern)
- [ ] No bead references a non-existent pattern doc

**Gate wiring:**
- [ ] Frontend beads depend on backend test gate, NEVER on backend impl beads
- [ ] Gate chain is complete: impl beads → test gate → next phase (no missing link)
- [ ] UC gates depend on ALL contributing feature test gates (not a subset)
- [ ] Module gate depends on ALL UC gates

---

### Phase 6: Synthesize Report

**Step 6.1 — Write the review report:**

Write to `docs/reviews/review-beads-{feature}-{date}.md`.

```markdown
# Bead Review: {Feature Name}

> **Date:** {date}
> **Reviewer:** /review-beads skill v1.0
> **Beads reviewed:** {count} ({impl} implementation + {gates} gates + {tests} tests)
> **Upstream docs loaded:** {count}

## Executive Summary

**Verdict:** {PASS | PASS WITH FINDINGS | FAIL — MUST REMEDIATE}

| Severity | Count |
|----------|-------|
| CRITICAL | {N} |
| HIGH | {N} |
| MEDIUM | {N} |
| LOW | {N} |
| UPSTREAM_DOC | {N} |

{1-3 sentence summary of the most important issues}

## FR Coverage Matrix

{From Phase 2, Step 2.1}

## UC Coverage Matrix

{From Phase 2, Step 2.2}

## Granularity Decomposition

### Expected Bead Count Derivation
{From Phase 3, Step 3.2}

### Decomposition Specs
{From Phase 3, Step 3.4 — for each recommended split}

## Findings

### CRITICAL ({N})

#### C{N}. {Title}
| Field | Value |
|-------|-------|
| **Bead** | `{bead-id}: {title}` |
| **Class** | {finding class} |
| **Category** | {review category number and name} |
| **Defect** | "{quoted text from bead or description of omission}" |
| **Source** | {upstream doc path and section} |
| **Impact** | {what goes wrong during execution} |
| **Fix** | {concrete resolution} |

### HIGH ({N})
{Same format}

### MEDIUM ({N})
{Same format, abbreviated — no Source field}

### LOW ({N})
{One-line each: bead-id, class, issue, fix}

### UPSTREAM_DOC ({N})
{Issues in upstream docs, not bead defects. Listed for awareness.}
| Doc | Issue | Suggested Fix |
|-----|-------|---------------|

## Stage Gate Analysis

| Level | Expected | Actual | Status |
|-------|----------|--------|--------|
| Feature ({N}) × 6 | {expected} | {actual} | {OK / MISSING / EXTRA} |
| Use Case ({N}) × 2 | {expected} | {actual} | {OK / MISSING} |
| Module × 2 | {expected} | {actual} | {OK / MISSING} |

Gate wiring issues: {list or "None"}
Cadence violations: {list or "None — max {N} impl beads between gates"}

## Recommended Actions

### Immediate (block /execute)
1. {action} — fixes C{N}, C{N}
2. {action} — fixes C{N}

### Before first gate
1. {action} — fixes H{N}, H{N}

### Can fix during execution
1. {action} — fixes M{N}

## Post-Decomposition Bead Inventory

{Updated bead list reflecting all recommended splits and additions}

| # | Bead ID | Title | Type | Status |
|---|---------|-------|------|--------|
| 1 | bd-001 | {title} | impl | OK |
| 2 | bd-002 | {title} | impl | SPLIT → bd-002a, bd-002b |
| 3 | — | {new bead title} | impl | NEW (MISSING_BEAD fix) |
| 4 | bd-003 | {title} | gate | EMPTY — needs scope |
```

**Step 6.2 — Present executive summary to user:**

Read only the executive summary (~30 lines) from the report. Present it with the verdict.

**PAUSE:** Present findings and collect user decision.

Present the executive summary as formatted markdown, then:

```
AskUserQuestion:
  question: "How should we handle the bead review findings?"
  header: "Findings"
  multiSelect: false
  options:
    - label: "Fix all (Recommended)"
      description: "Remediate all CRITICAL and HIGH findings before /execute"
    - label: "Fix critical only"
      description: "Remediate CRITICAL findings only, accept HIGH as risk"
    - label: "Review specifics"
      description: "Walk me through the findings — I'll decide per-finding"
    - label: "Approved as-is"
      description: "Accept beads without changes. Findings are acceptable risk."
    - label: "Back to /beads"
      description: "Findings reveal structural issues. Regenerate beads."
```

If "Review specifics": use Guided Review (Pattern 5) to walk through findings by severity, starting with CRITICAL. For each finding, present the full detail and ask approve/reject/modify.

If "Fix all" or "Fix critical only": proceed to remediation — update bead descriptions via `br update`, add missing beads via `br create`, rewire dependencies via `br dep add/remove`.

---

## Batch Execution (COMPREHENSIVE mode)

For reviewing beads across multiple modules, use parallel agents with these rules:

### Worker Isolation

- Each worker owns ONE module's review output file
- Workers MUST NOT read or write each other's output files
- Each worker runs the full Phase 1-6 sequence independently
- Max 5 concurrent workers

### Execution

```bash
# Launch workers (example using Task tool)
# Worker 1: /review-beads roles-module
# Worker 2: /review-beads permissions-module
# Worker 3: /review-beads entitlements-module
```

### Convergence Criteria

- **Pass:** 0 CRITICAL findings across ALL modules
- **Conditional pass:** 0 CRITICAL, <5 HIGH total — proceed with remediation plan
- **Fail:** Any CRITICAL remaining after remediation attempt — return to `/beads`

### Retry Policy

- Each worker gets ONE retry on failure (tool timeout, incomplete review)
- On second failure: flag module as requiring manual review
- Never retry more than twice — the issue is likely in the upstream docs

### Consolidation

After all workers complete, produce a cross-module summary:

```markdown
## Cross-Module Bead Review Summary

| Module | Beads | Critical | High | Medium | Low | Verdict |
|--------|-------|----------|------|--------|-----|---------|
| {Module A} | 30 | 0 | 2 | 5 | 3 | PASS WITH FINDINGS |
| Permissions | 22 | 1 | 1 | 3 | 1 | FAIL |
| {Module B} | 15 | 0 | 0 | 2 | 4 | PASS |

### Cross-Module Issues
{Issues that span modules — shared contracts, dependency ordering, etc.}

### Remediation Priority
1. {Module}: {critical finding} — blocks all downstream
2. {Module}: {high finding} — blocks frontend
```

---

## Anti-Patterns

**Rubber-Stamp Review** — Marking all beads as "OK" without verifying against upstream docs. The entire value of this skill is adversarial verification. If the review finds zero issues on a non-trivial bead set, something was missed — re-examine the granularity decomposition.

**Flagging Style Over Substance** — Reporting findings about bead description formatting, section ordering, or wording preferences. These don't affect execution. Focus on content that would cause an agent to produce wrong code.

**Plan-Trust Over Design-Trust** — Verifying beads against the plan instead of the design. Plans are derived from designs and may have drifted. When plan and design disagree, the design is authoritative (see Trust Hierarchy).

**Cached-Read Findings** — Writing a finding based on what you remember the bead says without re-reading it. Beads get updated. Always `br show` before writing a finding.

**Missing Granularity Analysis** — Reviewing bead content without first counting expected beads from the design. Granularity decomposition (Phase 3) is the highest-signal phase — it catches missing beads and over-combined beads that content review alone misses.

**Inflated Severity** — Rating cosmetic issues as HIGH or missing FR tags as CRITICAL. Severity inflation causes users to ignore findings. Use the calibration examples strictly.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "fix all" / "fix critical" | Remediate findings | Update beads, then re-verify |
| "approved" / "approved as-is" | Accept beads | Proceed to `/execute` |
| "back to /beads" | Structural issues | Return to `/beads` for regeneration |
| "review specifics" | Per-finding triage | Guided review walkthrough |

When approved: **"Bead review complete. Run /execute to start implementation."**

---

*Skill Version: 2.8 — [Version History](VERSIONS.md)*
