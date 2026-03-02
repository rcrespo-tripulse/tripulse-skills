# Changelog - Living Docs Skill

All notable changes to this skill will be documented in this file.

---

## [3.0.0] - 2026-03-02

### Added
- **Command-based interface**: 9 explicit commands (`document`, `document-branch`, `document-commits`, `sync`, `migrate-legacy`, `audit`, `document-flow`, `create-adr`, `system-overview`)
- **4-Layer Documentation System**: System overview, flows, per-MS docs, ADRs — each with clear source of truth
- **CTO Vault alignment**: All central docs mapped to the existing `vault/` structure (`engineering/`, `reference/`, `reports/`, `strategy/`)
- **New scripts**:
  - `detect-changes.sh` — Categorize changes by type with priority levels (from new version)
  - `check-freshness.sh` — Compare doc timestamps vs last code change, adapted for CTO paths (from new version)
  - `sync-to-central.sh` — Sync per-MS docs to CTO Vault structure (rewrite of gather_docs.sh)
- **New templates**:
  - `navigation-index.md` — Standardized navigation index for docs/index.md
  - `ms-overview.md` — Comprehensive service overview component doc
  - `flow.md` — Cross-service flow documentation
  - `system-overview.md` — System-level architecture overview
- **Templates split into individual files**: Each doc type now has its own template file (previously all in templates.md)
- **New references**:
  - `documentation-layers.md` — The 4-layer documentation system
  - `frontmatter-schema.md` — Complete frontmatter schema (CTO base + extensions)
  - `central-mapping.md` — Mapping from per-MS paths to vault paths
  - `ci-integration.md` — GitHub Actions workflow examples
- **Sacred Documents rule**: Never overwrite content authored by Erick Blangino or Jorge Cruz
- **Audience tag**: Required in frontmatter per CTO's distribution model
- **`last_documented_sha` tracking**: Enables incremental updates and freshness auditing
- **Flow impact detection**: When updating per-MS docs, check flow docs for references to the service
- **`migrate-legacy` command**: Detect and migrate pre-existing docs to standard format
- **Red Flags section** in analysis-patterns.md: 6 conditions that always trigger warnings

### Changed
- **Frontmatter schema**: Now uses CTO's base schema (aliases, type, layer, status, owner, tech_stack, audience, last_updated) with extensions (last_documented_sha, commit_range, source_branch, doc_version)
- **Folder structure**: `index.md` is now a navigation index (not a comprehensive service doc). Service overview goes in `components/{repo}_comp_overview.md`
- **Central mapping**: `sync` command maps per-MS docs to CTO Vault paths (not a flat `services/` mirror)
- **Workflow**: Replaced linear 8-step pipeline with case-based command instructions
- **analysis-patterns.md**: Merged with new version's commit-analysis-guide (10 detailed change categories, priority matrix)
- **vault entry point**: Uses CTO's `Global_Architecture_Map.md` (not CATALOG.md)
- **Flow docs location**: `vault/strategy/data-flows/` (not `flows/`)
- **ADR location**: `vault/engineering/adrs/` (not `decisions/`)

### Removed
- `templates.md` reference file (replaced by individual template files)
- `get-doc-category.sh` script (logic now in sync-to-central.sh mapping)
- `analyze_commits.sh` concept (extract-diff.sh is more robust)
- Gathered copies / services/ mirror concept (replaced by direct mapping to CTO structure)

### Fixed
- Aligned skill output with actual CTO Vault structure in vault
- Addressed mismatch where skill assumed no docs existed (many services already have docs/)
- Standardized index.md naming (was inconsistent: index.md vs integrator_docs_index.md vs utilities_main_index.md)
- Frontmatter now compatible with CTO's distribution model (audience tags)

---

## [2.0.2] - 2026-02-28

### Changed
- **Phase 2 structure updated** to match Tripulse Vault model:
  - Added `reference/{repo}/` folders for per-repo component docs
  - Added `engineering/adrs/` for Architecture Decision Records
  - Added `engineering/microservices/{repo}/` for service architectures
  - Added `reports/changelogs/` for changelogs
  - Added folder creation commands (`mkdir -p`) before copying in merge step
- **Frontmatter schema updated**: Added `adr` and `microservice` to type options, added `Microservices` to layer options

### Fixed
- Templates now include ADR type for vault compatibility

## [2.0.1] - 2026-02-28

### Added
- **Activation signals section** with high-confidence EN/ES trigger phrases
- **Intent-to-scope defaults** for common requests
- **Ambiguity protocol** to require targeted clarification
- **Repository detection guard** for microservice roots
- **Per-microservice execution rules**

### Changed
- Refined skill frontmatter description
- Clarified multi-service behavior

### Fixed
- Prevented invalid output placement outside git repositories

## [2.0.0] - 2026-02-28

### Added
- **New document types**: Technical Guide, User Guide, Bug Report, Plan, Task Doc
- **Repository-aware extraction scripts**: get-repo-name.sh, get-doc-category.sh, extract-diff-repo.sh
- **Naming convention**: `${REPO}_${TYPE}_${SLUG}.md`
- **Two-phase documentation workflow**

### Changed
- Extended frontmatter schema with new types
- Updated analysis-patterns.md with new detection heuristics

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
