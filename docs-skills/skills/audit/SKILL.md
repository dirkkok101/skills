---
name: docs-audit
description: Analyze documentation health for existing codebases. Detects structure, applies Diataxis gap analysis, checks AI-friendliness (CLAUDE.md, AGENTS.md, llms.txt), and scans for staleness. Use when joining a project, assessing documentation quality, or before a major documentation effort. Triggers on "review my docs", "what docs are missing", "audit documentation", "check doc health".
argument-hint: "[project-path] or run in current project"
---

# docs:audit — Documentation Health Analysis

**Philosophy:** Understand documentation health before creating or updating docs. Audit provides the evidence for what to write, where the gaps are, and what's stale. Creating docs without auditing first risks duplicating, contradicting, or missing existing work.

## Core Principles

1. **Audit before create** - Understand what exists before generating new docs
2. **Evidence-based** - Every finding backed by file paths, dates, git history
3. **Actionable output** - Report prioritizes recommendations, not just observations
4. **Progressive analysis** - Structure → inventory → gaps → quality → staleness
5. **AI + Human audience** - Check for both human docs and AI-optimization files

---

## Trigger Conditions

Run this skill when:
- Joining an existing project to assess documentation health
- Before a major documentation effort to identify gaps
- Reviewing documentation quality or AI-friendliness
- User says "review my docs", "what docs are missing", "audit documentation", "check doc health"

**Do NOT use this skill for:**
- Writing new documentation → Use `docs:write`
- Recording architectural decisions → Use `docs:adr`
- "Write a tutorial" or "generate README" → Use `docs:write`

---

## Critical Sequence

### Phase 0: Prerequisites Check

**Step 0.1 - Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
echo "Project root: ${PROJECT_ROOT}"
```

**Step 0.2 - Check Existing Documentation:**

```bash
# Check for docs/ folder
ls -la "${PROJECT_ROOT}/docs/" 2>/dev/null || echo "No docs/ folder"

# Check for AI files at root
ls "${PROJECT_ROOT}/CLAUDE.md" "${PROJECT_ROOT}/AGENTS.md" "${PROJECT_ROOT}/llms.txt" 2>/dev/null

# Check for package files (for command extraction)
ls "${PROJECT_ROOT}/package.json" "${PROJECT_ROOT}/Makefile" "${PROJECT_ROOT}/Cargo.toml" 2>/dev/null
```

**Verify:**
```
[ ] PROJECT_ROOT resolved correctly
[ ] Noted existing docs/ structure (or absence)
[ ] Identified AI files present/missing
[ ] Located package files for command extraction
```

---

### Phase 1: Auto-Detect Project Structure

Scan the project to identify subsystems and documentation locations:

```
- Scan for subsystems: backend/, frontend/, src/, lib/, packages/
- Identify monorepo structure if present
- Note language/framework from package files
- Detect documentation locations: docs/, wiki/, README files at various levels
```

Record findings:
```markdown
## Structure Detection

| Subsystem | Path | Language/Framework | Has Docs |
|-----------|------|--------------------|----------|
| {name} | {path} | {tech} | yes/no |
```

---

### Phase 2: Documentation Inventory

Inventory all markdown files and categorize:

```
- Find all .md files in the project
- Categorize each by Diataxis type based on content analysis:
  - Tutorial: learning-oriented, step-by-step with outcomes
  - How-to: task-oriented, goal-focused steps
  - Reference: information-oriented, API/config documentation
  - Explanation: understanding-oriented, discusses why/trade-offs
  - Other: README, CONTRIBUTING, CHANGELOG, ADRs
- Note last modification date from git
```

Record findings:
```markdown
## Documentation Inventory

| File | Diataxis Type | Last Updated | Status |
|------|---------------|--------------|--------|
| {path} | tutorial/howto/reference/explanation/other | {date} | current/stale |
```

---

### Phase 3: Diataxis Gap Analysis

For each subsystem, check coverage across all four Diataxis types:

```
- Tutorials: Does a newcomer have a learning path?
- How-to guides: Can a practitioner accomplish key tasks?
- Reference: Are APIs, configs, and parameters documented?
- Explanation: Is the "why" behind design decisions captured?
```

Record gaps with specific recommendations:
```markdown
## Diataxis Gaps

| Subsystem | Tutorials | How-To | Reference | Explanation |
|-----------|-----------|--------|-----------|-------------|
| {name} | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |

### Recommendations
- {Subsystem}: Missing {type} — suggest "{specific topic}" as first doc
```

---

### Phase 4: AI-Friendliness Check

**Load reference:** Read `references/quality-criteria.md` for evaluation standards.

Check each AI-optimization file against quality criteria:

```
- CLAUDE.md: Present? Has required elements? (overview, commands, conventions, testing)
- AGENTS.md: Present? Follows spec? (setup, build/test, style, PR conventions)
- llms.txt: Present? Follows spec? (H1+H2 only, blockquote, categorized links)
```

For each file that exists, evaluate quality:
```markdown
## AI-Friendliness

| File | Present | Quality | Issues |
|------|---------|---------|--------|
| CLAUDE.md | yes/no | good/fair/poor | {specific issues} |
| AGENTS.md | yes/no | good/fair/poor | {specific issues} |
| llms.txt | yes/no | good/fair/poor | {specific issues} |
```

---

### Phase 5: Staleness Scan

Compare documentation modification dates against code changes:

```bash
# For each doc file, check last modification
git log -1 --format="%ai" -- {doc-path}

# Compare against code changes in related directories
git log -1 --format="%ai" -- {code-path}
```

Flag documents where:
- Doc last modified > 90 days before related code changes
- References deprecated APIs, removed features, or old versions
- Contains broken internal links

---

### Phase 6: Generate Audit Report

Compile findings into structured report:

```markdown
# Documentation Audit Report

**Project:** {project-name}
**Date:** {date}
**Scope:** {subsystems audited}

## Summary

| Category | Status | Details |
|----------|--------|---------|
| Structure | {ok/gaps/missing} | {brief} |
| Diataxis Coverage | {N/4 types present} | {which types missing} |
| AI-Friendliness | {N/3 files present} | {which files missing} |
| Staleness | {N docs stale} | {oldest stale doc} |

## Documentation Inventory

| File | Diataxis Type | Last Updated | Status |
|------|---------------|--------------|--------|
| ... | ... | ... | current/stale/outdated |

## Gap Analysis

### Diataxis Gaps
- **Tutorials:** {present/missing} — {recommendation}
- **How-to Guides:** {present/missing} — {recommendation}
- **Reference:** {present/missing} — {recommendation}
- **Explanation:** {present/missing} — {recommendation}

### AI-Friendliness
- **CLAUDE.md:** {present/missing/incomplete} — {recommendation}
- **AGENTS.md:** {present/missing/incomplete} — {recommendation}
- **llms.txt:** {present/missing} — {recommendation}

## Prioritized Recommendations

1. **[Critical]** {action item}
2. **[High]** {action item}
3. **[Medium]** {action item}

## Next Steps

Run `docs:write {type} {subject}` to address the highest-priority gaps.
```

---

## Quality Standards

- [ ] Project structure detected correctly (subsystems, languages)
- [ ] All documentation directories scanned
- [ ] Diataxis gaps identified with specific recommendations (not just "missing")
- [ ] AI-files checked against quality-criteria.md standards
- [ ] Staleness assessed using git history (not just file dates)
- [ ] Report includes prioritized action items with severity levels
- [ ] Recommendations are actionable (specific doc type + topic)

---

## Anti-Patterns

❌ **Creating docs without audit**
```
"Let me generate a README for this project"
→ Might duplicate existing docs or miss project conventions
```

✅ **Audit first**
```
"Running docs:audit to understand existing documentation..."
"Found: partial README, no AGENTS.md, outdated API docs"
"Recommended: Complete README, create AGENTS.md, refresh API docs"
```

---

❌ **Ignoring existing doc structure**
```
Creating docs/guides/howto-auth.md when project uses docs/tutorials/
```

✅ **Follow existing conventions**
```
"Detected existing structure: docs/tutorials/, docs/reference/"
"Creating docs/tutorials/authentication.md to match convention"
```

---

❌ **Skipping AI-friendliness**
```
"Documentation is complete" (but no AGENTS.md, CLAUDE.md)
```

✅ **Including AI optimization**
```
"Documentation looks solid. Also checking AI optimization..."
"Missing: AGENTS.md for cross-platform agent support"
"Missing: llms.txt index for context optimization"
```

---

❌ **Vague findings**
```
"Documentation could be improved"
```

✅ **Specific, actionable findings**
```
"Missing how-to guide for authentication flow (docs/howto/)"
"CLAUDE.md line 12: build command 'npm build' should be 'npm run build'"
"docs/api.md last updated 2024-03-01, API changed in commit abc123 on 2024-09-15"
```

---

## Exit Signals

| Signal | Meaning |
|--------|---------|
| "audit complete" | Report generated, ready for action |
| "refine" | Continue iterating on the audit |
| "abort" | Cancel audit |
| "write docs" | → Redirect to `docs:write` |
| "create ADR" | → Redirect to `docs:adr` |
| "record decision" | → Redirect to `docs:adr` |

When complete: **"Audit complete. Run `docs:write {type} {subject}` to address the highest-priority gaps."**
