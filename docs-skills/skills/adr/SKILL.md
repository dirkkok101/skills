---
name: docs-adr
description: Record architectural decisions using MADR templates with full lifecycle support (Proposed, Accepted, Deprecated, Superseded). Supports full, minimal, and bare template variants. Use when making or recording architectural decisions, documenting technology choices, or capturing decision rationale. Triggers on "record this decision", "create an ADR", "document why we chose", "capture rationale".
argument-hint: "[decision title] e.g. 'use PostgreSQL for persistence'"
---

# docs:adr — Architecture Decision Records

**Philosophy:** Decisions are perishable — context fades, people leave, rationale is forgotten. ADRs capture the WHY behind architectural choices when it's fresh. A brief ADR now is worth more than a detailed one never written.

## Core Principles

1. **Capture when fresh** - Record decisions while context is available
2. **Context over conclusion** - The reasoning matters more than the outcome
3. **Sequential and immutable** - ADRs are numbered, never deleted (only superseded)
4. **Right-sized** - Full analysis for big decisions, bare capture for quick ones
5. **Status lifecycle** - Every ADR has a clear status that evolves

---

## Trigger Conditions

Run this skill when:
- Making or recording an architectural decision
- Documenting why a technology or approach was chosen
- Capturing decision context before it's lost
- User says "record this decision", "create an ADR", "document why we chose", "capture rationale"

**Do NOT use this skill for:**
- Writing general documentation → Use `docs:write`
- Assessing documentation health → Use `docs:audit`
- "Write a tutorial" or "generate README" → Use `docs:write`

---

## Critical Sequence

### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"

# Ensure ADR folder exists
mkdir -p "${PROJECT_ROOT}/docs/adr"
```

**Step 0.2 - Check Existing ADRs:**

```bash
# List existing ADRs to determine next number
ls "${PROJECT_ROOT}/docs/adr/" | grep -E "^[0-9]{4}-" | sort -r | head -5

# Check for related ADRs
grep -rl "{decision keywords}" "${PROJECT_ROOT}/docs/adr/"*.md 2>/dev/null
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly
[ ] docs/adr/ folder exists (created if needed)
[ ] Determined next sequential ADR number
[ ] Checked for related existing ADRs
```

---

### Phase 1: Determine Next Number

Scan existing ADRs and assign the next sequential number:

```
SCAN docs/adr/ for files matching NNNN-*.md
HIGHEST = maximum NNNN found
NEXT = HIGHEST + 1 (zero-padded to 4 digits)

IF no existing ADRs:
  NEXT = 0001

VERIFY no file exists at docs/adr/{NEXT}-*.md (collision check)
```

**Format:** `NNNN-kebab-case-title.md`
**Examples:**
- `0001-use-postgresql-database.md`
- `0002-adopt-event-driven-architecture.md`
- `0003-choose-react-for-frontend.md`

---

### Phase 2: Select Template Variant

Choose the MADR variant based on decision complexity. **Load only one reference file.**

| Complexity | Variant | Reference File | When to Use |
|-----------|---------|----------------|-------------|
| High | Full | `references/adr/madr-full.md` | Multiple options, significant consequences, cross-team impact |
| Medium | Minimal | `references/adr/madr-minimal.md` | Clear options, moderate impact, standard decisions |
| Low | Bare | `references/adr/madr-bare.md` | Quick capture, decision already made, fill details later |

**Default:** Minimal (covers most decisions). Suggest full if the decision involves multiple teams, has long-term commitment, or the user mentions trade-offs.

**If uncertain,** ask:
> "How detailed should this ADR be? Full (thorough analysis with pros/cons per option), minimal (key context and outcome), or bare (headings only for quick capture)?"

---

### Phase 3: Gather Decision Context

Collect the information needed to fill the template:

```
- What decision was made (or needs to be made)?
- What problem or question prompted this decision?
- Decision drivers (requirements, constraints, team capabilities)
- Options considered (at least 2 for full/minimal)
- Pros and cons of each option
- Consequences — positive, negative, and neutral
- Related ADRs or prior decisions
```

**If recording a past decision:**
- Set status to `Accepted` (it's already decided)
- Note the date or context when it was decided

**If recording a pending decision:**
- Set status to `Proposed`
- Flag for team review

---

### Phase 4: Generate ADR

Fill the selected template:

```
FILENAME = {NNNN}-{kebab-case-title}.md
FILL template sections with gathered context
SET status:
  - "Proposed" for pending decisions
  - "Accepted" for retrospective recording
```

---

### Phase 5: Validate

Before writing, check:

```
[ ] Status field present and valid (Proposed | Accepted | Deprecated | Superseded)
[ ] Context section explains the problem clearly
[ ] Decision drivers documented (for full/minimal)
[ ] At least 2 options considered (for full/minimal)
[ ] Consequences noted (for full/minimal)
[ ] Related ADRs linked if applicable
[ ] Filename matches NNNN-kebab-case-title.md pattern
[ ] No number collision with existing ADRs
```

---

### Phase 6: Write ADR

```bash
# Write the ADR file
# Path: ${PROJECT_ROOT}/docs/adr/{NNNN}-{title}.md
```

Confirm creation with:
- File path
- ADR number and title
- Status
- Summary of the decision

---

### Status Lifecycle Management

ADRs follow this lifecycle:

```
Proposed → Accepted → Deprecated
                   → Superseded by [ADR-NNNN](link)
```

**To update an existing ADR's status:**
1. Open the ADR file
2. Change the `## Status` section
3. If superseding: add `Superseded by [ADR-NNNN](NNNN-title.md)` and create the new ADR with a link back

**Never delete an ADR.** Mark as Deprecated or Superseded instead.

---

## Quality Standards

- [ ] Sequential number assigned (no gaps, no collisions)
- [ ] Status lifecycle followed (valid status value)
- [ ] Decision drivers documented (not just the conclusion)
- [ ] Options considered with pros/cons (at least 2 for full/minimal)
- [ ] Consequences noted (positive and negative)
- [ ] Related ADRs linked when applicable
- [ ] Filename follows NNNN-kebab-case-title.md convention
- [ ] Only one MADR variant loaded per invocation

---

## Anti-Patterns

❌ **ADR without context**
```markdown
# ADR 0005: Use Redis
We decided to use Redis.
```

✅ **ADR with full decision context**
```markdown
# ADR 0005: Use Redis for Session Storage

## Status
Accepted

## Context and Problem Statement
We need a session store that supports horizontal scaling.
Current in-memory sessions don't survive restarts.

## Decision Drivers
- Must support cluster deployment
- Team has Redis experience
- Need sub-millisecond latency

## Decision Outcome
Chosen: Redis, because it meets all drivers and the team
has operational experience.
```

---

❌ **Missing status**
```markdown
# ADR 0003: Choose React

## Context
We need a frontend framework...
(no status section)
```

✅ **Explicit status lifecycle**
```markdown
## Status
Accepted

(or: Superseded by [ADR-0007](0007-migrate-to-svelte.md))
```

---

❌ **Deleting outdated ADRs**
```
rm docs/adr/0003-choose-angular.md
(history lost)
```

✅ **Superseding with new ADR**
```markdown
# ADR 0003: Choose Angular
## Status
Superseded by [ADR-0007](0007-migrate-to-svelte.md)
```

---

❌ **Single option "decision"**
```
We considered React. We chose React.
```

✅ **Genuine alternatives**
```
Considered: React, Vue, Svelte
Chose React because: team familiarity, ecosystem maturity
Trade-off: larger bundle size than Svelte
```

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "adr created" | Decision recorded, file written |
| "refine" | Continue iterating on the ADR |
| "abort" | Cancel ADR creation |
| "write docs" | → Redirect to `docs:write` |
| "audit docs" | → Redirect to `docs:audit` |

When complete: **"ADR created at `docs/adr/NNNN-title.md`. Status: {Proposed|Accepted}."**
