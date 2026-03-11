---
name: research
description: >
  Deep research phase that produces a structured research brief through
  systematic investigation. Surveys the landscape, evaluates options, and
  synthesises findings with source attribution and confidence ratings.
  Output feeds directly into brainstorm or PRD. Use when starting a new
  feature that needs competitive analysis, technical landscape review, or
  prior art investigation. Trigger when user says "research this",
  "what's out there for", "investigate options for", or before any major
  new initiative where the problem space is unfamiliar.
argument-hint: "[research topic or feature idea]"
---

# Research: Deep Investigation → Structured Brief

**Philosophy:** Great designs start with great research. Understanding the landscape before committing to an approach is cheap — rework after a wrong assumption is expensive. Research answers "what exists, what's possible, and what are the constraints?" so that brainstorming and design happen within an informed space, not a vacuum.

## Why This Matters

Without research, teams build features that duplicate existing solutions, choose patterns that don't fit their constraints, or miss risks that surface late in development. A structured research phase prevents three common failures:
- **Reinventing the wheel** — building what already exists as a library, service, or pattern
- **Uninformed design** — choosing an architecture without understanding the trade-offs
- **Late-discovered constraints** — hitting regulatory, performance, or integration limits after implementation starts

Research is the cheapest phase in the pipeline. An hour of research can save weeks of rework.

---

## Trigger Conditions

Run this skill when:
- Starting a major new feature or initiative
- User wants competitive or market analysis before designing
- Technical landscape needs surveying (frameworks, patterns, tools)
- User says "research this first", "what options exist for..."
- Before brainstorm when the problem space is unfamiliar

## Stage Gate Reference
For interactive stage gate patterns used at PAUSE points: `../_shared/references/stage-gates.md`
If `AskUserQuestion` is unavailable, fall back to presenting options as markdown text and waiting for freeform response.

Do NOT run when:
- The answer is likely in the existing codebase or project docs — check there first
- The question is a simple fact check answerable from official docs in one search
- The user just needs a quick opinion, not evidence-backed analysis

---

## Mode Selection

| Mode | When | Effort | Output |
|------|------|--------|--------|
| **BRIEF** | Quick fact check, single library comparison, focused question | 3-10 searches | Findings appended to conversation, no file output |
| **STANDARD** | Typical feature research, technology evaluation, competitive scan | 15-30 searches | `research-brief.md` in `docs/research/{feature}/` |
| **COMPREHENSIVE** | Major initiative, architecture decision, unfamiliar domain | 30-50+ searches | Full research directory with brief, findings, and sources |

BRIEF mode skips file creation — findings are presented directly in conversation. Use when the user needs a quick answer, not a persistent document.

---

## Collaborative Model

```
Phase 1: Scope Definition
  ── PAUSE 1 (STANDARD+ only): "Here are the research questions. Right scope?" ──
Phase 2: Investigation (parallel where possible)
  ── Budget checkpoint at 70%: enough to synthesize? ──
Phase 3: Reflection & Gap Analysis
Phase 4: Synthesis & Brief
  ── PAUSE 2: "Research complete. Review findings?" ──
```

---

## Prerequisites

**Step 0 — Check Internal Sources First:**

Before web research, check internal sources — the cheapest research is the research you don't have to do:

- **Prior research** — `docs/research/{feature}/` (check for existing research brief to build on, not duplicate)
- **Learnings** — `docs/learnings/` (past gotchas, patterns, and context gaps relevant to this topic)
- **ADRs** — `docs/adr/` (existing architecture decisions that constrain options — tag as [CONSTRAINT])
- **Patterns** — `docs/patterns/` (established conventions that inform what's already solved — tag as [PRIOR-ART])
- **Existing codebase** — similar features or patterns already in use

If the answer is found in internal sources, present it directly — no web research needed.

---

## Critical Sequence

### Phase 1: Scope Definition

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
- **Decision this supports:** {what we're trying to decide}
```

**Step 1.3 — Plan Sources:**

| Source Type | When to Use | Reliability |
|-------------|------------|-------------|
| Official documentation, RFCs, source code | Always check first | Highest |
| Engineering blogs (Anthropic, Google, etc.) | Architecture and pattern research | High |
| Existing codebase patterns | When extending current system | High |
| Project docs and learnings | When prior decisions exist | High |
| Existing ADRs and patterns (`docs/adr/`, `docs/patterns/`) | Before web research — surfaces constraints | High |
| Academic papers, conference talks | Novel or complex problems | High |
| GitHub repos (stars, activity, issues) | Library evaluation | Medium |
| Community discussions (SO, forums) | Gotchas and real-world experience | Medium |
| Tutorial sites, aggregator blogs | Background understanding | Lower |

**PAUSE 1 (STANDARD+ only):** Present research questions and scope as formatted markdown (from Steps 1.1-1.3 above).

Then use AskUserQuestion (Decision Gate — Pattern 1):
```
AskUserQuestion:
  question: "Are these the right research questions?"
  header: "Scope"
  multiSelect: false
  options:
    - label: "Looks good (Recommended)"
      description: "Research questions and scope are correct. Proceed to investigation."
    - label: "Add questions"
      description: "I have additional questions to investigate."
    - label: "Narrow scope"
      description: "Some questions are out of scope or unnecessary."
```

BRIEF mode: skip this pause — the user asked a question, go answer it.

---

### Phase 2: Investigation

**Step 2.1 — Calibrate Effort & Set Budget:**

| Research Type | Search Budget | Depth |
|---------------|--------------|-------|
| Quick fact check | 3-5 searches | Find confirmed answer from reliable source |
| Library/tool comparison | 10-20 searches | Pros/cons for top 3 options with sources |
| Architecture decision | 20-40 searches | 2-3 viable patterns with trade-off analysis |
| Competitive landscape | 30-50 searches | Structured comparison matrix, 5+ entries |

Allocate your budget: **~70% on initial investigation, ~30% reserved for gap-filling in Phase 3.** Check progress at the 70% mark — if you have enough to synthesize, move to Phase 3 rather than exhausting the budget.

**Step 2.2 — Search Query Construction:**

AI agents default to vague queries that return generic results. Construct specific queries:

- **Add specificity:** "graphql relay cursor pagination vs offset tradeoffs" not "best pagination library"
- **Add date constraints:** append "2025" or "2026" for technology decisions
- **Search the counter-case:** for every "X benefits", also search "X problems", "X limitations", "X alternatives"
- **Use domain terms:** the exact terminology the technology uses, not paraphrases
- **Search error patterns:** "{library} common issues", "{pattern} gotchas", "{tool} migration pain"

**Step 2.3 — Competitive & Prior Art Analysis:**

For each competitor or existing solution:
```markdown
### {Solution Name}
- **What it does:** {1-2 sentences}
- **Approach:** {how it solves the problem}
- **Strengths:** {what it does well}
- **Weaknesses:** {gaps or limitations}
- **Relevance:** {what we can learn or adopt}
- **Source:** {link, publication date}
- **Confidence:** Strong / Moderate / Weak
```

Apply the build/buy/adopt/accept framework:
- **Accept** the current state if research reveals the problem isn't worth solving
- **Adopt** if an existing solution meets 80%+ of requirements
- **Adapt** if a solution meets 60-80% and can be extended
- **Build** only if nothing meets core requirements

"Accept" is the research equivalent of brainstorm's "Do Less" — sometimes the right answer is to not build anything.

**Step 2.4 — Technical Landscape:**

For each framework, library, or pattern:
```markdown
### {Framework/Library/Pattern}
- **Purpose:** {what it provides}
- **Maturity:** Established / Growing / Experimental
- **Community:** Active / Moderate / Minimal
- **Fit:** {compatibility with project constraints}
- **Trade-offs:** {pros vs cons}
- **Source:** {docs link, publication date}
- **Confidence:** Strong / Moderate / Weak
```

**Step 2.5 — Import User Context:**

Pull user and stakeholder context from upstream artifacts or the current conversation — do not re-interview the user for information they've already provided.

```markdown
### User Context
| Persona | Need | Current Workaround | Pain Level |
|---------|------|-------------------|------------|
| {role} | {need} | {how they cope} | High/Med/Low |
```

If no upstream context exists and user context is unclear, ask ONE focused question: **"Who will use this and what's their biggest pain today?"**

Note constraints: regulatory, performance, integration, timeline.

---

### Phase 3: Reflection & Gap Analysis

After initial investigation, evaluate coverage:

**Step 3.1 — Check Against Research Questions:**

For each research question from Phase 1:
- Answered with evidence? → Move on
- Partially answered? → Target follow-up searches from the 30% reserve budget
- Unanswered? → Flag as gap or explicitly unanswerable

**Step 3.2 — Verify Key Claims:**

For major findings, apply triangulation:
- Is this confirmed by at least 2 independent sources?
- Have you searched for the counter-case? ("problems with X", "X limitations")
- Are sources recent enough for technology decisions?

**Step 3.3 — Surface Conflicts:**

When sources disagree, present both sides:
```markdown
### Conflicting Information
**Topic:** {what they disagree about}
**Position A:** {source and claim}
**Position B:** {source and claim}
**Likely explanation:** {different contexts, scale, recency}
**Recommendation:** {which applies to our situation and why}
```

**Step 3.4 — Iterate if Needed:**

Use remaining search budget for targeted gap-filling. Do not start new investigation threads — only fill gaps in existing questions. If the budget is exhausted, flag remaining gaps as [UNKNOWN] and move to synthesis.

---

### Phase 4: Synthesis & Brief

**Step 4.1 — Extract Themes:**

Group findings into 3-5 major themes:
```markdown
### Theme: {Name}
**Finding:** {what we learned}
**Evidence:** {sources}
**Confidence:** Strong / Moderate / Weak
**Implication:** {what this means for our design}
```

**Step 4.2 — Tag Findings for Downstream Use:**

Tag each finding by how downstream skills should use it:
- **[CONSTRAINT]** — hard limits that requirements must respect
- **[OPTION]** — viable approaches for brainstorming
- **[RISK]** — threats to flag during design
- **[PRIOR-ART]** — existing solutions to adopt or adapt
- **[UNKNOWN]** — gaps requiring spike or prototype to resolve

**Tag validation:** Every finding must have at least one tag. The complete set should include at least one [OPTION] (otherwise research found nothing actionable) and at least one [RISK] (otherwise research wasn't critical enough).

**Step 4.3 — Write Research Brief (STANDARD+):**

Create `${PROJECT_ROOT}/docs/research/{feature}/research-brief.md`:

```markdown
# Research Brief: {Feature Name}

> Research completed {date}. This brief feeds into /brainstorm or /prd.

## Executive Summary
{3-5 sentences: what we researched, key findings, recommendation}

## Recommendation
{Suggested direction based on evidence. Max 3 recommendations, prioritised.
This is the most important section for downstream consumers — put it early.}

## Risks & Open Questions
| Risk/Unknown | Likelihood | Impact | Tag |
|-------------|-----------|--------|-----|
| {risk} | High/Med/Low | High/Med/Low | [RISK] |
| {unknown} | — | — | [UNKNOWN] |

## Research Questions & Answers
| Question | Answer | Confidence | Tag |
|----------|--------|------------|-----|
| {from Phase 1} | {finding} | Strong/Moderate/Weak | [OPTION] |

## Key Findings

### 1. {Finding Title}
{Evidence and implications. Source attribution.}

### 2. {Finding Title}
{Evidence and implications.}

## Competitive Landscape
| Solution | Approach | Strengths | Gaps | Verdict |
|----------|----------|-----------|------|---------|
| {name} | {how} | {good} | {missing} | Accept/Adopt/Adapt/Build |

## Technical Options
| Option | Fit | Maturity | Trade-offs |
|--------|-----|----------|------------|
| {tech} | {fit} | {level} | {trade-offs} |

## Conflicting Information
{From Phase 3.3, if any}

## Sources
| # | Source | Type | Date | Reliability |
|---|--------|------|------|-------------|
| 1 | {title/link} | {official/blog/academic/community} | {date} | {highest/high/medium/lower} |

---
*Research completed: {date}*
*Feeds into: /brainstorm or /prd*
```

**PAUSE 2:** Present the research brief summary as formatted markdown (executive summary, recommendation, key findings count, source count, and file path).

Then use AskUserQuestion (Combined Gate — Pattern 4):
```
AskUserQuestion:
  questions:
    - question: "Do the research findings address your original questions?"
      header: "Findings"
      multiSelect: false
      options:
        - label: "Complete (Recommended)"
          description: "All research questions are adequately answered."
        - label: "Gaps remain"
          description: "Some questions aren't fully answered."
        - label: "Need deeper dive"
          description: "Key areas need more investigation."
    - question: "What should we do next?"
      header: "Next step"
      multiSelect: false
      options:
        - label: "Start brainstorm (Recommended)"
          description: "Move to /brainstorm with research context."
        - label: "Start PRD"
          description: "Skip brainstorm, go straight to requirements."
        - label: "More research"
          description: "Return to Phase 2 for additional investigation."
        - label: "Park"
          description: "Save research brief for later."
```

---

## Source Credibility Assessment

| Confidence | Criteria |
|------------|----------|
| **Strong** | 3+ independent primary sources agree. Official docs or original research. Counter-case searched with no contradictions found. |
| **Moderate** | 2 independent sources agree. Expert blog or well-regarded community source. No contradicting evidence found. |
| **Weak** | Single source, or community-only sources. No independent verification. May be outdated or context-specific. |

Always note publication dates on sources. For technology decisions, sources older than 18 months should be treated with caution — frameworks and libraries evolve rapidly.

---

## BRIEF Mode

For BRIEF research (quick question, single comparison):

1. Clarify the question (no PAUSE — just confirm understanding inline)
2. Check internal sources first (codebase, project docs, learnings)
3. Run 3-10 targeted web searches if internal sources are insufficient
4. Present findings directly in conversation with source attribution
5. No file output unless user requests it

Example: "What pagination libraries exist for GraphQL?" → quick survey, present top 3 with trade-offs, done.

---

## Anti-Patterns

**The First-Result Trap** — Accepting the first search result as the answer without verification. Always triangulate major claims across 2+ independent sources, and search for the counter-case.

**Analysis Paralysis** — Research that never concludes because there's always more to investigate. Set a search budget upfront and check progress at the 70% mark. Research informs decisions — it doesn't make them.

**Confirmation Bias** — Only searching for evidence that supports a preferred approach. Actively search for limitations, failures, and alternatives to the leading option.

**Source Laundering** — Multiple sources that all cite the same original source don't count as independent verification. Trace claims back to primary sources. Two blog posts summarizing the same conference talk are one source, not two.

**The Comprehensive BRIEF** — Running a full investigation for a quick library comparison. Match effort to decision impact — not every question needs a research brief.

**Stale Sources** — Citing a 2022 blog post about a framework that has had 3 major versions since. Always check publication dates and verify against current documentation.

**Vague Queries** — Searching "best database" instead of "postgresql vs cockroachdb multi-tenant isolation 2025". Specific queries with domain terms and date constraints return actionable results; vague queries return listicles.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "research complete" | Proceed | /brainstorm or /prd |
| "start brainstorm" | Move to brainstorming | /brainstorm with research context |
| "start prd" | Skip brainstorm | /prd with research context |
| "more research" | Investigate deeper | Return to Phase 2 |
| "park" | Save for later | Archive research brief |

---

*Skill Version: 3.5*
*v3.5: Prerequisites modernized from bash scripts to prose-based artifact import. Internal source check expanded with docs/adr/ and docs/patterns/ (tag as [CONSTRAINT] and [PRIOR-ART]). Source planning table updated.*
*v3.4: PAUSE points use AskUserQuestion tool — Decision Gate for scope confirmation, Combined Gate for research completion (findings review + next step routing)*
*v3.1: Search query construction guidance, PAUSE 1 conditional on STANDARD+, budget checkpoints (70/30 split), "Accept" option in build/buy/adopt, import user context instead of re-interviewing, recommendation and risks promoted in brief template, tightened confidence calibration (3+/2/1 sources), tag validation, "do not run" guidance, vague queries anti-pattern*
