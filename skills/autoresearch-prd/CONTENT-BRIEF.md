# Content Brief: Autoresearch for Document Quality

Source material for blog posts, Twitter threads, and case studies. Extracted from the autoresearch refinement session on the NxGN Identity project (15 modules, 30 documents, 7 skills).

---

## The One-Liner

We applied Karpathy's autoresearch technique to document quality — PRDs, technical designs, and implementation plans — and converged 30 documents to zero defects using automated review-fix-re-review loops.

## The Hook (for Twitter/LinkedIn)

"We went from 68 defects across 30 documents to zero. Not by reviewing harder — by automating the review-fix-re-review loop. Here's how Karpathy's autoresearch technique works on documentation, not just ML."

---

## Key Numbers

| Metric | Value | Context |
|--------|-------|---------|
| Documents reviewed | 30 | 15 PRDs + 15 technical designs |
| Starting defects | 68 FAILs | First automated review pass |
| Manual fix rounds | 3 | Plateaued at 47-48 FAILs |
| After CONVERGE | 0 FAILs | Every module converged |
| Total findings resolved | 128 | 74 PRD + 54 design |
| Decisions escalated | 12 of 128 | 9.4% — rest fully automated |
| Average convergence rounds | 2.1 | Max was 3 |
| False positive rate | 0 | Every finding was a real issue |
| Skills improved | 7 | Through 4 production feedback cycles |
| Plan convergence | 6/6 modules | avg 1.7 rounds |

## The Narrative Arc

### Act 1: The Problem
- 15 PRDs and 15 technical designs in an identity platform project
- Written by different agents at different times, no consistency
- No way to know if a PRD would produce a consistent design, or if a design satisfied all requirements
- Portal PRD scored 70% on structural compliance. Authentication 77%.

### Act 2: The Karpathy Insight
- Karpathy's autoresearch works on any domain with a frozen metric
- Our frozen metric: FAIL count from review skills
- The "model" being optimized: the document itself
- The "training loop": review → classify → fix → re-review → converge

### Act 3: Building the Evaluation Function
- Created evaluate.sh (87 deterministic checks for PRDs)
- Created canonical structure reference (the "ground truth")
- Ran against all 15 PRDs — Languages scored 100%, Portal scored 70%
- **Key insight:** making conventions explicit (not just shown in templates) was the single highest-impact change

### Act 4: The Manual Fix Plateau
- Round 1 review: 68 FAILs across 15 designs
- Structural fixes (13 parallel agents): 68 → 47 FAILs
- Content fixes (12 user decisions, 8 parallel agents): 47 → 48 FAILs
- **Manual rounds plateaued.** Each fix exposed adjacent inconsistencies (cascade effect).

### Act 5: CONVERGE Breaks Through
- Built the autoresearch CONVERGE loop into review skills
- Classified findings: MECHANICAL (auto-fix) vs DECISION (escalate)
- Ran 15 parallel CONVERGE agents
- **Every module converged to 0 FAILs in 2-3 rounds**
- The cascade problem was solved by the cascade check: grep after each fix

### Act 6: Production Feedback Loop
- Each production run generated user feedback
- Feedback was applied to skills between runs
- Skills evolved through 4 cycles:
  1. Entitlements design → progressive loading, justified deviations
  2. Applications design → authority hierarchy, substance over form
  3. API Keys PRD → Phase 1 chunking, WARN triage, NFR template
  4. Sessions/Audit/Portal plans → non-greenfield fast path, verification mode

### Act 7: The Full Pipeline
- PRD → review-prd CONVERGE: 15/15 converged (avg 2.1 rounds)
- Design → review-design CONVERGE: 15/15 converged (avg 2.1 rounds)
- Plan → review-plan CONVERGE: 6/6 converged (avg 1.7 rounds)
- **Zero FAILs across the entire documentation suite**

---

## Quotable Insights

### On the technique
- "The frozen metric is the key — as long as the evaluation function doesn't change during the loop, convergence is achievable."
- "Manual fix rounds plateaued at 47-48 FAILs. Each fix exposed adjacent inconsistencies. CONVERGE solved this with cascade checks — grep after each fix."
- "128 findings found and resolved. 12 needed human decisions. The rest were fully automated."

### On making conventions explicit
- "23 of 24 structural conventions were implicit — shown in templates but never stated as rules. Making them explicit was the single highest-impact change."
- "A design that covers auth thoroughly in bullets under 'Security Model' is better than one with perfect heading format and shallow content. Substance over form."

### On the greenfield bias
- "The plan skill produced a 7-task build plan for a module that's 95% complete. The gap analysis revealed only 4 misalignments. Without it, we'd have created beads for work that already exists."
- "For non-greenfield work, the question isn't 'what to build' — it's 'what to fix.'"

### On the MECHANICAL vs DECISION classification
- "Of 128 findings, only 12 needed human decisions (9.4%). The authority hierarchy made everything else unambiguous: ADRs > patterns > architecture > PRD > api-surface > diagrams > tests."
- "A wrong automated decision is worse than an unfixed finding. Never guess on a DECISION."

### On production feedback
- "The skill improved through 4 production feedback cycles. Each run surfaced friction points that made the next run smoother. This IS the Karpathy loop — just applied to the skill itself, not just the documents."

---

## Blog Post Structure (suggested)

### Title Options
- "From 68 Defects to Zero: Applying Karpathy's Autoresearch to Documentation"
- "The Frozen Metric: How We Used Autoresearch to Converge 30 Documents to Zero Defects"
- "Beyond ML: Autoresearch for Document Quality Convergence"

### Outline
1. **The problem** — inconsistent documentation across 15 modules, no way to verify requirements flow through to implementation
2. **The insight** — Karpathy's autoresearch works on any frozen metric, not just ML loss
3. **The evaluation function** — review skills as deterministic scorers (87 checks, FAIL/WARN)
4. **The loop** — review → classify (MECHANICAL/JUSTIFIED_DEVIATION/DECISION) → fix → re-review
5. **The plateau** — manual rounds stuck at 47-48 FAILs (cascade effect)
6. **The breakthrough** — CONVERGE mode with cascade check: 68 → 0 FAILs
7. **The authority hierarchy** — how to make MECHANICAL classification unambiguous
8. **The non-greenfield insight** — plans for existing code need gap analysis first
9. **The numbers** — 128 findings, 12 decisions, 2.1 avg rounds, 0 false positives
10. **How to apply this** — any domain with structured review + deterministic scoring

---

## Twitter Thread (draft)

**Thread: How we used @kaboratohim's autoresearch technique on documentation (not ML) and converged 30 documents to zero defects**

1/ We had 15 PRDs and 15 technical designs. Written by different agents at different times. No consistency. Portal PRD scored 70%. Authentication 77%. We needed a systematic way to fix everything.

2/ The insight: Karpathy's autoresearch works on ANY frozen metric. ML loss, bundle size, or in our case — review FAIL count. The document is the model. The review skill is the evaluation function. The fix agent is the optimizer.

3/ First, we built the evaluation function: 87 deterministic checks for PRDs, 57 for designs. Every check has a citation (which template rule it enforces). No opinions — only verifiable claims.

4/ Then we made conventions explicit. 23 of 24 structural conventions were IMPLICIT — shown in templates but never stated as rules. Making them explicit was the single highest-impact change. PRD compliance went from 70-100% range to 97-100%.

5/ We ran reviews across all 15 designs in parallel. Found 68 FAILs. Fixed them with 13 parallel agents. Re-reviewed: 47 FAILs. Fixed again: 48 FAILs. PLATEAU. Each fix exposed adjacent inconsistencies.

6/ So we built CONVERGE mode into the review skills. The loop: review → classify findings (MECHANICAL vs DECISION) → auto-fix mechanicals → re-review → repeat until 0 FAILs.

7/ The key innovation: MECHANICAL vs DECISION classification. An authority hierarchy (ADRs > patterns > PRD > api-surface > diagrams > tests) makes most fixes unambiguous. Only 12 of 128 findings needed human decisions (9.4%).

8/ After each fix: CASCADE CHECK. Grep the directory for terms related to the fix. This caught the stale references that manual rounds missed. The cascade problem — fixing one doc invalidates another — was solved by searching after each fix.

9/ Result: EVERY module converged to 0 FAILs. 15 PRDs, 15 designs, 6 plans. Average 2.1 rounds. Zero false positives.

10/ The technique is domain-agnostic. You need: (1) a structured review skill with FAIL/WARN (2) an authority hierarchy for conflict resolution (3) a classify → fix → re-review loop with cascade check. Works on PRDs, designs, plans, any doc with a checklist.

11/ Production feedback made it better. Each run generated user feedback. We applied it between runs. The SKILL improved through 4 cycles — same Karpathy loop, applied to the skill itself.

12/ Full details: [link to blog]. Built with @AnthropicAI Claude Code. Inspired by @kaboratohim autoresearch and @davebcn87 pi-autoresearch.

---

## Visual Assets (suggested)

1. **Score trajectory chart:** 68 → 47 → 48 (plateau) → 0 FAILs
2. **Before/after PRD comparison:** Portal at 70% vs 98%
3. **The loop diagram:** review → classify → fix → cascade check → re-review
4. **Authority hierarchy pyramid:** ADRs at top → READMEs at bottom
5. **Convergence table:** all 15 modules with rounds and FAILs

---

## Related Content to Reference

- [karpathy/autoresearch](https://github.com/karpathy/autoresearch) — original technique
- [davebcn87/pi-autoresearch](https://github.com/davebcn87/pi-autoresearch) — domain-agnostic version
- [@itsolelehmann](https://x.com/itsolelehmann/status/2033919415771713715) — autoresearch for Claude Code skills (259K views)
- [Hybrid Horizons: The Frozen Metric](https://hybridhorizons.substack.com/p/the-frozen-metric-of-autoresearch) — essay on frozen evaluation functions
