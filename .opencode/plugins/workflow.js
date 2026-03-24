/**
 * OpenCode plugin for workflow-skills.
 *
 * Registers skill awareness via the session.created hook so the LLM
 * knows which workflow skills are available and when to use them.
 *
 * See: https://opencode.ai/docs/plugins/
 */

export const WorkflowSkillsPlugin = async () => {
  return {
    name: "workflow-skills",
    version: "5.0.0",

    hooks: {
      "session.created": async ({ session }) => {
        session.context = session.context || "";
        session.context += BOOTSTRAP_TEXT;
      },
    },
  };
};

const BOOTSTRAP_TEXT = `
## Workflow Skills Available (v5.0.0)

22 structured SDLC skills available. Key commands:

| Command | When to Use |
|---------|-------------|
| workflow:brainstorm | New feature, exploring approaches |
| workflow:prd | Writing formal requirements |
| workflow:technical-design | Architecture, API specs |
| workflow:plan | Breaking design into tasks |
| workflow:beads | Creating work packages |
| workflow:execute | Implementing from beads |
| workflow:review | Code review after implementation |
| workflow:diagnose | Bug investigation |
| workflow:ship | Create PR with traceability |

Pipeline: brainstorm → [prd] → [design] → plan → beads → execute → review → ship
`;
