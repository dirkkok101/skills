# Sub-Plan: docs:audit SKILL.md

> Part of [Documentation Skills Plan](overview.md)

## Objective

Create the `audit/SKILL.md` — the skill that analyzes documentation health for existing codebases. This is the entry point skill that users run first to understand what documentation exists, what's missing, and what's stale.

## Context

Depends on [02-reference-files](02-reference-files.md) for `references/quality-criteria.md`. Can be implemented in parallel with docs:write and docs:adr. Follows established skill patterns from `brainstorm/SKILL.md` and `diagnose/SKILL.md`.

## Tasks

### Task 1: Write Frontmatter

**Objective:** Define YAML frontmatter that triggers correctly from user intent.

**Approach:**
Use the frontmatter draft from the design document. The `description` field is the primary trigger — it must include all "when to use" conditions since the body only loads after triggering.

**Pseudocode:**
```
frontmatter:
  name: docs-audit
  description: (from design Frontmatter Drafts section)
    - Include: audit, review, check, gap analysis, AI-friendliness
    - Include trigger phrases: "review my docs", "check doc health"
  argument-hint: "[project-path] or run in current project"
```

**Pattern Reference:**
- Frontmatter pattern: `skills/brainstorm/SKILL.md`, `skills/diagnose/SKILL.md`
- Design: Frontmatter Drafts section

**Success Criteria:**
- Triggers on audit-related phrases ("review my docs", "check doc health")
- Does NOT trigger on write or ADR requests
- argument-hint shows usage example

**Failure Criteria:**
- ❌ Description too vague to trigger reliably
- ❌ Description overlaps with docs:write triggers

**Verification:**
- Test: Mentally walk through trigger phrases — would Claude select this skill for "review my docs"? For "write a tutorial"? (should NOT trigger)
- Manual: Compare description against docs:write and docs:adr descriptions to confirm no overlap

---

### Task 2: Write Core Workflow (Phases 0-6)

**Objective:** Define the phased audit workflow from project detection to report generation.

**Approach:**
Six-phase progressive workflow: prerequisites → structure detection → doc inventory → Diataxis gap analysis → AI-friendliness check → staleness scan → report generation. Each phase has a checklist and verification step.

**Pseudocode:**
```
Phase 0: Resolve PROJECT_ROOT, check for docs/ and AI files
Phase 1: Auto-detect project structure (scan for subsystems)
Phase 2: Inventory all .md files, categorize by Diataxis type
Phase 3: Apply Diataxis gap analysis (4 categories)
Phase 4: Check AI-optimization (CLAUDE.md, AGENTS.md, llms.txt)
  LOAD references/quality-criteria.md for evaluation standards
Phase 5: Scan for staleness (doc age vs code changes via git)
Phase 6: Generate structured audit report using output template
```

**Pattern Reference:**
- Phase structure: `skills/brainstorm/SKILL.md` (12 phases)
- Prerequisites pattern: `skills/diagnose/SKILL.md` (Phase 0)
- Output template: Design's Audit Report Output Template section

**Success Criteria:**
- Each phase has clear entry/exit criteria
- Phase 4 explicitly loads quality-criteria.md reference
- Phase 6 uses the structured report template from the design

**Failure Criteria:**
- ❌ Skipping Phase 0 prerequisites
- ❌ Loading quality-criteria.md eagerly (should be on-demand in Phase 4)

**Verification:**
- Test: Walk through phases with a sample brownfield project — does each phase produce useful output?
- Manual: Confirm quality-criteria.md is referenced only in Phase 4, not loaded at skill start

---

### Task 3: Write Quality Standards, Anti-Patterns, Exit Signals

**Objective:** Add the standard skill sections that ensure consistent behavior.

**Approach:**
Follow the established pattern: Quality Standards checklist, Anti-Patterns with ❌/✅ examples, Exit Signals table. Draw from the design's Quality Standards and Anti-Patterns sections.

**Pseudocode:**
```
Quality Standards:
  - Project structure detected correctly
  - Diataxis gaps identified with specific recommendations
  - AI-files checked with quality-criteria.md
  - Staleness assessed via git history
  - Report includes prioritized action items

Anti-Patterns:
  ❌ Creating docs without audit → ✅ Audit first
  ❌ Ignoring existing structure → ✅ Follow conventions
  ❌ Skipping AI-friendliness → ✅ Include AI optimization

Exit Signals:
  "audit complete" → Report generated
  "refine" → Continue iterating
  "abort" → Cancel
  Negative: "write docs" → redirect to docs:write
  Negative: "record decision" → redirect to docs:adr
```

**Pattern Reference:**
- Anti-Patterns format: `skills/brainstorm/SKILL.md`
- Exit Signals: Design's Exit Signals section
- Negative triggers: `skills/diagnose/SKILL.md`

**Success Criteria:**
- Anti-patterns include: creating docs without audit, ignoring existing structure
- Exit signals include: "audit complete", "refine", "abort"
- Negative triggers redirect to docs:write and docs:adr

**Failure Criteria:**
- ❌ Missing negative trigger redirects (user stuck in wrong skill)
- ❌ Anti-patterns too generic (not specific to audit workflow)

**Verification:**
- Manual: Compare anti-patterns against design's Anti-Patterns section for coverage
- Manual: Confirm exit signals match design's Exit Signals table

## Component Success Criteria

- SKILL.md is under 400 lines (target ~250-350)
- Frontmatter triggers correctly from audit-related phrases
- References load on demand (quality-criteria.md in Phase 4 only)
- Produces structured audit report matching the design template
- Follows established skill patterns (Phases, Anti-Patterns, Exit Signals)

## References

- Docs: [docs:audit Workflow](../../designs/documentation-skills/design.md#docsaudit-workflow), [Audit Report Output Template](../../designs/documentation-skills/design.md#audit-report-output-template)
- Patterns: `skills/brainstorm/SKILL.md` (phases, anti-patterns, exit signals), `skills/diagnose/SKILL.md` (negative triggers, prerequisites)
