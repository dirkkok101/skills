---
name: benchmark
description: >
  Use after /execute, before /review, when user says "benchmark",
  "performance", "check speed", or before shipping performance-sensitive
  changes.
argument-hint: "[feature-name] or [URL]"
---

# Benchmark: Measure Before You Ship

**Philosophy:** Performance is a feature. Measure it, track it, and catch regressions before they ship. Bundle size is the leading performance indicator — it's cheap to measure and correlates strongly with load time. Before/after comparison on every PR prevents the slow creep that turns fast apps into slow ones.

**Duration targets:** BRIEF ~5-10 minutes (bundle size + basic timing), STANDARD ~10-20 minutes (CWV + bundle + comparison), COMPREHENSIVE ~20-40 minutes (full audit + historical trend).

## Why This Matters

Performance regressions accumulate silently. Each PR adds "just 50ms" until the app is 3 seconds slower than it was 6 months ago. Without measurement, nobody notices until users complain. Benchmarking on every feature prevents this by catching regressions at the source — before they compound.

---

## Trigger Conditions

Run this skill when:
- After `/execute` completes, before `/review`
- User says "benchmark", "performance", "check speed", "is this slower"
- Before shipping features that affect load time, bundle size, or render performance
- After optimisation work to verify improvement

Do NOT use for:
- Backend-only API performance → use load testing tools
- Database query performance → use query profiling
- Features with no performance surface

## Stage Gates — AskUserQuestion

At every PAUSE point in this skill, **call the `AskUserQuestion` tool** to present structured options to the user.

For pattern details and examples: `../_shared/references/stage-gates.md`

> **Fallback:** Only if `AskUserQuestion` is not available as a tool (check your tool list), fall back to presenting options as markdown text and waiting for freeform response.

---

## Mode Selection

| Mode | When | Measurements |
|------|------|-------------|
| **BRIEF** | Quick check, small change | Bundle size comparison only |
| **STANDARD** | Typical feature | Bundle size + page load times + Core Web Vitals |
| **COMPREHENSIVE** | Performance-sensitive feature | Full audit + historical trend + resource breakdown + budget check |

---

## Collaborative Model

```
Phase 1: Baseline Capture (if needed)
Phase 2: Current Measurement
Phase 3: Comparison & Regression Detection
  ── PAUSE 1: "Performance report. {N} regressions detected." ──
```

---

## Prerequisites

Before starting, verify:
- Build succeeds in production mode (run the project's production build command)
- If measuring page load times, the application dev server is running
- Previous baseline exists at `docs/benchmarks/baseline.json` or will be captured in Phase 1

---

## Critical Sequence

### Phase 1: Baseline Capture

**Step 1.1 — Check for Existing Baseline:**

Look for `docs/benchmarks/baseline.json` or equivalent. If it exists, use it for comparison. If not, capture one from the main branch.

**Step 1.2 — Capture Baseline (if needed):**

If no baseline exists, measure the main branch state:

Run the project's production build command (check `package.json` scripts or project CLAUDE.md):

```bash
# Build production bundle using project's build command
# Examples: ng build --prod, npm run build, next build, vite build, dotnet publish
```

Identify the build output directory from the project's build configuration, then measure file sizes of all JS and CSS bundles. Match bundles by chunk type (main, vendor, lazy), not by filename — modern bundlers use content hashing.

Record:
- Bundle sizes (main, vendor, styles, lazy chunks)
- Page load times (if browser available)
- Core Web Vitals (if browser available): LCP, FID/INP, CLS

Save to `docs/benchmarks/baseline.json`.

---

### Phase 2: Current Measurement

**Step 2.1 — Build & Measure:**

Build the current branch in production mode and capture the same metrics as baseline.

**Step 2.2 — Core Web Vitals (STANDARD+):**

If browser automation is available, measure for each target page using Lighthouse CLI (`npx lighthouse {url} --output json --chrome-flags="--headless"`), browser DevTools Performance API, or the project's existing performance tools. If no browser automation is available, measure bundle sizes only (fall back to BRIEF mode).

For timing measurements, take the median of 3 runs — network conditions and system load cause variance. Bundle sizes are deterministic and need only one measurement.

| Metric | Good | Needs Improvement | Poor |
|--------|------|-------------------|------|
| LCP (Largest Contentful Paint) | ≤2.5s | 2.5-4s | >4s |
| INP (Interaction to Next Paint) | ≤200ms | 200-500ms | >500ms |
| CLS (Cumulative Layout Shift) | ≤0.1 | 0.1-0.25 | >0.25 |

**Step 2.3 — Resource Breakdown (COMPREHENSIVE):**

Identify the slowest and largest resources:
- Top 10 largest JS bundles
- Top 5 slowest network requests
- Render-blocking resources
- Unused JS percentage

---

### Phase 3: Comparison & Regression Detection

**Step 3.1 — Compare Against Baseline:**

**Regression thresholds:**
*These are default thresholds. If the project defines performance budgets (in lighthouse config, bundlesize config, or CLAUDE.md), use those instead.*

| Metric | WARNING | REGRESSION |
|--------|---------|-----------|
| Bundle size (total) | >10% increase | >25% increase |
| Bundle size (single chunk) | >15% increase | >30% increase |
| Page load time | >20% slower | >50% slower or >500ms absolute |
| LCP | >20% slower | >50% slower or exceeds "Good" threshold |
| INP | >20% slower | >50% slower or exceeds "Good" threshold |
| CLS | >0.05 increase | >0.1 increase or exceeds "Good" threshold |

**Step 3.2 — Build Report:**

Save to `docs/benchmarks/benchmark-{timestamp}.md`:

```markdown
# Performance Benchmark: {Feature Name}

> **Date:** {date}
> **Branch:** {branch}
> **Mode:** {BRIEF/STANDARD/COMPREHENSIVE}

## Summary

| Verdict | Details |
|---------|---------|
| **Overall** | ✅ PASS / ⚠️ WARNING / ❌ REGRESSION |
| **Regressions** | {count} |
| **Warnings** | {count} |

## Bundle Size Comparison

| Bundle | Baseline | Current | Change | Status |
|--------|----------|---------|--------|--------|
| main.js | {size} | {size} | {+/-}% | ✅/⚠️/❌ |
| vendor.js | {size} | {size} | {+/-}% | ✅/⚠️/❌ |
| styles.css | {size} | {size} | {+/-}% | ✅/⚠️/❌ |
| **Total** | **{size}** | **{size}** | **{+/-}%** | **{status}** |

## Page Load Times (STANDARD+)

| Page | Baseline | Current | Change | Status |
|------|----------|---------|--------|--------|
| {route} | {time}ms | {time}ms | {+/-}% | ✅/⚠️/❌ |

## Core Web Vitals (STANDARD+)

| Metric | Baseline | Current | Change | Rating |
|--------|----------|---------|--------|--------|
| LCP | {time} | {time} | {+/-}% | Good/NI/Poor |
| INP | {time} | {time} | {+/-}% | Good/NI/Poor |
| CLS | {score} | {score} | {+/-} | Good/NI/Poor |

## Resource Breakdown (COMPREHENSIVE)

### Largest Bundles
| Bundle | Size | % of Total |
|--------|------|-----------|
| {name} | {size} | {%} |

### Slowest Resources
| Resource | Time | Type |
|----------|------|------|
| {url} | {time}ms | {js/css/img/api} |
```

**PAUSE 1:** Present the summary (verdict, regression count, key metrics) as formatted markdown, then:

```
AskUserQuestion:
  question: "Performance benchmark complete. {verdict}. How to proceed?"
  header: "Benchmark"
  multiSelect: false
  options:
    - label: "Accept (Recommended)"
      description: "Performance is acceptable. Proceed."
    - label: "Investigate regressions"
      description: "Dig into the specific regressions to find the cause."
    - label: "Optimise"
      description: "Address performance issues before proceeding."
    - label: "Update baseline"
      description: "Accept current measurements as the new baseline."
```

---

## Anti-Patterns

**Measuring in Development Mode** — Development builds include source maps, unminified code, and hot-reload overhead. Always benchmark production builds for meaningful comparisons.

**Ignoring Bundle Size** — "It's just 50KB more" — every 50KB compounds. Bundle size is the single most predictable performance metric and the easiest to track. Treat it as seriously as test coverage.

**Benchmarking Without Baseline** — A number without context is meaningless. "Page loads in 1.2s" — is that good or bad? Without a baseline, you can't detect regressions. Always capture before measuring.

**Single-Run Measurements** — Network conditions and system load vary. For timing measurements, take the median of 3 runs minimum. Bundle sizes are deterministic and need only one measurement.

**Moving the Baseline to Hide Regressions** — Updating the baseline should be a conscious decision, not an automatic step. The baseline represents the performance contract with users. Update it when you intentionally change performance characteristics, not to make warnings disappear.

---

## Exit Signals

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| PASS | No regressions | Proceed to `/review` |
| WARNING | Minor regressions | Note in review, proceed |
| REGRESSION | Significant regressions | Investigate and fix before `/review` |

When complete: **"Benchmark saved to `docs/benchmarks/benchmark-{timestamp}.md`. {verdict}."**

---

*Skill Version: 1.0*
*v1.0: Initial release. Bundle size comparison, Core Web Vitals measurement, regression thresholds, before/after comparison, resource breakdown, baseline management. Inspired by gstack's /benchmark performance engineering patterns.*
