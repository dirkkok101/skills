# Execution Manifest Template

The execution manifest is written to `docs/execution/{feature}/manifest.md` by `/execute` and consumed by `/review-execute` for bead-by-bead verification.

## Manifest Robustness

1. **Verify working directory** — `pwd` must be the project root before writing
2. **Create directory first:** `mkdir -p docs/execution/{feature}/`
3. **Write incrementally** — start after the first bead, append per bead. Don't leave for end-of-session.
4. Commit and push as the final commit.

## Full Template

```markdown
# Execution Manifest: {Feature Name}

> **Date:** {date}
> **Epic:** {epic-id}
> **Beads Completed:** {N} of {N}
> **Build:** Passing
> **Tests:** All passing

## Bead Completion Log

### bd-{id}: {title}
- **Status:** Completed | Verified (no changes) | Deferred
- **Files changed:** {list of file paths}
- **Tests added:** {count} ({list of test file paths})
- **FRs addressed:** {FR IDs}
- **UCs contributed to:** {UC IDs and steps}
- **ACs claimed:** {acceptance criteria satisfied}
- **Design elements implemented:** {api-surface endpoint, data-model entity, etc.}
- **Commit:** {hash} — {message}
- **Key implementation choice:** {one sentence}

## Commits

{git log --oneline for this feature's commits}

## Files Changed

{git diff main --stat}

## FR Coverage Claimed

| FR ID | Bead(s) | ACs Claimed | Files |
|-------|---------|-------------|-------|
| {FR-ID} | {bd-ids} | {AC list} | {file paths} |

## UC Coverage Claimed

| UC ID | Step/Flow | Bead(s) | Implementation |
|-------|-----------|---------|----------------|
| {UC-ID} | Main.{N}: {description} | {bd-ids} | {endpoint/component} |

## Design Elements Implemented

| Design Element | Source Doc | Bead | Status |
|---------------|-----------|------|--------|
| {element} | {doc} | {bd-id} | Implemented |
```

## Compact Variant (for verification-only runs)

When all beads are verification-only (zero code changes):

```markdown
# Execution Manifest: {Feature Name}

> **Date:** {date}
> **Epic:** {epic-id}
> **Mode:** Verification-only — all beads confirmed existing code matches design
> **Beads Verified:** {N} of {N}

## Verification Summary

| Bead | Status |
|------|--------|
| bd-{id}: {title} | Verified — no changes needed |
```
