# Tutorial Template

A tutorial is a **learning-oriented** lesson that takes the reader through a series of steps to complete a project. The reader learns by doing.

## Key Characteristics
- Reader has no prior experience with the topic
- Steps are concrete and repeatable — the reader follows along
- Focuses on what the reader DOES, not what they need to understand
- Ends with a working result the reader can see
- Avoids explanations and choices — just guide them through

## Template

```markdown
# Tutorial: {Title}

Learn to {outcome} by building {concrete thing}.

## Prerequisites

- {Tool or account needed}
- {Prior knowledge assumed}

## What You'll Build

{1-2 sentences describing the end result. Include a screenshot or diagram if possible.}

## Step 1: {Action verb} {thing}

{Brief context for why this step exists.}

{Exact command or action:}

\`\`\`bash
{command}
\`\`\`

{Expected result:}
> You should see {output}

## Step 2: {Action verb} {thing}

{Continue pattern...}

## Step N: Verify It Works

{Final verification that the tutorial succeeded.}

## Next Steps

- {Link to related how-to guide}
- {Link to reference for deeper understanding}
```

## Anti-Patterns
- ❌ Offering choices ("you could use X or Y") — pick one, guide them through it
- ❌ Explaining theory before the reader has done anything
- ❌ Skipping verification steps — reader must see results
- ❌ Assuming knowledge not listed in prerequisites
