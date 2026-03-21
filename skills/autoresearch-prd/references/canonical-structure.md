# Canonical PRD Structure (COMPREHENSIVE)

This is the definitive structural specification. Every COMPREHENSIVE PRD
produced by the /prd skill MUST match this structure exactly. Only content
varies between PRDs — structure, naming, and conventions are fixed.

Derived from: /prd SKILL.md v3.5 + structural audit of 15 ground truth PRDs.

---

## Document Skeleton

```markdown
# PRD: {Feature Name}

| Field | Value |
|---|---|
| Version | {semver} |
| Date | {YYYY-MM-DD} |
| Author | {name} |
| Status | Draft |
| Scope | COMPREHENSIVE |
| Brainstorm | {link or N/A} |
| Discovery | {link or N/A} |
| Depends On | {links to prerequisite PRDs, or N/A} |

> Part of the [{project} PRD]({link to prd-index.md}). {One-sentence module description.}

## Document History

| Version | Date | Changes |
|---|---|---|
| {ver} | {date} | {description of changes} |

## Table of Contents

1. [Problem Statement](#problem-statement)
2. [Goals](#goals)
3. [Non-Goals](#non-goals)
4. [Success Metrics](#success-metrics)
5. [User Personas](#user-personas)
6. [Assumptions & Constraints](#assumptions--constraints)
7. [Use Cases](#use-cases)
8. [Functional Requirements](#functional-requirements)
9. [Non-Functional Requirements](#non-functional-requirements)
10. [Integration Points](#integration-points)
11. [Prioritisation (MoSCoW)](#prioritisation-moscow)
12. [Domain Validation](#domain-validation)
13. [Document Approval](#document-approval)

---

## Problem Statement

{2-3 sentences with specific evidence.}

Impact:
- {Quantified effect 1}
- {Quantified effect 2}
- {Quantified effect 3}

Why now: {urgency, opportunity, strategic alignment}

---

## Goals

- **G1:** {Measurable outcome}
- **G2:** {Measurable outcome}
- **G3:** {Measurable outcome}

{3-5 goals. Each prefixed G1-Gn.}

## Non-Goals

- **NG1:** {Exclusion} — Reason: {why}
- **NG2:** {Exclusion} — Reason: {why}

{Each prefixed NG1-NGn with rationale.}

## Success Metrics

| Metric | Current | Target | By When | How Measured |
|--------|---------|--------|---------|--------------|
| {KPI} | {baseline} | {target} | {date} | {method} |

---

## User Personas

### P1: {Role Title} (Primary)

"{Archetype description}"
- **Goals:** {2-3 items}
- **Pain Points:** {2-3 items}
- **Current Workaround:** {how they cope today}
- **Success Criteria:** {how they know the feature works for them}
- **Tech Level:** {description}
- **Frequency:** {how often they use this feature}

### P2: {Role Title}

{Same sub-fields as P1.}

{2-4 personas. Each H3 heading: ### P{n}: {Role Title}
Six mandatory sub-fields per persona: Goals, Pain Points, Current Workaround,
Success Criteria, Tech Level, Frequency. All bold with colon.}

---

## Assumptions & Constraints

### Assumptions

- **A1:** {Assumption text}
- **A2:** {Assumption text}

{Numbered A1-An. Bullet list with bold prefix.}

### Constraints

- **C1:** {Constraint text}
- **C2:** {Constraint text}

{Numbered C1-Cn. Bullet list with bold prefix.}

### Risks

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| {description} | Low/Med/High | Low/Med/High | {mitigation} |

### Open Questions

| # | Question | Context | Status | Decision | Owner |
|---|----------|---------|--------|----------|-------|
| 1 | {question} | {why it matters} | Open/Resolved | {decision} | {who} |

{6 columns: #, Question, Context, Status, Decision, Owner.}

---

## Use Cases

{Index table linking to standalone UC files.}

| UC ID | Title | Depth | Actor | Status |
|-------|-------|-------|-------|--------|
| [UC-{MODULE}-001](use-cases/UC-{MODULE}-001-{slug}.md) | {title} | Tier 1 | {actor} | Draft |

---

## Functional Requirements

### Epic: {Epic Name}

#### FR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}
Priority: Must / Should / Could / Won't
Complexity: S / M / L / XL
Related: UC-{MODULE}-{NNN}

As a {persona reference (P1/P2/role)},
I want to {action},
So that {benefit}.

{Optional narrative description.}

Acceptance Criteria:
  Given {precondition}
  When {action}
  Then {expected result}

  Given {error condition}
  When {invalid action}
  Then {error handling behavior}

Security Criteria:
  - {requirement}

Compliance Criteria:
  - {requirement}

{FR rules:
- H4 heading: #### FR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}
- Descriptive IDs, NEVER sequential (FR-APP-REGISTER not FR-APP-001)
- Lines: Priority, Complexity, Related (one per line, no bold)
- User story: multiline As a / I want / So that
- Acceptance Criteria: indented 2 spaces, Given/When/Then
- At least one error/edge case criterion per Must Have FR
- Security Criteria on FRs that modify data, touch auth, or handle PII
- Compliance Criteria on FRs touching regulated data
- FRs organized under ### Epic: {name} headings}

---

## Non-Functional Requirements

### NFR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}
Category: Performance / Security / Scalability / Data / Accessibility
Target: {specific measurable target with number}
Load Condition: {context — optional but recommended}
Measurement: {how to verify}
Rationale: {why this target — trace to problem, metrics, or persona}

{NFR rules:
- H3 heading: ### NFR-{MODULE}-{DESCRIPTIVE-NAME}: {Title}
- Descriptive IDs, NEVER sequential
- Lines: Category, Target, Load Condition, Measurement, Rationale
- Target MUST contain a number ("P95 < 200ms" not "should be fast")
- Rationale traces to problem statement, success metrics, or persona needs
- Minimum 6 NFRs for COMPREHENSIVE}

---

## Integration Points

### Consumed Services

| Service | Purpose | Failure Impact |
|---------|---------|---------------|
| {upstream} | {what this feature needs} | {what happens if unavailable} |

### Exposed Services

| Interface | Consumers | Contract Stability |
|-----------|-----------|-------------------|
| {API/Event} | {who depends on it} | Stable / Evolving / Experimental |

### Integration NFRs

- {latency, retry, consistency requirements}

---

## Prioritisation (MoSCoW)

### Must Have (MVP)
- FR-{MODULE}-{NAME}: {title}
{5-10 items. ≤10 enforced.}

### Should Have (v1)
- FR-{MODULE}-{NAME}: {title}

### Could Have (Future)
- {enhancement idea}

### Won't Have (Yet)
- {excluded item} — Reason: {why}

## Dependency Graph

```
FR-A ──> FR-B ──> FR-C
  |                 |
  +──> FR-D      FR-E
```

---

## Domain Validation

- [ ] All discovery requirements mapped to at least one FR
- [ ] Security criteria present on security-sensitive FRs
- [ ] Compliance criteria present where regulations apply
- [ ] All integration points have corresponding NFRs
- [ ] All personas referenced by at least one FR

### Coverage Matrix

| Requirement Area | Mapped FRs | Use Cases | Status |
|-----------------|------------|-----------|--------|
| {area} | FR-{MODULE}-{NAME} | UC-{MODULE}-{NNN} | Covered / Gap |

---

## Document Approval

| Role | Name | Status | Date |
|------|------|--------|------|
| Product Owner | {name} | Approved / Pending | {date} |
| Tech Lead | {name} | Approved / Pending | {date} |

**Approval means:** Requirements are correct and complete enough to begin
technical design. It does NOT mean requirements are frozen — the Document
History table tracks subsequent changes.
```

---

## Mandatory Sections (COMPREHENSIVE)

Every COMPREHENSIVE PRD must contain ALL of these H2 sections in this order:

1. `## Document History`
2. `## Table of Contents`
3. `## Problem Statement`
4. `## Goals`
5. `## Non-Goals`
6. `## Success Metrics`
7. `## User Personas`
8. `## Assumptions & Constraints`
9. `## Use Cases`
10. `## Functional Requirements`
11. `## Non-Functional Requirements`
12. `## Integration Points`
13. `## Prioritisation (MoSCoW)`
14. `## Domain Validation`
15. `## Document Approval`

Optional H2 sections (add when relevant, after Domain Validation):
- `## Appendix: API Endpoint Summary (Indicative)`
- `## Appendix: Database Tables (Indicative)`

---

## Naming Conventions

| Element | Format | Example |
|---------|--------|---------|
| Goals | **G{n}:** | **G1:** Reduce time-to-access |
| Non-Goals | **NG{n}:** — Reason: | **NG1:** Mobile — Reason: desktop-only |
| Assumptions | **A{n}:** | **A1:** API handles load |
| Constraints | **C{n}:** | **C1:** Must use existing schema |
| FR IDs | FR-{MODULE}-{DESCRIPTIVE-NAME} | FR-APP-REGISTER |
| NFR IDs | NFR-{MODULE}-{DESCRIPTIVE-NAME} | NFR-APP-RESPONSE-TIME |
| UC IDs | UC-{MODULE}-{NNN} | UC-APP-001 |
| Personas | ### P{n}: {Role Title} | ### P1: Platform Administrator (Primary) |
| Epics | ### Epic: {Name} | ### Epic: User Lifecycle |
| MoSCoW | ### Must Have (MVP) | fixed heading text |

---

## Strict Rules

1. FR IDs are DESCRIPTIVE, never sequential numbers
2. NFR targets contain specific numbers, never adjectives
3. Every persona has exactly 6 sub-fields: Goals, Pain Points, Current Workaround, Success Criteria, Tech Level, Frequency
4. Assumptions use bullet format with **A{n}:** prefix, not tables
5. Constraints use bullet format with **C{n}:** prefix, not tables
6. Open Questions table has 6 columns: #, Question, Context, Status, Decision, Owner
7. Risks table has 4 columns: Risk, Likelihood, Impact, Mitigation
8. Integration Points uses H3 headings: "Consumed Services", "Exposed Services"
9. MoSCoW headings: "Must Have (MVP)", "Should Have (v1)", "Could Have (Future)", "Won't Have (Yet)"
10. Document Approval table columns: Role, Name, Status, Date (in that order)
11. No ambiguity words in acceptance criteria
12. At least one error/edge case acceptance criterion per Must Have FR
