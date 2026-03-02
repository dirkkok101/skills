---
name: prd
description: Generate a formal Product Requirements Document from brainstorm output or from scratch. Produces user personas, use cases, functional requirements as user stories with acceptance criteria, non-functional requirements, and MoSCoW prioritization. Use when starting a business feature that needs requirements documentation, when user says "write requirements", "create PRD", "define user stories", or after brainstorm approval for business features.
argument-hint: "[feature name or brainstorm reference]"
---

# PRD Skill

Generate a formal Product Requirements Document that bridges brainstorm output to technical design. This skill produces user personas, use cases, functional requirements as user stories with acceptance criteria, non-functional requirements, and MoSCoW prioritization.

## Workflow Position
```
research → brainstorm → PRD → technical-design → plan → beads → execute
```

## When to Use This Skill
- User says "write requirements", "create PRD", or "define user stories"
- After brainstorm approval for business features
- Starting a feature that needs formal requirements documentation
- Preparing handoff to technical design phase

## 8-Phase Execution

### Phase 0: Prerequisites
Resolve PROJECT_ROOT and establish context files.

1. **Resolve PROJECT_ROOT**
   - Export PROJECT_ROOT from parent environment or infer from git repo root
   - Confirm docs/ directory exists at PROJECT_ROOT

2. **Check for Upstream Artifacts**
   - Look for brainstorm output: `docs/brainstorm/{feature}/brainstorm.md`
   - Look for research brief: `docs/research/{feature}/research-brief.md`
   - Import problem statement, chosen approach, boundaries from brainstorm
   - Import key findings from research brief

3. **Create Output Directory**
   - Initialize `docs/prd/{feature}/` if it doesn't exist
   - Create persistent context files:
     - `task_plan.md` — 3-5 key milestones
     - `findings.md` — discoveries and constraints
     - `progress.md` — phase completion tracking

4. **Gather Initial Context**
   - If no brainstorm or research exists, ask user:
     - "What is the feature name and core problem it solves?"
     - "Who are the primary users and what outcomes matter to them?"
   - Record feature name, version (0.1), date, status (draft)

---

### Phase 1: Document Setup & Context Import

Create the PRD skeleton with metadata and import upstream context.

1. **Initialize PRD Metadata**
   - Feature Name
   - Version: 0.1
   - Date: Today's date
   - Status: Draft
   - Author: Note if this is from brainstorm or created fresh

2. **Import Problem Statement**
   - Copy from brainstorm if available
   - Include quantified business impact if known
   - Record data sources or assumptions

3. **Import Strategic Boundaries**
   - What's in scope (from brainstorm chosen approach)
   - What's explicitly out of scope
   - Key constraints or dependencies

4. **Import Research Findings**
   - Competitive context (if research brief exists)
   - Market or user behavior insights
   - Regulatory or technical constraints

5. **Document Assumptions**
   - Record any assumptions about user needs, market, or feasibility
   - Flag assumptions that need validation before technical design

---

### Phase 2: Business Context

Define the business problem, strategic alignment, and success metrics.

1. **Problem Statement**
   - Current state pain point (1-2 sentences)
   - Quantified impact (affected users, cost, lost revenue)
   - Why solving this now matters strategically
   - Why now > later (urgency and opportunity)

2. **Strategic Alignment**
   - How does this feature serve business goals (growth, retention, efficiency)?
   - Link to company strategy or roadmap priorities
   - Expected ROI or business outcome
   - Competitive advantage or risk mitigation

3. **Success Metrics (KPIs)**
   - Define 3-5 measurable outcomes
   - Format: "Metric: current baseline → target by [date]"
   - Examples: adoption rate, time-to-value, error reduction, revenue impact
   - How success will be measured post-launch

4. **Competitive Context**
   - How do competitors solve this? (from research if available)
   - What's our differentiation?
   - Market trends or shifts that inform this feature

---

### Phase 3: User Personas & Roles

Define 2-4 key personas with detailed context.

For each persona, document:
- **Name & Role** — e.g., "Alice, Operations Manager"
- **Goals** — What are they trying to accomplish? (2-3 primary goals)
- **Pain Points** — What frustrates them today? (2-3 key frustrations)
- **Current Workarounds** — How do they solve the problem now?
- **Success Criteria** — How will they know the feature is working?
- **Role-Based Access** — What can this persona do? (permissions model)
- **User Journey** — 3-4 step journey mapping this persona's interaction

Ask the user: **"Who are the key users and what are they trying to accomplish? What are their current pain points?"**

Include a role-based access matrix if applicable:
```
| Role | Action | Resource | Constraint |
|------|--------|----------|----------|
```

---

### Phase 4: Use Cases

Document formal use cases that connect personas to feature behavior.

**Use Case Format:**
```
UC-001: {Name}
Actor: {Persona}
Precondition: {System state before interaction begins}
Main Flow:
  1. {Actor does X}
  2. {System does Y}
  3. {Flow completes}
Alternative Flows:
  A1. {Branch condition} → {Actor takes alternate path}
  A2. ...
Postcondition: {System state after successful completion}
Exception Flows:
  E1. {Error condition} → {System handles gracefully}
  E2. ...
```

Guidelines:
- Create 5-8 use cases covering primary feature areas
- Group by feature area or user journey
- Include happy path, alternative flows (user choices), exception flows (errors)
- Each use case maps to at least one persona
- Number sequentially (UC-001, UC-002...)
- Exception flows should document error handling, not just "fail"

Example structure:
```
UC-001: Submit Request Form
UC-002: Approve Request (Manager Role)
UC-003: System Validates Business Rules
UC-004: Archive Completed Requests
UC-005: Handle Concurrent Edits (Conflict Resolution)
```

---

### Phase 5: Functional Requirements as User Stories

Convert use cases into user stories with acceptance criteria in Given/When/Then format.

**User Story Format:**
```
FR-001: {Title}
As a {persona},
I want to {action},
So that {benefit}.

Acceptance Criteria:
  Given {precondition}
  When {action}
  Then {expected result}

  Given {precondition}
  When {alternate action}
  Then {alternate result}

Priority: Must/Should/Could/Won't
Complexity: S/M/L/XL
Related Use Cases: UC-001, UC-002
```

Guidelines:
- Unique IDs (FR-001, FR-002...) matching phases
- Group by epic or feature area
- Each story maps to at least one use case
- Each story serves at least one persona goal
- Acceptance criteria are testable and verifiable
- Complexity estimates help with scoping
- Include .NET/C# aware patterns (API endpoints, CQRS patterns, validation rules)

Example structure:
```
Epic: Request Management
  FR-001: Submit Request Form
  FR-002: Notify Manager of New Request
  FR-003: Manager Approves/Rejects Request

Epic: Search & Filtering
  FR-004: Filter Requests by Status
  FR-005: Full-Text Search Requests
```

---

### Phase 6: Non-Functional Requirements

Define performance, security, scalability, data, and accessibility requirements.

**Format: NFR-001, NFR-002...**

1. **Performance**
   - API response time: < Xms for 95th percentile
   - Page load time: < Xms
   - Database query performance (e.g., "Search across 1M records in < 500ms")
   - Batch operation throughput (records/second)

2. **Security & Compliance**
   - Authentication model (OAuth 2.0, SAML, etc.)
   - Authorization (role-based, attribute-based)
   - Data encryption (at rest, in transit)
   - Audit logging (what events are logged, retention period)
   - Compliance frameworks (POPIA for SA, GDPR if EU users, SOC 2, etc.)

3. **Scalability & Availability**
   - Concurrent user targets (peak load)
   - Target uptime (99.9%, SLA)
   - Geographic redundancy (if applicable)
   - Auto-scaling triggers and limits

4. **Data Management**
   - Data retention policy (how long is data kept?)
   - Data deletion workflow (GDPR right-to-be-forgotten, POPIA)
   - Backup and recovery RTO/RPO
   - Data partitioning strategy (if handling large datasets)

5. **Accessibility**
   - WCAG 2.1 Level AA conformance (if web UI)
   - Keyboard navigation support
   - Screen reader compatibility
   - High contrast mode support

Example:
```
NFR-001: API Response Time
Target: 95th percentile < 200ms for request submission
Rationale: Users expect responsive feedback; delays > 200ms feel sluggish

NFR-002: Authentication
Mechanism: OAuth 2.0 with JWT tokens
Token Lifetime: 15 minutes access token, 7-day refresh token
Audit: Log all authentication attempts (success and failure)

NFR-003: Concurrent Users
Target: Support 1000 concurrent users without degradation
Load Test: Run on staging environment before release
```

---

### Phase 7: Feature Prioritization (MoSCoW)

Classify requirements by priority and document dependencies.

1. **Must Have (MVP)**
   - Without these, the feature doesn't work at all
   - List 5-10 critical requirements
   - Affects go/no-go launch decision

2. **Should Have (V1)**
   - Significant user value but not blocking MVP
   - Planned for initial release but could slip to V1.1
   - List 5-10 important features

3. **Could Have (Future)**
   - Nice-to-have features that enhance the experience
   - No impact on core functionality
   - List 3-5 enhancement ideas

4. **Won't Have (Yet)**
   - Explicitly out of scope with documented reasoning
   - Prevents scope creep
   - Revisit in future roadmap cycles

5. **Dependency Graph**
   - Create a Mermaid diagram showing feature dependencies
   - Identify critical path for MVP delivery
   - Highlight risks or bottlenecks

Example:
```
## Must Have (MVP)
- FR-001: Submit Request Form
- FR-002: Manager Approval Workflow
- FR-003: Basic Audit Logging
- NFR-001: API response < 200ms

## Should Have (V1)
- FR-004: Advanced Search & Filtering
- FR-005: Bulk Operations
- NFR-002: Full Compliance Audit Trail

## Could Have (Future)
- AI-powered request recommendations
- Mobile native app
- Integration with Slack/Teams

## Won't Have (Yet)
- Multi-tenant support (reason: single org only, revisit in 2026 Q3)
- Advanced analytics dashboard (reason: focus on core workflow first)

## Dependency Graph
graph LR
  FR-001["Submit Request"] --> FR-002["Manager Approval"]
  FR-002 --> FR-003["Notifications"]
  FR-001 --> NFR-002["Audit Logging"]
  FR-004["Search"] -.->|after MVP| FR-001
```

6. **Risk Assessment per Tier**
   - What could go wrong with each Must-Have?
   - Mitigation strategy
   - Impact if deferred

---

### Phase 8: Self-Review & Approval

Perform 2 rounds of review minimum, exit on 2 consecutive clean rounds.

**5 Review Themes:**

1. **Completeness**
   - [ ] All personas covered by at least one use case?
   - [ ] All use cases mapped to at least one user story?
   - [ ] All user stories have acceptance criteria?
   - [ ] All must-haves prioritized?
   - [ ] Business metrics defined?

2. **Clarity**
   - [ ] Could a developer implement these stories without asking questions?
   - [ ] Acceptance criteria are unambiguous (not "intuitive", "fast", etc.)?
   - [ ] Each persona description is detailed enough to guide design?
   - [ ] Use case flows are step-by-step, not summarized?

3. **Testability**
   - [ ] Every acceptance criterion is verifiable?
   - [ ] Success metrics are measurable?
   - [ ] Performance targets have units (ms, %, users)?
   - [ ] Security requirements are testable (e.g., "audit log captures X events")?

4. **Scope Discipline**
   - [ ] Nothing exceeds brainstorm boundaries?
   - [ ] Won't-Have items have clear reasoning?
   - [ ] Features don't creep into adjacent areas?
   - [ ] Dependencies are documented?

5. **Traceability**
   - [ ] FR → Use Case → Persona chain is complete?
   - [ ] Traceability matrix is filled in?
   - [ ] If FR is added, use case and persona are updated?

**Self-Review Workflow:**

Round 1:
- Review against all 5 themes
- Record gaps or issues in findings.md
- Document 2-3 key changes needed

Round 2:
- Re-review after fixes
- If clean (no issues), **exit with approval signal**
- If issues remain, loop back to Phase 1-7 as needed

**Update progress.md after each round:**
```
## Round 1
- Issues: Missing personas for analyst role, NFR-003 not testable
- Fixes: Added Analyst persona, rewrote NFR-003 with measurable target
- Status: In Progress

## Round 2
- Issues: None
- Status: APPROVED
```

---

## Exit Signals

Use these signals to communicate next steps to user:

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| "prd approved" | PRD is complete and ready | Proceed to `/technical-design` |
| "refine" | Continue iterating (gaps or clarity issues) | Return to relevant phases (3-7) |
| "park" | Save for later without approval | Archive in docs/archive; user resumes later |
| "abandon" | Don't build this feature | Close out; document decision rationale |

When exiting, update PRD metadata:
- Status: Approved / Parked / Abandoned
- Next Step: Technical Design / TBD / None
- Completion Date: Today's date

---

## Key Design Principles

1. **Why > What**: Explain why business context matters before defining features
2. **Traceability**: Every requirement traces back to user persona and business goal
3. **Testability**: Acceptance criteria enable QA to verify completion
4. **Scope Discipline**: Won't-Have section prevents scope creep
5. **.NET/C# Awareness**: User stories consider API patterns, validation, CQRS where relevant
6. **Persistent Context**: task_plan.md, findings.md, progress.md track decisions and blockers

---

## Output Location

PRD is written to: `docs/prd/{feature}/prd.md`

Template:
```markdown
# PRD: {Feature Name}

> Product Requirements Document for {feature}. Status: {Draft/In Review/Approved}
> Version: 0.1 | Date: {date} | Author: {user/agent}

## Executive Summary
{Problem, solution, business value in 3-5 sentences}

## Business Context
### Problem Statement
{Current pain, quantified impact, why now}

### Strategic Alignment
{How this serves business goals}

### Success Metrics
{3-5 KPIs with baseline and target}

### Competitive Context
{How competitors solve this, our differentiation}

## User Personas
### Persona 1: {Name/Role}
- Goals: ...
- Pain Points: ...
- Success Criteria: ...

## Use Cases
### UC-001: {Name}
Actor: {Persona}
Precondition: ...
Main Flow: ...
Alternative Flows: ...
Postcondition: ...
Exception Flows: ...

## Functional Requirements
### Epic: {Feature Area}
#### FR-001: {Title}
As a ..., I want ..., So that ...
Acceptance Criteria: ...

## Non-Functional Requirements
### NFR-001: {Title}
...

## Feature Prioritization
### Must Have (MVP)
- FR-001, FR-002, ...

### Should Have (V1)
- FR-003, ...

### Could Have (Future)
- ...

### Won't Have (Yet)
- ... (with reasoning)

### Dependency Graph
{Mermaid diagram}

## Self-Review Log
### Round 1
- Issues: ...
- Fixes: ...

### Round 2
- Issues: None
- Status: APPROVED

## Open Questions
- {Question 1}
- {Question 2}

## Traceability Matrix
| FR | Use Case | Persona | Priority |
|----|----------|---------|----------|
| FR-001 | UC-001 | Alice | Must |

---
*PRD created: {date}*
*Status: {Approved/Draft/Parked}*
*Next step: {/technical-design | TBD | None}*
```

---

## Running This Skill

Invocation:
```
/prd [feature-name]
```

Example:
```
/prd request-approval-workflow
```

The skill will:
1. Resolve PROJECT_ROOT and check for brainstorm/research artifacts
2. Guide you through Phases 0-8 interactively
3. Create docs/prd/{feature}/ with prd.md and context files
4. Perform self-review and exit with approval signal
5. Output PRD ready for `/technical-design`

---

*Skill Version: 1.0*
*Designed for: Feature-level requirements documentation*
*Integrates with: brainstorm → technical-design workflow*
