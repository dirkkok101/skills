# Stage Gate Patterns — AskUserQuestion

At every PAUSE point, **call the `AskUserQuestion` tool** — do not present options as plain markdown text. The YAML blocks in each skill show the exact parameters to pass to the tool. This is not pseudocode or documentation — these are tool call specifications.

## When to Use AskUserQuestion

Use at **decision gates and review checkpoints** — points where the user must approve, select, or validate before work continues. Do NOT use for informational status updates (those stay as regular markdown prose).

## Fallback

Only if `AskUserQuestion` is genuinely not available as a tool in your environment (e.g., Claude.ai, older Claude Code versions without the tool), fall back to the prose-based pattern: present content as markdown, list options as text, and wait for freeform response. If you are unsure whether the tool is available, attempt to call it — do not pre-emptively fall back.

---

## Pattern 1: Decision Gate

**Use for:** Approval gates, routing decisions, triage outcomes.

Single-select question with 2-4 options. Put the recommended option first with "(Recommended)" suffix.

Call the tool with these parameters:

```
AskUserQuestion:
  question: "Is the problem framing correct?"
  header: "Problem"       # max 12 chars
  multiSelect: false
  options:
    - label: "Accept (Recommended)"
      description: "Root problem and user journey are correct. Proceed to Phase 2."
    - label: "Redirect"
      description: "This is a symptom, not the root cause. Iterate on problem definition."
    - label: "Clarify"
      description: "Need more context before confirming."
```

The user always has "Other" available for freeform input.

**Multiple decisions in one gate:** Use up to 4 questions per call when decisions are independent. Example: PRD PAUSE 4 asks about acceptance criteria confidence AND assumption validity AND Won't Have comfort — all three can be asked simultaneously.

---

## Pattern 2: Comparison Gate

**Use for:** Choosing between approaches, architectures, or strategies where the user needs to see concrete detail for each option.

Single-select question with `preview` fields showing the actual content being compared. The UI renders a side-by-side layout — options on the left, preview content on the right.

```
AskUserQuestion:
  question: "Which approach should we take?"
  header: "Approach"
  multiSelect: false
  options:
    - label: "Approach A"
      description: "Event-driven with message queue. Medium complexity."
      preview: |
        ### Approach A: Event-Driven
        **Core idea:** Async event bus with message queue
        **Pros:** Decoupled, scalable, resilient
        **Cons:** Eventual consistency, harder debugging
        **Complexity:** Medium
        **Biggest risk:** Message ordering in edge cases
    - label: "Approach B"
      description: "Direct service calls with circuit breaker. Low complexity."
      preview: |
        ### Approach B: Direct Calls
        **Core idea:** Synchronous calls with retry/circuit breaker
        **Pros:** Simple, immediate consistency
        **Cons:** Tight coupling, cascading failures
        **Complexity:** Low
        **Biggest risk:** Cascading failure under load
    - label: "Do Less"
      description: "Use existing notification system. Minimal change."
      preview: |
        ### Approach C: Do Less
        **Core idea:** Extend current notification system
        **When right:** If volume stays under 1K/day
        **Pros:** No new infrastructure
        **Cons:** Doesn't scale past current limits
```

**Note:** Previews only work with single-select (not multi-select). Use Pattern 2 when the user needs to visually compare options side-by-side.

---

## Pattern 3: Batch Review

**Use for:** Reviewing batches of items (requirements, tasks, beads, actors, constraints) where the user needs to see full detail and flag specific items for revision.

**Two-step process:**

1. **Present full detail** as formatted markdown BEFORE calling AskUserQuestion. Include everything the user needs to make informed decisions — acceptance criteria, context, rationale.

2. **Ask via multi-select** which items need revision. Unselected items are approved as-is.

```markdown
## Requirements Batch 1 of 3

### FR-APP-REGISTER: Register New Application
**Priority:** Must Have | **Complexity:** M
As a facility admin, I want to register a new application...
**Acceptance Criteria:**
- Given valid form data, When submitted, Then application is created
- Given duplicate name, When submitted, Then error shown with suggestion

### FR-APP-EDIT: Edit Application Details
**Priority:** Must Have | **Complexity:** S
As a facility admin, I want to edit application details...
**Acceptance Criteria:**
- Given an existing application, When details updated, Then changes persisted
- Given concurrent edit, When saved, Then conflict resolution shown

### FR-APP-SEARCH: Search Applications
**Priority:** Should Have | **Complexity:** M
As a facility admin, I want to search applications...
**Acceptance Criteria:**
- Given search term, When submitted, Then matching results shown within 200ms
- Given no results, When search complete, Then helpful empty state shown
```

Then:

```
AskUserQuestion:
  question: "Which requirements need revision? (Unselected items are approved as-is)"
  header: "FR Review"
  multiSelect: true
  options:
    - label: "FR-APP-REGISTER"
      description: "Register New Application — Must Have, complexity M"
    - label: "FR-APP-EDIT"
      description: "Edit Application Details — Must Have, complexity S"
    - label: "FR-APP-SEARCH"
      description: "Search Applications — Should Have, complexity M"
```

**Batch sizing:** Max 4 options per question, so present items in batches of 3-4. If more items exist, use multiple batches (sequential AskUserQuestion calls). The user can always select "Other" to provide freeform notes.

For items flagged for revision, ask a follow-up question or read the user's notes from the "Other" field to understand what needs changing.

---

## Pattern 4: Combined Gate

Some stage gates combine a review with a routing decision. Use up to 4 questions per call to handle these efficiently.

Example — Discovery PAUSE 3 (review + routing):

```
AskUserQuestion:
  questions:
    - question: "Are all actors and domain requirements complete?"
      header: "Completeness"
      multiSelect: false
      options:
        - label: "Complete (Recommended)"
          description: "All actors, workflows, and domain requirements are captured."
        - label: "Missing actors"
          description: "There are actors or roles not yet mapped."
        - label: "Missing requirements"
          description: "Some domain areas need deeper investigation."
    - question: "What should we do next?"
      header: "Next step"
      multiSelect: false
      options:
        - label: "Start PRD (Recommended)"
          description: "Discovery is sufficient. Proceed to formal requirements."
        - label: "Go deeper"
          description: "Investigate additional areas before moving to PRD."
        - label: "Park"
          description: "Save discovery findings for later."
```

---

## Pattern 5: Guided Review Workflow

**Use for:** Walking the user through a review of a large document section by section, so they don't miss anything. This is the primary pattern for PRD review, plan review, design review, and bead review.

The key idea: instead of presenting the entire document and asking "does this look right?", break it into logical sections and walk the user through each one with focused questions. The agent controls the pace, the user provides focused feedback.

**Structure:**

```
Step 1: Present Section A with full detail (markdown)
        → AskUserQuestion: "How does this section look?" [Approved / Needs revision]
        → If "Needs revision": collect notes, iterate on this section

Step 2: Present Section B with full detail (markdown)
        → AskUserQuestion: "How does this section look?" [Approved / Needs revision]
        → If "Needs revision": collect notes, iterate

Step 3: ... repeat for each section ...

Final:  AskUserQuestion (Combined Gate):
        → "All sections reviewed. Ready to proceed?" [Approve / Revisit specific section]
        → "Which step next?" [routing options]
```

**Example — PRD guided review:**

```
## Reviewing: Problem Statement & Goals

### Problem Statement
{full problem statement text}

### Goals
- {goal 1}
- {goal 2}

### Non-Goals
- {non-goal 1}
```

```
AskUserQuestion:
  question: "Does the problem statement accurately describe the pain? Are goals measurable?"
  header: "Problem"
  multiSelect: false
  options:
    - label: "Approved"
      description: "Problem framing, goals, and non-goals are correct."
    - label: "Needs revision"
      description: "Something needs changing — I'll provide notes."
    - label: "Skip for now"
      description: "Come back to this section later."
```

Then move to the next section (Personas, Assumptions, etc.).

**When to use guided review vs batch review:**

| Situation | Pattern |
|-----------|---------|
| Items needing individual review (FRs, design decisions) | **Guided Review** (Pattern 5) — one at a time with approve/revise/remove |
| Large document with distinct sections | **Guided Review** (Pattern 5) — walk through sequentially |
| Long list needing quick triage (tasks, beads, constraints) | **Batch Review** (Pattern 3) — multi-select to flag |
| Homogeneous items where detail per item is minimal | **Batch Review** — flag and move on |

**Why this matters:** Users miss things in long documents. By controlling the pace and focusing attention on one section at a time, the agent ensures every section gets genuine review. The user can "Skip for now" any section and return to it later, but they can't accidentally skip something by scrolling past it.

---

## Guidelines

### Do

- Present detailed content as markdown BEFORE calling AskUserQuestion — the tool captures decisions, not content
- Put the recommended option first with "(Recommended)" suffix
- Use descriptions to explain consequences of each choice
- Use previews for side-by-side comparison of approaches or architectures
- Batch independent decisions into a single AskUserQuestion call (up to 4 questions)
- Use multi-select when items are independently reviewable (requirements, tasks, constraints)

### Don't

- Don't use AskUserQuestion for status updates or informational pauses
- Don't put long content in option descriptions — that's what previews (Pattern 2) or pre-presentation (Pattern 3) are for
- Don't use previews with multi-select (not supported)
- Don't create more than 4 options per question — use "Other" as the escape hatch for edge cases
- Don't use AskUserQuestion when the skill is running autonomously (e.g., execute phase between beads)
