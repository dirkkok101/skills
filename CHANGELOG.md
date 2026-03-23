# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.0.0] - 2026-03-20

### Added
- **review-prd** (v1.0): Adversarial PRD review against /prd skill template and cross-cutting requirements. 6-phase review: structural completeness, content quality, cross-cutting compliance, adversarial depth, interactive findings, summary. BRIEF/STANDARD/COMPREHENSIVE modes. READ-ONLY audit with AskUserQuestion stage gates.
- **review-design** (v1.0): Adversarial technical design review against PRD, ADRs, patterns, and architecture docs. 7-phase review: structural completeness, PRD→design alignment, ADR & pattern compliance, cross-module consistency, to-be coherence, interactive findings, summary. Checks every FR maps to an endpoint, every UC to a flow, every NFR to an operational concern.
- **review-plan** (v1.0): Adversarial plan review against 6 authority sources (skill spec, design, gap analysis, PRD, ADRs/patterns, internal consistency). Early termination on 5+ Critical design findings. Execution priority: design fidelity and PRD traceability first. Verdict matrix: PASS/PASS WITH CONDITIONS/FAIL.
- **review-beads** (v1.0): Adversarial bead compliance review across 11 categories (FR coverage, UC coverage, design compliance, architecture, API patterns, web patterns, test coverage, stage gates, bead quality, backwards compat, granularity). Finding quality standards with anti-false-positive philosophy. Severity calibration with concrete examples. Batch execution support for multi-module reviews (max 5 concurrent workers, convergence criteria).

### Changed
- **execute** (v4.1): Systemic blocker circuit breaker — Phase 1 baseline check now distinguishes isolated failures (1-10 tests, proceed) from systemic failures (>10 tests across multiple modules, STOP with AskUserQuestion). Prevents wasting entire sessions on work blocked by codebase-level issues like broken migrations or missing dependencies.
- **review** (v3.6): ADR consistency check added to design-intent agent — when changed files include new or modified ADRs, agent reads all existing ADRs and flags contradictions as criticality 8-10. Prevents silent ADR conflicts from slipping through review.

## [3.6.0] - 2026-03-12

### Changed
- **init**: Minimal scaffold — creates only 6 foundational directories (prd, designs, architecture, patterns, adr, learnings) instead of 15. Remaining directories are created on demand by each skill when it runs
- **AskUserQuestion enforcement** across all 11 skills — stage gate section rewritten from passive reference to imperative instruction ("call the tool"), fallback demoted to blockquote with "check your tool list" guard, stage-gates.md clarifies YAML blocks are tool call specs not pseudocode
- **On-demand directory creation** added to research, brainstorm, review, diagnose, and technical-design (browser-e2e-plans) — each skill now creates its output directory if it doesn't exist

## [3.5.1] - 2026-03-12

### Changed
- **init**: Removed `docs/features/` from scaffold — consolidated feature specs now live inside `docs/designs/{feature}/features/` as part of the design that produces them
- **technical-design**: Feature spec output path changed from `docs/features/` to `docs/designs/{feature}/features/` — keeps feature specs co-located with the design that creates them

## [3.5.0] - 2026-03-11

### Changed
- **All 12 workflow skills** upgraded to v3.5 — comprehensive cross-skill alignment review
- **Prerequisites modernized** across brainstorm, research, and discovery — bash scripts (`cat`, `ls`, `mkdir -p`) replaced with prose-based artifact import matching the pattern established by technical-design and plan
- **docs/adr/ and docs/patterns/** added as upstream artifact sources to brainstorm, research, and discovery prerequisites (tagged [CONSTRAINT] and [PRIOR-ART] respectively)
- **Collaborative models** updated across multiple skills — brainstorm adds Phase 6 (Output), discovery adds Phase 5 (Output), execute gains a collaborative model (was missing entirely)
- **prd** restructured: Phase 2 now handles FR authoring with per-requirement Guided Review (Pattern 5), Phase 3 handles cross-cutting concerns and synthesis, self-review added before PAUSE 3
- **technical-design** restructured: feature-first decomposition (per-feature design docs), browser E2E test plans (`docs/browser-e2e-plans/`), project-wide ADRs (`docs/adr/`), patterns consumption (`docs/patterns/`), feature specs moved to `docs/designs/{feature}/features/`
- **plan** expanded: prerequisites import use cases, browser E2E plans, ADRs, and patterns; BRIEF skip list made explicit; ascii-conventions path corrected to `../_shared/`
- **beads** improved: prerequisites add design docs; Parallel Tracks cross-ref fixed; Good Bead example references design doc
- **execute** enhanced: review-bead handling for /simplify checkpoints; COMPREHENSIVE check-in with AskUserQuestion; PRD and UC paths added to upstream verification
- **review** refined: design-intent agent scopes feature subdirs; plan-intent agent receives patterns path; consolidation agent uses `${PROJECT_ROOT}`; browser E2E plans noted in upstream check; cherry-pick option added to findings gate
- **compound** aligned: bulk mode selects latest timestamp; collaborative model shows "More" loop; Step 3.2 uses Decision Gate; `docs/decisions/` → `docs/adr/`
- **diagnose** improved: non-reproducible PAUSE labeled (PAUSE NR); Phase 4 clarified as "(with self-review)"; dead ends return to PAUSE; brainstorm escalation passes diagnostic context
- **discovery** modernized: prerequisites prose-based with ADRs/patterns; collaborative model adds Output phase; exit signals table expanded
- **init** updated: removed `docs/decisions/` (superseded by `docs/adr/`); updated `docs/adr/` attribution; `docs/patterns/` description expanded; Phase 3 tree diagram corrected
- **Exit signals** tables expanded with "When to Recommend" column (discovery)
- **BRIEF scope routing** clarified in brainstorm (explicit skip list)

## [3.4.1] - 2026-03-10

### Changed
- **prd: PAUSE 2** switched from Batch Review (Pattern 3) to per-requirement Guided Review (Pattern 5) — each FR is reviewed individually with Approve/Revise/Remove/Skip options instead of batched multi-select, eliminating scroll-back during requirement review
- **stage-gates.md** updated guidance table to recommend Guided Review for items needing individual attention (FRs, design decisions) and Batch Review for quick triage of lightweight items (tasks, beads, constraints)

## [3.4.0] - 2026-03-10

### Added
- **stage-gates.md** — shared reference (`skills/_shared/references/stage-gates.md`) defining 5 AskUserQuestion interaction patterns used across all workflow skills

### Changed
- **All workflow skills** upgraded to v3.4 with structured AskUserQuestion stage gates
- **PAUSE points** replaced freeform prose with structured AskUserQuestion interactions using 5 patterns:
  - **Decision Gate** — single-select approval/routing (Accept/Redirect/Clarify)
  - **Comparison Gate** — single-select with preview panels for side-by-side approach comparison
  - **Batch Review** — full markdown detail + multi-select to flag items needing revision
  - **Combined Gate** — multiple independent questions in one call (e.g., completeness + routing)
  - **Guided Review Workflow** — section-by-section walkthrough so users review everything without scroll fatigue
- **Inline fallback** added to all skills for environments where AskUserQuestion is unavailable (Claude.ai, older Claude Code versions)
- **beads PAUSE 1** added "Adjust mapping" option for minor changes without escalating to /plan
- **execute** learnings batch overflow instruction for >4 items; "Compound" label renamed to "Document" for clarity
- **review** Should Consider findings now presented as full markdown before cherry-pick multi-select

## [3.3.0] - 2026-03-09

### Added
- **init skill** — project scaffold that creates full `docs/` hierarchy (15 directories) and appends workflow guidance to CLAUDE.md. Idempotent, detects `.claude/CLAUDE.md` location, warns on missing tech stack.
- **beads: /simplify review beads** — real work packages inserted at logical boundaries (phase transitions, feature slices) that run `/simplify` to catch quality issues during implementation
- **plan: companion documents** (COMPREHENSIVE) — `e2e-test-plan.md`, `security-hardening-checklist.md`, `test-scenario-matrix.md`
- **review: alignment audit agent** (COMPREHENSIVE) — permanent `docs/reference/alignment-audit.md` with PRD ↔ Design ↔ Plan ↔ Patterns cross-verification
- **prd: integration points section** — documents consumed/exposed services for platform features
- **prd: document approval section** (COMPREHENSIVE) — formal sign-off tracking
- **technical-design: consolidated feature specs** — `docs/features/` for COMPREHENSIVE mode with 10+ UCs

### Changed
- **prd: open questions** upgraded from checklist to resolution tracking table (Status/Decision/Owner)
- **prd: TOC** added for COMPREHENSIVE PRDs with 10+ sections
- **technical-design: sibling design cross-refs** for multi-design projects
- **technical-design: optional backend.md** per feature when 5+ commands/queries
- **discovery: standalone glossary** extracted as separate file enabling downstream inheritance with disambiguation tables
- **prd + technical-design: legacy update notices** convention for long-lived documents
- **README** fully rewritten — deduplicated sections, added init skill, skill versions table, key concepts, stack-agnostic philosophy
- **All skills** bumped to v3.3

### Improvements derived from
- nxgn.identity production docs (36 design files, 134KB PRD, 10 standalone use cases)
- nxgn.actions production docs (151 files, 5 numbered designs, 17 sub-plans, 11 pattern docs)

## [3.1.0] - 2026-03-08

### Changed
- **All workflow skills** upgraded to v3.1 via first-principles adversarial review
- **Duration targets** added to every skill per mode (BRIEF/STANDARD/COMPREHENSIVE)
- **Kill criteria monitoring** at every pipeline stage (brainstorm through review)
- **Structured PAUSE response options** (Accept/Modify/Escalate) at all decision points
- **Self-review before presentation** — agents review their own work before showing to user
- **Tool-agnostic issue tracker** — skills use conditional language, not hardcoded `br` commands
- **Prose-based artifact import** — no hardcoded shell commands for loading upstream docs
- **Anti-patterns explain WHY** — not just what to avoid, but why it matters
- **Duplicate Quality Standards sections** merged into phase descriptions

### Added
- **Prerequisites doc** (`skills/_shared/prerequisites.md`) documenting required global tooling
- **README prerequisites section** linking to the prerequisites doc
- **RELEASING.md** with complete release process documentation
- **Git Commits convention** in CLAUDE.md template (Conventional Commits v1.0.0)
- **Project Learnings section** in CLAUDE.md template for `docs/learnings/` awareness
- **Session lifecycle learnings check** in AGENTS.md template

### Skill-specific changes
- **technical-design**: Data model merged into Phase 3 (joint architecture validation), diagram selection moved after Phase 2 decisions, security before operations
- **plan**: Self-review moved before user presentation, overview reconciliation after sub-plans, plan/beads boundary check
- **beads**: Scope growth check (kill criteria), merged PAUSE 2+3, integrated self-review into assessment gate
- **execute**: Execution health circuit breaker, review fix cycle as explicit re-entry section, per-bead completion summaries
- **review**: BRIEF skips consolidation agent, agent failure/timeout recovery, kill criteria in all upstream agent prompts
- **compound**: Surfacing promoted to dedicated phase with end-to-end chain verification, format validation before saving
- **diagnose**: Three-path fork in collaborative model, proportionality theme in self-review, all resolution paths offer /compound

## [2.0.0] - 2026-03-08

### Added
- **workflow:discovery**: New skill for domain-aware requirements elicitation between brainstorm and PRD. Walks domain checklists, maps actors/workflows, captures UI flows, analyses integrations and security. Triggered for COMPREHENSIVE scope features.
- **Scope classifier** in brainstorm: Weighted signal scoring (auth/security ×2, others ×1) routes features to BRIEF/STANDARD/COMPREHENSIVE pipeline depths
- **Domain references**: Shared reference files for identity-auth, general-saas, capstone-data, guardian-mobile loaded by discovery and technical-design
- **ASCII conventions**: Shared notation reference for all diagram types (C4, sequence, ER, DFD, workflow, UI mockups)
- **FR traceability** in beads: Each bead tags the FRs it implements and BDD scenarios that verify it, with FR coverage table in output
- **Upstream verification** in execute: New Step 2.8 verifies implementation against PRD acceptance criteria, API spec, and data model after each bead
- **PRD-compliance agent** in review: 9th conditional agent checks Must-Have FR coverage, acceptance criteria satisfaction, security/compliance criteria enforcement, and scope compliance
- **BRIEF mode** in plan: Decomposes directly from brainstorm output without requiring a design document
- **Stable ID convention** in PRD: Descriptive IDs (FR-APP-REGISTER) instead of sequential (FR-APP-001) to prevent cascade updates
- **Tiered PRD modes**: BRIEF (~50-100 lines), STANDARD (~200-300 lines), COMPREHENSIVE (~400-500 lines with Cockburn use cases)
- **C4-based architecture** in technical-design: Progressive zoom with diagram selection logic
- **Domain classification** in research: Output includes domain classification for downstream skills
- **Batch mode** in discovery: Present domain checklists as batches with shortcuts instead of one-at-a-time
- **Self-review limitation acknowledgement** in discovery and PRD: Explicit note that self-review by the same agent has blind spot limitations
- **Version numbers** on all skills
- **Updated CLAUDE.md template** with scope-based entry points, discovery phase, domain references section

### Changed
- **workflow:brainstorm**: Simplified from 495→392 lines. Scope classifier replaces fixed routing. BRIEF path now goes directly to plan (skipping PRD and design)
- **workflow:prd**: Enhanced from original to v2 with tiered modes, security/compliance criteria on FRs, domain validation phase
- **workflow:technical-design**: Enhanced with C4-based architecture, ASCII-native diagrams, diagram selection logic, alternatives emphasis
- **workflow:plan**: Enhanced with BRIEF mode, FR traceability per sub-plan, BDD scenario references
- **workflow:beads**: Restored full operational guidance (sizing heuristics, lifecycle, self-assessment) from v1 while adding v2 traceability features
- **workflow:execute**: Restored full operational guidance (parallel beads, auto-recovery, blocker handling, context compaction recovery) from v1 while adding v2 upstream verification
- **workflow:review**: Restored full three-layer context isolation detail from v1 while adding v2 PRD-compliance agent. Expanded from up to 8 to up to 9 agents
- **workflow:research**: Restored full operational guidance from v1 while adding v2 domain classification
- **workflow:compound**: Fixed review file reference (was /tmp, now docs/reviews/), added structured categories by phase/domain

### Fixed
- BRIEF scope path no longer requires a design document (was a contradiction — brainstorm routed to plan but plan required design)
- Compound no longer references /tmp/review-consolidation.md (transient file); now reads from docs/reviews/

## [1.9.0] - 2026-01-29

### Changed
- **workflow:review**: Changed review summary output location from `.beads/review-summary.md` to `docs/reviews/review-{timestamp}.md` for better discoverability and to avoid permission issues with the `.beads/` folder

## [1.8.0] - 2026-01-28

### Changed
- **workflow:review**: Added three-layer context isolation (review agents → consolidation agent → executive summary) to prevent context bloat and finding loss
- **workflow:review**: Added conditional design-intent and plan-intent agents that verify implementation against upstream design and plan documents
- **workflow:review**: Consolidation agent now writes structured summary to `.beads/review-summary.md` with executive summary first for selective reading
- **workflow:review**: Expanded from 6 to up to 8 agents (6 core + 2 conditional)
- **workflow:review**: Added project root resolution step for reliable document path handling

## [1.7.0] - 2026-01-28

### Changed
- **workflow:review**: Redesigned agent orchestration to use background execution with consolidation agent, preventing context bloat and lost findings
- **workflow:review**: Added Core Principles, Anti-Patterns sections per skill-creator guidelines
- **workflow:review**: Moved trigger conditions into frontmatter description for proper skill triggering
- **workflow:review**: Generalized build/test commands to be project-agnostic (removed hardcoded dotnet references)

## [1.6.0] - 2026-01-27

### Added
- **docs:audit**: Phased documentation audit skill for identifying gaps, staleness, and coverage issues across Diataxis, AI-optimization, architecture, and project docs
- **docs:write**: Template-routed documentation generation skill with idempotent updates for all supported doc types (CLAUDE.md, AGENTS.md, llms.txt, README, CONTRIBUTING, ADRs, C4/arc42, and Diataxis guides)
- **docs:adr**: Architectural Decision Record skill using MADR format with full status lifecycle (proposed, accepted, deprecated, superseded)
- Unified version tracking across all plugins (workflow + docs)

## [1.5.0] - 2026-01-26

### Added
- **diagnose**: New skill for systematic root cause analysis of bugs and unexpected behavior
  - Evidence-driven investigation with reproduction verification
  - Adaptive triage: fix-in-place for simple bugs, beads for medium issues, brainstorm handoff for complex issues
  - Direct fix capability for isolated <20 line changes
  - Diagnostic 5 Whys for root cause analysis
  - Integration with `/compound` for learning capture after fixes

## [1.4.0] - 2026-01-26

### Changed
- Moved `marketplace.json` to `.claude-plugin/` folder per Claude Code best practices

## [1.3.0] - 2026-01-25

### Fixed
- Moved `marketplace.json` out of `.claude-plugin/` folder (reverted in 1.4.0)

## [1.2.0] - 2026-01-25

### Fixed
- Use `skills/` folder and correct namespaced invocations

## [1.1.0] - 2026-01-25

### Changed
- Version bump for plugin updates

### Fixed
- Inline SKILL.md content into command files
- Update command names from `/workflow:*` to `/*` format

## [1.0.0] - 2026-01-24

### Added
- Initial release of workflow skills plugin
- **brainstorm**: Transform rough ideas into validated designs
- **plan**: Convert validated designs into hierarchical implementation plans
- **beads**: Convert approved plans into intent-based work packages
- **execute**: Execute approved beads using sub-agent model
- **review**: Multi-perspective code review using parallel agents
- **compound**: Capture learnings from feature development
- Plugin manifest for proper skill discovery
- Project setup templates (CLAUDE.md, AGENTS.md)
