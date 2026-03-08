---
name: discovery
description: >
  Domain-aware requirements elicitation between brainstorm and PRD. Walks through
  domain-specific checklists, maps actors and workflows, captures UI flows,
  analyses integrations and security, and produces a discovery brief that feeds
  directly into PRD. Use after brainstorm for complex features, when user says
  'discover requirements', 'deep dive', 'requirements elicitation', or when
  brainstorm scope classifier recommends COMPREHENSIVE.
argument-hint: "[feature name or brainstorm reference]"
---

# Discovery: Approach → Domain-Aware Requirements

**Philosophy:** The gap between "we picked an approach" (brainstorm) and "we have formal requirements" (PRD) is where complex features fail. Discovery fills that gap with domain-specific depth. **Discovery is a working process — the PRD is the authoritative document.** Discovery produces a brief that feeds into PRD; the PRD absorbs and formalises discovery's findings. The discovery brief is reference material, not a duplicate of the PRD.

## Core Principles

1. **Domain-driven** — Load domain reference, walk the checklist, don't guess
2. **Actor-complete** — Every human, system, and background process enumerated
3. **Workflow-first** — Map current state before designing desired state
4. **Visually grounded** — ASCII diagrams for workflows, navigation, data flows
5. **Security-aware** — STRIDE-lite for auth features, compliance checkpoints for regulated

---

## Trigger Conditions

Run this skill when:
- Brainstorm scope classifier says COMPREHENSIVE
- User says "discover requirements", "deep dive requirements", "requirements elicitation"
- Feature touches auth/identity, multiple user roles, external integrations, or complex UI
- After brainstorm, before PRD, for any non-trivial feature

Do NOT run when:
- Simple CRUD or config change (go straight to PRD or plan)
- Brainstorm scope classifier says BRIEF
- Pure technical refactor with no new requirements

---

## Critical Sequence

### Phase 0: Prerequisites & Domain Detection

**Step 0.1 — Resolve Project Root:**

```bash
PROJECT_ROOT=$(git rev-parse --show-toplevel)
mkdir -p "${PROJECT_ROOT}/docs/discovery/{feature}"
```

**Step 0.2 — Import Brainstorm Output:**

```bash
cat "${PROJECT_ROOT}/docs/brainstorm/{feature}/brainstorm.md"
```

Extract: problem statement, chosen approach, boundaries, scope classification, recommended domain.

If no brainstorm exists, ask user for: feature name, problem statement, chosen approach, key constraints.

**Step 0.3 — Detect Domain:**

Scan feature description and brainstorm for domain signals:

| Domain | Signals |
|--------|---------|
| Identity/Auth | login, auth, user, roles, permissions, OIDC, OAuth, tokens, SSO, MFA, password, session, client registration, scopes, claims |
| Data Platform | data model, reporting, dashboard, computed values, curation, MCP, formulas, KPIs, metrics, ETL, import, export |
| Mobile/EHS | mobile, offline, sync, inspection, incident, field, GPS, camera, checklist, observation, safety |
| General SaaS | tenant, subscription, billing, onboarding, admin, configuration, notification, webhook, API key |

Present detection to user: "Detected domain: {domain}. Loading {domain} reference. Correct? Any additional domains?"

**Step 0.4 — Load References:**

Read the domain reference file(s):
- `skills/_shared/references/{domain}.md`
- `skills/_shared/references/ascii-conventions.md`

If domain reference doesn't exist, note this and proceed with generic elicitation.

**Step 0.5 — Initialise Context Files:**

Create in `${PROJECT_ROOT}/docs/discovery/{feature}/`:
- `progress.md` — phase tracking
- `findings.md` — working notes accumulated during discovery

---

### Phase 1: Actor & Workflow Mapping

**Step 1.1 — Identify ALL Actors:**

Not just "users" — enumerate every distinct entity that interacts with this feature.

Ask: **"Who or what interacts with this feature? Think about: human roles, external systems, background processes, other NXGN products."**

Document as table:

```
| Actor | Type | Key Actions | Frequency |
|-------|------|-------------|-----------|
| {role} | Human / System / Automated | {what they do} | {how often} |
```

Types:
- **Human**: Tenant Admin, End User, Support Engineer, Auditor
- **System**: Client App, External IdP, Email Service, Key Vault
- **Automated**: Background Job, Scheduler, Event Handler

**Step 1.2 — Map Current-State Workflow:**

Ask: **"How does this work TODAY? Walk me through the current process step by step."**

Create ASCII workflow diagram using conventions from `ascii-conventions.md`:

```
( Current Trigger )
       |
       v
+------------------+
|  Current Step 1  |  ⚠ pain point annotation
+------------------+
       |
       v
  < Decision? >
   /         \
  Yes         No
  ...         ...
```

Annotate pain points inline with ⚠ markers.

If there is no current process (greenfield feature), note this and skip to desired state.

**Step 1.3 — Map Desired-State Workflow:**

Create ASCII workflow diagram showing how the feature SHOULD work:

```
( New Trigger )
       |
       v
+------------------+
|  New Step 1      |  ✓ improvement annotation
+------------------+
```

**Step 1.4 — Gap Analysis:**

Compare current vs. desired:

```
| Gap | Current | Desired | Impact |
|-----|---------|---------|--------|
| {what changes} | {how it works now} | {how it should work} | {benefit} |
```

**Output:** `workflow-map.md` with actor table, both workflow diagrams, and gap analysis.

---

### Phase 2: Domain-Specific Requirements Elicitation

**Step 2.1 — Walk Domain Checklist:**

Load the domain checklist from the domain reference file.

**Batch mode (preferred):** Present the entire category at once and ask the user to mark items, rather than walking through one-by-one. This prevents user fatigue on large checklists.

```
## {Category Name} — mark each item:

  [ ] Item 1: {description}
  [ ] Item 2: {description}
  [ ] Item 3: {description}
  ...

For each item, reply with:
  IN — in scope for this feature
  DEF — deferred to v2+
  OUT — excluded
  Or use shortcuts: "all IN", "1-3 IN, 4-5 DEF, rest OUT"
```

For each IN SCOPE item, follow up with:
- What are the business rules?
- What are the constraints or limits?
- What edge cases should we handle?
- What validation is needed?

**One-at-a-time mode (fallback):** If the checklist is short (under 10 items) or the user prefers interactive exploration, walk through one category at a time.

Ask one category at a time. Do NOT present all categories simultaneously.

**Step 2.2 — Document Domain Requirements:**

Group by domain checklist category:

```markdown
### {Category Name}

#### IN SCOPE
DR-{MODULE}-{DESCRIPTIVE-NAME}: {Requirement title}
  Description: {what it does}
  Business rules: {specific rules with parameters}
  Constraints: {limits, validation rules}
  Edge cases: {what happens when...}
  Maps to FR: {FR-{MODULE}-{NAME} — filled in during PRD phase}

DR-{MODULE}-{DESCRIPTIVE-NAME}: ...

#### DEFERRED (v2+)
- {Requirement} — Reason: {why deferred}

#### EXCLUDED
- {Requirement} — Reason: {why excluded}
```

**Output:** `domain-requirements.md`

---

### Phase 3: UI/UX Flow Mapping

**Skip this phase if the feature has no user interface.**

**Step 3.1 — Screen Inventory:**

Ask: **"What screens or views does this feature need?"**

```
| Screen | Purpose | Entry Point | Key Actions |
|--------|---------|-------------|-------------|
| {name} | {what user does here} | {how they get here} | {buttons/forms} |
```

**Step 3.2 — Navigation Flow:**

ASCII diagram showing how users move between screens:

```
[Screen A] ──"action"──> [Screen B] ──"action"──> [Screen C]
     |                                                  |
     +────"action"───> [Screen D] <────"action"─────────+
```

**Step 3.3 — Screen States:**

For each screen, identify states:

```
| Screen | States |
|--------|--------|
| {name} | Loading, Populated, Empty, Error, Saving |
```

**Step 3.4 — Key Mockup Sketches (optional):**

Quick layout sketches for complex screens. Full mockups go in technical-design.
Use UI mockup conventions from `ascii-conventions.md`.

**Output:** `ux-flows.md`

---

### Phase 4: Integration & Security Analysis

**Step 4.1 — External System Touchpoints:**

```
| System | Direction | Data | Protocol | Frequency | Auth |
|--------|-----------|------|----------|-----------|------|
| {name} | In/Out/Both | {what data} | REST/gRPC/SMTP | {rate} | {how} |
```

**Step 4.2 — Data Flow Diagram (Context Level):**

ASCII DFD showing data movement across system boundaries:

```
[External Entity]
     |
     | {data description}
     v
(1.0 Process) ---- {data} ----> |= D1 Store |
```

Use DFD conventions from `ascii-conventions.md`.

**Step 4.3 — Security Analysis:**

For features touching auth, PII, or sensitive operations, do STRIDE-lite:

```
| Threat Category | Applies? | Threat | Mitigation |
|-----------------|----------|--------|------------|
| Spoofing | Yes/No | {specific threat} | {specific mitigation} |
| Tampering | Yes/No | ... | ... |
| Repudiation | Yes/No | ... | ... |
| Info Disclosure | Yes/No | ... | ... |
| Denial of Service | Yes/No | ... | ... |
| Elevation of Privilege | Yes/No | ... | ... |
```

For non-security features, do abbreviated analysis (just note "no significant security implications" with reasoning).

**Step 4.4 — Compliance Checkpoints:**

```
| Regulation | Requirement | How Addressed | Status |
|-----------|-------------|---------------|--------|
| POPIA | {specific requirement} | {how the feature addresses it} | Addressed/Gap |
| SOC 2 | ... | ... | ... |
```

Skip if no regulatory requirements apply to this feature.

**Output:** `integration-analysis.md`

---

### Phase 5: Requirements Synthesis

**Step 5.1 — Consolidate:**

Merge findings from all phases into a unified view.

**Step 5.2 — Cross-Reference with Brainstorm Boundaries:**

For each discovered requirement:
- Within brainstorm scope? → Keep
- Exceeds scope? → Flag for user: "This requirement wasn't in the original scope. Expand scope or defer?"
- Conflicts with anti-requirements? → Resolve with user

**Step 5.3 — Requirements Summary:**

```
| Category | In Scope | Deferred | Excluded |
|----------|----------|----------|----------|
| {domain category} | {count} | {count} | {count} |
| Total | {total} | {total} | {total} |
```

**Step 5.4 — Open Questions:**

List unresolved items that PRD needs to address.

---

### Phase 6: Self-Review & Route

**2 rounds minimum. Exit on 2 consecutive clean rounds.**

**Known limitation:** Self-review is performed by the same agent that produced the document. The same biases and blind spots that influenced the output may persist during review. Mitigate by: following the themes strictly as a checklist, inviting user to spot-check specific sections, and noting where you're least confident.

#### 4 Review Themes

**Theme 1: Domain Completeness**
- [ ] All domain checklist items addressed (in scope, deferred, or excluded)?
- [ ] No obvious gaps between domain reference and captured requirements?
- [ ] Business rules documented for all in-scope items?

**Theme 2: Workflow Accuracy**
- [ ] Current-state workflow matches actual reality?
- [ ] Desired-state workflow achievable within boundaries?
- [ ] All actors from Phase 1 appear in at least one workflow?

**Theme 3: Scope Discipline**
- [ ] Nothing exceeds brainstorm boundaries without explicit user approval?
- [ ] Deferred items have version targets?
- [ ] Excluded items have clear reasoning?

**Theme 4: Traceability**
- [ ] Every requirement traceable to an actor and a workflow step?
- [ ] Every UI screen traceable to a workflow step?
- [ ] Every integration point identified in data flow?

---

### Discovery Brief Output

Save to: `${PROJECT_ROOT}/docs/discovery/{feature}/discovery-brief.md`

```markdown
# Discovery Brief: {Feature Name}

> Domain-aware requirements for {feature}.
> Domain(s): {detected domains}
> Brainstorm: docs/brainstorm/{feature}/brainstorm.md

## Actors
| Actor | Type | Key Actions | Frequency |
|-------|------|-------------|-----------|

## Workflows
### Current State
{ASCII workflow diagram — or "Greenfield, no current process"}

### Desired State
{ASCII workflow diagram}

### Gaps
| Gap | Current | Desired | Impact |
|-----|---------|---------|--------|

## Domain Requirements
{Grouped by domain checklist category}
### {Category}
#### In Scope
DR-{MODULE}-{DESCRIPTIVE-NAME}: {requirement with rules, constraints, edge cases}
...
#### Deferred (v2+)
- {requirement} — {reason}
#### Excluded
- {requirement} — {reason}

## UI/UX Flows
### Screen Inventory
| Screen | Purpose | Entry Point | Key Actions |
...
### Navigation Flow
{ASCII navigation diagram}
### Screen States
| Screen | States |
...

## Integrations
| System | Direction | Data | Protocol | Frequency |
...
### Data Flow Diagram
{ASCII DFD — context level}

## Security Analysis
{STRIDE table or "No significant security implications — {reasoning}"}

## Compliance
{Regulation table or "No regulatory requirements for this feature"}

## Requirements Summary
| Category | In Scope | Deferred | Excluded |
...
Total discovered: {count}

## Open Questions
- {items for PRD to resolve}

## Self-Review Log
### Round 1
Issues: {count}
- [{theme}] {issue} → Fix: {fix}
### Round 2
Issues: 0 ✅

---
*Discovery completed: {date}*
*Next step: /prd*
```

---

## Exit Signals

| Signal | Next Skill |
|--------|-----------|
| "start prd" | /prd (default — feeds discovery brief into PRD) |
| "start technical-design" | /technical-design (if PRD not needed — technical improvement) |
| "refine" | Continue iterating discovery |
| "park" | Save for later |
| "abandon" | Don't proceed |

**Exit message:** Present summary with requirement counts, then route to /prd.

---

## Quality Standards

### Actor Completeness
- Every human role, system, and automated process identified
- No "the user" — specific role names from actual customer organisations

### Workflow Accuracy
- Current state reflects reality, not aspirations
- Desired state achievable within complexity budget
- Pain points annotated on current state

### Domain Coverage
- Every domain checklist item has a disposition (in scope, deferred, excluded)
- Business rules have specific parameters, not vague descriptions
- Edge cases identified for all in-scope items

### Traceability
- Every requirement links to an actor and workflow
- Every screen links to a workflow step
- Every integration links to a data flow

### ASCII Quality
- All diagrams follow conventions from `ascii-conventions.md`
- Diagrams under 100 characters wide
- Realistic data in mockup sketches

---

*Skill Version: 1.0*
