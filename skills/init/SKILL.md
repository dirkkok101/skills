---
name: init
description: >
  Initialize a project's documentation structure and workflow configuration.
  Creates the full docs/ folder hierarchy, adds workflow guidance to the
  project's CLAUDE.md, and verifies the project is ready for the skill
  pipeline. Idempotent — safe to run on existing projects. Use when starting
  a new project, when user says "init", "initialize project", "set up docs",
  "set up workflow", or when onboarding a project to the skill pipeline.
argument-hint: "[project name]"
---

# Init: Project Scaffold for Workflow Skills

**Philosophy:** Every project deserves a clear home for its documentation from day one. The init skill creates the folder structure that all downstream skills expect, configures CLAUDE.md with workflow guidance, and verifies the project is ready. Running init before any other skill prevents ad-hoc folder creation and ensures consistent documentation structure across all projects.

**Target duration:** ~5 minutes.

## Why This Matters

Without init, every skill creates its own folders on first use, leading to inconsistent structures and missing guidance. New team members (and new Claude sessions) don't know the workflow exists. Init solves this by:
- **Creating the full folder structure eagerly** — no surprises when skills run later
- **Documenting the workflow in CLAUDE.md** — every session knows how to use the pipeline
- **Verifying prerequisites** — catches missing tech stack documentation early

---

## Trigger Conditions

Run this skill when:
- Starting a new project that will use the workflow skills
- User says "init", "initialize", "set up docs", "set up workflow"
- Onboarding an existing project to the skill pipeline
- First time running any workflow skill on a project (suggest init first)

---

## Critical Sequence

### Phase 0: Project Detection

**Step 0.1 — Resolve PROJECT_ROOT:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
```

If not a git repo, ask the user to initialize one first — the workflow relies on git for change tracking and the skills reference `PROJECT_ROOT` throughout.

**Step 0.2 — Detect Existing State:**

Check what already exists to make this idempotent:

```bash
# Check for existing docs structure
ls "${PROJECT_ROOT}/docs/" 2>/dev/null

# Check for existing CLAUDE.md (root or .claude/)
CLAUDE_MD=""
if [ -f "${PROJECT_ROOT}/CLAUDE.md" ]; then
  CLAUDE_MD="${PROJECT_ROOT}/CLAUDE.md"
elif [ -f "${PROJECT_ROOT}/.claude/CLAUDE.md" ]; then
  CLAUDE_MD="${PROJECT_ROOT}/.claude/CLAUDE.md"
fi

# Check for workflow markers
if [ -n "$CLAUDE_MD" ]; then
  grep -q "<!-- workflow-skills-init -->" "$CLAUDE_MD" 2>/dev/null
  grep -q "<!-- /workflow-skills-init -->" "$CLAUDE_MD" 2>/dev/null
fi
```

**Idempotency logic:**

- **Both markers present + `docs/` structure exists** → Already initialized. Tell the user and stop.
- **Opening marker present but closing marker missing** → Corrupt state. Warn the user: "The workflow section in CLAUDE.md appears incomplete — the opening marker exists but the closing marker is missing. Remove the `<!-- workflow-skills-init -->` line and re-run /init to regenerate the section."
- **Markers present but `docs/` structure missing** → Marker was added manually without running init. Proceed with Phase 1 (create directories) but skip Phase 2 (CLAUDE.md already has content).
- **No markers** → Fresh project. Proceed with all phases.

**Step 0.3 — CLAUDE.md Location:**

If no CLAUDE.md exists at either `${PROJECT_ROOT}/CLAUDE.md` or `${PROJECT_ROOT}/.claude/CLAUDE.md`, create one at `${PROJECT_ROOT}/CLAUDE.md` (root level). If one exists at `.claude/CLAUDE.md`, use that location — do not create a second one at the root.

**Step 0.4 — Tech Stack Check:**

Look for evidence of a documented tech stack:

```bash
# Check CLAUDE.md for tech stack section
grep -i "tech stack\|technology\|stack\|framework" "$CLAUDE_MD" 2>/dev/null
```

If the CLAUDE.md has no tech stack section, warn the user:

> "Your project doesn't have a documented tech stack in CLAUDE.md yet. The workflow skills work best when Claude knows your stack — it informs technical design decisions, test strategies, and code patterns. Please add a Tech Stack section to your CLAUDE.md before running /brainstorm or /technical-design."

Do NOT create the tech stack section — the user knows their stack, the agent doesn't. Continue with the rest of init.

---

### Phase 1: Create Documentation Structure

Create the full folder hierarchy. Every directory gets a `.gitkeep` so git tracks empty directories.

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Core documentation directories
mkdir -p "${PROJECT_ROOT}/docs/research"
mkdir -p "${PROJECT_ROOT}/docs/brainstorm"
mkdir -p "${PROJECT_ROOT}/docs/discovery"
mkdir -p "${PROJECT_ROOT}/docs/prd"
mkdir -p "${PROJECT_ROOT}/docs/use-cases"
mkdir -p "${PROJECT_ROOT}/docs/designs"
mkdir -p "${PROJECT_ROOT}/docs/plans"
mkdir -p "${PROJECT_ROOT}/docs/learnings"
mkdir -p "${PROJECT_ROOT}/docs/reference"
mkdir -p "${PROJECT_ROOT}/docs/features"
mkdir -p "${PROJECT_ROOT}/docs/reviews"
mkdir -p "${PROJECT_ROOT}/docs/adr"
mkdir -p "${PROJECT_ROOT}/docs/decisions"
mkdir -p "${PROJECT_ROOT}/docs/architecture"
mkdir -p "${PROJECT_ROOT}/docs/diagnosis"

# Add .gitkeep to empty directories
for dir in research brainstorm discovery prd use-cases designs plans learnings reference features reviews adr decisions architecture diagnosis; do
  touch "${PROJECT_ROOT}/docs/${dir}/.gitkeep"
done
```

**Directory purposes:**

| Directory | Created By | Purpose |
|-----------|-----------|---------|
| `docs/research/` | /research | Research briefs, landscape surveys, competitive analysis |
| `docs/brainstorm/` | /brainstorm | Problem framing, approach selection, scope classification |
| `docs/discovery/` | /discovery | Requirements elicitation, glossaries, domain analysis |
| `docs/prd/` | /prd | Product requirements documents |
| `docs/use-cases/` | /prd | Standalone use case files (COMPREHENSIVE mode) |
| `docs/designs/` | /technical-design | Technical designs, architecture, API specs |
| `docs/plans/` | /plan | Implementation plans, sub-plans, companion docs |
| `docs/learnings/` | /compound | Pattern, gotcha, architecture, process learnings |
| `docs/reference/` | /review | Alignment audits (COMPREHENSIVE mode with 2+ upstream docs) |
| `docs/features/` | /technical-design | Consolidated feature specifications (COMPREHENSIVE, 10+ UCs) |
| `docs/reviews/` | /review | Consolidated review reports |
| `docs/adr/` | /technical-design | Project-wide architectural decision records |
| `docs/decisions/` | /compound | Feature-scoped decisions and rationale |
| `docs/architecture/` | (project) | Existing architecture context consumed by /technical-design |
| `docs/diagnosis/` | /diagnose | Root cause analyses, diagnostic reports |

Do NOT create files inside `docs/learnings/` — the /compound skill creates category files (`pattern.md`, `gotcha.md`, etc.) on first use based on what learnings actually emerge.

---

### Phase 2: Configure CLAUDE.md

This is the most important phase — it teaches every future Claude session how to use the workflow.

**Step 2.1 — Create or Append to CLAUDE.md:**

If no CLAUDE.md exists, create one with the workflow section. If one exists, append the workflow section at the end (ensure a blank line before the marker if the file doesn't end with a newline).

The workflow section uses HTML comment markers (`<!-- workflow-skills-init -->` / `<!-- /workflow-skills-init -->`) so the init skill can detect its own content for idempotency.

**Step 2.2 — Workflow Content:**

Append the following to CLAUDE.md. Note: the pipeline is shown as an indented line, not a fenced code block, to avoid rendering issues.

```markdown
<!-- workflow-skills-init -->

## Workflow Skills

This project uses a structured skill pipeline for feature development. Each skill produces documented artifacts that feed the next stage.

### Pipeline

    /research → /brainstorm → /discovery → /prd → /technical-design → /plan → /beads → /execute → /review → /compound

Not every feature needs every step:
- **Small fixes:** /diagnose → fix → /compound
- **Simple features (BRIEF):** /brainstorm → /plan → /beads → /execute → /review → /compound
- **Standard features:** /brainstorm → /prd → /technical-design → /plan → /beads → /execute → /review → /compound
- **Complex features (COMPREHENSIVE):** Full pipeline including /research and /discovery

### Documentation Structure

All project documentation lives in `docs/`:

| Directory | Skill | What Goes Here |
|-----------|-------|---------------|
| `docs/research/` | /research | Research briefs, landscape surveys |
| `docs/brainstorm/` | /brainstorm | Problem framing, approach selection |
| `docs/discovery/` | /discovery | Requirements elicitation, glossaries |
| `docs/prd/` | /prd | Product requirements documents |
| `docs/use-cases/` | /prd | Standalone use case files |
| `docs/designs/` | /technical-design | Technical designs, API specs |
| `docs/plans/` | /plan | Implementation plans, sub-plans |
| `docs/learnings/` | /compound | Accumulated project learnings |
| `docs/reviews/` | /review | Consolidated review reports |
| `docs/reference/` | /review | Alignment audits (COMPREHENSIVE) |
| `docs/features/` | /technical-design | Feature specifications (COMPREHENSIVE) |
| `docs/adr/` | /technical-design | Project-wide architecture decisions |
| `docs/decisions/` | /compound | Feature-scoped decisions |
| `docs/architecture/` | (project) | Existing architecture context |
| `docs/diagnosis/` | /diagnose | Root cause analysis reports |

### Conventions

- **Feature folders:** Each feature gets its own subfolder (e.g., `docs/prd/user-auth/prd.md`)
- **Stable IDs:** Requirements use `FR-{MODULE}-{DESCRIPTIVE-NAME}` format that chains through design → plan → beads → tests → code
- **Glossary inheritance:** Discovery seeds glossary → PRD imports → Design extends
- **Learnings:** Run /compound after completing features to capture patterns, gotchas, and decisions for future sessions

### Quick Reference

| I want to... | Run |
|--------------|-----|
| Explore a problem space | `/research` |
| Frame a problem and pick an approach | `/brainstorm` |
| Deep-dive requirements for complex features | `/discovery` |
| Write formal requirements | `/prd` |
| Design the technical solution | `/technical-design` |
| Create an implementation plan | `/plan` |
| Break plan into executable work packages | `/beads` |
| Implement work packages | `/execute` |
| Review completed implementation | `/review` |
| Capture learnings from the work | `/compound` |
| Debug something broken | `/diagnose` |

<!-- /workflow-skills-init -->
```

**Step 2.3 — Verify CLAUDE.md:**

After appending, read back the CLAUDE.md to verify:
1. Both markers (`<!-- workflow-skills-init -->` and `<!-- /workflow-skills-init -->`) are present
2. The content between them renders correctly
3. No existing content was damaged

---

### Phase 3: Summary & Next Steps

Present what was created:

```
Initialized project documentation structure:

docs/
├── research/        ← /research output
├── brainstorm/      ← /brainstorm output
├── discovery/       ← /discovery output
├── prd/             ← /prd output
├── use-cases/       ← /prd use cases (COMPREHENSIVE)
├── designs/         ← /technical-design output
├── plans/           ← /plan output
├── learnings/       ← /compound output
├── reviews/         ← /review reports
├── reference/       ← /review alignment audits
├── features/        ← /technical-design feature specs
├── adr/             ← project-wide architecture decisions
├── decisions/       ← feature-scoped decisions
├── architecture/    ← existing architecture context
└── diagnosis/       ← /diagnose output

CLAUDE.md: Workflow section added ✓
```

Then check and advise:

1. **Tech stack:** If not documented, remind the user to add it
2. **First feature:** Suggest starting with `/brainstorm` for new features or `/diagnose` for bugs
3. **Existing docs:** If the project already has documentation in non-standard locations, mention that the user may want to move them into the new structure

---

## Idempotency Rules

The init skill is safe to run multiple times:

1. `mkdir -p` is inherently idempotent — existing directories are untouched
2. The `<!-- workflow-skills-init -->` / `<!-- /workflow-skills-init -->` marker pair prevents duplicate CLAUDE.md sections
3. Corrupt marker state (opening without closing) is detected and reported to the user
4. `.gitkeep` files use `touch` — existing files are untouched
5. Existing files inside docs/ directories are never modified or deleted

---

## Anti-Patterns

**Guessing the Tech Stack** — The agent does not know the project's tech stack. Do not infer it from project files and write a tech stack section. The user documents their stack — the init skill just warns if it's missing.

**Creating Learnings Files** — Do not create `pattern.md`, `gotcha.md`, etc. in `docs/learnings/`. These are created by /compound when actual learnings emerge. Empty template files add noise.

**Overwriting CLAUDE.md** — Never replace an existing CLAUDE.md. Always append the workflow section. The user's existing configuration (code style, anti-patterns, tool usage) must be preserved. Check both `${PROJECT_ROOT}/CLAUDE.md` and `${PROJECT_ROOT}/.claude/CLAUDE.md` before creating a new file.

**Creating Sample Docs** — Do not create example brainstorm, PRD, or design files. Empty templates create false confidence and noise. The skills produce real artifacts when invoked.

**Running Other Skills** — Init only sets up structure and configuration. Do not automatically trigger /brainstorm or any other skill. Let the user decide what to do next.

**Duplicating CLAUDE.md** — If the project already has a CLAUDE.md at `.claude/CLAUDE.md`, do not create a second one at the project root. Use whichever location already exists.

---

*Skill Version: 3.3*
*v1.1: Adversarial review fixes. Added 4 missing directories (reviews, adr, decisions, architecture). Fixed nested code fence rendering (pipeline uses indented block). Fixed BRIEF pipeline routing to match brainstorm skill (skips prd and technical-design). Added .claude/CLAUDE.md location detection. Improved idempotency to check both markers and handle corrupt state. Clarified COMPREHENSIVE-only directories in table descriptions.*
*v1.0: Initial release. Eager folder creation, CLAUDE.md workflow section with markers, tech stack detection and warning, idempotent design.*
