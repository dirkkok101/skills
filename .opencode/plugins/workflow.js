/**
 * OpenCode plugin for workflow-skills.
 *
 * Injects skill awareness into the system prompt so the LLM knows
 * which workflow commands are available and when to suggest them.
 *
 * Usage:
 *   Place this file (or symlink it) into your OpenCode plugins directory,
 *   typically ~/.opencode/plugins/ or .opencode/plugins/ in your project.
 */

const PLUGIN_NAME = "workflow-skills";
const PLUGIN_VERSION = "5.0.0";

const SKILLS = [
  { name: "workflow:init",            trigger: "project setup, scaffold, initialize docs structure" },
  { name: "workflow:research",        trigger: "need background research, competitive analysis, technology survey" },
  { name: "workflow:brainstorm",      trigger: "new feature idea, problem framing, scope classification" },
  { name: "workflow:discovery",       trigger: "complex feature needing domain-aware requirements (COMPREHENSIVE scope)" },
  { name: "workflow:prd",             trigger: "formal product requirements, after brainstorm or discovery" },
  { name: "workflow:technical-design", trigger: "architecture, API specs, data models, after PRD approved" },
  { name: "workflow:plan",            trigger: "implementation plan, task decomposition, after design approved" },
  { name: "workflow:beads",           trigger: "create work packages with FR traceability, after plan approved" },
  { name: "workflow:execute",         trigger: "implement code from approved beads, sub-agent execution" },
  { name: "workflow:review",          trigger: "code review with parallel agents, after implementation" },
  { name: "workflow:review-prd",      trigger: "adversarial PRD quality review against skill template" },
  { name: "workflow:review-design",   trigger: "adversarial design review against PRD and ADRs" },
  { name: "workflow:review-plan",     trigger: "adversarial plan review against authority sources" },
  { name: "workflow:review-beads",    trigger: "adversarial bead compliance review (11 categories)" },
  { name: "workflow:review-execute",  trigger: "post-execution bead satisfaction verification" },
  { name: "workflow:compound",        trigger: "capture learnings after review, structured by phase/domain" },
  { name: "workflow:diagnose",        trigger: "bug investigation, root cause analysis, something is broken" },
  { name: "workflow:qa",              trigger: "browser-based QA testing, diff-aware scoping" },
  { name: "workflow:benchmark",       trigger: "performance benchmarking, bundle size, Core Web Vitals" },
  { name: "workflow:security-audit",  trigger: "OWASP + STRIDE security audit, zero-noise" },
  { name: "workflow:ship",            trigger: "release pipeline, changelog, PR creation with traceability" },
];

const PIPELINE = `
Scope-based routing (determined by brainstorm):
  BRIEF (0-2 pts):         brainstorm -> plan -> beads -> execute -> review -> ship
  STANDARD (3-4 pts):      brainstorm -> prd -> technical-design -> plan -> beads -> execute -> review -> ship
  COMPREHENSIVE (5+ pts):  brainstorm -> discovery -> prd -> technical-design -> plan -> beads -> execute -> review -> ship
  Bug fix:                 diagnose -> fix / beads / brainstorm
`;

function buildSystemPromptInjection() {
  const skillList = SKILLS.map(
    (s) => `- ${s.name}: ${s.trigger}`
  ).join("\n");

  return `
## Workflow Skills (${PLUGIN_NAME} v${PLUGIN_VERSION})

The following workflow skills are available. Suggest the appropriate skill when the user's request matches a trigger condition.

### Available Skills
${skillList}

### Pipeline
${PIPELINE}
### Rules
- Each phase requires explicit user approval before proceeding to the next.
- Never write implementation code until the user approves.
- All phases produce documentation under docs/.
- Requires br (beads-rust) CLI for task management.
`.trim();
}

module.exports = {
  name: PLUGIN_NAME,
  version: PLUGIN_VERSION,

  /**
   * Called by OpenCode when the plugin is loaded.
   * Returns a system prompt fragment to inject.
   */
  activate() {
    return {
      systemPrompt: buildSystemPromptInjection(),
    };
  },

  /**
   * Returns the list of skills for programmatic discovery.
   */
  skills() {
    return SKILLS;
  },
};
