---
name: living-docs
description: "Generate living documentation from git diffs — analyze branch comparisons or last N commits to automatically create or update Component Docs, Changelogs, ADRs, Runbooks, Guides, Technical Docs, Bug Reports, Plans, and Task Docs in Markdown with Obsidian-compatible YAML frontmatter. Use when asked to: (1) document changes from a branch diff, (2) generate release notes, (3) update service documentation, (4) analyze commits and produce docs, (5) create ADRs from architectural changes, (6) create guides or technical docs. Triggers: 'document the diff', 'generate docs from commits', 'update docs for [service]', 'release notes', 'what changed and document it', 'living docs', 'analiza el diff y genera documentacion', 'create guide', 'create technical doc'."
---

# Living Docs

Generate documentation driven by actual code changes. Every document traces to specific commits and files. When code changes, docs change.

**Language policy**: Generate all documentation in English. Include Spanish translations in the `aliases` frontmatter field.

## Folder Structure

This skill supports a two-phase documentation workflow for microservice architectures:

### Phase 1: Local Development (per microservice)

Generate docs in the `docs/` folder of each microservice during feature development. Keep the folder structure but use the naming convention:

```
<repo-root>/
├── react/
│   └── docs/
│       ├── components/          # Component Docs
│       │   ├── react_comp_auth.md
│       │   └── react_comp_user_service.md
│       ├── changelogs/         # Changelogs and release notes
│       │   └── react_cl_2026-02-28.md
│       ├── adrs/               # Architecture Decision Records
│       │   └── react_adr_001_oauth.md
│       ├── runbooks/           # Runbooks and SOPs
│       │   └── react_rb_deploy.md
│       ├── guides/             # User Guides (NEW)
│       │   └── react_guide_oauth_setup.md
│       ├── technical/          # Technical Guides (NEW)
│       │   └── react_tech_state_mgmt.md
│       ├── bugs/               # Bug Reports (NEW)
│       │   └── react_bug_auth_timeout.md
│       ├── plans/              # Plans (NEW)
│       │   └── react_plan_q2_migration.md
│       ├── tasks/              # Task Docs (NEW)
│       │   └── react_task_deps_update.md
│       └── index.md            # Auto-generated index linking all docs
├── integrator/
│   └── docs/
│       └── ...
└── ...
```

### Phase 2: Centralized (docs-microservices)

After PR approval, merge docs to `docs-microservices/`:

```
docs-microservices/
├── reference/     # Component Docs, Guides, Technical Docs (from components/, guides/, technical/)
│   ├── react/
│   ├── integrator/
│   └── ...
├── engineering/   # ADRs, Runbooks (from adrs/, runbooks/)
│   ├── adrs/
│   └── runbooks/
├── reports/       # Changelogs, Bug Reports (from changelogs/, bugs/)
│   └── changelogs/
└── strategy/     # Plans (from plans/)
    └── ...
```

### File Naming Conventions

**Pattern**: `${REPO}_${TYPE_CODE}_${SLUG}.md`

| Doc Type | Folder | Type Code | Filename Pattern | Example |
|----------|--------|-----------|------------------|---------|
| Component Doc | `docs/components/` | comp | `{repo}_comp_{name}.md` | `react_comp_auth.md` |
| Changelog | `docs/changelogs/` | cl | `{repo}_cl_{YYYY-MM-DD}.md` | `react_cl_2026-02-28.md` |
| ADR | `docs/adrs/` | adr | `{repo}_adr_{NNN}_{slug}.md` | `react_adr_001_oauth.md` |
| Runbook | `docs/runbooks/` | rb | `{repo}_rb_{operation}.md` | `react_rb_deploy.md` |
| Guide | `docs/guides/` | guide | `{repo}_guide_{topic}.md` | `react_guide_oauth_setup.md` |
| Technical | `docs/technical/` | tech | `{repo}_tech_{topic}.md` | `react_tech_state_mgmt.md` |
| Bug Report | `docs/bugs/` | bug | `{repo}_bug_{issue}.md` | `react_bug_auth_timeout.md` |
| Plan | `docs/plans/` | plan | `{repo}_plan_{initiative}.md` | `react_plan_q2_migration.md` |
| Task Doc | `docs/tasks/` | task | `{repo}_task_{name}.md` | `react_task_deps_update.md` |

### Index File

After generating or updating docs, update `docs/index.md` with links to all docs:

```markdown
# Documentation Index — react

> Last updated: 2026-02-28

## Component Docs
- [[react_comp_auth]] — Authentication service

## Changelogs
- [[react_cl_2026-02-28]] — Feature release

## Guides
- [[react_guide_oauth_setup]] — OAuth setup guide

## Technical
- [[react_tech_state_mgmt]] — State management deep-dive
```

---

## Workflow

```
1. Gather context     → Determine diff scope, identify repo
2. Extract diff data  → Run extraction scripts
3. Classify changes   → Identify what matters (see references/analysis-patterns.md)
4. Select templates  → Pick doc types (see references/templates.md)
5. Generate docs     → Write markdown with naming convention
6. Verify output     → Cross-check generated docs against diff
7. Present summary   → Show what was generated and why
8. Merge to central → After PR approval, merge to docs-microservices
```

### Step 1: Gather Context

Determine from the user's message (ask only if not inferrable):
- **Diff scope**: Branch comparison (e.g., `feature/X` vs `Develop`) or last N commits?
- **Repository**: Which microservice is being documented?
- **Existing docs**: Any docs to update rather than create from scratch?

**Defaults (when not specified):**
- **Diff scope**: Current branch vs default branch (auto-detected from repo)
- **Repository**: Auto-detect using `scripts/get-repo-name.sh`
- **Output path**: `${GIT_REPO_ROOT}/docs/` (local development phase)
- **Existing docs**: Search `${GIT_REPO_ROOT}/docs/` for matching filenames before creating new docs

### Step 2: Extract Diff Data

Use the extraction scripts from this skill's directory:

```bash
# Get repository name (use this first!)
REPO_NAME=$(bash <skill-path>/scripts/get-repo-name.sh <repo-path>)

# Branch comparison with repo detection (recommended)
bash <skill-path>/scripts/extract-diff-repo.sh <repo-path> --branch <target>

# Last N commits
bash <skill-path>/scripts/extract-diff-repo.sh <repo-path> --commits 20

# Filtered by path (for monorepos)
bash <skill-path>/scripts/extract-diff-repo.sh <repo-path> --branch Develop --path services/auth/

# Large diffs: start with --stat only
bash <skill-path>/scripts/extract-diff-repo.sh <repo-path> --branch feature/X --stat
```

For multi-repo workspaces, run per repository.

#### Determine Document Category

After extracting the diff, determine the target category for docs-microservices:

```bash
CATEGORY=$(bash <skill-path>/scripts/get-doc-category.sh <change-type>)
# Options: reference, engineering, reports, strategy
```

#### Large Diff Strategy

When the diff is large (100+ files changed or output exceeds ~50KB):

1. **Start with `--stat` only** — Use the file list and change counts to plan
2. **Read full diff only for high-impact files** — APIs, schemas, configs, contracts, new files
3. **Read only changed hunks for medium-impact files** — Business logic, services
4. **Skip full diff for low-impact files** — Tests, formatting, comments
5. **Split by directory** — If still too large, analyze one component/service at a time

### Step 3: Classify Changes

Read `references/analysis-patterns.md` for the full classification guide.

**Priority**: High-impact changes (new components, public API changes, business logic changes, schema migrations, new dependencies, infra changes) are always documented. Medium-impact (internal refactors, test changes) only if significant. Low-impact (formatting, comments, patch bumps) are skipped.

**Key distinctions** (from analysis-patterns.md):
- **Business logic vs refactor**: Did test expectations change? → business logic. Same tests pass? → refactor.
- **Interface exposure**: External (public API) > Inter-component (shared packages) > Internal (same module). Document proportionally.

Map each significant change to doc types:

| Change Type | Impact | Doc Types |
|-------------|--------|-----------|
| New component / module | High | Component Doc (new) |
| Public API change | High | Component Doc + Changelog (Breaking if contract changed) |
| Business logic change | High | Component Doc + Changelog |
| Inter-component interface change | High | Component Doc + flag downstream consumers |
| Schema / data model change | High | ADR + Component Doc |
| Major dependency added | Medium-High | ADR + Component Doc |
| Infrastructure / deployment change | Medium | Runbook |
| Internal refactor (same behavior) | Low | Changelog (Internal) or skip |
| Release milestone | — | Changelog |

### Step 4: Select and Fill Templates

Read `references/templates.md` for all templates and the frontmatter schema.

Frontmatter rules:
- ALWAYS include all required fields: `aliases`, `type`, `layer`, `status`, `owner`, `tech_stack`, `last_updated`, `source_branch`, `commit_range`
- Use `[[wiki-links]]` for owner, tech_stack, and cross-references
- Set `last_updated` to today's date
- Set `source_branch` and `commit_range` from the actual diff
- Set `status` honestly: `active`, `debt`, `zombie`, or `gap`
- Populate `aliases` with English keywords + Spanish equivalents
- Infer `owner` and `tech_stack` using the heuristics in templates.md → "Inferring Frontmatter from Diffs"
- **Omit template sections that don't apply** (e.g., don't include "Events Published" for a REST-only service)

### Step 5: Generate Docs

Write docs to the folder structure defined above.

**Updating existing docs**: Read first, preserve frontmatter structure, update `last_updated` and `commit_range`, modify only affected sections, append to "Recent Changes".

#### Merge Strategy for Incremental Updates

When a doc already exists:

| Section | Strategy |
|---------|----------|
| Frontmatter | **Merge**: Update `last_updated`, `commit_range`, `status`. Preserve `owner`, `aliases` (append new ones) |
| What It Does | **Replace only if** the component's purpose fundamentally changed |
| API Surface / Exported API | **Merge**: Add new entries, update changed entries, mark removed entries as deprecated |
| Dependencies | **Replace** with current state |
| Configuration | **Merge**: Add new env vars, update changed ones |
| Key Files | **Replace** with current state |
| Recent Changes | **Append** new changes at the top, keep last 5-10 entries |

### Step 6: Verify Output

Before presenting to the user, cross-check:

- [ ] Every endpoint/export mentioned in docs exists in the diff or codebase
- [ ] All frontmatter required fields are populated (no empty or placeholder values except `owner: "[[TBD]]"`)
- [ ] File paths referenced in "Key Files" actually exist
- [ ] Breaking changes flagged in Changelog match actual contract changes in the diff
- [ ] No duplicate docs (check existing files before creating new ones)

### Step 7: Present Summary

Show the user what was generated:

```
## Documentation Generated

| File | Type | Reason |
|------|------|--------|
| docs/components/react_comp_auth.md | Component Doc | New endpoints in routes/users.ts |
| docs/changelogs/react_cl_2026-02-28.md | Changelog | 12 commits with 3 features, 2 fixes |
| docs/guides/react_guide_oauth_setup.md | Guide | OAuth integration guide |

### Key Changes Documented
- [bullets]

### Skipped (Low Impact)
- [what and why]
```

Always update `${GIT_REPO_ROOT}/docs/index.md` with links to all generated docs (for multi-repo workspaces, do this per repository).

### Step 8: Merge to docs-microservices (Post-PR)

After PR approval, merge the documentation to the centralized `docs-microservices/` repository:

1. **Copy docs** from each microservice `docs/` folder to the corresponding category in `docs-microservices/`:
   - `docs/components/` → `docs-microservices/reference/{repo}/`
   - `docs/changelogs/` → `docs-microservices/reports/changelogs/`
   - `docs/adrs/` → `docs-microservices/engineering/adrs/`
   - `docs/runbooks/` → `docs-microservices/engineering/runbooks/`
   - `docs/guides/` → `docs-microservices/reference/{repo}/`
   - `docs/technical/` → `docs-microservices/reference/{repo}/`
   - `docs/bugs/` → `docs-microservices/reports/bugs/`
   - `docs/plans/` → `docs-microservices/strategy/plans/`

2. **Update central index** at `docs-microservices/index.md`
3. **Cross-reference** — Add links between services if applicable

```bash
# Example workflow after PR approval
# Copy all docs from react to docs-microservices
cp -r react/docs/components/* docs-microservices/reference/react/
cp -r react/docs/changelogs/* docs-microservices/reports/changelogs/
cp -r react/docs/adrs/* docs-microservices/engineering/adrs/
cp -r react/docs/runbooks/* docs-microservices/engineering/runbooks/
cp -r react/docs/guides/* docs-microservices/reference/react/
cp -r react/docs/technical/* docs-microservices/reference/react/
cp -r react/docs/bugs/* docs-microservices/reports/bugs/
cp -r react/docs/plans/* docs-microservices/strategy/plans/
```

**Merge criteria**:
- PR must be approved and merged
- Docs must follow naming convention
- All frontmatter fields must be complete

---

## Quality Rules

- **No fluff**: Every sentence carries information. Cut filler.
- **Trace to code**: Every claim references a file, commit, or config.
- **Tables over prose**: For endpoints, env vars, dependencies — always tables.
- **Be honest**: If the diff reveals tech debt, set `status: debt`. Living docs tell the truth.
- **Aliases matter**: Include concept name, Spanish translation, common abbreviations.
- **Omit empty sections**: Don't include template sections that have no content for this component.

---

## Few-Shot Example

### Input: Diff Summary

```
=== REPO: react ===
=== BRANCH: feature/oauth vs Develop ===
=== COMMIT RANGE: a1b2c3d..d4e5f6g ===

=== FILE STATS ===
 src/routes/auth.ts   | 45 +++++++++--
 src/services/oauth.ts | 120 ++++++++++++++++++++++++++++
 src/types/auth.dto.ts |  15 ++++
 package.json          |   2 +  (added passport-google-oauth20)
 tests/oauth.test.ts   |  85 ++++++++++++++++++++

=== COMMIT LOG ===
a1b2c3d feat: add Google OAuth2 login flow
d4e5f6g feat: add OAuth callback handler
h7i8j9k fix: handle missing email in OAuth profile
l0m1n2o chore: add passport-google-oauth20 dependency
```

### Output: Classification

1. **New OAuth service file** (oauth.ts, 120 lines) → High impact, new feature → Component Doc
2. **Route changes** (auth.ts, 45 lines) → Public API change → Component Doc + Changelog
3. **New major dependency** (passport-google-oauth20) → Technical Guide (integration)
4. **New tests with different expectations** → Confirms business logic change

### Output: Generated Docs

Using folder structure + naming convention `${REPO}_${TYPE}_${SLUG}.md`:

- `docs/components/react_comp_auth.md` — Updated: added OAuth endpoints, new key files
- `docs/changelogs/react_cl_2026-02-28.md` — New: 2 features (OAuth login, callback handler), 1 fix
- `docs/guides/react_guide_oauth_google.md` — New: Guide for Google OAuth integration
- `docs/technical/react_tech_oauth_architecture.md` — New: Technical deep-dive on OAuth flow

---

## Resources

- `scripts/extract-diff.sh` — Extract structured diff data (file stats, commit log, full diff)
- `scripts/extract-diff-repo.sh` — Extract diff with automatic repository name detection
- `scripts/get-repo-name.sh` — Get the current git repository name
- `scripts/get-doc-category.sh` — Determine destination category (reference/engineering/reports/strategy)
- `references/templates.md` — All doc templates with frontmatter schema
- `references/analysis-patterns.md` — How to classify changes from diffs
