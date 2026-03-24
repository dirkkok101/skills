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

**Shared loop, classification, convergence criteria, and report formats:** [`../_shared/references/converge-mode.md`](../_shared/references/converge-mode.md)

**Severity model and finding quality standards:** [`../_shared/references/review-finding-taxonomy.md`](../_shared/references/review-finding-taxonomy.md)

**PRD-review-specific CONVERGE behavior:**

- **Skip scope confirmation gate.** CONVERGE implies "just go."
- **Replace Phase 5 interactive walkthrough** with a summary table of all findings, classified as MECHANICAL / JUSTIFIED_DEVIATION / DECISION. No per-finding AskUserQuestion for FAILs — present in batch, fix mechanicals directly.
- **WARNs are listed** in the summary table but NOT presented interactively and NOT auto-fixed. Triaged after FAILs reach 0 via AskUserQuestion with "Fix / Accept as-is" options.
- **Phase 1 chunking strategy:** For PRDs over 300 lines, split Phase 1 into three passes: Pass A (Metadata through Personas), Pass B (Assumptions through NFRs), Pass C (Prioritisation through Approval). Record findings per pass.
- **PRD-specific authority hierarchy:** `/prd skill Structural Conventions > cross-cutting PRD > ADRs > project personas > the PRD being reviewed`

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

Check every section the /prd skill template requires for the PRD's scope level (11 section groups, from metadata through document approval). The /prd v3.7 Structural Conventions section defines exact formats — these are non-negotiable.

**Full checklists (Sections 1.1-1.11):** [`references/prd-review-checklists.md` — Phase 1](references/prd-review-checklists.md#phase-1-structural-completeness)

Record all results. Do not present passes to the user.

---

### Phase 2: Content Quality (STANDARD+)

Beyond structural presence, examine content substance: acceptance criteria testability, NFR measurability, success metrics completeness, use case completeness (COMPREHENSIVE), persona references, stable ID convention, naming convention consistency, heading level compliance, and audit coverage.

**Full checklists:** [`references/prd-review-checklists.md` — Phase 2](references/prd-review-checklists.md#phase-2-content-quality-rules-standard)

---

### Phase 3: Cross-Cutting Compliance (STANDARD+)

Check the PRD against the cross-cutting PRD and project-wide standards for audit logging, data lifecycle, error handling, pagination/filtering, and ADR compliance. Each finding cites the specific cross-cutting requirement.

**Full checklists:** [`references/prd-review-checklists.md` — Phase 3](references/prd-review-checklists.md#phase-3-cross-cutting-compliance-framework-standard)

---

### Phase 4: Adversarial Depth (COMPREHENSIVE only)

Go beyond compliance into adversarial analysis. Checks acceptance criteria discrimination, failure path exhaustiveness, assumption impact analysis, non-goal effectiveness, and security coverage.

**Full checklists (severity guide + all checks):** [`references/prd-review-checklists.md` — Phase 4](references/prd-review-checklists.md#phase-4-adversarial-depth-checks-comprehensive-only)

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
