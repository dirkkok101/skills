# MADR Minimal Template

Minimal MADR 4.0.0 template with required sections and brief guidance. Use for routine decisions that still warrant a record.

## Status Lifecycle

`Proposed` → `Accepted` → `Deprecated` or `Superseded by [ADR-NNNN](link)`

## Template

```markdown
# {Short title of the decision}

## Status

{Proposed | Accepted | Deprecated | Superseded by [ADR-NNNN](link)}

## Context and Problem Statement

{What is the problem or question? Why does this need a decision?}

## Decision Outcome

Chosen option: "{Option}", because {justification}.

### Consequences

- Good, because {positive outcome}
- Bad, because {negative trade-off}
```

## When to Use
- Day-to-day architectural decisions
- Decisions with a clear winner and few alternatives
- Situations where recording the "what and why" matters more than detailed analysis
