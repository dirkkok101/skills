# Agent Instructions

This project uses **br** (beads-rust) for local issue tracking. Issues are stored in `.beads/beads.db` (SQLite-only, local to this machine).

## Quick Reference

```bash
br ready              # Find available work (unblocked, open)
br show <id>          # View issue details
br update <id> --status in_progress  # Claim work
br close <id>         # Complete work
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues with `br create "Title" --type task -p 2`
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git add .
   git commit -m "..."
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Verify** - All changes committed AND pushed
6. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
- Beads database is local-only (not synced to git) - that's fine

---

## Beads CLI Reference (br)

### Issue Lifecycle

| Command | Purpose | Example |
|---------|---------|---------|
| `br create` | New issue | `br create "Title" -p 2 --type task` |
| `br q` | Quick capture (ID only) | `br q "Fix typo"` |
| `br show` | Display details | `br show bd-abc123` |
| `br update` | Modify issue | `br update bd-abc123 --status in_progress` |
| `br close` | Complete work | `br close bd-abc123` |
| `br close` | Close multiple | `br close bd-abc bd-def bd-ghi` |
| `br reopen` | Restore closed | `br reopen bd-abc123` |
| `br delete` | Remove (tombstone) | `br delete bd-abc123` |

### Querying Issues

| Command | Purpose | Example |
|---------|---------|---------|
| `br list` | Filter issues | `br list --status open` |
| `br ready` | Unblocked work | `br ready` |
| `br blocked` | Blocked items | `br blocked` |
| `br search` | Text search | `br search "authentication"` |
| `br stale` | Inactive issues | `br stale --days 30` |
| `br count` | Aggregation | `br count --by status` |
| `br stats` | Project overview | `br stats` |

### Dependencies

| Command | Purpose | Example |
|---------|---------|---------|
| `br dep add` | Create dependency | `br dep add bd-child bd-parent` |
| `br dep remove` | Remove dependency | `br dep remove bd-child bd-parent` |
| `br dep list` | Show dependencies | `br dep list bd-abc123` |
| `br dep tree` | Visual hierarchy | `br dep tree bd-abc123` |
| `br dep cycles` | Find circular deps | `br dep cycles` |

### Labels & Comments

| Command | Purpose | Example |
|---------|---------|---------|
| `br label add` | Tag issue | `br label add bd-abc123 backend` |
| `br label remove` | Remove tag | `br label remove bd-abc123 backend` |
| `br comments add` | Add note | `br comments add bd-abc123 "Root cause found"` |
| `br comments list` | View notes | `br comments list bd-abc123` |

### System

| Command | Purpose |
|---------|---------|
| `br init` | Initialize workspace |
| `br doctor` | Diagnostics |
| `br version` | Version info |

---

## Key Concepts

- **Priority**: 0=critical, 1=high, 2=medium (default), 3=low, 4=backlog
- **Types**: `task`, `bug`, `feature`
- **Status**: `open`, `in_progress`, `closed`
- **Dependencies**: `br dep add <child> <parent>` - child is blocked by parent
- **JSON Output**: All commands support `--json` for machine-readable output

---

## Workflow Pattern

```bash
# 1. Start session - find work
br ready

# 2. Claim task
br update bd-xxx --status in_progress

# 3. Do the work
# ... implement ...

# 4. Complete task
br close bd-xxx

# 5. Repeat or end session
```
