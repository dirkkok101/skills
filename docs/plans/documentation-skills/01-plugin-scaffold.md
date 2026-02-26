# Sub-Plan: Plugin Scaffold

> Part of [Documentation Skills Plan](overview.md)

## Objective

Create the plugin directory structure, `plugin.json`, and `CLAUDE.md` template for the standalone `docs` plugin. This establishes the foundation that all reference files and skills will be added to.

## Context

This is the first component — all other components depend on this directory structure existing. The plugin is a **separate** repo/directory from the existing `workflow` plugin. It uses the `name: "docs"` namespace so skills resolve as `docs:audit`, `docs:write`, `docs:adr`.

## Tasks

### Task 1: Create Plugin Directory Structure

**Objective:** Scaffold the complete directory tree for the docs-skills plugin.

**Approach:**
Create the top-level directory with `.claude-plugin/`, `skills/` (with 3 skill subdirs each having `references/`), and `templates/` directories.

**Pseudocode:**
```
CREATE directory tree:
  docs-skills/
  ├── .claude-plugin/
  ├── skills/
  │   ├── audit/references/
  │   ├── write/references/
  │   │   ├── diataxis/
  │   │   ├── ai-files/
  │   │   ├── architecture/
  │   │   └── project/
  │   └── adr/references/adr/
  └── templates/
```

**Pattern Reference:**
- Directory layout: Design's Skill Overview and Plugin Namespace Decision sections

**Success Criteria:**
- All directories exist matching the design's Skill Overview layout
- Subdirectory structure under `write/references/` has all 4 categories

**Failure Criteria:**
- ❌ Using `templates/` inside skills instead of `references/`
- ❌ Missing nested directories (e.g., `diataxis/` under `write/references/`)

**Verification:**
- Manual: Run `tree docs-skills/` and compare against design's directory structure
- Manual: Confirm each skill has a `references/` directory (not `templates/`)

---

### Task 2: Create plugin.json

**Objective:** Define the plugin metadata for the `docs` namespace.

**Approach:**
Create `.claude-plugin/plugin.json` following the same schema as the existing `workflow` plugin. Use `name: "docs"` for clean skill invocation names.

**Pseudocode:**
```
CREATE .claude-plugin/plugin.json:
  name: "docs"
  description: (summarize all 3 skills and their purpose)
  version: "1.0.0"
  author, homepage, repository, license: (match workflow plugin fields)
  keywords: ["docs", "documentation", "audit", "adr", "diataxis"]
```

**Pattern Reference:**
- Schema: existing `.claude-plugin/plugin.json` in the workflow plugin

**Success Criteria:**
- Plugin name is `"docs"`
- Version starts at `"1.0.0"`
- Required fields present: name, description, version

**Failure Criteria:**
- ❌ Name conflicts with existing plugin
- ❌ Missing required fields

**Verification:**
- Manual: Validate JSON parses correctly (`python -m json.tool plugin.json`)
- Manual: Confirm name is `"docs"` (not `"documentation"` or `"doc"`)

---

### Task 3: Create Plugin CLAUDE.md

**Objective:** Provide the plugin's own CLAUDE.md with development instructions for contributing to the docs-skills plugin.

**Approach:**
Place in `templates/CLAUDE.md`. This is the plugin's internal development guide (similar to how repos have their own CLAUDE.md), NOT a template for docs:write output. The docs:write skill has its own `references/ai-files/claude-md.md` for generating CLAUDE.md in target projects.

**Pseudocode:**
```
CREATE templates/CLAUDE.md:
  - Plugin overview (3 skills, purpose)
  - Skill authoring conventions (frontmatter, phases, references/)
  - Reference file structure (which skill owns which refs)
  - Development workflow (how to add/modify skills)
```

**Pattern Reference:**
- CLAUDE.md conventions: existing CLAUDE.md files in projects

**Success Criteria:**
- Contains plugin development conventions (skill authoring patterns, reference file structure)
- Explains the plugin's architecture and skill relationships
- Follows established CLAUDE.md conventions

**Failure Criteria:**
- ❌ Confused with docs:write's claude-md.md reference (different purpose)
- ❌ Contains user-facing documentation instead of development instructions

**Verification:**
- Manual: Confirm CLAUDE.md describes plugin development, not end-user usage
- Manual: Verify it references all 3 skills and their reference structures

## Component Success Criteria

- Directory structure matches design exactly
- `plugin.json` validates (correct JSON, all required fields)
- Ready for reference files and SKILL.md files to be added

## References

- Docs: [Plugin Namespace Decision](../../designs/documentation-skills/design.md#plugin-namespace-decision)
- Patterns: existing `workflow` plugin at `.claude-plugin/plugin.json`
