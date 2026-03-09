# Releasing

How to publish a new version of the skills library.

## Version Files

All of these must be updated when releasing:

| File | Field | Example |
|------|-------|---------|
| `.claude-plugin/plugin.json` | `"version"` | `"3.3.0"` |
| `.claude-plugin/marketplace.json` | `"metadata.version"` | `"3.3.0"` |
| `docs-skills/.claude-plugin/plugin.json` | `"version"` | `"3.3.0"` |
| `gemini-extension.json` | `"version"` | `"3.3.0"` |
| `CHANGELOG.md` | New section header | `## [3.3.0] - YYYY-MM-DD` |

Individual skill versions are in each `skills/*/SKILL.md` footer line (`*Skill Version: X.Y*`). These track the skill's own revision history and may differ from the plugin version — update them when the skill content changes.

## Versioning Strategy

We use [Semantic Versioning](https://semver.org/):

- **Major** (X.0.0): Breaking changes to skill behavior, removed skills, renamed commands, changed output formats that would break existing workflows
- **Minor** (0.X.0): New skills, new phases, new capabilities, non-breaking improvements to existing skills
- **Patch** (0.0.X): Bug fixes, typo corrections, clarifications that don't change behavior

The workflow and docs plugins share the same version number via `marketplace.json`. Keep them in sync.

## Release Process

### 1. Pre-Release Checks

```bash
# Verify all skills parse (no broken markdown)
for f in skills/*/SKILL.md; do echo "--- $f ---"; head -5 "$f"; done

# Check skill versions match expectations
grep "Skill Version" skills/*/SKILL.md

# Verify no uncommitted changes
git status

# Run any project-specific validation
# (e.g., OpenAI schema validation)
node openai/validate-tools.mjs 2>/dev/null || echo "OpenAI tools not configured"
```

### 2. Update Version Files

Update all 5 files listed in the table above. Use the same version string everywhere.

### 3. Update CHANGELOG.md

Add a new section at the top following [Keep a Changelog](https://keepachangelog.com/) format:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- {new skills or capabilities}

### Changed
- {modifications to existing skills}

### Fixed
- {bug fixes}
```

Categories: Added, Changed, Deprecated, Removed, Fixed, Security.

### 4. Update README.md (if needed)

If the release adds new skills, changes the pipeline, or modifies installation steps, update README.md.

### 5. Update Templates (if needed)

If the release changes conventions that affect project setup:
- `templates/CLAUDE.md` — project-level agent instructions
- `templates/AGENTS.md` — agent tool reference
- `templates/GEMINI.md` — Gemini CLI instructions
- `templates/OPENAI_AGENT.md` — OpenAI/Codex instructions

### 6. Commit and Tag

```bash
git add -A
git commit -m "release: v{X.Y.Z}

{Brief summary of what changed}

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

git tag v{X.Y.Z}
git push && git push --tags
```

### 7. Post-Release Verification

After pushing, verify the release is available:

```bash
# Claude Code — check marketplace update is visible
# (users update with: claude plugin update workflow@dirkkok-skills)

# Verify tag exists on remote
git ls-remote --tags origin | grep v{X.Y.Z}
```

## Platform-Specific Notes

### Claude Code (Primary)

- Distribution: marketplace plugin at `dirkkok101/skills`
- Users install: `/plugin marketplace add dirkkok101/skills` then `/plugin install workflow@dirkkok-skills`
- Users update: `claude plugin update workflow@dirkkok-skills`
- Auto-update available via marketplace settings

### Gemini CLI

- Distribution: GitHub extension URL
- Users install: `gemini extensions install https://github.com/dirkkok101/skills`
- Version tracked in `gemini-extension.json`

### OpenAI/Codex

- Distribution: function schema + bootstrap
- Files: `openai/tools.json`, `openai/bootstrap.ts`
- Validate before release: `node openai/validate-tools.mjs`
- Users copy `templates/OPENAI_AGENT.md` to their project

## Hotfix Process

For urgent fixes that can't wait for a full release:

1. Fix the issue on `main`
2. Bump patch version (e.g., 3.3.0 → 3.3.1)
3. Add a `### Fixed` entry to CHANGELOG.md under a new section
4. Follow steps 6-7 above

## Checklist Template

Copy this for each release:

```
- [ ] All skill SKILL.md versions match expectations
- [ ] .claude-plugin/plugin.json version bumped
- [ ] .claude-plugin/marketplace.json version bumped
- [ ] docs-skills/.claude-plugin/plugin.json version bumped
- [ ] gemini-extension.json version bumped
- [ ] CHANGELOG.md updated with new section
- [ ] README.md updated (if needed)
- [ ] Templates updated (if needed)
- [ ] OpenAI tools validated (if changed)
- [ ] Committed with release: message
- [ ] Tagged with v{X.Y.Z}
- [ ] Pushed with tags
- [ ] Verified on remote
```
