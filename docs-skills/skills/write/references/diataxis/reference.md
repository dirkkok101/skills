# Reference Template

A reference is an **information-oriented** technical description of the system. The reader needs to look up specific facts — APIs, configuration, parameters.

## Key Characteristics
- Reader knows what they're looking for and needs accurate details
- Structure mirrors the code or system structure (not the user's journey)
- Austere and consistent — no tutorials or opinions
- Complete and accurate — covers everything, not a "getting started" subset
- Uses tables, type signatures, parameter lists

## Template

```markdown
# {Component/API/Module} Reference

{1-sentence description of what this reference covers.}

## Overview

{Brief description of the component's purpose and scope.}

## {Section matching code structure}

### `{function/method/endpoint}`

{Brief description.}

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `{name}` | `{type}` | {yes/no} | {description} |

**Returns:** `{type}` — {description}

**Example:**

\`\`\`{language}
{minimal usage example}
\`\`\`

### `{next function/method/endpoint}`

{Continue pattern...}

## Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `{key}` | `{type}` | `{default}` | {description} |

## See Also

- {Link to tutorial for getting started}
- {Link to how-to for common tasks}
```

## Anti-Patterns
- ❌ Mixing instructions or opinions into reference material
- ❌ Organizing by user workflow instead of code structure
- ❌ Incomplete coverage (documenting only "important" parts)
- ❌ Missing types, defaults, or return values
