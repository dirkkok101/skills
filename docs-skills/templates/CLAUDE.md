# docs-skills Plugin

Documentation lifecycle plugin for Claude Code with three skills: `docs:audit`, `docs:write`, `docs:adr`.

## Plugin Architecture

```
docs-skills/
├── .claude-plugin/plugin.json
├── skills/
│   ├── audit/                    # docs:audit — documentation health analysis
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── quality-criteria.md
│   ├── write/                    # docs:write — template-driven doc generation
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── diataxis/         # tutorial, howto, reference, explanation
│   │       ├── ai-files/         # claude-md, agents-md, llms-txt
│   │       ├── architecture/     # c4-context, c4-container, system-overview, diagram-mermaid
│   │       └── project/          # readme, contributing, glossary
│   └── adr/                      # docs:adr — architectural decision records
│       ├── SKILL.md
│       └── references/
│           └── adr/              # madr-full, madr-minimal, madr-bare
└── templates/
    └── CLAUDE.md                 # this file
```

## Skill Authoring Conventions

### SKILL.md Structure
- **Frontmatter:** YAML with `name` and `description` (primary trigger mechanism)
- **Body:** Phased workflow with numbered phases (Phase 0: Prerequisites → Phase N: Final output)
- **Standard sections:** Quality Standards, Anti-Patterns (❌/✅ format), Exit Signals table

### Reference Files
- Live under `references/` in each skill directory (never `templates/`)
- Loaded on demand via progressive disclosure (not eagerly at skill start)
- Each file is a self-contained template + guidance document (~50-150 lines)
- Organized by domain: one subdirectory per category

### Frontmatter Descriptions
- Include all trigger phrases and use cases
- Must distinguish this skill from sibling skills (audit vs write vs adr)
- Include `argument-hint` showing usage pattern

## Reference File Ownership

| Skill | References | Count |
|-------|-----------|-------|
| docs:audit | `quality-criteria.md` | 1 |
| docs:write | `diataxis/` (4), `ai-files/` (3), `architecture/` (4), `project/` (3) | 14 |
| docs:adr | `adr/` (3 MADR variants) | 3 |

## Development Workflow

1. **Adding a reference:** Create `.md` file in the owning skill's `references/` subdirectory. Update SKILL.md to route to it.
2. **Modifying a skill:** Edit `SKILL.md`. Keep under 400 lines. Ensure frontmatter description doesn't overlap sibling skills.
3. **Adding a skill:** Create new directory under `skills/` with `SKILL.md` and `references/`. Update plugin.json description.
4. **Testing triggers:** Verify frontmatter description triggers for intended phrases and does NOT trigger for sibling skill phrases.
