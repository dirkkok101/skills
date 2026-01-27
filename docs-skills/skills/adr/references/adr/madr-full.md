# MADR Full Template

Full MADR 4.0.0 template with all sections and explanatory guidance. Use for important architectural decisions that need thorough documentation.

## Status Lifecycle

`Proposed` → `Accepted` → `Deprecated` or `Superseded by [ADR-NNNN](link)`

## Template

```markdown
# {Short title of the decision}

## Status

{Proposed | Accepted | Deprecated | Superseded by [ADR-NNNN](link)}

## Context and Problem Statement

{Describe the context and the problem or question this decision addresses. What forces are at play? Why does this decision need to be made now?}

## Decision Drivers

- {Driver 1, e.g., "Must support 10k concurrent connections"}
- {Driver 2, e.g., "Team has limited experience with technology X"}
- {Driver 3, e.g., "Must integrate with existing system Y"}

## Considered Options

1. {Option 1}
2. {Option 2}
3. {Option 3}

## Decision Outcome

Chosen option: "{Option N}", because {1-2 sentence justification linking back to decision drivers}.

### Consequences

#### Good

- {Positive consequence, e.g., "Simplifies deployment pipeline"}
- {Positive consequence}

#### Bad

- {Negative consequence, e.g., "Requires team training on new framework"}
- {Negative consequence}

#### Neutral

- {Neutral observation, e.g., "Requires migration of existing data"}

## Pros and Cons of the Options

### {Option 1}

{Brief description of the option.}

- Good, because {advantage}
- Good, because {advantage}
- Bad, because {disadvantage}
- Bad, because {disadvantage}

### {Option 2}

{Brief description of the option.}

- Good, because {advantage}
- Bad, because {disadvantage}

### {Option 3}

{Brief description of the option.}

- Good, because {advantage}
- Bad, because {disadvantage}

## More Information

- {Link to related ADR, e.g., "[ADR-001: Database Choice](001-database-choice.md)"}
- {Link to design doc, RFC, or discussion}
- {Date decided, who participated}
```

## When to Use
- Decisions affecting multiple teams or components
- Technology choices with long-term commitment
- Trade-offs that future developers will question
- Decisions where the rejected alternatives matter
