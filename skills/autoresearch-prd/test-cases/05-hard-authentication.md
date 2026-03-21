# Test Case: Authentication

## Difficulty: Hard (security-heavy, cross-module integration contracts, token profile as first-class contract, OIDC conformance, phase deferrals, 9 document history versions, all 7 OQs resolved with detailed decisions)

## Input — What the skill receives

```
Feature: Authentication
Project: NxGN Identity Platform
Module Prefix: AUTH

Problem Context:
  Identity needs a complete authentication subsystem built on OpenIddict: BFF
  (Backend-For-Frontend) authorization code flow for web apps, client credentials
  for M2M, token profile contract, local credential management (password + MFA),
  and logout. Must pass OpenID Foundation Conformance Suite. Token profile defines
  the contract between Identity (issuer) and all consuming applications.

Upstream: brainstorm exists
Discovery: security analysis exists
Scope: COMPREHENSIVE

Personas:
  - P1: End User — authenticates via web app, manages MFA
  - P2: App Developer — integrates with auth flows, consumes token claims
  - P3: Platform Admin — configures auth policies, manages credential policies

Key Domain Concepts:
  - BFF Authorization Code Flow: PKCE + SameSite cookies + custom CSRF header
  - Client Credentials: M2M token issuance (no user context)
  - Token Profile: at+jwt, claims contract (sub, tenant_id, language_id, security_epoch, sid)
  - M2M detection rule: absent tenant_id + sid, NOT absent sub
  - Local Credentials: password hashing (Argon2id), password policies, lazy hash upgrade
  - MFA: TOTP (authenticator app), backup codes
  - Logout: RP-initiated + back-channel
  - Three-layered CSRF: SameSite + custom header + origin validation
  - Security epoch: per-user counter for mass token invalidation
  - Phase 1: bearer + PKCE + rotation + epoch
  - Phase 2: Guardian Mobile DPoP (deferred)

Operations:
  BFF Flow, Client Credentials, Token Profile, Local Credentials (hash, policy, upgrade),
  MFA TOTP (enable, verify, disable), MFA Backup Codes, Logout (RP-initiated, back-channel),
  Magic Link (Should Have), Device Code (Should Have), Account Linking (Should Have)

Dependencies: Sessions PRD (security_epoch), Users PRD, Organizations PRD, API Keys PRD, Roles PRD

Epics:
  1. BFF Authorization Code Flow
  2. Client Credentials (M2M)
  3. Token Profile
  4. Local Credential Management
  5. MFA: TOTP
  6. MFA: Backup Codes
  7. Logout
  8. Deferred Auth Methods (Magic Link, Device Code, Account Linking)
```

## Expected Output — Files that should be generated

### Primary
- `docs/prd/authentication/prd.md`

## Ground Truth Location

```
~/nxgn.identity/main/docs/prd/authentication/prd.md
```

## Evaluation Checklist

### Structure (20 points)
- [ ] Metadata table
- [ ] Document History (multiple iterations — adversarial review rounds visible)
- [ ] Table of Contents
- [ ] Problem Statement with Impact list
- [ ] Goals
- [ ] Non-Goals
- [ ] Success Metrics table
- [ ] User Personas (P1, P2, P3)
- [ ] Assumptions (numbered)
- [ ] Constraints (numbered)
- [ ] Risks table (7+ items for security-heavy module)
- [ ] Open Questions table (all resolved with decisions)
- [ ] Use Cases (cross-module + module-specific)
- [ ] Functional Requirements across 8 Epics
- [ ] NFR section (6 NFRs)
- [ ] Integration Points with cross-module contracts
- [ ] MoSCoW Prioritisation
- [ ] Domain Validation
- [ ] Document Approval
- [ ] Dependency references to Sessions, Users, API Keys

### Pattern Compliance (15 points)
- [ ] FR IDs use FR-AUTH-* prefix
- [ ] NFR IDs use NFR-AUTH-* prefix
- [ ] Descriptive IDs
- [ ] FRs have user story format
- [ ] Given/When/Then acceptance criteria
- [ ] Priority and Complexity
- [ ] NFRs with measurable targets
- [ ] Numbered assumptions/constraints
- [ ] No ambiguity words
- [ ] Error paths in acceptance criteria (especially auth failures)
- [ ] Security Criteria on every FR
- [ ] Compliance Criteria where applicable
- [ ] Phase deferral clearly marked (Phase 2 items in Should Have / Won't Have)
- [ ] Cross-module integration contracts table
- [ ] Resolved OQs documented with decisions and owners

### Content Quality (15 points)
- [ ] OIDC conformance as first-class NFR
- [ ] Token profile documented as contract (claim names, types, M2M detection rule)
- [ ] M2M detection rule explicit (absent tenant_id + sid, not absent sub)
- [ ] Three-layered CSRF documented
- [ ] Security epoch integration with Sessions PRD
- [ ] Argon2id or equivalent hashing standard specified
- [ ] Password policy documented (not just "secure passwords")
- [ ] TOTP implementation details (RFC 6238, QR code provisioning)
- [ ] Backup codes one-time-use, pre-generated
- [ ] Logout covers both RP-initiated and back-channel
- [ ] Phase 2 Guardian DPoP deferred with rationale
- [ ] Lazy hash upgrade pattern (migrate old hashes on successful login)
- [ ] Token size NFR (JWT size limits for cookie transport)
- [ ] Cross-module references (Sessions for epoch, API Keys for M2M)
- [ ] 400 vs 422 error distinction in auth endpoints
