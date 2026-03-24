# Multi-Agent Concurrent Execution Reference

When multiple agents execute on the same branch simultaneously, expect and handle these issues proactively.

## Build Artifact Collisions

Other agents' builds delete/lock compiled files mid-compilation, causing spurious build errors. **Fix:** Retry the build once. If it fails with the same error, wait 10 seconds and retry — the other agent's build will finish.

## File Reverts

Other agents may revert your changes via their own git operations (commit, checkout, stash). **Fix:** After each commit, verify your changes are in the commit with `git show --stat HEAD`. If a file you changed is missing, re-apply with `Write` (full file overwrite) rather than `Edit` (which fails on stale content).

## Shared File Conflicts

Other agents may break files you depend on (test files, shared components). **Fix:** Do NOT fix other agents' files. If their broken code blocks your tests, use module-scoped tests instead of the full suite.

## File Reservation

Use `macro_file_reservation_cycle` to reserve files before editing. This is the **default** when agent-mail is available, not optional. Without reservation, other agents commit YOUR unstaged files during the window between `git add` and `git commit` (the pre-commit hook runs in between, creating a race window). **Exception:** Skip reservation for beads modifying ≤2 files where the edit takes <30 seconds.

## Pre-Commit Hook Transience

Pre-commit hooks that run builds may fail when another agent is building simultaneously due to file locks. **Fix:** Retry the commit once after a transient hook failure. If it fails twice, wait 10 seconds and retry.

## Verification Strategy

| Context | Test Scope | Rationale |
|---------|-----------|-----------|
| **Per-bead (concurrent)** | Module-scoped tests | Reliable even when other agents have broken code |
| **Per-bead (solo)** | Full suite | No concurrent interference |
| **Test gate bead** | Full suite | Run when your module is complete and activity has settled |
| **If full suite broken by others** | Module-scoped + log skipped | Verify failures NOT in your files (`git diff --name-only`) |
| **If module-scoped also fails** | Per-class execution | Shared test infrastructure collisions |
