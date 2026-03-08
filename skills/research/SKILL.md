---
name: research
description: Deep research phase that produces a structured research brief before brainstorming or PRD creation. Use this skill when starting a new feature that needs competitive analysis, technical landscape review, or stakeholder research before designing. Trigger when user says "research this", "what's out there for", "investigate options for", or before any major new initiative.
argument-hint: "[research topic or feature idea]"
---

# Research: Deep Investigation → Structured Brief

**Philosophy:** Great designs start with great research. Spend time understanding the landscape before committing to an approach. Research is cheap; rework is expensive.

## Core Principles

1. **Breadth before depth** — Survey the landscape, then drill into what matters
2. **Evidence-rated findings** — Every finding gets a confidence level (strong/moderate/weak)
3. **Source tracking** — All findings traceable to sources
4. **Structured output** — Research brief feeds directly into brainstorm or PRD
5. **Time-boxed** — Research supports decisions, it doesn't replace them
6. **Domain-classified** — Output includes domain classification for downstream skills

---

## Trigger Conditions

Run this skill when:
- Starting a major new feature or initiative
- User wants competitive/market analysis before designing
- Technical landscape needs surveying (frameworks, patterns, tools)
- User says "research this first", "what options exist for..."
- Before brainstorm when the problem space is unfamiliar

---

## Persistent Context Files

Create these files at the start and update throughout:

```
${PROJECT_ROOT}/docs/research/{feature}/
├── research-brief.md    # Final output
├── findings.md          # Accumulates notes during research
├── sources.md           # All sources with reliability ratings
└── progress.md          # Phase completion tracking
```

Initialize `progress.md`:
```markdown
# Research Progress: {Feature}

- [ ] Phase 1: Scope Definition
- [ ] Phase 2: Competitive & Market Analysis
- [ ] Phase 3: Technical Landscape
- [ ] Phase 4: Stakeholder & User Research
- [ ] Phase 5: Synthesis
- [ ] Phase 6: Research Brief Output
```

Update `findings.md` after every research activity — this is your working memory across context windows.

---

## Critical Sequence

### Phase 0: Prerequisites

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
mkdir -p "${PROJECT_ROOT}/docs/research/{feature}"
```

Check for existing research:
```bash
ls "${PROJECT_ROOT}/docs/research/"
ls "${PROJECT_ROOT}/docs/learnings/"
```

---

### Phase 1: Research Scope Definition

**Step 1.1 — Define Research Questions:**
Ask the user: **"What decisions will this research help you make?"**

Structure as 3-5 key questions:
```markdown
## Research Questions
1. {What problem are we solving and for whom?}
2. {What solutions already exist?}
3. {What technical approaches are viable?}
4. {What constraints should we know about?}
5. {What risks should we investigate?}
```

**Step 1.2 — Set Research Boundaries:**
```markdown
## Research Scope
- **In scope:** {what to investigate}
- **Out of scope:** {what to skip}
- **Time budget:** {estimated research effort}
- **Decision this supports:** {what we're trying to decide}
```

**Step 1.3 — Identify Research Sources:**
```markdown
## Planned Sources
| Source Type | Where to Look | Priority |
|-------------|---------------|----------|
| Existing docs | docs/reference/, docs/systems/, docs/learnings/ | High |
| Codebase | Existing patterns, similar features | High |
| Competitors | {specific competitors or similar products} | Medium |
| Technical docs | Framework docs, library docs, API docs | Medium |
| Community | GitHub repos, blog posts, conference talks | Low |
```

---

### Phase 2: Competitive & Market Analysis

**Step 2.1 — Identify Existing Solutions:**

For each competitor/alternative:
```markdown
### {Solution Name}
- **What it does:** {1-2 sentences}
- **How it solves the problem:** {approach}
- **Strengths:** {what it does well}
- **Weaknesses:** {gaps or limitations}
- **Relevance to us:** {what we can learn}
- **Source:** {link or reference}
- **Confidence:** Strong / Moderate / Weak
```

**Step 2.2 — Pattern Recognition:**
- What approaches do most solutions share?
- Where do they diverge?
- What gaps exist that none address?

Append all findings to `findings.md` with timestamps.

---

### Phase 3: Technical Landscape

**Step 3.1 — Framework & Library Survey:**

Research available frameworks, libraries, and patterns:
```markdown
### {Framework/Library/Pattern}
- **Purpose:** {what it provides}
- **Maturity:** Established / Growing / Experimental
- **Community:** Active / Moderate / Minimal
- **Fit with our stack:** {.NET/C# compatibility}
- **Trade-offs:** {pros vs cons}
- **Source:** {docs link}
- **Confidence:** Strong / Moderate / Weak
```

**Step 3.2 — Codebase Pattern Research (Parallel Agents):**

| Agent | Research Focus |
|-------|----------------|
| `Explore` | "How does {similar feature} work in this codebase?" |
| `Explore` | "What patterns exist for {relevant area}?" |

**Step 3.3 — Architecture Constraints:**
- What does our current architecture support?
- What would require significant changes?
- What patterns from `docs/architecture/` apply?

---

### Phase 4: Stakeholder & User Research

**Step 4.1 — User Needs Analysis:**
Ask the user: **"Who will use this and what's their current workflow?"**

```markdown
### User Personas Identified
| Persona | Need | Current Workaround | Pain Level |
|---------|------|-------------------|------------|
| {role} | {need} | {how they cope} | High/Med/Low |
```

**Step 4.2 — Existing Documentation Review:**

```bash
grep -r "{keywords}" "${PROJECT_ROOT}/docs/learnings/"
grep -r "{keywords}" "${PROJECT_ROOT}/docs/reference/"
grep -r "{keywords}" "${PROJECT_ROOT}/docs/systems/"
```

Document what existing docs tell us about this problem space.

**Step 4.3 — Constraints & Requirements Signals:**
- Regulatory or compliance needs?
- Performance requirements?
- Integration requirements?
- Timeline pressures?

---

### Phase 5: Synthesis

**Consolidate findings.md into a coherent picture.**

**Step 5.1 — Theme Extraction:**
Group findings into 3-5 major themes:
```markdown
## Research Themes

### Theme 1: {Name}
**Finding:** {what we learned}
**Evidence:** {sources supporting this}
**Confidence:** Strong / Moderate / Weak
**Implication:** {what this means for our design}

### Theme 2: {Name}
...
```

**Step 5.2 — Answer Research Questions:**
Go back to Phase 1 questions and answer each with evidence.

**Step 5.3 — Identify Gaps & Risks:**
```markdown
## Open Questions
- {things we couldn't answer}

## Identified Risks
| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {risk} | High/Med/Low | High/Med/Low | {approach} |
```

---

### Phase 6: Domain Classification

**Based on research findings, classify the feature's domain(s).**

```markdown
## Domain Classification

Based on research findings, this feature primarily touches:
- [ ] Identity/Auth — authentication, authorization, user management, OIDC
- [ ] Data Platform — data curation, modeling, computed values, MCP
- [ ] Mobile/EHS — offline-first, inspections, sync, field operations
- [ ] General SaaS — multi-tenancy, billing, onboarding, administration

Primary domain: {domain}
Secondary domain(s): {if applicable}

Recommended references for downstream skills:
- _shared/references/{domain}.md
```

This classification feeds into brainstorm's scope classifier and discovery's domain detection.

---

### Phase 7: Research Brief Output

Write `research-brief.md`:

```markdown
# Research Brief: {Feature Name}

> Research completed {date}. This brief feeds into brainstorm or PRD.

## Executive Summary
{3-5 sentences: what we researched, key findings, recommendation}

## Research Questions & Answers
| Question | Answer | Confidence |
|----------|--------|------------|
| {from Phase 1} | {finding} | Strong/Moderate/Weak |

## Key Findings
### 1. {Finding}
{Evidence and implications}

### 2. {Finding}
{Evidence and implications}

## Competitive Landscape
| Solution | Approach | Strengths | Gaps |
|----------|----------|-----------|------|
| {name} | {how} | {good} | {missing} |

## Technical Options
| Option | Fit | Maturity | Trade-offs |
|--------|-----|----------|------------|
| {tech} | {fit} | {level} | {trade-offs} |

## User Insights
{Key user needs and pain points}

## Risks & Open Questions
{Unresolved items for brainstorm/PRD to address}

## Domain Classification
{Primary domain, secondary domains, recommended references}

## Recommendation
{Suggested direction based on evidence}

## Sources
{Complete source list from sources.md}

---
*Research completed: {date}*
*Feeds into: /brainstorm or /prd*
```

---

### Present to User

```markdown
## Research Complete

**Topic:** {feature}
**Key findings:** {count}
**Sources consulted:** {count}
**Confidence level:** High / Medium / Low

Research brief saved to: `docs/research/{feature}/research-brief.md`

Ready for next step:
1. "start brainstorm" → Run /brainstorm with research context
2. "start prd" → Run /prd with research context
3. "more research" → Investigate specific areas deeper
4. "park" → Save for later
```

---

## Exit Signals

| Signal | Meaning |
|--------|--------|
| "research complete" | Proceed to brainstorm or PRD |
| "start brainstorm" | Proceed to /brainstorm |
| "start prd" | Proceed to /prd |
| "more research" | Continue investigating |
| "park" | Save for later |

---

*Skill Version: 2.0*
*Added in v2: Domain classification phase*
