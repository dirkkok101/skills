---
name: ship
description: >
  Use when review is complete, user says "ship", "create PR", "ready to
  merge", or after /review approval.
argument-hint: "[feature-name] or [branch-name]"
---

# Ship: Review → Pull Request

**Philosophy:** Shipping is the last mile — where reviewed, tested code becomes a pull request ready for merge. The skill automates the mechanical steps (branch, changelog, PR creation) while enforcing quality gates that prevent shipping incomplete work. Every PR traces back to the requirements and beads that produced it, creating an auditable chain from intent to code.

**Duration targets:** BRIEF ~5-10 minutes (small change, few files), STANDARD ~10-20 minutes (typical feature), COMPREHENSIVE ~20-40 minutes (multi-service, release candidate).

## Why This Matters

The gap between "review approved" and "PR merged" is where things fall through cracks: forgotten changelog entries, missing test coverage for review fixes, incomplete commit messages, PRs with no context for human reviewers. Automating this step ensures consistent quality and traceability.

---

## Trigger Conditions

Run this skill when:
- Code review is complete (`/review` approved)
- User says "ship", "create PR", "ready to merge"
- All tests pass and build succeeds
- Changes are committed and ready for PR

Do NOT use for:
- Code that hasn't been reviewed → run `/review` first
- Work in progress → complete execution first
- Hotfixes that bypass the pipeline → use manual PR creation

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Behaviour |
|------|------|-----------|
| **BRIEF** | Small change (<50 lines, 1-5 files) | Skip adversarial checks, minimal changelog, fast PR |
| **STANDARD** | Typical feature (50-500 lines) | Full changelog, review readiness check, PR with traceability |
| **COMPREHENSIVE** | Large feature, release candidate (500+ lines) | Full changelog, regression test audit, version bump decision, PR with full traceability |

---

## Collaborative Model

```
Phase 1: Pre-Flight Checks
Phase 2: Review Readiness Dashboard
  ── PAUSE 1: "Review readiness. Proceed or address gaps?" ──
Phase 3: Generate Changelog & Version
Phase 4: Create Pull Request
  ── PAUSE 2: "PR ready. Create?" ──
Phase 5: Post-Ship Documentation
```

---

## Prerequisites

Before starting, verify:
- All tests pass (run project build and test commands)
- Build succeeds
- Changes are committed (check `git status`)
- Review has been completed (check for `docs/reviews/review-*.md`)
- `gh` CLI is installed and authenticated (`gh auth status`). If `gh` is not available, fall back to providing the user a manual PR creation command with the generated description.

---

## Critical Sequence

### Phase 1: Pre-Flight Checks

**Step 1.1 — Verify Clean State:**

```bash
git status              # No uncommitted changes
git log --oneline -20   # Review recent commits
```

Ensure all changes are committed. If uncommitted changes exist, ask the user what to do.

**Step 1.2 — Verify Tests & Build:**

Run the project's build and test commands. Both MUST pass. If either fails, stop and report — do not create a PR with failing tests.

**Step 1.3 — Determine Scope:**

```bash
git diff main --stat          # Files changed
git diff main --shortstat     # Lines changed
git log main..HEAD --oneline  # Commits
```

Count files, lines, and commits to determine mode (BRIEF/STANDARD/COMPREHENSIVE).

**Step 1.4 — Locate Upstream Artifacts:**

Check for existing documentation that feeds into the PR:
- **Execution manifest** — `docs/execution/{feature}/manifest.md` (FR/bead traceability)
- **Review report** — `docs/reviews/review-*.md` (review findings and resolutions)
- **PRD** — `docs/prd/{feature}/prd.md` (requirements context)
- **Brainstorm** — `docs/brainstorm/{feature}/brainstorm.md` (problem context)

Record which artifacts exist — they feed into the PR description.

---

### Phase 2: Review Readiness Dashboard

**Step 2.1 — Build Readiness Dashboard:**

```markdown
## Review Readiness Dashboard

| Check | Status | Details |
|-------|--------|---------|
| Build passes | ✅/❌ | {result} |
| All tests pass | ✅/❌ | {pass count}/{total count} |
| Review completed | ✅/❌ | {review file path or "no review found"} |
| Review findings resolved | ✅/❌/⚠️ | {N must-fix resolved, M remaining} |
| No uncommitted changes | ✅/❌ | {git status summary} |
| Branch up to date with main | ✅/❌ | {ahead/behind count} |
| Execution manifest exists | ✅/❌ | {path or "not found"} |

### Traceability
| Source | Coverage |
|--------|----------|
| FRs implemented | {list from manifest or commit messages} |
| Beads completed | {count from manifest or issue tracker} |
| UCs verified | {list from manifest} |
```

**Step 2.2 — Assess Readiness:**

- **All ✅:** Proceed to Phase 3
- **Any ❌ on build/tests:** STOP — fix before shipping
- **Review not completed:** Warn — recommend running `/review` first
- **Review findings unresolved:** Flag remaining must-fix items

**PAUSE 1:** Present the readiness dashboard as formatted markdown, then:

```
AskUserQuestion:
  question: "Review readiness assessment complete. How should we proceed?"
  header: "Readiness"
  multiSelect: false
  options:
    - label: "Ship it (Recommended)"
      description: "All checks pass. Proceed to changelog and PR creation."
    - label: "Address gaps"
      description: "Fix the flagged issues before shipping."
    - label: "Ship anyway"
      description: "Override readiness checks and proceed (adds warning to PR)."
    - label: "Cancel"
      description: "Don't ship yet."
```

If the user selects "Ship anyway" with failing checks, add a prominent warning to the PR description:
```
⚠️ **Shipped with readiness overrides:** {list of overridden checks}
```

---

### Phase 3: Generate Changelog & Version

**Step 3.1 — Draft Changelog Entry:**

Analyze all commits since divergence from main. Categorize changes.

Match the existing CHANGELOG.md format. If no changelog exists, use the Keep a Changelog format:

```markdown
### Added
- {new features}

### Changed
- {modifications to existing features}

### Fixed
- {bug fixes}
```

If an execution manifest exists, use FR references for richer changelog entries:
```markdown
### Added
- **FR-APP-REGISTER:** Application registration with validation (bd-001, bd-002, bd-003)
```

**Step 3.2 — Version Decision (COMPREHENSIVE only):**

In COMPREHENSIVE mode, assess version bump:
- **Lines changed <50:** MICRO (no version bump)
- **Lines changed 50-500:** PATCH
- **New features added:** MINOR
- **Breaking changes:** MAJOR — always ask user

If a VERSION or package.json file exists, present the version bump recommendation.

```
AskUserQuestion:
  question: "Version bump recommendation: {PATCH/MINOR}. Accept?"
  header: "Version"
  multiSelect: false
  options:
    - label: "{Recommended bump} (Recommended)"
      description: "Bump from {current} to {new}"
    - label: "Different bump"
      description: "I want a different version increment."
    - label: "No bump"
      description: "Skip version bump for this release."
```

**Step 3.3 — Update Changelog:**

If a CHANGELOG.md exists, prepend the new entry under a new version header. Follow the existing changelog format and conventions.

---

### Phase 4: Create Pull Request

**Step 4.1 — Ensure Remote Branch:**

```bash
git push -u origin HEAD     # Push current branch
```

**Step 4.2 — Draft PR Description:**

Build a PR description with traceability:

```markdown
## Summary

{1-3 bullet points describing what this PR does and why}

## Changes

{Changelog entry from Phase 3}

## Traceability

| Type | Reference |
|------|-----------|
| PRD | {link or "N/A"} |
| Beads | {bead IDs from manifest} |
| FRs | {FR IDs from manifest} |
| UCs | {UC IDs from manifest} |
| Review | {review file path} |
| Manifest | {manifest file path} |

## Test Plan

- [ ] All tests pass ({count} tests)
- [ ] Build succeeds
- [ ] Review findings resolved
{additional test items from execution manifest}

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

**PAUSE 2:** Present the PR title and description as formatted markdown, then:

```
AskUserQuestion:
  question: "PR ready to create. Proceed?"
  header: "PR"
  multiSelect: false
  options:
    - label: "Create PR (Recommended)"
      description: "Create the pull request with this title and description."
    - label: "Edit"
      description: "I want to modify the title or description."
    - label: "Cancel"
      description: "Don't create the PR yet."
```

**Step 4.3 — Create PR:**

Write the PR description to a temporary file, then create the PR:
```bash
gh pr create --title "{title}" --body-file /tmp/pr-description.md
```

This avoids shell escaping issues with markdown content containing quotes, backticks, and special characters.

Add `--base {main-branch}` if the repository's default branch differs from the target.

Record the PR URL.

---

### Phase 5: Post-Ship Documentation

**Step 5.1 — Verify PR Created:**

Confirm the PR was created successfully and record the URL.

**Step 5.2 — Update Issue Tracker:**

If the project uses an issue tracker, update relevant issues:
- Link the PR to related issues
- Update status of implemented features

**Step 5.3 — Report Completion:**

```markdown
## Ship Complete

**PR:** {URL}
**Branch:** {branch name}
**Changes:** {files changed}, {lines added/removed}
**Changelog:** Updated with {N} entries
**Traceability:** {N} FRs, {N} beads, {N} UCs referenced

Next: Merge the PR when CI passes, then run `/compound` to capture learnings.
```

---

## Anti-Patterns

**Shipping Without Review** — Creating a PR before running `/review`. The review skill catches bugs, security issues, and design deviations that automated tests miss. Skipping it is a false economy — the time saved is paid back in PR review comments and post-merge fixes.

**Empty PR Descriptions** — A PR with just a title tells reviewers nothing. The traceability section connects the PR to requirements, beads, and review findings — giving reviewers the context to review efficiently. Time spent on the PR description saves multiples in review time.

**Force-Pushing to Shared Branches** — Never force-push to main or shared branches. If the branch needs rebasing, do it locally and push normally. Force-push can destroy other people's work.

**Skipping Changelog** — "It's just a small change" — every change deserves a changelog entry. Small changes that accumulate without documentation become invisible technical debt. The changelog is the user-facing record of what changed.

**Shipping Failing Tests** — Tests exist to catch regressions. Shipping with failing tests means either the tests are wrong (fix them) or the code is wrong (fix it). "They were already failing" is not an excuse — fix or skip them explicitly with documented reasoning.

**Version Bump Without Checking** — Automated version bumps can be wrong. A "patch" that adds a new API endpoint is actually a minor bump. Always verify the semantic versioning classification against actual changes.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| PR created | Ship complete | Merge when CI passes, then `/compound` |
| Readiness failed | Not ready to ship | Fix gaps, re-run `/review` if needed |
| User cancelled | Decided not to ship | Return to development |

When PR created: **"PR created at {URL}. Merge when CI passes, then run `/compound` to capture learnings."**

---

*Skill Version: 1.0*
*v1.0: Initial release. Pre-flight checks, review readiness dashboard, changelog generation with FR traceability, version bump decision, PR creation with traceability section, post-ship documentation. Inspired by gstack's /ship release pipeline.*
