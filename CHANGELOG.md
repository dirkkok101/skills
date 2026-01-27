# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
