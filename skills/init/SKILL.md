---
name: init
description: >
  Use when starting a new project, when user says "init", "initialize
  project", "set up docs", "set up workflow", or when onboarding a project
  to the skill pipeline. Idempotent — safe to run on existing projects.
argument-hint: "[project name]"
---

# Init: Project Scaffold for Workflow Skills

**Philosophy:** Every project deserves a clear home for its documentation from day one. The init skill creates the foundational folder structure — project-level directories that exist before any feature — and configures CLAUDE.md with workflow guidance. Feature-specific directories (research, brainstorm, plans, reviews, etc.) are created on demand by each skill when it runs.

**Target duration:** ~5 minutes.

## Why This Matters

Without init, new team members (and new Claude sessions) don't know the workflow exists. Init solves this by:
- **Creating foundational directories** — project-level folders that multiple skills consume (architecture, patterns, learnings, ADRs)
- **Documenting the workflow in CLAUDE.md** — every session knows how to use the pipeline
- **Verifying prerequisites** — catches missing tech stack documentation early

Each skill creates its own output directories on demand (e.g., /research creates `docs/research/{feature}/`, /plan creates `docs/plans/`). Init only creates the shared foundations.

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

Create the foundational directories — project-level folders that exist before any feature and are consumed by multiple skills. Every directory gets a `.gitkeep` so git tracks empty directories.

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Foundational directories (created by init)
mkdir -p "${PROJECT_ROOT}/docs/prd"
mkdir -p "${PROJECT_ROOT}/docs/designs"
mkdir -p "${PROJECT_ROOT}/docs/architecture"
mkdir -p "${PROJECT_ROOT}/docs/patterns"
mkdir -p "${PROJECT_ROOT}/docs/adr"
mkdir -p "${PROJECT_ROOT}/docs/learnings"

# Add .gitkeep to empty directories
for dir in prd designs architecture patterns adr learnings; do
  touch "${PROJECT_ROOT}/docs/${dir}/.gitkeep"
done
```

**Directories created by init:**

| Directory | Purpose |
|-----------|---------|
| `docs/prd/` | Product requirements documents |
| `docs/designs/` | Technical designs, architecture, API specs |
| `docs/architecture/` | Existing architecture context consumed by /technical-design |
| `docs/patterns/` | Established conventions and reusable approaches consumed by /technical-design, /plan, and /review |
| `docs/adr/` | Project-wide and feature-scoped architectural decision records |
| `docs/learnings/` | Pattern, gotcha, architecture, process learnings consumed by all upstream skills |

**Directories created on demand by each skill:**

| Directory | Created By | Purpose |
|-----------|-----------|---------|
| `docs/research/{feature}/` | /research | Research briefs, landscape surveys |
| `docs/brainstorm/{feature}/` | /brainstorm | Problem framing, approach selection |
| `docs/discovery/{feature}/` | /discovery | Requirements elicitation, glossaries |
| `docs/use-cases/` | /prd | Cross-module use cases (COMPREHENSIVE) |
| `docs/plans/` | /plan | Implementation plans, sub-plans |
| `docs/reviews/` | /review | Consolidated review reports |
| `docs/reference/` | /review | Alignment audits (COMPREHENSIVE) |
| `docs/browser-e2e-plans/` | /technical-design | Browser E2E test plans per feature |
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

Project documentation lives in `docs/`. Init creates foundational directories; each skill creates additional directories on demand.

**Foundations (created by /init):**

| Directory | What Goes Here |
|-----------|---------------|
| `docs/prd/` | Product requirements documents |
| `docs/designs/` | Technical designs, API specs |
| `docs/architecture/` | Existing architecture context |
| `docs/patterns/` | Established conventions and reusable approaches |
| `docs/adr/` | Architecture decisions (/technical-design, /compound) |
| `docs/learnings/` | Accumulated project learnings (/compound) |

**Created on demand by skills:**

| Directory | Skill | What Goes Here |
|-----------|-------|---------------|
| `docs/research/` | /research | Research briefs, landscape surveys |
| `docs/brainstorm/` | /brainstorm | Problem framing, approach selection |
| `docs/discovery/` | /discovery | Requirements elicitation, glossaries |
| `docs/use-cases/` | /prd | Cross-module use cases (COMPREHENSIVE) |
| `docs/plans/` | /plan | Implementation plans, sub-plans |
| `docs/reviews/` | /review | Consolidated review reports |
| `docs/reference/` | /review | Alignment audits (COMPREHENSIVE) |
| `docs/browser-e2e-plans/` | /technical-design | Browser E2E test plans per feature |
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
├── prd/             ← product requirements
├── designs/         ← technical designs
├── architecture/    ← existing architecture context
├── patterns/        ← established conventions and reusable approaches
├── adr/             ← architecture decision records
└── learnings/       ← accumulated project learnings

CLAUDE.md: Workflow section added ✓

Additional directories (research/, brainstorm/, plans/, reviews/, etc.)
are created on demand when each skill runs.
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

*Skill Version: 3.6 — [Version History](VERSIONS.md)*
