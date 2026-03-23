# Feature Workflow Skills

A complete feature development workflow for Claude Code with structured SDLC phases, scope-based routing, and requirement traceability.

## Skills

| Command | Purpose | Output |
|---------|---------|--------|
| `/workflow:init` | Initialize project docs structure and CLAUDE.md | `docs/` hierarchy + CLAUDE.md workflow section |
| `/workflow:research` | Deep research before designing | `docs/research/{feature}/research-brief.md` |
| `/workflow:brainstorm` | Problem framing, approaches, scope classification | `docs/brainstorm/{feature}/brainstorm.md` |
| `/workflow:discovery` | Domain-aware requirements elicitation | `docs/discovery/{feature}/discovery-brief.md` |
| `/workflow:prd` | Tiered product requirements document | `docs/prd/{feature}/prd.md` |
| `/workflow:technical-design` | Architecture, API specs, data models | `docs/designs/{feature}/` |
| `/workflow:plan` | Implementation plans with companion docs | `docs/plans/{feature}/overview.md` |
| `/workflow:beads` | Intent-based work packages with FR traceability | Beads in `br` database |
| `/workflow:execute` | Sub-agent implementation with upstream verification | Working code |
| `/workflow:review` | Parallel agent review with alignment audits | `docs/reviews/review-{timestamp}.md` |
| `/workflow:review-prd` | Adversarial PRD review against skill template | Findings via AskUserQuestion (READ-ONLY) |
| `/workflow:review-design` | Adversarial design review against PRD/ADRs/patterns | Findings via AskUserQuestion (READ-ONLY) |
| `/workflow:review-plan` | Adversarial plan review against 6 authority sources | `docs/reviews/plan-review-{module}.md` |
| `/workflow:review-beads` | Adversarial bead compliance review (11 categories) | `docs/reviews/bead-review-{module}.md` |
| `/workflow:review-execute` | Post-execution bead satisfaction verification | `docs/reviews/review-execute-{feature}-{date}.md` |
| `/workflow:compound` | Structured learning capture by phase/domain | `docs/learnings/{category}.md` |
| `/workflow:diagnose` | Bug investigation with root cause analysis | Fix, beads, or design handoff |
| `/workflow:qa` | Browser-based QA with diff-aware scoping | `docs/reviews/qa-{timestamp}.md` |
| `/workflow:benchmark` | Performance benchmarking with regression detection | `docs/benchmarks/benchmark-{timestamp}.md` |
| `/workflow:security-audit` | OWASP + STRIDE zero-noise security audit (READ-ONLY) | `docs/reviews/security-audit-{timestamp}.md` |
| `/workflow:ship` | Release pipeline: readiness check → changelog → PR | Pull request with traceability |

> **Note:** All commands use the `workflow:` namespace prefix because this is a marketplace plugin.

## Pipeline

```
research ─> brainstorm ─> discovery ─> prd ────────> technical-design ──> plan ─────> beads ────> execute
(optional)                 (COMP only)    └─review-prd─┘       └─review-design─┘  └─review-plan─┘ └─review-beads─┘

  execute ─> qa ─> benchmark ─> review ─> review-execute ─> security-audit ─> ship ─> compound
             (opt)   (opt)                                      (opt)
```

The `review-*` skills are optional quality gates between pipeline stages. `qa`, `benchmark`, and `security-audit` are optional but recommended for STANDARD+ features.

### Scope-Based Routing

Brainstorm classifies features using weighted complexity signals (auth/security x2, others x1):

| Scope | Weighted Score | Pipeline Path |
|-------|---------------|---------------|
| **BRIEF** | 0-2 points | brainstorm → plan → beads → execute → review → compound |
| **STANDARD** | 3-4 points | brainstorm → prd → technical-design → plan → beads → execute → review → compound |
| **COMPREHENSIVE** | 5+ points | brainstorm → discovery → prd → technical-design → plan → beads → execute → review → compound |

### Other Entry Points

| Scenario | Path |
|----------|------|
| **Full SDLC** | research → brainstorm → (scope-dependent path above) → ship |
| **Known requirements** | prd → technical-design → plan → beads → execute → review → ship |
| **Technical improvement** | brainstorm → technical-design → plan → beads → execute → review → ship |
| **Bug fix** | diagnose → fix / beads / brainstorm |
| **Pre-release check** | qa → benchmark → review → security-audit → ship |

### Approval Gates

Each phase pauses at structured stage gates using the `AskUserQuestion` tool, presenting clear options instead of freeform text. Five interaction patterns are used across all skills:

| Pattern | Use Case |
|---------|----------|
| **Decision Gate** | Approval/routing choices (Accept, Redirect, Clarify) |
| **Comparison Gate** | Side-by-side approach comparison with preview panels |
| **Batch Review** | Full detail as markdown, then multi-select to flag items |
| **Guided Review** | Section-by-section walkthrough — nothing gets missed |
| **Combined Gate** | Multiple independent questions in one call |

| Phase | Exit Signal | Next Step |
|-------|-------------|----------|
| research | "research complete" | brainstorm or prd |
| brainstorm | "start discovery" / "start prd" / "start plan" | discovery, prd, technical-design, or plan |
| discovery | "start prd" | prd |
| prd | "prd approved" | technical-design |
| technical-design | "design approved" | plan |
| plan | "plan approved" | beads |
| beads | "beads approved" | execute |
| execute | "done" | qa, benchmark, or review |
| qa | "QA complete" | benchmark or review |
| benchmark | "benchmark complete" | review |
| review | "changes approved" | security-audit or ship |
| security-audit | "audit complete" | ship |
| ship | "PR created" | compound |

> **Fallback:** If `AskUserQuestion` is unavailable (Claude.ai, older Claude Code versions), skills fall back to presenting options as markdown text and waiting for freeform response.

### Traceability Chain

```
PRD FR-{feature}-{NAME}
  → UC-{feature}-{NAME} (use case)
    → @UC-{feature}-{NAME} (BDD tag)
      → BEAD-{id} (implements FR, tags UC)
        → execute upstream verification
          → review PRD-compliance agent
```

## Getting Started

### 1. Install br (beads-rust) CLI

```bash
cargo install beads-rust
br version
```

### 2. Install the Plugin

```bash
# Add marketplace
/plugin marketplace add dirkkok101/skills

# Install plugin
/plugin install workflow@dirkkok-skills
```

### 3. Initialize Your Project

```bash
/workflow:init my-project
```

This creates the full `docs/` folder structure and adds workflow guidance to your project's CLAUDE.md. See [init skill](skills/init/SKILL.md) for details.

### Project Structure After Init

```
your-project/
├── CLAUDE.md              # Workflow section appended by /init
├── .beads/
│   └── beads.db           # Created by br init
└── docs/
    ├── research/          # /research output
    ├── brainstorm/        # /brainstorm output
    ├── discovery/         # /discovery output (COMPREHENSIVE)
    ├── prd/               # /prd output
    ├── use-cases/         # /prd standalone use cases
    ├── designs/           # /technical-design output
    ├── plans/             # /plan output
    ├── learnings/         # /compound output
    ├── reviews/           # /review, /qa, /security-audit reports
    ├── reference/         # /review alignment audits
    ├── execution/         # /execute manifests (per-bead completion logs)
    ├── benchmarks/        # /benchmark baselines and reports
    ├── qa/                # /qa baselines
    ├── features/          # /technical-design feature specs
    ├── adr/               # Project-wide architecture decisions
    ├── decisions/         # Feature-scoped decisions
    ├── architecture/      # Existing architecture context
    └── diagnosis/         # /diagnose output
```

## Usage Examples

### Full SDLC (COMPREHENSIVE Feature)

```
/workflow:research user authentication options
→ "research complete"

/workflow:brainstorm I want to add user authentication
→ Scope: COMPREHENSIVE (auth x2 + multiple roles x1 + regulatory x2 = 5)
→ "start discovery"

/workflow:discovery user authentication
→ "start prd"

/workflow:prd user authentication
→ "prd approved"

/workflow:technical-design user authentication
→ "design approved"

/workflow:plan user authentication
→ "plan approved"

/workflow:beads user authentication
→ "beads approved"

/workflow:execute
→ /workflow:qa                    # browser-based testing
→ /workflow:benchmark             # performance regression check
→ /workflow:review
→ /workflow:security-audit        # OWASP + STRIDE audit
→ /workflow:ship                  # PR with traceability
→ /workflow:compound
```

### Quick Change (BRIEF Feature)

```
/workflow:brainstorm add sorting to the user list
→ Scope: BRIEF (1 signal: UI-heavy = 1 point)
→ "start plan"

/workflow:plan user list sorting
→ "plan approved"

/workflow:beads user list sorting
→ /workflow:execute
→ /workflow:review
→ /workflow:ship
```

### Bug Investigation

```
/workflow:diagnose users can't log in after password reset
→ Fix-in-Place (simple bugs)
→ /workflow:beads (medium issues)
→ /workflow:brainstorm (complex/systemic issues)
```

### Pre-Release Quality Check

```
/workflow:qa my-feature              # browser-based QA testing
/workflow:benchmark my-feature       # performance regression detection
/workflow:security-audit my-feature  # OWASP + STRIDE audit
/workflow:ship my-feature            # PR with changelog and traceability
```

## Key Concepts

### Stable FR IDs

Requirements use descriptive IDs (`FR-APP-REGISTER` not `FR-APP-001`) that survive when requirements are added or removed. These IDs chain through design → plan → beads → tests → code, so stability prevents cascade updates.

### Glossary Inheritance

Discovery seeds the glossary as a standalone file → PRD imports and extends it → Technical design inherits and adds implementation terms. This prevents terminology drift across artifacts.

### Document History

PRDs and designs include Document History tables that track what changed and why after each revision. Legacy Update notices mark sections that were revised due to architecture changes, preserving the decision trail.

### Three-Layer Review

Review uses context isolation: review agents produce raw findings → a consolidation agent deduplicates into a structured report → the main agent presents an executive summary. This prevents context window overflow while preserving detail.

### Companion Docs (COMPREHENSIVE)

Plans in COMPREHENSIVE mode produce companion documents alongside the implementation plan:
- `e2e-test-plan.md` — acceptance-level E2E scenarios
- `security-hardening-checklist.md` — operationalized security findings with priority tiers
- `test-scenario-matrix.md` — UC → test class living mapping

### Alignment Audit (COMPREHENSIVE)

Review in COMPREHENSIVE mode with 2+ upstream docs produces a permanent `docs/reference/alignment-audit.md` with systematic PRD ↔ Design ↔ Plan ↔ Patterns cross-verification.

### Self-Regulation Heuristics

Execute and QA track cumulative risk scores during operation. Events like auto-recovery, reverts, and app crashes increment the score. When thresholds are crossed, the skill pauses (moderate risk) or stops (high risk) to prevent doing more harm than good.

### MECHANICAL/JUDGMENT Classification

Review classifies each finding as MECHANICAL (auto-fixable: dead code, missing import, wrong verb) or JUDGMENT (needs human decision: security, design, architecture). Mechanical fixes are applied automatically within the user's approved scope; judgment calls are batched for user decision.

### Zero-Noise Security

Security-audit uses a confidence ≥ 8/10 gate with 10 explicit false positive exclusions. Every finding requires a concrete exploit scenario ("an attacker could..."), not generic warnings. Framework-aware scanning recognises built-in protections and doesn't flag them as missing.

### Release Traceability

Ship creates PRs that trace back through the pipeline: which FRs were implemented, which beads completed them, which UCs were verified, and which review findings were resolved. This gives human reviewers full context without reading the code.

## Domain References

Skills load domain-specific checklists and patterns from shared references:

| Domain | Reference File | Used By |
|--------|---------------|---------|
| Stage Gates | `_shared/references/stage-gates.md` | all workflow skills |
| Identity/Auth | `_shared/references/identity-auth.md` | discovery, technical-design |
| Data Platform (Capstone) | `_shared/references/capstone-data.md` | discovery, technical-design |
| Mobile/EHS (Guardian) | `_shared/references/guardian-mobile.md` | discovery, technical-design |
| General SaaS | `_shared/references/general-saas.md` | discovery, technical-design |

Domain references are updated by `/workflow:compound` when domain-specific learnings are captured.

## Prerequisites

This skill library assumes your Claude Code environment has global tooling configured via `~/.claude/CLAUDE.md` and `~/AGENTS.md`. These provide the tool instructions that skills reference conditionally (issue tracking, session search, knowledge base).

**Required:** `br` (beads-rust), `rtk` (token optimization)
**Recommended:** `bv` (beads-viewer), `cass` (session search), `qmd` (knowledge base)
**Optional:** `agent-browser` (browser automation for UI work)

See [`skills/_shared/prerequisites.md`](skills/_shared/prerequisites.md) for full details on each tool and how skills reference them.

## Multi-Model Support

### Claude Code (Primary)

Use the plugin as documented above.

### OpenAI / Codex

1. Load `templates/OPENAI_AGENT.md` as your system/agent instruction file
2. Register OpenAI function tools from `openai/tools.json`
3. Optionally use `openai/bootstrap.ts` as a reference dispatcher

```bash
node openai/validate-tools.mjs
```

### Gemini CLI

1. Install: `gemini extensions install https://github.com/dirkkok101/skills`
2. Copy templates: `templates/GEMINI.md` → `your-project/GEMINI.md`
3. Gemini CLI automatically discovers and activates skills

## Skill Versions

| Skill | Version | Highlights |
|-------|---------|-----------|
| init | v3.3 | Project scaffold, CLAUDE.md workflow section, idempotent |
| research | v3.4 | Structured research briefs, source attribution |
| brainstorm | v3.6 | Weighted scope classifier, completeness scoring, "Boil the Lake" framing |
| discovery | v3.5 | Domain-aware requirements, guided review for actors/workflows |
| prd | v3.4.1 | Tiered output (Brief/Standard/Comprehensive), stable FR IDs |
| technical-design | v3.5 | Feature-first decomposition, sibling cross-refs |
| plan | v3.5 | Task decomposition with dependency ordering, companion docs |
| beads | v5.8 | Pattern-granular decomposition, context budgets, test gates |
| execute | v4.6 | Cumulative health score, Iron Law verification, AI slop detection |
| review | v3.7 | MECHANICAL/JUDGMENT classification, diff-size scaling, agent output cap |
| review-prd | v2.3 | Adversarial PRD review, 6-phase structural + content check |
| review-design | v2.5 | PRD alignment, ADR compliance, cross-module consistency |
| review-plan | v2.5 | 6 authority sources, early termination on critical findings |
| review-beads | v2.7 | 11 review categories, batch execution, convergence criteria |
| review-execute | v1.3 | Bead satisfaction verification, CONVERGE auto-fix mode |
| compound | v3.5 | Structured learning capture by phase and domain |
| diagnose | v3.6 | Investigation time budgets, environment checklist, test scope guidance |
| qa | v1.0 | Diff-aware browser QA, 8-category health scoring, self-regulation |
| benchmark | v1.0 | Bundle size + CWV, regression thresholds, baseline management |
| security-audit | v1.0 | OWASP + STRIDE, zero-noise (confidence ≥8/10), framework-aware |
| ship | v1.0 | Review readiness dashboard, changelog, PR with FR/bead traceability |

## Philosophy

- **Scope-Routed SDLC** — Weighted signals route features to the right pipeline depth
- **Domain-Aware** — Shared checklists and patterns for identity, data, mobile, and SaaS domains
- **Traceable** — Requirements trace from PRD through design, plan, beads, and review
- **Documentation-First** — All phases produce permanent documentation in `docs/`
- **Intent Over Implementation** — Beads contain objectives, not source code
- **Surgical Context** — Each bead specifies exactly which files to read
- **Upstream Fidelity** — Execute and review verify implementation matches what was specified
- **Continuous Learning** — `/workflow:compound` captures learnings by phase and domain
- **Explicit Approval** — Each phase requires user approval before proceeding
- **Stack-Agnostic** — Skills work with any tech stack; your CLAUDE.md configures the specifics

## License

MIT
