---
name: discovery
description: >
  Deep requirements elicitation between brainstorm and PRD through structured
  dialogue. Maps actors and workflows, walks domain-specific checklists,
  analyses integrations and security, and produces a discovery brief that feeds
  directly into PRD. Use after brainstorm for complex features, when user says
  'discover requirements', 'deep dive', 'requirements elicitation', or when
  brainstorm scope classifier recommends COMPREHENSIVE.
argument-hint: "[feature name or brainstorm reference]"
---

# Discovery: Approach → Domain-Aware Requirements

**Philosophy:** The gap between "we picked an approach" (brainstorm) and "we have formal requirements" (PRD) is where complex features fail. Discovery fills that gap with domain-specific depth — mapping every actor, walking every workflow, surfacing every integration point and security concern. Discovery is a working process — the PRD is the authoritative document. Discovery produces a brief that feeds into PRD; the PRD absorbs and formalises discovery's findings.

**Target duration: 2-4 hours** for a typical COMPREHENSIVE discovery. If it's taking longer, you're likely designing instead of discovering — stay at the requirements level.

## Why This Matters

Complex features fail when requirements are discovered during implementation instead of before it. A missing actor, an overlooked integration, or an unidentified compliance requirement can force expensive rework weeks into development. Discovery prevents this by systematically walking through the problem domain before a single line of code is written. The cost of discovery is hours; the cost of missed requirements is weeks.

---

## Trigger Conditions

Run this skill when:
- Brainstorm scope classifier says COMPREHENSIVE
- User says "discover requirements", "deep dive requirements", "requirements elicitation"
- Feature touches auth, multiple user roles, external integrations, or complex UI
- After brainstorm, before PRD, for any non-trivial feature

Do NOT run when:
- Simple CRUD or config change (go straight to PRD or plan)
- Brainstorm scope classifier says BRIEF
- Pure technical refactor with no new requirements

---

## Collaborative Model

```
Phase 1: Actor & Workflow Mapping
  ── Pre-mortem: "Imagine this failed. Why?" ──
  ── PAUSE 1: "Here are the actors, workflows, and early risks. Complete?" ──
Phase 2: Domain Requirements Elicitation
  ── PAUSE 2: "Here are the domain requirements. Scope right?" ──
Phase 3: Integration & UI Analysis
Phase 3b: Security, Compliance, Feasibility & Risk
Phase 4: Synthesis & Brief
  ── PAUSE 3: "Discovery complete. Ready for PRD?" ──
```

---

## Prerequisites

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
mkdir -p "${PROJECT_ROOT}/docs/discovery/{feature}"
```

**Import upstream artifacts:**

```bash
# Brainstorm (primary input)
cat "${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md"

# Research brief (if /research was run)
cat "${PROJECT_ROOT}/docs/research/{feature}/research-brief.md" 2>/dev/null

# Past learnings
ls "${PROJECT_ROOT}/docs/learnings/" 2>/dev/null
```

Extract from brainstorm: problem statement, chosen approach, boundaries, scope classification, **kill criteria**.

Import research findings by tag:
- **[CONSTRAINT]** → note for boundaries
- **[RISK]** → seed for risk register
- **[PRIOR-ART]** → inform domain requirements
- **[UNKNOWN]** → flag for investigation during discovery

If no brainstorm exists, ask user for: feature name, problem statement, chosen approach, key constraints.

**Start the glossary** — create a running glossary of domain terms from the brainstorm. Update it throughout all phases as new terms emerge.

```markdown
## Glossary (living document — update throughout discovery)
| Term | Definition |
|------|-----------|
| {term from brainstorm} | {what it means in this feature's context} |
```

---

## Critical Sequence

### Phase 1: Actor & Workflow Mapping

**Step 1.1 — Identify ALL Actors:**

Not just "users" — enumerate every distinct entity that interacts with this feature.

Ask: **"Who or what interacts with this feature? Think about: human roles, external systems, background processes, other products."**

```markdown
| Actor | Type | Key Actions | Frequency |
|-------|------|-------------|-----------|
| {role} | Human / System / Automated | {what they do} | {how often} |
```

Types:
- **Human**: Named roles from the actual organisation (Tenant Admin, Inspector, Auditor)
- **System**: External systems (Identity Provider, Email Service, Payment Gateway)
- **Automated**: Background jobs, schedulers, event handlers

For each human actor, capture a Jobs-to-be-Done statement:

```markdown
| Actor | Job-to-be-Done |
|-------|----------------|
| {role} | When {situation}, I want to {motivation}, so I can {outcome} |
```

**Step 1.2 — Map Current-State Workflow:**

Ask: **"How does this work TODAY? Walk me through the current process step by step."**

Three starting points:
- **Existing process**: Full workflow exists — map it with ⚠ pain point annotations
- **Partial process**: Workaround, manual process, or related feature exists — map what exists, note where it breaks down
- **Greenfield**: No current process — note this and skip to desired state

```
( Current Trigger )
       |
       v
+------------------+
|  Current Step 1  |  ⚠ pain point
+------------------+
       |
       v
  < Decision? >
   /         \
  Yes         No
  ...         ...
```

A current-state workflow that shows no pain points is either wrong or the feature doesn't need building.

**Step 1.3 — Map Desired-State Workflow:**

Create ASCII workflow diagram showing how the feature SHOULD work:

```
( New Trigger )
       |
       v
+------------------+
|  New Step 1      |  ✓ improvement
+------------------+
```

**Step 1.4 — Gap Analysis:**

```markdown
| Gap | Current | Desired | Impact |
|-----|---------|---------|--------|
| {what changes} | {how it works now} | {how it should work} | {benefit} |
```

**Step 1.5 — Pre-Mortem:**

Ask the user NOW, before domain requirements: **"Imagine this feature shipped and was considered a failure 6 months later. What are the top 3 reasons it failed?"**

Capture responses as early risks. These shape which domain areas to investigate deeply in Phase 2 — a pre-mortem answer about "users couldn't figure out the UI" means UI/UX needs deep investigation, while "the integration was unreliable" means integrations need depth.

**PAUSE 1:** Present actors, workflows, gaps, and pre-mortem risks.
"Here are the actors and workflows I've mapped, plus 3 failure risks from the pre-mortem. Are all actors accounted for? Do the workflows match reality? Do the risks resonate?"

---

### Phase 2: Domain Requirements Elicitation

**Step 2.1 — Identify and Prioritize Domain Areas:**

Based on the feature description, brainstorm, and pre-mortem risks, identify which domain areas need investigation. Common areas include:

- Authentication and authorisation
- Data model and persistence
- User interface and navigation
- Integrations and external systems
- Background processing and async workflows
- Reporting and analytics
- Notifications and communications
- Configuration and administration
- Multi-tenancy and isolation

**Prioritize depth based on the chosen approach:** Which domain areas does the selected approach most affect? Go deep on those. Go shallow (existence check only) on tangential areas.

Present to user: "This feature primarily affects {deep areas}. I'll also check {shallow areas} for completeness. Any others?"

**Step 2.2 — Walk Domain Checklist:**

If the project has domain reference files, load the relevant checklist.

If no reference files exist, generate questions **grounded in the brainstorm boundaries and chosen approach** — not from general knowledge. Every question should trace back to a specific aspect of the chosen approach, a boundary from the brainstorm, or a risk from the pre-mortem. Do not generate generic domain questions that aren't connected to this specific feature.

**Batch mode (preferred):** Present an entire category at once:

```markdown
## {Category} — mark each item:

  [ ] Item 1: {description}
  [ ] Item 2: {description}
  [ ] Item 3: {description}

For each item, reply with:
  IN — in scope (Must Have)
  SHOULD — in scope (Should Have)
  DEF — deferred to v2+
  OUT — excluded
  Or use shortcuts: "all IN", "1-3 IN, 4-5 DEF, rest OUT"
```

For each IN SCOPE item, follow up with:
- What are the business rules?
- What are the constraints or limits?
- What edge cases should we handle?

**Step 2.3 — Example Mapping (complex requirements):**

For high-priority or complex requirements, capture concrete examples:

```markdown
**Rule:** {business rule}
**Example:** {scenario that follows the rule}
**Counter-example:** {scenario that must fail}
**Question:** {open question about edge cases}
```

This surfaces hidden assumptions and edge cases that abstract descriptions miss.

**Step 2.4 — Document Domain Requirements:**

Group by domain area:

```markdown
### {Domain Area}

#### Must Have
DR-{MODULE}-{DESCRIPTIVE-NAME}: {Requirement title}
  Description: {what it does}
  Business rules: {specific rules with parameters}
  Constraints: {limits, validation rules}
  Edge cases: {what happens when...}
  Evidence: {Direct / Indirect / Assumption}

#### Should Have
DR-{MODULE}-{DESCRIPTIVE-NAME}: ...

#### Deferred (v2+)
- {Requirement} — Reason: {why deferred}

#### Excluded
- {Requirement} — Reason: {why excluded}
```

**Evidence quality:**
- **Direct** — user interview data, support tickets, analytics
- **Indirect** — analogous features, competitor analysis, expert opinion
- **Assumption** — needs validation (flag for PRD)

**PAUSE 2:** Present domain requirements summary.
"Discovered {N} requirements across {N} domain areas. {N} Must Have, {N} Should Have, {N} Deferred. Does the scope look right?"

---

### Phase 3: Integration & UI Analysis

**Step 3.1 — UI/UX Flow Mapping (skip if no UI):**

```markdown
| Screen | Purpose | Entry Point | Key Actions |
|--------|---------|-------------|-------------|
| {name} | {what user does} | {how they get here} | {buttons/forms} |
```

ASCII navigation flow:
```
[Screen A] ──"action"──> [Screen B] ──"action"──> [Screen C]
```

Screen states for each: Loading, Populated, Empty, Error, Saving.

**Step 3.2 — External System Touchpoints:**

```markdown
| System | Direction | Data | Protocol | Auth |
|--------|-----------|------|----------|------|
| {name} | In/Out/Both | {what data} | REST/gRPC/events | {how} |
```

ASCII data flow diagram (context level) showing data movement across system boundaries.

---

### Phase 3b: Security, Compliance, Feasibility & Risk

**Step 3b.1 — Security Analysis:**

Apply STRIDE only to threat categories relevant to this feature's actual attack surface. Do not mechanically fill in all 6 categories — identify which threats are plausible given the feature's architecture and data flows, and focus on those.

For features touching auth, PII, or sensitive operations:

```markdown
| Threat | Specific Risk | Mitigation |
|--------|---------------|------------|
| {applicable STRIDE category} | {concrete threat for THIS feature} | {mitigation} |
```

For non-security features, note "No significant security implications — {reasoning}" and move on. A single sentence explaining why is more valuable than a table of "No" entries.

**Step 3b.2 — Compliance Checkpoints:**

If regulatory requirements apply:

```markdown
| Regulation | Requirement | How Addressed | Status |
|-----------|-------------|---------------|--------|
| {regulation} | {specific requirement} | {approach} | Addressed/Gap |
```

Skip if no regulatory requirements apply.

**Step 3b.3 — Feasibility Assessment:**

For each Must Have requirement, assess technical feasibility:

```markdown
| Requirement | Feasibility | Confidence | Action Needed |
|-------------|-------------|------------|---------------|
| DR-{MODULE}-{NAME} | Known pattern | High | None |
| DR-{MODULE}-{NAME} | Uncertain | Low | Spike needed |
| DR-{MODULE}-{NAME} | Complex | Medium | Research needed |
```

Low confidence items should generate explicit spike or research recommendations.

**Step 3b.4 — Risk Register:**

Consolidate risks from pre-mortem (Phase 1), domain requirements (Phase 2), and analysis (Phase 3):

```markdown
| Risk | Category | Likelihood | Impact | Mitigation |
|------|----------|-----------|--------|------------|
| {risk} | Value/Usability/Feasibility/Viability | High/Med/Low | High/Med/Low | {approach} |
```

---

### Phase 4: Synthesis & Brief

**Step 4.1 — Cross-Reference with Brainstorm:**

For each discovered requirement:
- Within brainstorm scope? → Keep
- Exceeds scope? → Flag: "This requirement wasn't in the original scope. Expand scope or defer?"
- Conflicts with anti-requirements? → Resolve with user

**Check kill criteria:** Review the brainstorm's kill criteria against discovery findings. Has discovery revealed that complexity exceeds the budget by 50%+? Has a technical blocker surfaced? If any kill criterion is triggered, flag it explicitly:

"Discovery finding {X} triggers kill criterion {Y} from the brainstorm. Options: (1) Adjust the approach, (2) Adjust the kill criteria, (3) Abandon the feature."

**Step 4.2 — Requirements Summary:**

```markdown
| Domain Area | Must Have | Should Have | Deferred | Excluded |
|-------------|----------|------------|----------|----------|
| {area} | {count} | {count} | {count} | {count} |
| Total | {total} | {total} | {total} | {total} |
```

**Step 4.3 — Finalize Glossary:**

Review and finalize the glossary that's been building throughout discovery. This becomes the ubiquitous language for PRD and technical design.

**Step 4.4 — Discovery Readiness Checklist:**

```markdown
Discovery is ready for PRD when:
- [ ] Every actor has at least one JTBD documented
- [ ] Desired-state workflow covers all actors
- [ ] All domain areas fully dispositioned (in/deferred/out)
- [ ] No "Low confidence" feasibility items without a spike/research plan
- [ ] Open questions are non-blocking for initial PRD draft
- [ ] User has confirmed scope boundaries ← requires explicit user confirmation, not agent self-assessment
- [ ] No brainstorm kill criteria triggered (or triggered and resolved)
```

Items marked with ← are things the agent cannot self-verify — they require explicit user confirmation during PAUSE 3.

**Step 4.5 — Self-Review:**

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Theme 1: Domain Completeness**
- [ ] All prioritized domain areas addressed at appropriate depth?
- [ ] Business rules documented for Must Have items?
- [ ] Edge cases identified?

**Theme 2: Workflow Accuracy**
- [ ] Current-state workflow matches reality (or partial/greenfield documented)?
- [ ] Desired-state workflow achievable within boundaries?
- [ ] All actors appear in at least one workflow?

**Theme 3: Scope Discipline**
- [ ] Nothing exceeds brainstorm boundaries without user approval?
- [ ] Deferred items have clear rationale?
- [ ] Excluded items have clear reasoning?
- [ ] Kill criteria checked and not triggered (or resolved)?

**Theme 4: Traceability**
- [ ] Every requirement traceable to an actor and workflow step?
- [ ] Every UI screen traceable to a workflow step?
- [ ] Every integration point identified?

---

### Discovery Brief Output

Save to: `${PROJECT_ROOT}/docs/discovery/{feature}/discovery-brief.md`

```markdown
# Discovery Brief: {Feature Name}

> Domain-aware requirements for {feature}.
> Brainstorm: docs/brainstorm/{feature}/brainstorm.md

## Actors
| Actor | Type | Key Actions | JTBD |
|-------|------|-------------|------|

## Workflows
### Current State
{ASCII workflow diagram — or "Greenfield" / "Partial — workaround exists"}

### Desired State
{ASCII workflow diagram}

### Gaps
| Gap | Current | Desired | Impact |
|-----|---------|---------|--------|

## Domain Requirements
{Grouped by domain area}
### {Area}
#### Must Have
DR-{MODULE}-{NAME}: {requirement with rules, constraints, edge cases, evidence}
#### Should Have
DR-{MODULE}-{NAME}: ...
#### Deferred
- {requirement} — {reason}
#### Excluded
- {requirement} — {reason}

## UI/UX Flows (if applicable)
### Screen Inventory
| Screen | Purpose | Entry Point | Key Actions |
### Navigation Flow
{ASCII navigation diagram}
### Screen States
| Screen | States |

## Integrations
| System | Direction | Data | Protocol | Auth |
### Data Flow Diagram
{ASCII DFD — context level}

## Security Analysis
{Focused STRIDE table or "No significant security implications — {reasoning}"}

## Compliance
{Regulation table or "No regulatory requirements"}

## Feasibility Assessment
| Requirement | Feasibility | Confidence | Action |

## Risk Register
| Risk | Category | Likelihood | Impact | Mitigation |

## Requirements Summary
| Domain Area | Must | Should | Deferred | Excluded |
Total discovered: {count}

## Glossary
| Term | Definition |

## Open Questions
- {items for PRD to resolve}

---
*Discovery completed: {date}*
*Next step: /prd*
```

**PAUSE 3:** Present summary and route.

```markdown
## Discovery Complete

**Feature:** {name}
**Requirements:** {N} Must Have, {N} Should Have, {N} Deferred
**Risks:** {N} identified
**Feasibility flags:** {N} need spikes, {N} need research
**Kill criteria:** {all clear / {N} triggered — see above}
**Open questions:** {N} for PRD to resolve

Ready for next step:
1. "start prd" → /prd (default — feeds discovery into PRD)
2. "refine" → continue iterating discovery
3. "park" / "abandon"
```

---

## Anti-Patterns

**Surface-Level Actor Mapping** — Listing "the user" instead of specific roles. Different roles have different needs, permissions, and workflows. "Tenant Admin" and "End User" are not interchangeable.

**Designing During Discovery** — Discovery captures WHAT is needed, not HOW to build it. If you're drawing database schemas or writing API specs, you've crossed into /technical-design territory. Stay at the requirements level.

**Scope Creep Through Checklists** — Domain checklists surface many possible requirements. Not everything discovered needs to be in scope. The "Deferred" and "Excluded" categories exist for a reason — use them aggressively.

**Assumption-as-Fact** — Stating user needs without evidence. When the user says "users want X", ask "how do you know?" If the answer is "I think so", mark it as an assumption that needs validation, not a confirmed requirement.

**Skipping Security for "Simple" Features** — Features that seem simple can have security implications (information disclosure, privilege escalation) that only surface during threat analysis. At minimum, document "No significant security implications — {reasoning}" so the decision is explicit.

**Generic Domain Questions** — Generating checklist questions from general knowledge rather than grounding them in the brainstorm's chosen approach and boundaries. Every discovery question should trace back to something specific about THIS feature, not generic best practices.

---

## Exit Signals

| Signal | Next Skill |
|--------|-----------|
| "start prd" | /prd (default — feeds discovery into PRD) |
| "refine" | Continue iterating discovery |
| "park" | Save for later |
| "abandon" | Don't proceed |

**Exit message:** "Discovery complete. Run /prd to formalise requirements."

---

*Skill Version: 3.1*
*v3.1: Duration target, pre-mortem moved to Phase 1, glossary started early, domain depth prioritization, grounded checklist questions, focused STRIDE analysis, split Phase 3/3b, partial workflow option, kill criteria check in synthesis, readiness items requiring user confirmation flagged, generic questions anti-pattern added*
