# Changelog - Living Docs Skill

All notable changes to this skill will be documented in this file.

---

## [2.0.1] - 2026-02-28

### Added
- **Activation signals section** in `SKILL.md` with high-confidence EN/ES trigger phrases for documentation-from-git intents.
- **Intent-to-scope defaults** for common requests:
  - feature/functionality -> current branch vs default branch
  - current branch -> current branch vs default branch
  - release notes/changelog -> last 20 commits (default)
  - what changed -> branch diff first, fallback to commit-window analysis
- **Ambiguity protocol** to require targeted clarification when repo/scope/branch materially affects output.
- **Repository detection guard** for microservice roots when `git status` returns `fatal: not a git repository...`.
- **Per-microservice execution rules** enforcing documentation generation only inside each selected git repo's `docs/` folder.

### Changed
- Refined skill frontmatter `description` to improve automatic trigger recall for bilingual requests and microservice-specific intents (`react`, `integrator`, `magento`, `all`).
- Clarified multi-service behavior: process each selected microservice independently and present grouped summaries.

### Fixed
- Prevented invalid output placement by explicitly forbidding doc generation outside git repositories or in shared workspace root paths.

## [2.0.0] - 2026-02-28

### Added
- **New document types**: Added 5 new templates
  - Technical Guide: Deep technical documentation for architectures, patterns, integrations
  - User Guide: How-to guides for developers/users
  - Bug Report: Documentation of significant bugs and their fixes
  - Plan: Migration plans, roadmaps, large initiatives
  - Task Doc: Specific task documentation

- **Repository-aware extraction scripts**
  - `get-repo-name.sh` - Get current git repository name automatically
  - `get-doc-category.sh` - Determine destination category (reference/engineering/reports/strategy)
  - `extract-diff-repo.sh` - Extract diff with automatic repo detection

- **Naming convention**: `${REPO}_${TYPE}_${SLUG}.md`
  - Component Doc: `{repo}_comp_{name}.md`
  - Changelog: `{repo}_cl_{YYYY-MM-DD}.md`
  - ADR: `{repo}_adr_{NNN}_{slug}.md`
  - Runbook: `{repo}_rb_{operation}.md`
  - Guide: `{repo}_guide_{topic}.md`
  - Technical: `{repo}_tech_{topic}.md`
  - Bug Report: `{repo}_bug_{issue}.md`
  - Plan: `{repo}_plan_{initiative}.md`
  - Task Doc: `{repo}_task_{name}.md`

- **Two-phase documentation workflow**
  - Phase 1: Local development in each microservice's `docs/` folder
  - Phase 2: Centralized merge to `docs-microservices/` after PR approval

### Changed
- Extended frontmatter schema with new types: `guide`, `technical`, `bug`, `plan`, `task`
- Extended layer options: `Store (Magento)`, `ERP (SAP)`, `Frontend (React)`
- Updated analysis-patterns.md with new detection heuristics
- Updated commit message mining with new prefixes (`migration:`, `hotfix:`)

### New Folders
- `docs/guides/` - User guides
- `docs/technical/` - Technical documentation
- `docs/bugs/` - Bug reports
- `docs/plans/` - Plans and roadmaps
- `docs/tasks/` - Task documentation

---

## [1.0.0] - 2026-02-13

### Added
- Initial release
- Component Doc template
- Changelog template
- ADR template
- Runbook template
- Extract-diff.sh script
- Analysis patterns reference
- Templates reference
