---
name: qa
description: >
  Use after /execute, before /review, when user says "QA", "test the app",
  "browser test", "check the UI", or for any feature with UI changes.
argument-hint: "[feature-name] or [URL]"
---

# QA: Test Like a Real User

**Philosophy:** The best test is the one that finds the bug before users do. Automated tests verify code logic; QA verifies user experience. Click the buttons, fill the forms, navigate the flows — and document every failure with screenshots and reproduction steps. Self-regulation prevents the QA process itself from causing more harm than good.

**Duration targets:** BRIEF ~10-15 minutes (quick smoke test), STANDARD ~20-40 minutes (full feature QA), COMPREHENSIVE ~40-60 minutes (exhaustive including edge cases and accessibility).

## Why This Matters

Unit and integration tests verify that code works as written. QA verifies that the application works as intended — from a user's perspective. The gap between these is where UI bugs, broken flows, accessibility failures, and confusing interactions hide. Browser-based QA catches what automated tests miss: the button that's there but invisible, the form that submits but shows no feedback, the flow that works but confuses.

---

## Trigger Conditions

Run this skill when:
- After `/execute` completes, before `/review`
- User says "QA", "test the app", "browser test", "check the UI"
- Before shipping any feature with UI changes
- After fixing review findings that affect UI

Do NOT use for:
- Backend-only changes with no UI impact
- API-only testing → use integration tests
- Performance testing → use `/benchmark`

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user. Do not present options as plain markdown text — use the tool.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Coverage |
|------|------|----------|
| **BRIEF** | Quick smoke test, small UI change | Happy path only, console errors, visual check |
| **STANDARD** | Typical feature QA | Happy path + error paths + form validation + accessibility basics |
| **COMPREHENSIVE** | Pre-release, complex UI | All paths + edge cases + accessibility audit + responsive + performance basics |

---

## Collaborative Model

```
Phase 1: Scope & Setup
Phase 2: Diff-Aware Test Planning
Phase 3: Execute Tests (with self-regulation)
  ── PAUSE 1: "QA complete. Health score: {grade}." ──
Phase 4: Report & Baseline
```

---

## Prerequisites

Before starting, verify:
- Application is running locally (dev server started)
- Build succeeds
- If browser automation tools are available (Playwright MCP, Puppeteer, browser-use, or similar headless browser tools in your tool list), use them for automated testing. Otherwise, instruct user to test manually with the report as a checklist.

---

## Critical Sequence

### Phase 1: Scope & Setup

**Step 1.1 — Identify Target Pages:**

**Diff-aware mode (default):** Detect affected pages from the execution manifest and git diff:

1. Read `docs/execution/{feature}/manifest.md` for files changed
2. Map changed frontend files to UI routes using the project's framework conventions:
   - Component/page files → the route they serve
   - Service/store/hook files → all routes that consume them
   - Routing configuration files → all referenced routes
   - Check the project's CLAUDE.md for framework-specific file patterns
3. Map changed backend files to affected UI:
   - Endpoint changes → pages that call these endpoints
   - Model/schema changes → forms/grids displaying these models

**Manual mode:** User specifies URLs or pages to test.

**Step 1.2 — Detect Dev Server:**

Auto-detect the local development server:
- Check for common ports: 4200 (Angular), 3000 (React/Next), 5173 (Vite), 8080
- Check `package.json` scripts for dev server configuration
- Ask user if auto-detection fails

**Step 1.3 — Capture Baseline (if first run):**

If no baseline exists at `docs/qa/baseline.json` (or project equivalent), capture one:
- Console error count per page
- Page load times
- Screenshot of each target page

---

### Phase 2: Diff-Aware Test Planning

**Step 2.1 — Build Test Matrix:**

For each target page, plan tests based on mode:

```markdown
## Test Matrix

| Page | Happy Path | Error Path | Forms | Accessibility | Responsive |
|------|-----------|-----------|-------|--------------|------------|
| {route} | ✅ | {STD+} | {if forms} | {STD+} | {COMP} |
```

**Step 2.2 — Map to UC Tags (if available):**

If execution manifest has UC references, map QA tests to use cases:
- UC main scenario steps → happy path tests
- UC extension flows → error path tests
- UC alternative flows → edge case tests

---

### Phase 3: Execute Tests

**For each target page, execute tests with self-regulation:**

**Test categories and weights:**

| Category | Weight | What to Check |
|----------|--------|---------------|
| Console Errors | 15% | New JS errors, unhandled promise rejections, failed network requests |
| Functional | 20% | Buttons work, forms submit, navigation flows, data loads |
| Forms & Validation | 15% | Required fields, error messages, submit/cancel, invalid input handling |
| Visual | 10% | Layout correct, no overlapping elements, text readable, images load |
| Accessibility | 15% | Keyboard navigation, ARIA labels, colour contrast, screen reader basics |
| Responsive | 10% | Mobile viewport, tablet viewport, no horizontal scroll |
| Performance | 5% | Page load <3s, no infinite spinners, no layout shift |
| Data | 10% | Correct data displayed, pagination works, empty states handled |

**Self-Regulation (WTF-Likelihood Heuristic):**

Track a running risk score starting at 0:

| Event | Score Impact |
|-------|-------------|
| Found a real bug | +0 (expected) |
| Test caused an app crash | +15 |
| Test modified data unexpectedly | +20 |
| Browser became unresponsive | +10 |
| Test result seems wrong/flaky | +5 |

**Thresholds:**
- **Score ≥ 20 — ASK:** "QA is encountering unexpected behavior. Continue or stop?"
- **Score ≥ 40 — STOP:** "QA is causing more disruption than finding bugs. Stopping."
- **Hard cap:** Stop after 30 findings regardless of risk score

**For each finding:**

```markdown
### QA-{N}: {Title}

**Page:** {URL/route}
**Category:** {from table above}
**Severity:** Critical / High / Medium / Low
**UC Reference:** {UC-ID if mapped, or "N/A"}

**Steps to Reproduce:**
1. Navigate to {page}
2. {action}
3. {action}

**Expected:** {what should happen}
**Actual:** {what happens}

**Screenshot:** {if browser available, include screenshot reference}
**Console Errors:** {if any, include relevant error}
```

---

### Phase 4: Report & Baseline

**Step 4.1 — Calculate Health Score:**

Weight findings by category and severity:

```markdown
## QA Health Score

| Category | Weight | Issues Found | Weighted Score |
|----------|--------|-------------|---------------|
| Console Errors | 15% | {count} | {score} |
| Functional | 20% | {count} | {score} |
| ... | ... | ... | ... |
| **Total** | **100%** | **{total}** | **{grade}** |

**Scoring:** Each finding contributes to the weighted score based on severity:
- Critical: `category_weight × 4`
- High: `category_weight × 3`
- Medium: `category_weight × 2`
- Low: `category_weight × 1`

**Grade:** A (weighted score <5) / B (5-15) / C (16-30) / D (31-50) / F (>50)
```

**Step 4.2 — Write Report:**

Save to `docs/reviews/qa-{timestamp}.md`.

**Step 4.3 — Update Baseline:**

Save current state as baseline for future regression detection.

**PAUSE 1:** Present the health score and finding summary as formatted markdown, then:

```
AskUserQuestion:
  question: "QA complete. Health score: {grade}. {N} findings ({critical} critical). How to proceed?"
  header: "QA"
  multiSelect: false
  options:
    - label: "Fix critical (Recommended)"
      description: "Create beads for critical/high findings."
    - label: "Accept report"
      description: "Proceed to /review with QA findings noted."
    - label: "Retest"
      description: "Fix issues manually, then re-run QA on affected pages."
    - label: "Full report"
      description: "Walk through each finding in detail."
```

---

## Anti-Patterns

**Testing Without Scope** — Testing every page in the application instead of focusing on pages affected by the current changes. Diff-aware scoping exists to prevent wasted effort. Test what changed.

**Ignoring Self-Regulation** — Continuing to test when the risk score is high. If QA is crashing the app or corrupting data, stop. The point of QA is to find bugs, not create new ones.

**No Reproduction Steps** — "The page looks wrong" is not a finding. Every finding needs exact reproduction steps, expected vs actual behavior, and ideally a screenshot. Without these, the finding is unfixable.

**Testing in Production** — QA runs against the local dev server, never production. The point is to catch issues before they ship.

**Manual-Only Testing** — If agent-browser is available, use it. Manual testing is a fallback, not the default. Automated browser testing is faster, more consistent, and produces better documentation.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| Grade A-B | Feature is solid | Proceed to `/review` |
| Grade C | Issues found | Fix critical items, then `/review` |
| Grade D-F | Significant issues | Return to `/execute` to fix |
| Self-regulation triggered | QA causing harm | Stop, investigate, resume carefully |

When complete: **"QA complete. Health score: {grade}. Report at `docs/reviews/qa-{timestamp}.md`."**

---

*Skill Version: 1.0*
*v1.0: Initial release. Diff-aware scoping from execution manifest, 8-category health scoring, WTF-likelihood self-regulation heuristic, UC tag mapping, baseline capture for regression detection. Inspired by gstack's /qa browser-based testing patterns.*
