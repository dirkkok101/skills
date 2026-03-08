# Skill Library Prerequisites

This skill library assumes the following global tooling is installed and configured in the user's environment (via `~/.claude/CLAUDE.md` and `~/AGENTS.md`).

## Required Tools

### br (beads-rust) — Local Issue Tracking

**Purpose:** Task management, issue tracking, dependency graphs. Used by beads, execute, review, and compound skills.

**Install:** `cargo install beads-rust`

**Skills that use it:** beads (creates work packages), execute (updates status), review (tracks findings), compound (captures learnings), any skill that conditionally creates tracked issues.

**How skills reference it:** Skills use conditional language — "If the project uses an issue tracker, offer to create tracked items." They never hardcode `br` commands directly. The user's CLAUDE.md maps this to `br`.

### bv (beads-viewer) — Graph-Aware Issue Intelligence

**Purpose:** Smart task selection, dependency analysis, triage recommendations.

**Install:** See beads-viewer repository.

**Skills that use it:** None directly — this is a session-start tool. But skills assume the user has triaged their work before starting a skill.

**Critical:** Never run bare `bv` — always use `--robot-*` flags.

### cass — Coding Agent Session Search

**Purpose:** Search past coding sessions for prior implementation context.

**Skills that use it:** research (searches for prior art), any skill that says "check for existing patterns."

**Critical:** Never run bare `cass` — always use `--robot` or `--json` flags.

### qmd — Markdown Knowledge Base Search

**Purpose:** Search architecture docs, design decisions, meeting notes.

**Skills that use it:** research (deep searches), technical-design (architecture references), any skill that references "project documentation."

### rtk — Rust Token Killer

**Purpose:** Token-optimized CLI output compression. Runs automatically via Claude Code hooks.

**Skills that use it:** None directly — RTK is transparent. It compresses tool output automatically.

## Optional Tools

### agent-browser — Browser Automation

**Purpose:** Visual verification of web UIs, screenshot capture, testing local web apps.

**Skills that use it:** execute (for visual verification of UI work), review (for UI review).

## Configuration

### Global CLAUDE.md (~/.claude/CLAUDE.md)

The user's global CLAUDE.md should contain:
- Tool usage instructions for br, bv, cass, qmd, rtk
- Code style conventions (language-specific)
- Anti-patterns to avoid
- Session lifecycle (start/end procedures)

### Global AGENTS.md (~/AGENTS.md)

The user's global AGENTS.md should contain:
- Tool selection table (which tool for which need)
- br command reference
- bv robot command reference
- cass search commands
- qmd search commands

## How Skills Reference These Tools

Skills in this library are **tool-agnostic by design**. They never hardcode tool-specific commands. Instead, they use conditional language:

- "If the project uses an issue tracker..." (maps to `br` via CLAUDE.md)
- "Search for prior implementation context..." (maps to `cass` via CLAUDE.md)
- "Check project documentation for architecture decisions..." (maps to `qmd` via CLAUDE.md)

This means the skills work with any tooling that provides equivalent capabilities. The user's CLAUDE.md and AGENTS.md bridge the gap between skill intent and tool commands.

## Verifying Installation

```bash
br version          # Should show beads-rust version
bv --robot-help     # Should show robot mode docs
cass stats --json   # Should show index stats
qmd status          # Should show collection info
rtk --version       # Should show rtk version
```

If any of these fail, the corresponding skill features will still work — they'll just skip the tool-specific integration and rely on manual user action instead.
