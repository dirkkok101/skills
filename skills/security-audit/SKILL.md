---
name: security-audit
description: >
  Use after /review, before /ship, when user says "security audit", "security
  review", "check for vulnerabilities", or before shipping auth, payment, or
  data features. READ-ONLY — never modifies code.
argument-hint: "[feature-name] or --diff or --scope auth"
---

# Security Audit: Zero-Noise Vulnerability Assessment

**Philosophy:** Security findings must be actionable, not aspirational. Every finding requires a concrete exploit scenario — "an attacker could..." not "this might be vulnerable." Framework-aware scanning recognises built-in protections and doesn't flag them as missing. Zero-noise means developers trust the findings and act on them, instead of learning to ignore a wall of false positives.

**Duration targets:** BRIEF ~10-15 minutes (diff-only, focused scope), STANDARD ~20-40 minutes (full feature), COMPREHENSIVE ~40-60 minutes (full codebase section + threat model).

**IMPORTANT: This skill is READ-ONLY. It never modifies code. It produces a report with findings and recommendations. Fixes are implemented by the developer or by returning to /execute.**

## Why This Matters

Security vulnerabilities in production code are among the most expensive defects to fix. The cost multiplier grows exponentially: a SQL injection caught in code review costs minutes; caught in penetration testing costs hours; caught after a breach costs reputation, legal fees, and customer trust. Automated security scanning catches the mechanical vulnerabilities that humans consistently miss — the ones hiding in plain sight.

---

## Trigger Conditions

Run this skill when:
- Before shipping features that handle authentication, authorisation, or user data
- Before shipping payment or financial processing features
- After `/review` and before `/ship` for any STANDARD+ scope feature
- User says "security audit", "security review", "check for vulnerabilities"
- Regulatory or compliance requirements mandate security review

Do NOT use for:
- Code quality review → `/review`
- Performance issues → different investigation
- Features with no security surface (pure UI styling, documentation)

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool. The YAML blocks at each PAUSE point show the exact parameters to pass.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Scope |
|------|------|-------|
| **BRIEF** | Diff-only scan, small change | Only files changed since main. Quick OWASP check. |
| **STANDARD** | Full feature audit | All files in the feature. OWASP Top 10 + basic STRIDE. |
| **COMPREHENSIVE** | Pre-release, auth/payment features | Full OWASP + STRIDE threat model + dependency audit + ADR security review. |

**Scope modifiers** (pass as part of the argument, e.g., "/security-audit auth diff-only"):
- **diff-only** — Only scan files changed since main (forces BRIEF)
- **scope: {area}** — Focus on specific area (auth, data, api, payment)
- **owasp-only** — OWASP Top 10 checklist only
- **supply-chain** — Dependency/supply chain audit only

---

## Collaborative Model

```
Phase 1: Scope & Context
Phase 2: Framework-Aware Scanning
Phase 3: STRIDE Threat Model (STANDARD+)
Phase 4: Findings & Report
  ── PAUSE 1: "Security audit complete. {N} findings." ──
```

---

## Prerequisites

Before starting, verify:
- Build succeeds (ensures code is parseable)
- Understand the tech stack (read CLAUDE.md for framework info)
- If upstream docs exist (PRD, design), note any security requirements or NFRs

---

## Critical Sequence

### Phase 1: Scope & Context

**Step 1.1 — Identify Target:**

Determine what to scan based on mode and scope modifiers:

```bash
# BRIEF (diff-only)
git diff main --name-only

# STANDARD (feature files)
# Read execution manifest or locate feature directory

# COMPREHENSIVE (broad)
# All source files in affected services/projects
```

**Step 1.2 — Identify Framework Protections:**

Read the project's CLAUDE.md and identify built-in security protections from the tech stack. Understanding what the framework handles prevents false positives.

**Identify framework protections (DO NOT flag these as missing):**

Read the project's CLAUDE.md or equivalent to identify the tech stack. Then identify which security concerns are handled by the framework. Common patterns:

| Protection Category | What to Look For | Example Frameworks |
|-------------------|-----------------|-------------------|
| CSRF prevention | Anti-forgery tokens, SameSite cookies | ASP.NET Core, Django, Rails, Spring Security |
| Mass assignment prevention | DTO/model binding, allowed-field lists | ASP.NET Core model binding, Django forms, Rails strong params |
| Input validation pipeline | Framework-level request validation | FastEndpoints, Express-validator, Django REST serializers |
| SQL injection prevention | ORM parameterised queries | EF Core LINQ, Django ORM, SQLAlchemy, Hibernate |
| XSS prevention | Template auto-escaping, sanitisation | Angular templates, React JSX, Vue templates, Jinja2 |
| Session management | Framework-managed sessions | ASP.NET Core Identity, Django sessions, Passport.js |

If the project's framework handles a concern, verify it's correctly configured rather than flagging it as missing.

**Step 1.3 — Identify Security Requirements:**

If PRD or design docs exist, extract security-related requirements:
- Authentication requirements (who can access what)
- Authorisation rules (role-based, tenant-based, resource-based)
- Data protection requirements (encryption, PII handling)
- Compliance requirements (GDPR, HIPAA, SOC2)
- Security NFRs from the PRD

Record these — findings are more valuable when they reference violated requirements.

---

### Phase 2: Framework-Aware Scanning

**Run through OWASP Top 10 (2021) checklist against the target files.**

For each category, scan for vulnerabilities while respecting framework protections:

| # | Category | What to Look For | False Positive Exclusions |
|---|----------|-----------------|--------------------------|
| A01 | Broken Access Control | Missing auth attributes, direct object references, path traversal, CORS misconfiguration | Framework-provided auth middleware (if consistently applied) |
| A02 | Cryptographic Failures | Hardcoded secrets, weak hashing, plaintext sensitive data, missing TLS | Framework-managed secrets (user-secrets, key vault references) |
| A03 | Injection | Raw SQL, command injection, LDAP injection, template injection | EF Core LINQ queries, parameterised queries, Angular template binding |
| A04 | Insecure Design | Missing rate limiting, no abuse case handling, business logic flaws | N/A — design issues are always reportable |
| A05 | Security Misconfiguration | Debug endpoints in production, default credentials, unnecessary features enabled | Development-only configuration in `appsettings.Development.json` |
| A06 | Vulnerable Components | Known CVE in dependencies, outdated packages, unmaintained libraries | N/A — always reportable |
| A07 | Auth Failures | Weak password policy, missing brute-force protection, session fixation | Framework-provided identity (when correctly configured) |
| A08 | Data Integrity Failures | Insecure deserialization, unsigned updates, CI/CD pipeline vulnerabilities | Framework-managed serialization (System.Text.Json with default options) |
| A09 | Logging Failures | Missing security event logging, sensitive data in logs, no audit trail | N/A — logging gaps are always reportable |
| A10 | SSRF | Unvalidated URLs in server-side requests, internal service discovery exposure | N/A — always reportable |

**Scanning discipline:**

For each potential finding:
1. **Verify it's real** — Is this actually exploitable, or does the framework prevent it?
2. **Confidence gate** — Only report findings with confidence ≥ 8/10
3. **Write the exploit scenario** — "An attacker could {action} by {method} to {impact}"
4. **Check for mitigations** — Is there an existing mitigation that makes this lower risk?

**DO NOT report these (common false positives):**
1. Missing CSRF protection on API endpoints that use JWT (token-based auth doesn't need CSRF)
2. "Sensitive data in URL" for non-sensitive query parameters
3. Missing Content-Security-Policy on API-only services
4. "Hardcoded string" that is actually a configuration key name, not a secret
5. Missing rate limiting on internal-only endpoints
6. "Insecure direct object reference" when authorisation is checked by middleware
7. Missing input validation when the framework's validation pipeline is correctly configured
8. "SQL injection" in ORM-generated parameterised queries (EF Core LINQ, Django ORM, etc.)
9. Template expressions flagged as XSS when the framework auto-sanitises (Angular, React JSX, Vue, etc.)
10. Missing HTTPS in development-only configuration files

---

### Phase 2.5: Dependency Audit (COMPREHENSIVE only)

**Skip in BRIEF and STANDARD modes.**

Check project dependencies for known vulnerabilities:

1. **Identify lock files** — `package-lock.json`, `yarn.lock`, `bun.lockb`, `*.csproj`, `requirements.txt`, `go.sum`, `Cargo.lock`
2. **Run audit commands** — Use the project's package manager audit: `npm audit`, `dotnet list package --vulnerable`, `pip audit`, `cargo audit`
3. **Check for outdated critical dependencies** — security-relevant packages (auth libraries, crypto, HTTP clients) that are >2 major versions behind
4. **Report findings** — Only report vulnerabilities with a published CVE and a fix available

### Phase 3: STRIDE Threat Model (STANDARD+)

**Skip in BRIEF mode.**

For each component in the feature, assess threats using STRIDE:

| Threat | Question | Example Finding |
|--------|----------|-----------------|
| **S**poofing | Can an attacker pretend to be someone else? | Missing auth on endpoint, weak token validation |
| **T**ampering | Can an attacker modify data they shouldn't? | Missing integrity checks, direct DB access bypassing business rules |
| **R**epudiation | Can an attacker deny their actions? | Missing audit logging, no action attribution |
| **I**nformation Disclosure | Can an attacker access data they shouldn't? | Verbose error messages, missing authorisation on queries, PII in logs |
| **D**enial of Service | Can an attacker make the system unavailable? | Unbounded queries, missing pagination, resource exhaustion |
| **E**levation of Privilege | Can an attacker gain higher access? | Role manipulation, tenant boundary bypass, admin endpoint without auth |

**Build a threat model table:**

```markdown
## Threat Model

| Component | Threat | Risk | Mitigation | Status |
|-----------|--------|------|-----------|--------|
| {endpoint} | Spoofing | High | Auth attribute required | ✅ Mitigated |
| {endpoint} | Info Disclosure | Medium | Authorisation check | ❌ Missing |
| {data store} | Tampering | High | Business rule enforcement | ✅ Mitigated |
```

---

### Phase 4: Findings & Report

**Step 4.1 — Compile Findings:**

Write the report to `docs/reviews/security-audit-{timestamp}.md`:

```markdown
# Security Audit: {Feature Name}

> **Date:** {date}
> **Scope:** {BRIEF/STANDARD/COMPREHENSIVE} — {description of what was scanned}
> **Framework:** {tech stack from CLAUDE.md}
> **Files Scanned:** {count}

## Executive Summary

**Findings:** {count} ({critical}/{high}/{medium}/{low})
**Threat Model:** {STRIDE coverage if STANDARD+}
**Overall Risk:** {Critical / High / Medium / Low / Minimal}

## Critical Findings (Confidence ≥ 8/10)

### F1. {Title}
| Field | Value |
|-------|-------|
| **OWASP** | {A01-A10} |
| **STRIDE** | {S/T/R/I/D/E} |
| **Severity** | {Critical/High/Medium/Low} |
| **Confidence** | {8-10}/10 |
| **File** | `{path}:{line}` |
| **Exploit Scenario** | An attacker could {action} by {method} to {impact} |
| **Recommendation** | {specific fix} |
| **FR Reference** | {FR ID if applicable, or "N/A"} |

## Threat Model (STANDARD+)

{STRIDE table from Phase 3}

## Framework Protections Verified

| Protection | Status | Notes |
|-----------|--------|-------|
| {protection} | ✅ Active | {verification method} |

## Scope Limitations

This automated security audit is not a substitute for professional penetration testing.
It covers code-level vulnerabilities in the scanned files but does not cover:
- Infrastructure and network security
- Social engineering vectors
- Physical security
- Third-party service security posture
- Runtime configuration in production
```

**PAUSE 1:** Present the executive summary (finding count, severity breakdown, overall risk) as formatted markdown, then:

```
AskUserQuestion:
  question: "Security audit complete. {N} findings ({critical} critical, {high} high). How should we proceed?"
  header: "Security"
  multiSelect: false
  options:
    - label: "Review findings"
      description: "Walk through each finding in detail."
    - label: "Accept report"
      description: "Report saved. Address findings before shipping."
    - label: "Ship anyway"
      description: "Proceed to /ship despite findings (adds security warning to PR)."
    - label: "Fix critical"
      description: "Fix critical/high findings now, defer medium/low."
```

If "Review findings", present each finding individually using Guided Review (Pattern 5).

If "Fix critical", create targeted beads or return to /execute for critical/high findings.

---

## Anti-Patterns

**Flag Everything** — Reporting low-confidence findings "just in case" trains developers to ignore security reports. The confidence ≥ 8/10 gate exists because false positives destroy trust. A report with 3 real findings is infinitely more valuable than one with 3 real findings buried in 50 false positives.

**Ignoring Framework Protections** — Flagging "missing CSRF protection" on a JWT-authenticated API endpoint shows ignorance of how the framework works. Understanding built-in protections is prerequisite knowledge, not optional context. Read the framework docs before scanning.

**Generic Recommendations** — "Add input validation" is not actionable. Specify WHAT input, WHERE it enters, and HOW to validate it. Reference the specific file and line. Generic findings get ignored; specific findings get fixed.

**Modifying Code** — This skill is READ-ONLY. Never edit source files during a security audit. Findings go in the report; fixes go through /execute or direct development. Mixing audit and fix creates confusion about what was found vs what was changed.

**Skipping Scope Limitations** — Every security audit report MUST include the scope limitations disclaimer. Automated code scanning catches a subset of vulnerabilities. Presenting the audit as comprehensive security assurance is irresponsible and potentially dangerous.

**Severity Inflation** — A missing Content-Security-Policy header is not "Critical." Severity must match exploitability and impact. Critical means "exploitable now with significant impact." Reserve it for real emergencies — when everything is critical, nothing is.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| No findings | Clean audit | Proceed to `/ship` |
| Findings reported | Issues found | Fix critical findings, then `/ship` |
| Critical findings | Serious issues | Fix before shipping — return to `/execute` |
| User accepts report | Acknowledged | Proceed to `/ship` (findings noted in PR) |

When complete: **"Security audit saved to `docs/reviews/security-audit-{timestamp}.md`. {N} findings. Address critical items before shipping."**

---

*Skill Version: 1.0*
*v1.0: Initial release. OWASP Top 10 framework-aware scanning, STRIDE threat model, zero-noise reporting with confidence ≥8/10 gate, concrete exploit scenarios, 10 false positive exclusions, FR traceability, scope limitations disclaimer. Inspired by gstack's /cso zero-noise security audit.*
