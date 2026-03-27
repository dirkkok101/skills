---
name: review-prd
description: >
  Use before /technical-design, after /prd, when user says "review prd",
  "check requirements", or when PRD quality is uncertain.
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
- **Replace Phase 5 interactive walkthrough** with a **per-finding summary table** before fixing. Each finding gets one row with: finding number, one-line description, classification, and location. This gives the user visibility into what will change before edits begin:

  ```
  | # | Finding | Class | Location |
  |---|---------|-------|----------|
  | F1 | Goals missing G{n} numbering | MECHANICAL | ## Goals |
  | F2 | Persona P1 → project P6 alignment | DECISION | ## User Personas |
  | F3 | Success Metrics section missing | DECISION (draft) | — |
  ```

  No per-finding AskUserQuestion for FAILs — present in batch, fix mechanicals directly.
- **WARNs are listed** in the summary table but NOT presented interactively and NOT auto-fixed.

**Phase 1 chunking strategy:** For PRDs over 300 lines in **interactive (non-CONVERGE) mode**, split Phase 1 into three passes:
- Pass A: Metadata, Document History, Problem Statement, Goals, Non-Goals, Success Metrics, Personas
- Pass B: Assumptions & Constraints, Use Cases, Functional Requirements, NFRs
- Pass C: Prioritisation, Domain Validation, Document Approval
Record findings per pass. This reduces cognitive load on large PRDs.

In **CONVERGE mode**, chunking is optional. CONVERGE's value is speed — reading sequentially and tracking findings as you go is acceptable if you can maintain accuracy. Use chunking only if the PRD is exceptionally large (>1000 lines) or if you find yourself losing track of findings late in the document.

**The loop:**

1. **Review** — Run the review at the selected depth using the chunking strategy above.
2. **Classify** findings:
   - **MECHANICAL** — wrong numbering prefix, stale count, missing section header, format error, ambiguity word in acceptance criteria, internal contradiction where one side is clearly correct. Auto-fix these. **Content additions are NOT mechanical.** Adding new goals, NFRs, FRs, or acceptance criteria to hit count minimums is authoring — classify as DECISION and preview the proposed content before writing it. The review skill audits; it does not generate requirements. Renumbering existing items = MECHANICAL. Writing new items = DECISION.
   - **JUSTIFIED_DEVIATION** — PRD deviates from a convention with explicit, documented rationale. Verify rationale is sound; if yes, mark as PASS. **Inline waiver recognition:** If the PRD contains an explicit justification paragraph near a threshold deviation (e.g., "13 Must Haves is intentional because this is an authentication module with N security requirements"), treat this as a standing waiver — do not re-flag as WARN on subsequent CONVERGE runs. The justification functions as a permanent acceptance. Only re-flag if the justification's reasoning no longer holds (e.g., scope changed but the note wasn't updated).
   - **DECISION** — PRD contradicts cross-cutting PRD, persona references don't match, scope question requiring user judgment. Escalate to user via AskUserQuestion.

   **Persona alignment is always DECISION, never MECHANICAL.** When PRD personas don't match project personas, the renumbering cascades across FR user stories, UC metadata, coverage matrices, and domain validation. Present a mapping preview before applying:

   ```
   AskUserQuestion:
     question: "PRD personas need alignment with project personas. Review this mapping before I apply cascading changes:"
     header: "Persona Mapping"
     multiSelect: false
     options:
       - label: "Apply mapping"
         description: "PRD P1 '{name}' → Project P{n} '{name}', PRD P2 '{name}' → Project P{n} '{name}', ..."
       - label: "Keep local numbering"
         description: "Add a mapping note to the PRD instead of renumbering. Avoids cascading edits."
       - label: "Revise mapping"
         description: "I'll provide corrections to the proposed mapping."
   ```

   If the user chooses "Keep local numbering", add a `> **Persona Mapping:** P1 = Project P{n}, P2 = Project P{n}, ...` note after the Personas section header instead of renumbering. This avoids disproportionate cascading edits for a cosmetic alignment.
3. **Deduplicate** same-type findings before fixing. Multiple instances of the same violation type count as **one finding with multiple locations**, not separate findings. Examples:
   - "Assumptions A1-A9 missing `**A{n}:**` prefix" = 1 finding, 9 locations
   - "FRs 3, 5, 7 missing Security Criteria" = 1 finding, 3 locations
   - "Goals, Non-Goals, Constraints all missing numbering convention" = 1 finding, 3 sections

   This reduces finding count, simplifies the summary, and enables batch fixing. Report as: "F{N}: {violation type} ({M} locations: {list})."
4. **Fix** mechanical findings using minimum changes. Batch same-type fixes into a single editing pass — collect all numbering fixes and apply them together rather than one Edit call per instance. Start fixing obvious mechanicals (numbering, headings) immediately — don't wait for full analysis to complete before touching the file.
5. **Corruption scan** — After fixes, Grep the modified file for known anti-patterns introduced by bulk edits:
   - Concatenated lines: `\w(Priority|Complexity):` (heading merged with metadata line)
   - Orphaned code fences: unmatched `` ``` `` lines
   - Duplicate headings: same `##` or `###` heading appearing twice
   - Missing blank lines: heading immediately preceded by non-blank line

   Fix any corruption before proceeding. This catches regressions like the `[MUST]` removal bug that concatenated FR titles with Priority lines.
6. **Internal consistency check** — After adding or removing FRs/NFRs, verify that complexity budget statements, traceability tables, and count references in the document are updated to match. A CONVERGE round that adds 2 NFRs must also update any "Total: N NFRs" text.
7. **Re-review** — Run the review again on the fixed PRD.
8. **Compare** — Did FAILs decrease? If increased, revert and stop. If same findings for 3 rounds, stop.
9. **Repeat** until FAILs = 0 or max 5 rounds.
10. **WARN reconciliation** — Before triage, re-check each baseline WARN against the post-fix PRD state. WARNs that were resolved as side effects of FAIL fixes (e.g., metadata fields fixed during version bump, section format corrected during restructure) should be marked "Auto-resolved by F{N} fix" and dropped from the triage list. Only present WARNs that still exist in the current document.
11. **WARN triage** — After reconciliation, offer a "fix all" shortcut before per-batch review:

   ```
   AskUserQuestion:
     question: "{N} WARNs remain after reconciliation. How would you like to handle them?"
     header: "WARN Triage"
     multiSelect: false
     options:
       - label: "Fix all"
         description: "Apply fixes for all {N} remaining WARNs without individual review."
       - label: "Review individually"
         description: "Present WARNs in batches of 4 for selective fixing."
       - label: "Accept all as-is"
         description: "Skip WARN fixes entirely. No changes."
   ```

   If "Fix all": apply all WARN fixes directly. If "Review individually": present in batches of up to 4 via multi-select AskUserQuestion as before. Report auto-resolved WARNs in the summary: "W2, W5 auto-resolved by FAIL fixes."

**Severity alignment:** The review's own FAIL/WARN classification is authoritative. CONVERGE fixes FAILs only. WARNs are triaged after convergence.

**CONVERGE depth auto-recommendation:** After Round 0 (baseline review), check the finding distribution. If ALL FAILs are Structural (Phase 1) and zero FAILs come from Content Quality (Phase 2), Cross-Cutting (Phase 3), or Adversarial (Phase 4), the content is solid and only formatting needs fixing. In this case, report:

> "Round 0 found {N} structural FAILs and 0 content/adversarial FAILs — content quality is high. Fixing structural issues at STANDARD depth (skipping Phase 4 re-run after fixes)."

Then fix the structural MECHANICALs and skip the Phase 4 re-run on subsequent rounds, since it already produced no findings. This avoids the pattern where CONVERGE + COMPREHENSIVE re-runs Phase 4 adversarial checks on every round even though they've already passed.

**Authority hierarchy for mechanical fixes:**
```
/prd skill Structural Conventions > cross-cutting PRD > ADRs > project personas > the PRD being reviewed
```

**Convergence report — compact format (default):**

Use the compact format by default:
`{N} findings → {N} fixed in {N} rounds. {N} decisions escalated. WARNs: {N} triaged ({N} fixed, {N} accepted).`

**Full table format (>3 rounds or >10 total findings):**

Only use the full table when convergence was complex — more than 3 rounds or more than 10 total findings across all rounds:

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

---

## Important Rules

1. **READ-ONLY** (non-CONVERGE modes) — Do not modify any files. This skill audits; it does not fix. **Exception:** CONVERGE mode modifies the PRD directly to fix mechanical findings.
2. **Findings only** — Every finding cites a specific /prd template section or cross-cutting requirement. No opinions beyond documented standards.
3. **Do not read source code** — This reviews documents against documents. Code does not exist yet.
4. **Pattern docs and ADRs are constraints** — They are binding specifications, not suggestions.
5. **Skip passes silently** — Only present failures and warnings to the user. Passing checks are recorded in the summary table but not discussed.
6. **Review scope boundary** — This skill audits and fixes formatting; it does not generate new requirements content. If a section is missing entirely (e.g., no use case files exist), flag it as FAIL and recommend running `/prd` to create the missing content — do not write use cases, FRs, or other requirements inline. The review skill must maintain independence from the authoring skill. Exception: CONVERGE may draft NFR/goal content to fill structural gaps, but only as a DECISION with user preview, never as MECHANICAL auto-fix.
6. **Direct reads, not agents** — For Phase 0 context loading, use direct parallel Read tool calls for the PRD, personas, UCs, and references. Do not use Explore agents — they return summaries, not the raw text needed for line-by-line structural checks. Explore agents are useful for *finding* files but not for *reading* them for review.
7. **Use Edit, not Write, for CONVERGE fixes** — Always use targeted Edit calls, never a full-file Write. Full rewrites are opaque (the user can't see what changed), hard to diff, and risky (a dropped section is invisible). Group same-type fixes into batched Edit calls — numbering fixes in one pass, Security Criteria additions in another, heading fixes in a third. Target 3-5 editing passes for a typical 10-15 finding round.
8. **Concise Document History entries** — When CONVERGE bumps the PRD version, write a one-line changelog entry, not a per-finding list. Example: `"v3.4: Template compliance — numbering conventions, heading levels, persona alignment, Security Criteria additions (review-prd CONVERGE)"`. The finding details are in the CONVERGE report, not the Document History.
9. **TOC anchor verification** — After renaming sections (e.g., `## Personas` → `## User Personas`) or restructuring headings, verify the TOC anchor links still resolve. Markdown anchors are generated from heading text (lowercase, spaces → hyphens, punctuation stripped). A renamed heading breaks its anchor. Check each TOC entry's `(#anchor)` against the actual heading text after edits.
10. **Verify bulk replacements immediately** — After any `replace_all` edit, Grep for the pattern in the modified file to confirm it worked cleanly. Bulk replacements can consume adjacent whitespace or newlines, causing line merges (e.g., removing `[MUST]` from FR headings merges the title with the next line). Catch these before moving to the next fix.
11. **Grep for stale references after cascading renames** — After renaming personas, sections, or FR IDs that appear in multiple locations, Grep for the old name/ID across the PRD and all UC files. A persona rename from "Site Administrator" to "Tenant Administrator" must not leave stale "Site Administrator" references in FR user stories, UC metadata, or coverage matrices.

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

**Missing cross-cutting PRD:** If `docs/prd/cross-cutting/prd.md` does not exist, record a project-level WARN immediately:

> "No cross-cutting PRD found at `docs/prd/cross-cutting/prd.md`. Phase 3 (Cross-Cutting Compliance) will be limited to ADR checks only. Audit logging, data lifecycle, error handling, and pagination checks cannot be verified against shared standards."

This is reported once in the summary table, not per-check. Phase 3 still runs but only the ADR Compliance check is fully verifiable — the other checks (Audit Logging, Data Lifecycle, Error Handling, Pagination) are best-effort against general principles rather than project-specific requirements.

**Step 0.3 — Determine PRD scope and origin:**

Read the PRD metadata table to identify its scope (BRIEF / STANDARD / COMPREHENSIVE). This determines which template sections are required.

**PRD origin detection:** Determine whether the PRD was generated by the `/prd` skill or hand-written. Signals of skill generation:
- Document History mentions "Initial PRD" as v0.1 with no prior versions
- Structural conventions (heading formats, numbering prefixes, FR body format) are uniformly correct
- Presence of all mandatory sections in correct order

**Why this matters:** A skill-generated PRD will have near-perfect structural compliance — few Phase 1/2 findings are expected and healthy. A hand-written PRD is more likely to have structural gaps. The anti-pattern warning ("zero issues on a first-draft = insufficient review") applies to **hand-written** PRDs only. For skill-generated PRDs, the primary value comes from Phase 3 (cross-cutting compliance) and Phase 4 (adversarial depth), not structural checks.

**PRD maturity detection:** Check the Document History table for revision count and prior review evidence:
- **Mature PRD** (v2.0+ with prior review evidence, or 5+ versions): Apply the **maturity discount** (see below). Structural and naming checks will mostly pass. Phase 4 adversarial depth has diminishing returns.
- **Early PRD** (v0.1-v1.x, no prior reviews): Full review depth is warranted. All severities apply as written.

**Maturity discount:** For mature PRDs, **cosmetic template formatting** findings are downgraded from FAIL to WARN. This includes:
- Numbering convention violations (`G{n}`, `NG{n}`, `A{n}`, `C{n}` prefixes)
- Heading level mismatches (H2 vs H3 nesting)
- `Reason:` suffix missing on Won't Have items
- `Impact:` / `Why now:` format deviations
- Section ordering within a correctly-structured document

These are real template violations but they don't affect downstream design or implementation quality on a document that's already been through substantive review.

**Not discounted** (remain FAIL regardless of maturity):
- Missing sections entirely (no FR section, no NFR section)
- Missing acceptance criteria on FRs
- Missing Security Criteria on auth/PII FRs
- FR ID format violations (affects traceability tooling)
- Missing mandatory audit NFR
- Content contradictions or stale cross-references

**Time allocation for mature PRDs:** When the maturity discount applies, invert the effort allocation:
- **Phase 1 (Structural): ~20%** — Quick pass, mostly WARNs. Don't dwell.
- **Phase 2 (Content): ~20%** — Spot-check naming/heading; focus on AC testability and NFR measurability.
- **Phase 3 (Cross-Cutting): ~20%** — Read actual ADR content, not just titles.
- **Phase 4 (Adversarial): ~40%** — This is where the real value lives for mature PRDs. Push hard on boundary conditions, race conditions, cross-module ambiguity, and underspecified defaults. If Phase 4 produces 0 findings on a mature PRD, you likely weren't thorough enough — mature PRDs accumulate subtle gaps that earlier structural-focused reviews missed.

**Step 0.4 — Confirm review mode:**

If the PRD is mature (5+ versions) and the user requests COMPREHENSIVE, present a maturity-aware recommendation:

```
AskUserQuestion:
  question: "This PRD is at v{N} with {N} prior revisions. COMPREHENSIVE adversarial depth is unlikely to find new issues. Recommended: STANDARD (structural + content + cross-cutting). Proceed with COMPREHENSIVE anyway?"
  header: "Mode"
  multiSelect: false
  options:
    - label: "Standard (Recommended)"
      description: "Full template compliance + content quality + cross-cutting. Appropriate for mature PRDs."
    - label: "Comprehensive (as requested)"
      description: "All checks + adversarial depth. Will run but Phase 4 may produce few findings."
    - label: "Brief"
      description: "Quick structural completeness check only (~15 min)."
```

**Scope-depth mismatch:** If the PRD declares STANDARD or BRIEF scope but the user requests COMPREHENSIVE review depth, note that Phase 4 adversarial checks are designed for COMPREHENSIVE-scope PRDs (multiple FRs, Tier 1 use cases, integration points). On a STANDARD PRD with 3-8 FRs and no use case files, Phase 4 adds limited value. Recommend matching review depth to PRD scope unless the user has a specific reason to go deeper.

For non-mature PRDs or when COMPREHENSIVE is clearly appropriate, use the standard mode selection:

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

Check every section the /prd skill template requires for the PRD's scope level. The /prd v3.9 Structural Conventions section defines exact formats — these are non-negotiable. For each check, record Pass / Warning / Fail.

**Note on Policy & Standards PRDs:** PRDs that define shared policies or cross-cutting concerns (rather than a single bounded module) may legitimately have lighter Personas, Use Cases, NFRs, and Dependency Graphs. If the PRD explicitly identifies itself as a policy/standards document, apply the exceptions noted in /prd v3.9 "Policy & Standards PRDs" section. The structural conventions (heading formats, numbering, table columns) still apply without exception.

**Note on Library & Package PRDs:** PRDs for NuGet packages, npm packages, or shared libraries have a different lens — developer personas, integration use cases, Package API Contract format for Integration Points. See /prd v3.9 "Library & Package PRDs" section. Key differences: (1) personas are developers, not end-users; (2) Integration Points uses Package API Contract variant, not Consumed/Exposed Services; (3) NFRs may include package-specific concerns (binary size, dependency footprint, API stability). Apply the matching structural checks from Phase 1.8.

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
| FR count minimum | At least 3 (BRIEF), 8 (STANDARD), 10 (COMPREHENSIVE) | INFO — soft guideline (see note) |

**Note on FR count minimum:** The count thresholds are soft guidelines, not hard rules. A well-decomposed narrow module with 8 FRs that fully covers its domain is better than the same module with 10 FRs where 2 were artificially split to hit a number. The check should verify "are all requirements covered?" — not "are there enough items?" Report as INFO in the summary; do not flag as FAIL or WARN. If the PRD's FRs cover all personas, use cases, and business goals, the count is sufficient regardless of the number.

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

Two valid formats exist — the standard microservice format and the Package API Contract variant for shared libraries/packages (see /prd v3.9 Phase 8b).

**Standard format (microservices):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Integration Points` section | Present as H2 | Fail if missing for COMPREHENSIVE |
| `### Consumed Services` sub-heading | H3 with service table | Fail if missing |
| `### Exposed Services` sub-heading | H3 with service table | Fail if missing |
| `### Integration NFRs` sub-heading | H3 with integration constraints | Warning if missing |

**Package API Contract format (libraries/packages):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Integration Points — Package API Contract` section | Present as H2 | Fail if missing |
| `### Public API Surface` sub-heading | H3 with API table (API, Type, Purpose, Stability columns) | Fail if missing |
| `### Consumer Integration Pattern` sub-heading | H3 with representative code | Fail if missing |
| `### Consumer Responsibilities` sub-heading | H3 with bullet list | Fail if missing |
| `### Package Dependencies` sub-heading | H3 with dependency table | Warning if missing |

Use the format that matches the PRD's deliverable type. Do not flag a Package API Contract PRD for missing "Consumed Services / Exposed Services" sub-headings, or vice versa.

**1.9 Prioritisation (STANDARD+):**

| Check | Criteria | Severity |
|-------|----------|----------|
| `## Prioritisation (MoSCoW)` section | Present as H2 | Fail if missing for STANDARD+ |
| `### Must Have (MVP)` heading | Exact H3 text | Fail if missing |
| `### Should Have (v1)` heading | Exact H3 text | Fail if missing |
| `### Could Have (Future)` heading | Exact H3 text | Fail if missing |
| `### Won't Have (Yet)` heading | Exact H3 text, each item has `Reason:` | Fail if missing |
| Must Have list bounded | 10 or fewer items | INFO — heuristic only (see note) |
| `## Dependency Graph` section | ASCII diagram using `──>` arrows showing FR-to-FR build order | Fail if missing |

**Note on Must Have ≤10:** This is a heuristic from agile prioritization, not a hard rule. Security-critical packages, authentication modules, and compliance-heavy features may legitimately require more than 10 Must Have items. Do not flag this as a FAIL or WARN — report it as INFO in the summary and let the user decide. In particular, if the Must Have count exceeds 10 because the review itself added a missing FR (e.g., CORS, CSRF), the original prioritization was correct — the fix just expanded scope.

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

**Quality-adaptive fast path (COMPREHENSIVE only):** If Phase 1 structural completeness achieved ≥95% pass rate (e.g., ≤2 findings across all Phase 1 checks), skip the Naming Convention Consistency and Heading Level Compliance checks below — they are highly correlated with structural compliance and will almost certainly pass. Proceed directly to the substantive checks (AC Testability, NFR Measurability, Persona References, etc.). This avoids going through the motions on well-structured PRDs and shifts review effort toward adversarial depth (Phase 4) where the real value lies.

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

**Read ALL Tier 1 UC files.** Do not sample — read every Tier 1 use case referenced in the PRD's Use Cases index. Tier 2/3 UCs may be spot-checked (read at least half). Skipping Tier 1 UCs is a review shortcut that misses cross-reference inconsistencies and stale failure paths.

For each Tier 1 use case:
- Are preconditions specific? (Can you set up this state in a test?)
- Is the success guarantee observable? (Can you verify it happened?)
- Are failure paths enumerated for every step that can fail?
- Is the Minimal Guarantee defined?

Citation: /prd Phase 5 — Tier 1 use case format.

**Use Case Cross-Reference Integrity (COMPREHENSIVE):**

Beyond checking UC file existence and section presence, verify:
- **UC-to-FR traceability:** Every UC referenced in the PRD's Use Cases index maps to at least one FR via the `Related:` field. Flag orphan UCs (not referenced by any FR) as WARN.
- **FR-to-UC back-reference:** Every FR with a `Related: UC-{MODULE}-{NNN}` line points to a UC that exists and covers the FR's scenario. Flag stale references as FAIL.
- **UC content alignment with OQ resolutions:** If the PRD's Open Questions table has resolved questions that affect UC behavior, verify the UC content reflects the resolution. A resolved OQ that changed CSRF behavior should be reflected in the UC's failure paths — not just in the FR's acceptance criteria.
- **UC-to-UC consistency:** If multiple UCs share actors or preconditions, verify they don't contradict each other (e.g., one UC assumes session exists, another assumes it doesn't, for the same actor state).

Citation: /prd Traceability Rules — "COMPREHENSIVE: every FR maps to at least one UC."

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

Citation: /prd v3.9 Structural Conventions — Naming & Numbering Conventions.

**Heading Level Compliance:**

- Are all main sections H2? (## Problem Statement, ## Goals, etc.)
- Are epics H3? (### Epic: {Name})
- Are FRs H4? (#### FR-{MODULE}-{NAME}: {Title})
- Are NFRs H3? (### NFR-{MODULE}-{NAME}: {Title})
- Are personas H3? (### P{n}: {Role Title})

Citation: /prd v3.9 Structural Conventions — Heading Levels.

**Audit Coverage:**

- Does the PRD include an audit NFR (NFR-{MODULE}-AUDIT or equivalent)?
- Does the audit NFR specify: mutation coverage %, actor ID + timestamp + entity ID, and event type naming convention?
- For modules with state-changing operations, is audit logging addressed in Security Criteria on individual FRs?

Citation: /prd v3.9 Phase 7 — Mandatory NFR: Audit coverage.

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

- **Read the actual ADR files the PRD references**, not just the ADR index. If the PRD cites ADR-0001, ADR-0010, and ADR-0020, read those 3 files and verify the PRD's claims match the ADR content. PRDs sometimes self-cite ADRs inaccurately (e.g., claiming an ADR mandates a pattern it only recommends).
- Do FRs contradict any existing ADRs? (e.g., using string constants where ADR-0004 requires enums)
- Do NFRs align with architecture decisions?
- For ADRs referenced in assumptions or constraints, verify the ADR status is still "Accepted" (not "Deprecated" or "Superseded").
- Citation: Specific ADR number and title, with the relevant clause from the ADR body.

**Sibling Module Consistency (COMPREHENSIVE only):**

For COMPREHENSIVE reviews of a module within a multi-module project, spot-check **one sibling module PRD** for convention consistency:

```bash
# Find a sibling PRD
ls ${PROJECT_ROOT}/docs/prd/*/prd.md | head -3
```

Read the first 50-100 lines (metadata, problem, goals, persona references) of one sibling PRD and check:
- Are persona references using the same project-wide numbering?
- Are FR ID conventions consistent? (e.g., `FR-{MODULE}-{NAME}` pattern, same heading level)
- Are NFR categories and targets in the same ballpark? (e.g., if one module has P95 < 200ms and this one has P95 < 2s, is the difference justified?)

This is a quick sanity check (5 minutes), not a full cross-module review. Report as INFO if conventions diverge, with a note about which module to align with.

---

### Phase 4: Adversarial Depth (COMPREHENSIVE only)

**Phase 4 requires a separate read pass.** Do not merge Phases 1-4 into a single mental pass — adversarial depth consistently gets shortchanged when combined with structural checking. After completing Phases 1-3 and recording their findings, re-read the PRD's FRs, UCs, and assumptions with a fresh focus solely on: "Could this PRD lead to a wrong implementation that still technically satisfies the requirements?"

**Minimum spot-check count:** Phase 4 must adversarial-test at least **3 Must Have FRs** and **2 Tier 1 UCs** (or all of them if fewer exist). For each, record an explicit pass/fail with reasoning — not just "ACs look good." If all spot-checks pass, that's a valid result, but the reasoning must demonstrate you actually stress-tested the criteria (boundary values, discrimination, failure paths), not just read them.

Go beyond compliance into adversarial analysis.

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

**Domain-Specific Probes (push harder on mature PRDs):**

The generic checks above (AC discrimination, failure paths, assumptions) are necessary but not sufficient for mature PRDs where obvious gaps have already been caught. Apply these additional probe categories to find the subtle issues:

- **Race conditions & concurrency:** What happens if two actors perform the same operation simultaneously? (Two people closing a case, two admins updating config, concurrent token refresh.) Are there optimistic concurrency controls specified?
- **Arbitrary limits:** Are numeric limits justified or arbitrary? ("100KB payload limit" — why 100KB? What happens at 99KB vs 101KB? Is this configurable?) Every hardcoded limit should trace to a capacity constraint, UX decision, or infrastructure limit.
- **Unbounded growth:** Do any FRs create data that grows without bound? (Version history, audit logs, snapshots, session records.) Is there a retention policy or archival strategy?
- **Seed/default data sufficiency:** If FRs reference seed data, profiles, or default configurations, are they specified precisely enough to implement? ("Default profile" — with what exact values?)
- **Cross-module boundary ambiguity:** When the PRD references functionality from other modules (audit, notification, escalation), is ownership clear? Who is responsible for the integration point — this module or the other?
- **Cascading failure:** If a dependency (Redis, Identity, external API) is down, what happens to each FR's behavior? Are degraded-mode behaviors specified, or does the PRD silently assume 100% availability?

Finding format: "FR-{ID} / A{N} / UC-{ID}: {probe category} — {specific gap}. Example scenario: {concrete example}."

---

### Phase 5: Present Findings

Present findings interactively. Skip passes. Present Fails first, then Warnings.

**Reclassification transparency:** If you downgrade any finding from FAIL to WARN (e.g., because fixing it would break TOC anchors, or the deviation is cosmetic on a mature PRD), state the reason explicitly in the summary table with a `↓` marker: `"F3 ↓ W3: Section heading uses '&' vs 'and' — downgraded because fixing breaks TOC anchors"`. Do not silently reclassify.

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

After all Fails are resolved, present Warnings in batches of up to 4 using Batch Review (Pattern 3).

**Exclusion transparency:** Some WARNs may not be actionable by the user (e.g., PRE_EXISTING issues in other artifacts, WARNs with documented rationale that qualifies as JUSTIFIED_DEVIATION). Before presenting the triage question, list any excluded WARNs with rationale:

> "Excluded from triage: W2 (timeline vagueness — not mechanically fixable, requires business decision), W5 (URL mismatch — PRE_EXISTING in ADR, not this PRD's issue), W6 (goals count — documented rationale exists)."

**Multi-batch for >4 WARNs:** When there are more than 4 actionable WARNs, present multiple batches. Do not silently accept WARNs that overflow the first batch.

Present the warning details as formatted markdown, then for each batch of up to 4:

```
AskUserQuestion:
  question: "Which warnings should be addressed? (Unselected items are accepted as-is) [Batch {M} of {N}]"
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

**Rubber Stamp** — Accepting the PRD without actually reading it. Every section must be checked against the template requirements. If Phase 1 finds zero issues on a **hand-written first-draft** PRD, the review was not thorough enough. However, PRDs generated by the `/prd` skill or that have been through multiple revision cycles (v1.2+, prior adversarial reviews) may legitimately have few Phase 1/2 findings — this is a positive quality signal, not a sign of insufficient review depth. For skill-generated PRDs, Phase 3 (cross-cutting) and Phase 4 (adversarial depth) are the primary value-add.

**Scope Inflation** — Adding requirements the PRD does not need. The reviewer's job is to check what's there against what should be there, not to invent new features or requirements. If a section is intentionally absent (e.g., no Integration Points for a simple feature), that's fine — flag only what the template requires for the PRD's declared scope.

**Template Worship** — Inventing requirements the template doesn't ask for. The reviewer's job is to check what's there against the /prd skill's Structural Conventions — not to add new sections, suggest features, or impose preferences beyond the documented standard. If a section is intentionally absent because the PRD's scope doesn't require it (e.g., no Use Cases for STANDARD scope), that's correct — don't flag it. However, structural conventions (heading formats, numbering prefixes, table columns, heading levels) ARE enforced — these are non-negotiable per /prd v3.9.

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

*Skill Version: 2.11 — [Version History](VERSIONS.md)*
