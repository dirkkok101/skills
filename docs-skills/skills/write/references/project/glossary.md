# Glossary Template

A glossary captures **domain-specific terminology** so contributors and AI agents understand terms consistently. Use a flexible table format that accommodates different levels of term complexity.

## Template

```markdown
# {Project/Domain} Glossary

Terms and definitions used in this project. Sorted alphabetically.

| Term | Definition | Context | Aliases |
|------|-----------|---------|---------|
| {Term} | {Clear, concise definition} | {Where/how it's used} | {Other names} |
```

## Example Entries

```markdown
| Term | Definition | Context | Aliases |
|------|-----------|---------|---------|
| Bead | A self-contained work package with intent, criteria, and context references | Workflow execution | Task, work item |
| Epic | A feature-level grouping of related beads | Planning and tracking | Feature, initiative |
| Skill | A modular package that extends Claude's capabilities with specialized knowledge | Plugin system | Capability, module |
| Progressive Disclosure | Loading information in layers: metadata → instructions → references | Skill design | Layered loading |
```

## Extended Format

For domains with complex terminology, add columns as needed:

```markdown
| Term | Definition | Context | Aliases | See Also |
|------|-----------|---------|---------|----------|
| {Term} | {Definition} | {Context} | {Aliases} | {Related terms or docs} |
```

## Minimal Format

For simpler domains, a two-column format works:

```markdown
| Term | Definition |
|------|-----------|
| {Term} | {Definition} |
```

## Guidance
- Sort alphabetically for quick lookup
- Write definitions that stand alone (don't require reading other entries to understand)
- Use the "Context" column to show where/how the term appears in the codebase
- Include aliases to help people who know the concept by a different name
- Keep definitions to 1-2 sentences — link to docs for deeper explanation
- Update the glossary when new domain terms appear in the codebase

## Anti-Patterns
- ❌ Definitions that use other glossary terms without explanation
- ❌ Including generic programming terms (use for domain-specific terms only)
- ❌ Stale terms that no longer appear in the codebase
- ❌ Definitions longer than 2 sentences (link to docs instead)
- ❌ Unsorted entries (makes lookup difficult)
