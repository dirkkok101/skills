# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.8.0] - 2026-01-28

### Changed
- **workflow:review**: Added three-layer context isolation (review agents → consolidation agent → executive summary) to prevent context bloat and finding loss
- **workflow:review**: Added conditional design-intent and plan-intent agents that verify implementation against upstream design and plan documents
- **workflow:review**: Consolidation agent now writes structured summary to `.beads/review-summary.md` with executive summary first for selective reading
- **workflow:review**: Expanded from 6 to up to 8 agents (6 core + 2 conditional)
- **workflow:review**: Added project root resolution step for reliable document path handling

## [1.7.0] - 2026-01-28

### Changed
- **workflow:review**: Redesigned agent orchestration to use background execution with consolidation agent, preventing context bloat and lost findings
- **workflow:review**: Added Core Principles, Anti-Patterns sections per skill-creator guidelines
- **workflow:review**: Moved trigger conditions into frontmatter description for proper skill triggering
- **workflow:review**: Generalized build/test commands to be project-agnostic (removed hardcoded dotnet references)

## [1.6.0] - 2026-01-27

### Added
- **docs:audit**: Phased documentation audit skill for identifying gaps, staleness, and coverage issues across Diataxis, AI-optimization, architecture, and project docs
- **docs:write**: Template-routed documentation generation skill with idempotent updates for all supported doc types (CLAUDE.md, AGENTS.md, llms.txt, README, CONTRIBUTING, ADRs, C4/arc42, and Diataxis guides)
- **docs:adr**: Architectural Decision Record skill using MADR format with full status lifecycle (proposed, accepted, deprecated, superseded)
- Unified version tracking across all plugins (workflow + docs)

## [1.5.0] - 2026-01-26

### Added
- **diagnose**: New skill for systematic root cause analysis of bugs and unexpected behavior
  - Evidence-driven investigation with reproduction verification
  - Adaptive triage: fix-in-place for simple bugs, beads for medium issues, brainstorm handoff for complex issues
  - Direct fix capability for isolated <20 line changes
  - Diagnostic 5 Whys for root cause analysis
  - Integration with `/compound` for learning capture after fixes

## [1.4.0] - 2026-01-26

### Changed
- Moved `marketplace.json` to `.claude-plugin/` folder per Claude Code best practices

## [1.3.0] - 2026-01-25

### Fixed
- Moved `marketplace.json` out of `.claude-plugin/` folder (reverted in 1.4.0)

## [1.2.0] - 2026-01-25

### Fixed
- Use `skills/` folder and correct namespaced invocations

## [1.1.0] - 2026-01-25

### Changed
- Version bump for plugin updates

### Fixed
- Inline SKILL.md content into command files
- Update command names from `/workflow:*` to `/*` format

## [1.0.0] - 2026-01-24

### Added
- Initial release of workflow skills plugin
- **brainstorm**: Transform rough ideas into validated designs
- **plan**: Convert validated designs into hierarchical implementation plans
- **beads**: Convert approved plans into intent-based work packages
- **execute**: Execute approved beads using sub-agent model
- **review**: Multi-perspective code review using parallel agents
- **compound**: Capture learnings from feature development
- Plugin manifest for proper skill discovery
- Project setup templates (CLAUDE.md, AGENTS.md)
