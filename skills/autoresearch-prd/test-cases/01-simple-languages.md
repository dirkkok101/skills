# Test Case: Languages & Translation Keys

## Difficulty: Simple (standard CRUD with two sub-entities sharing parallel structure; no cross-module security complexity)

## Input — What the skill receives

```
Feature: Languages & Translation Keys
Project: NxGN Identity Platform
Module Prefix: LANG (languages), TKEY (translation keys)

Problem Context:
  Identity manages session language preferences (Session.LanguageId) and provides
  translation infrastructure, but has no Language master entity backing either.
  The LanguageId field is a dangling FK with no catalog. Each NxGN application
  maintains its own independent language list — no single source of truth.

Upstream: brainstorm/languages/brainstorm.md exists
Discovery: N/A
Scope: COMPREHENSIVE

Personas:
  - P1: Platform Admin — manages language catalog and translation keys via web UI
  - P2: App Developer — integrates with language APIs from consuming applications

Key Domain Concepts:
  - Languages: master catalog of platform-supported languages (Code, Name, NativeName)
  - Translation Keys: Identity UI string translations keyed by language
  - Session FK: Session.LanguageId should reference Language table
  - Seed data: English defaults seeded on startup
  - Lookup endpoint: consumers query Identity for supported languages
  - Map endpoint: bulk translation key retrieval for frontend rendering

Operations:
  Languages: Save, Get, GridList, Delete, Lookup, Seed, SessionFK
  Translation Keys: Save, Get, GridList, Delete, Seed, Map

Dependencies: Sessions PRD (Session.LanguageId FK)

Epics:
  1. Language Lifecycle (CRUD + lookup + seed + session FK)
  2. Translation Key Lifecycle (CRUD + seed + map)
  3. Frontend (language admin page, translation key admin page)
```

## Expected Output — Files that should be generated

### Primary
- `docs/prd/languages/prd.md`

## Ground Truth Location

```
~/nxgn.identity/main/docs/prd/languages/prd.md
```

## Evaluation Checklist

### Structure (20 points)
- [ ] Metadata table with Version, Date, Author, Status, Scope, Brainstorm, Discovery
- [ ] Depends On field in metadata (Sessions PRD)
- [ ] Document History table
- [ ] Table of Contents
- [ ] Problem Statement with Impact list and Why now
- [ ] Goals section (5 items expected)
- [ ] Non-Goals section (5+ items)
- [ ] Success Metrics table
- [ ] User Personas (P1, P2)
- [ ] Assumptions (numbered A1-An, at least 8)
- [ ] Constraints (numbered C1-Cn, at least 5)
- [ ] Risks table
- [ ] Open Questions table with resolution tracking
- [ ] Use Cases section with index
- [ ] Functional Requirements with 3 Epics
- [ ] NFR section (6+ NFRs)
- [ ] Integration Points (Consumed/Exposed)
- [ ] MoSCoW Prioritisation with Dependency Graph
- [ ] Domain Validation with Coverage Matrix
- [ ] Document Approval section

### Pattern Compliance (15 points)
- [ ] FR IDs use FR-LANG-* and FR-TKEY-* prefixes (dual family)
- [ ] NFR IDs use NFR-LANG-* prefix
- [ ] FR IDs are descriptive (FR-LANG-SAVE not FR-LANG-001)
- [ ] FRs have user story format (As a...)
- [ ] FRs have Given/When/Then acceptance criteria
- [ ] FRs have Priority (Must/Should/Could/Won't)
- [ ] FRs have Complexity (S/M/L/XL)
- [ ] NFRs have Target with specific numbers
- [ ] NFRs have Measurement method
- [ ] NFRs have Rationale
- [ ] Assumptions numbered A1-An
- [ ] Constraints numbered C1-Cn
- [ ] No ambiguity words in acceptance criteria
- [ ] Error/edge case criteria present (not just happy path)
- [ ] Personas referenced in FR user stories

### Content Quality (10 points)
- [ ] Two parallel CRUD families (Language + Translation Key) with consistent structure
- [ ] Seed idempotency mentioned as NFR or acceptance criterion
- [ ] Session FK completion as explicit FR
- [ ] Lookup and Map endpoints as distinct FRs
- [ ] Consumer integration pattern documented in Integration Points
- [ ] Cascade delete behavior addressed (language with translation keys)
- [ ] Frontend UI FRs separate from backend FRs
- [ ] At least one audit-related NFR
- [ ] Security criteria on state-changing FRs
- [ ] ADR references where applicable
