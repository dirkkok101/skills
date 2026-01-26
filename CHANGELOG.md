# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
