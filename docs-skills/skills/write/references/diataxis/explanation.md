# Explanation Template

An explanation is an **understanding-oriented** discussion that clarifies and illuminates a topic. The reader wants to understand why things work the way they do.

## Key Characteristics
- Reader wants context, background, and reasoning — not steps to follow
- Discusses alternatives, trade-offs, and design decisions
- Can reference history, constraints, and connections between concepts
- No steps to follow — this is about thinking, not doing
- Named with "About", "Understanding", or topic nouns

## Template

```markdown
# {Understanding/About} {Topic}

{Opening paragraph establishing what this topic is and why it matters.}

## Background

{Historical context or problem that led to this approach.}

## How {Topic} Works

{Clear explanation of the mechanism or concept. Use diagrams if helpful.}

## Why {This Approach}

{Decision drivers, trade-offs considered, and rationale for the current design.}

## Alternatives

{Other approaches considered and why they were not chosen.}

| Approach | Pros | Cons |
|----------|------|------|
| {Current} | {pros} | {cons} |
| {Alternative} | {pros} | {cons} |

## Implications

{Consequences of this design — what it enables and what it constrains.}

## Related

- {Link to how-to for practical application}
- {Link to reference for technical details}
- {Link to ADR if a formal decision was recorded}
```

## Anti-Patterns
- ❌ Including step-by-step instructions (that's a how-to or tutorial)
- ❌ Listing facts without connecting them to meaning
- ❌ Avoiding opinions or trade-offs — explanations should take a position
- ❌ Writing without a clear "why" thread running through the document
