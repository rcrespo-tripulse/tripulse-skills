---
name: living-docs
description: "Generate and maintain living documentation for microservices by analyzing Git history. Trigger when users ask to document a service, update docs after changes, compare branches, generate changelogs, audit doc freshness, sync docs to central repo, migrate legacy docs, create flow docs, ADRs, or system overviews. Trigger phrases: 'document [service]', 'document-branch', 'document-commits', 'sync', 'audit', 'migrate-legacy', 'document-flow', 'create-adr', 'system-overview', 'documenta', 'qué cambió', 'actualizar docs', 'generar changelog', 'release notes', 'living docs'."
---

# Living Docs

Generate documentation driven by actual code changes. Every document traces to specific commits and files. When code changes, docs change.

## Philosophy

Documentation must be:
- **Accurate**: derived from code and commits, not imagination
- **Navigable**: a human or agent can find what they need in 1-2 hops
- **Maintainable**: updating docs is a natural part of the development flow
- **Dual-audience**: useful for both humans reading markdown and agents consuming context
- **Co-located**: per-service docs live with the service code they describe

**Language policy**: Generate all documentation in English. Include Spanish translations in the `aliases` frontmatter field.

---

## Commands

| Command | Description | Scope |
|---------|-------------|-------|
| `document [service]` | Full MS documentation (from scratch or incremental) | Per-service |
| `document-branch` | Document current branch changes vs base branch | Per-service |
| `document-commits [N]` | Document last N commits | Per-service |
| `sync` | Sync per-MS docs to docs-microservices (CTO structure) | Central |
| `migrate-legacy` | Detect and migrate pre-existing docs to standard format | Per-service |
| `audit` | Freshness audit of all per-MS docs | All services |
| `document-flow [name]` | Create/update cross-service flow documentation | Central |
| `create-adr` | Create Architecture Decision Record | Central |
| `system-overview` | Generate/update system-level overview | Central |

---

## Activation Signals

Use this skill when the user intent matches documentation-from-code-changes or any command above.

High-confidence trigger phrases (English/Spanish):
- "document this feature", "document X functionality", "document current branch"
- "document the diff", "what changed", "generate release notes", "generate changelog"
- "update docs for react/integrator/magento", "document all microservices"
- "documenta esta funcionalidad", "documenta la branch actual", "analiza el diff y genera documentacion"
- "sync docs", "audit docs", "migrate legacy", "document flow", "create adr"

Intent-to-scope defaults:
- "document this feature/funcionalidad" → `document-branch` (current branch vs default branch)
- "document current branch/branch actual" → `document-branch`
- "release notes/changelog" → `document-commits 20` (default 20 unless user specifies)
- "what changed" → `document-branch` first; fall back to `document-commits` if branch base is unclear
- "sync/sincronizar" → `sync`
- "audit/revisar docs" → `audit`

Do not trigger this skill for generic writing requests not tied to git changes.

---

## Source of Truth Model

This is the most important concept. Understand it before doing anything.

```
ms-root/                              # Non-git parent directory (e.g., /home/user/tripulse/microservices)
├── react/                            # Git repo
│   ├── src/
│   └── docs/
│       ├── index.md                  ← NAVIGATION INDEX (auto-generated links)
│       ├── components/               ← Component docs
│       ├── changelogs/               ← Changelogs
│       ├── adrs/                     ← Per-service ADRs
│       ├── guides/                   ← User guides
│       ├── technical/                ← Technical deep-dives
│       ├── bugs/                     ← Bug reports
│       ├── runbooks/                 ← Runbooks
│       ├── plans/                    ← Plans
│       └── tasks/                    ← Task docs
├── integrator/                       # Git repo
│   └── docs/
│       └── ...                       (same structure)
├── sap/                              # Git repo
│   └── docs/
│       └── ...
└── docs-microservices/               # Git repo — Obsidian Vault structure
    ├── CLAUDE.MD.md                  ← Agent rules and vault config
    ├── Global_Architecture_Map.md    ← ENTRY POINT for navigation
    ├── engineering/
    │   ├── adrs/                     ← Architecture Decision Records (transversal)
    │   ├── microservices/            ← Per-service architecture docs
    │   │   ├── react/
    │   │   ├── integrator/
    │   │   └── ...
    │   ├── guides/                   ← SOPs, runbooks, guides
    │   ├── diagnostics/              ← Troubleshooting runbooks
    │   ├── database/                 ← Schema docs
    │   ├── infrastructure/           ← Infra specs per service
    │   ├── frontend/                 ← Frontend docs
    │   └── onboarding/               ← Dev setup guides
    ├── reference/
    │   ├── react/                    ← Per-repo component/technical docs
    │   ├── integrator/
    │   └── ...                       ← Tech reference cards (Ref_*.md)
    ├── reports/
    │   ├── changelogs/               ← Changelogs
    │   └── ...                       ← Bug reports, incident reports
    └── strategy/
        ├── data-flows/               ← Cross-service flow docs
        └── ...                       ← Plans, registries
```

### Source of Truth Rules

1. **Per-MS docs** (`{ms-root}/{service}/docs/`) are the authoritative source. This is where living-docs generates and updates documentation.
2. **docs-microservices/** follows the Obsidian Vault structure. Never invent new top-level folders. The `sync` command copies per-MS docs to the correct Vault paths.
3. **Transversal docs** (system overview, flows, ADRs, architecture map) live ONLY in docs-microservices. They don't belong to any single service.
4. **Never edit docs-microservices directly** for per-service content — generate in the service repo first, then sync.
5. **Sacred Documents**: Docs authored by [[Erick Blangino]] or [[Jorge Cruz]] are preserved verbatim. Append new sections — never edit their original content.

---

## The 4-Layer Documentation System

Read `references/documentation-layers.md` for full details. Summary:

| Layer | What | Source of Truth | Updated by |
|---|---|---|---|
| 1. System Overview | Architecture, service map, glossary | `docs-microservices/engineering/` | `system-overview` command (rare) |
| 2. Flows | End-to-end business flows across services | `docs-microservices/strategy/data-flows/` | `document-flow` command |
| 3. Per-MS Docs | Endpoints, modules, internal decisions | `{service}/docs/` | `document` / `document-branch` commands |
| 4. ADRs | Architecture decisions with context | `docs-microservices/engineering/adrs/` | `create-adr` command |

---

## Folder Structure per Microservice

```
{service}/docs/
├── index.md              # Navigation index linking all docs (auto-generated)
├── components/           # Component Docs + service overview
│   ├── {repo}_comp_overview.md
│   └── {repo}_comp_{name}.md
├── changelogs/           # Changelogs by date
│   └── {repo}_cl_{YYYY-MM-DD}.md
├── adrs/                 # Per-service Architecture Decision Records
│   └── {repo}_adr_{NNN}_{slug}.md
├── guides/               # User Guides
│   └── {repo}_guide_{topic}.md
├── technical/            # Technical deep-dives
│   └── {repo}_tech_{topic}.md
├── bugs/                 # Bug Reports
│   └── {repo}_bug_{issue}.md
├── runbooks/             # Operational Runbooks
│   └── {repo}_rb_{operation}.md
├── plans/                # Plans and roadmaps
│   └── {repo}_plan_{initiative}.md
└── tasks/                # Task documentation
    └── {repo}_task_{name}.md
```

### File Naming Convention

**Pattern**: `${REPO}_${TYPE_CODE}_${SLUG}.md`

Always use the prefix, even inside the service repo. This ensures files are identifiable when synced to docs-microservices.

| Doc Type | Folder | Type Code | Example |
|----------|--------|-----------|---------|
| Service Overview | `components/` | comp | `react_comp_overview.md` |
| Component Doc | `components/` | comp | `react_comp_auth.md` |
| Changelog | `changelogs/` | cl | `react_cl_2026-03-01.md` |
| ADR | `adrs/` | adr | `react_adr_001_oauth.md` |
| Runbook | `runbooks/` | rb | `react_rb_deploy.md` |
| Guide | `guides/` | guide | `react_guide_oauth_setup.md` |
| Technical | `technical/` | tech | `react_tech_state_mgmt.md` |
| Bug Report | `bugs/` | bug | `react_bug_auth_timeout.md` |
| Plan | `plans/` | plan | `react_plan_q2_migration.md` |
| Task Doc | `tasks/` | task | `react_task_deps_update.md` |

### Navigation Index (index.md)

After generating or updating docs, update `docs/index.md` with links to all docs. Use the `templates/navigation-index.md` template. Example:

```markdown
# Documentation Index — react

> Auto-generated. Last updated: 2026-03-01

## Components & Features
- [[react_comp_overview]] — Service overview
- [[react_comp_auth]] — Authentication service

## Recent Changelogs
- [[react_cl_2026-03-01]] — Feature release

## Architecture Decisions
- [[react_adr_001_oauth]] — OAuth provider selection

## Guides
- [[react_guide_oauth_setup]] — OAuth setup guide

## Legacy Docs (not yet migrated)
- [React.md](./React.md) — Original service documentation
```

---

## Workspace Detection (mandatory)

Run `git status` before selecting a repo path.

- If `git status` succeeds: continue in current git repository
- If `git status` returns `fatal: not a git repository`:
  - Treat current location as microservices root
  - Ask: "Which microservice(s) should I document: react, integrator, sap, magento, or all?"
  - Accept answers like `react`, `integrator`, `magento`, `todos`/`all`, or comma-separated combinations
  - Resolve `all` to all available microservice repos with a `.git` directory

For each selected microservice, set `REPO_PATH=<workspace-root>/<microservice>` and process independently.

### Ambiguity Protocol

If scope, branch, or repository is ambiguous, ask a focused question before generating docs.

- Prefer an interactive question tool when available (single-select or multi-select options)
- Ask one targeted question at a time, with a recommended default
- Continue with safe defaults only when ambiguity does not change the output materially

---

## Command Instructions

### CMD 1: `document [service]`

**Trigger**: User asks to document a microservice, or wants to regenerate docs.

**Steps**:

1. **Identify the repo**:
   ```bash
   REPO_NAME=$(bash <skill-path>/scripts/get-repo-name.sh <repo-path>)
   ```
   If no existing docs → full generation. If docs exist → incremental update.

2. **Determine the range**:
   - If existing doc has `last_documented_sha` in frontmatter → analyze from that SHA to HEAD
   - If no existing docs → analyze full branch or last 50 commits
   ```bash
   # For incremental: read last_documented_sha from existing docs
   LAST_SHA=$(grep -m1 'last_documented_sha:' "<repo-path>/docs/components/${REPO}_comp_overview.md" | sed 's/.*: *"\?\([^"]*\)"\?/\1/' | tr -d ' ')
   ```

3. **Extract diff data**:
   ```bash
   bash <skill-path>/scripts/extract-diff-repo.sh <repo-path> --branch <target>
   # or for incremental:
   bash <skill-path>/scripts/extract-diff.sh <repo-path> --branch <base>
   ```

4. **Detect and classify changes**:
   ```bash
   bash <skill-path>/scripts/detect-changes.sh --repo <repo-path> --from <SHA> --to HEAD
   ```
   Read `references/analysis-patterns.md` for the full classification guide. Map each significant change to doc types:

   | Change Type | Impact | Doc Types |
   |-------------|--------|-----------|
   | New component / module | High | Component Doc (new) |
   | Public API change | High | Component Doc + Changelog |
   | Business logic change | High | Component Doc + Changelog |
   | Schema / data model change | High | ADR + Component Doc |
   | Major dependency added | Medium-High | ADR + Component Doc |
   | Infrastructure change | Medium | Runbook |
   | Internal refactor | Low | Changelog (Internal) or skip |

5. **Select and fill templates**: Read templates from `templates/` directory. See `references/frontmatter-schema.md` for frontmatter rules.

   Frontmatter rules:
   - ALWAYS include required fields: `aliases`, `type`, `layer`, `status`, `owner`, `tech_stack`, `last_updated`, `source_branch`, `commit_range`
   - Include `audience` tag per CTO's distribution model
   - Use `[[wiki-links]]` for owner, tech_stack, and cross-references
   - Set `last_updated` to today's date
   - Set `status` honestly: `active`, `debt`, `zombie`, or `gap`
   - Populate `aliases` with English keywords + Spanish equivalents
   - **Omit template sections that don't apply**

6. **Generate docs**: Write docs to the folder structure. For incremental updates, use the merge strategy:

   | Section | Strategy |
   |---------|----------|
   | Frontmatter | **Merge**: Update `last_updated`, `commit_range`, `status`. Preserve `owner`, `aliases` (append new ones) |
   | What It Does | **Replace only if** the component's purpose fundamentally changed |
   | API Surface | **Merge**: Add new entries, update changed, mark removed as deprecated |
   | Dependencies | **Replace** with current state |
   | Configuration | **Merge**: Add new env vars, update changed |
   | Key Files | **Replace** with current state |
   | Recent Changes | **Append** new changes at top, keep last 5-10 entries |

7. **Verify output**: Before presenting to the user:
   - [ ] Every endpoint/export mentioned in docs exists in the diff or codebase
   - [ ] All frontmatter required fields are populated
   - [ ] File paths referenced in "Key Files" actually exist
   - [ ] Breaking changes flagged in Changelog match actual contract changes
   - [ ] No duplicate docs (check existing files before creating new ones)

8. **Update index.md**: Regenerate `docs/index.md` with links to all docs.

9. **Present summary**:
   ```
   ## Documentation Generated

   | File | Type | Reason |
   |------|------|--------|
   | docs/components/react_comp_auth.md | Component Doc | New endpoints in routes/users.ts |
   | docs/changelogs/react_cl_2026-03-01.md | Changelog | 12 commits with 3 features, 2 fixes |

   ### Key Changes Documented
   - [bullets]

   ### Skipped (Low Impact)
   - [what and why]
   ```

**Rules**:
- NEVER invent endpoints, environment variables, or behaviors not found in code
- If something is unclear, document it as "⚠️ Unclear: [what you found] — needs human verification"
- Every claim must be grounded in code or commits
- Never create docs outside a git repo or in the workspace root

---

### CMD 2: `document-branch`

**Trigger**: User wants to document current branch changes, or says "document this feature".

**Steps**:

1. **Identify branches**:
   ```bash
   cd <repo-path>
   CURRENT=$(git branch --show-current)
   BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
   # Fallback: try Develop, main, master
   ```

2. **Extract diff**:
   ```bash
   bash <skill-path>/scripts/extract-diff.sh <repo-path> --branch $BASE
   ```

3. **Classify changes**: Run `detect-changes.sh` and apply classification from `references/analysis-patterns.md`.

4. **Generate docs**: Same as CMD 1 steps 5-8.

5. **Check for flow impact** (critical step):
   If docs-microservices exists, read frontmatter of all docs in `strategy/data-flows/`. If any flow lists this service in its `services:` array, flag it:
   ```
   ⚠️ FLOW IMPACT DETECTED:
   - strategy/data-flows/order-b2b-flow.md references this service
   - Changes in: [endpoints, business-logic]
   - Recommendation: review flow doc for accuracy
   ```
   Do NOT auto-update flow docs. Only flag.

6. **Present summary**: Same format as CMD 1.

---

### CMD 3: `document-commits [N]`

**Trigger**: User wants to document the last N commits, or says "release notes", "changelog".

**Steps**: Same as CMD 2, but use `--commits N` instead of `--branch`:
```bash
bash <skill-path>/scripts/extract-diff.sh <repo-path> --commits <N>
```

Default N = 20 unless user specifies otherwise.

---

### CMD 4: `sync`

**Trigger**: User says "sync", "sync docs", "sincronizar docs".

**Steps**:

1. **Run sync**:
   ```bash
   bash <skill-path>/scripts/sync-to-central.sh \
     --repos-dir <ms-root> \
     --docs-repo <ms-root>/docs-microservices
   ```

2. **Review the output**: The script shows what was copied, updated, or skipped.

3. **Mapping rules** (see `references/central-mapping.md` for full table):
   ```
   Per-MS docs/              → docs-microservices/
   docs/components/*.md      → reference/{repo}/
   docs/changelogs/*.md      → reports/changelogs/
   docs/adrs/*.md            → engineering/adrs/
   docs/runbooks/*.md        → engineering/guides/
   docs/guides/*.md          → engineering/guides/
   docs/technical/*.md       → reference/{repo}/
   docs/bugs/*.md            → reports/
   docs/plans/*.md           → strategy/
   docs/tasks/*.md           → engineering/microservices/{repo}/
   ```

4. **Remind the user**: The script does NOT auto-commit. The user must review and commit.

**Rules**:
- Never overwrite docs authored by [[Erick Blangino]] or [[Jorge Cruz]] — flag conflicts instead
- Check `audience` frontmatter tag before syncing (only sync docs with `audience: [microservices]` or multi-audience)
- Never auto-commit or auto-push

---

### CMD 5: `migrate-legacy`

**Trigger**: User says "migrate legacy", "migrate docs", "migrar docs legacy".

**Steps**:

1. **Scan for legacy docs**: Look for `.md` files in `docs/` that:
   - Have no YAML frontmatter (no `---` block at top)
   - Don't follow the naming convention `${REPO}_${TYPE}_${SLUG}.md`
   - Are not in a subdirectory (e.g., `docs/React.md`, `docs/SAP.md`)

2. **For each legacy doc**:
   - Read its content to determine type (component, guide, technical, etc.)
   - Propose: new filename, target subdirectory, frontmatter to add
   - Show preview of the migration (diff)

3. **Ask for confirmation** before applying each migration.

4. **After migration**: Update `index.md` to replace legacy links with standard links.

**Rules**:
- Never auto-migrate without showing the user what will change
- Preserve all original content — only add frontmatter and rename
- If the content doesn't map cleanly to a doc type, ask the user

---

### CMD 6: `audit`

**Trigger**: User says "audit", "audit docs", "check freshness", "revisar docs".

**Steps**:

1. **Run freshness check**:
   ```bash
   bash <skill-path>/scripts/check-freshness.sh --repos-dir <ms-root>
   ```

2. **Generate freshness report**:
   ```markdown
   ## Doc Freshness Report — 2026-03-01

   | Service | Doc SHA | Current HEAD | Commits Behind | Status |
   |---|---|---|---|---|
   | integrator | abc123 | def456 | 12 | ⚠️ STALE |
   | sap | xyz789 | xyz789 | 0 | ✅ Current |
   | magento | — | fed321 | ∞ | ❌ No docs |
   ```

3. **For stale docs**, offer to run `document [service]` (incremental update).

4. **For undocumented services**, offer to run `document [service]` (full generation).

5. **Check flow docs**: For each flow doc in `docs-microservices/strategy/data-flows/`, verify all referenced services have current docs. Flag any flows that reference stale services.

---

### CMD 7: `document-flow [name]`

**Trigger**: User wants to document a business flow that spans multiple services.

**Steps**:

1. **Identify the flow**: Ask the user to describe the flow if not clear.

2. **Identify involved services**: From user input or by tracing code:
   - Check queue consumers/producers across services
   - Check HTTP calls between services
   - Check shared Redis keys or database references

3. **Read existing docs** for each involved service from their source of truth (`{service}/docs/`).

4. **Trace the flow in code**: Actually read the code paths. Don't rely solely on docs.
   - Start from the entry point (webhook, cron, queue message)
   - Follow the chain: which service calls which
   - Document data transformations at each boundary
   - Document error handling at each step

5. **Generate flow doc** using `templates/flow.md`:
   - Include mermaid sequence diagram (mandatory for 3+ steps)
   - Reference specific files/functions in each service
   - Document retry behavior and dead letter queues

6. **Save to docs-microservices**:
   ```
   docs-microservices/strategy/data-flows/{flow-name}.md
   ```
   With frontmatter including `services: [list]` array for impact detection.

**Rules**:
- Every step must reference actual code (file:line or function name)
- If you can't trace a step in code, mark it: "⚠️ Could not verify in code"
- Flows are the highest-value docs. Take extra care.

---

### CMD 8: `create-adr`

**Trigger**: User wants to record a technical decision, or a significant architectural change is detected.

**Steps**:

1. **Gather context**: Ask or extract:
   - What was decided?
   - Why? (what problem does it solve?)
   - What alternatives were considered?
   - What are the consequences/trade-offs?

2. **Number it**: Read existing ADRs in `docs-microservices/engineering/adrs/`, take the next number.

3. **Generate ADR** using `templates/adr.md`.

4. **Save** to `docs-microservices/engineering/adrs/{NNN}-{slug}.md`.

**Rules**:
- ADRs are immutable once merged. If a decision is reversed, create a new ADR that supersedes the old one.
- Keep the "Consequences" section honest — include downsides.
- Use CTO frontmatter schema with `audience: [microservices]`.

---

### CMD 9: `system-overview`

**Trigger**: User wants to create or update the top-level system documentation.

**Steps**:

1. **Scan all service repos**:
   ```bash
   for dir in <ms-root>/*/; do
     if [ -d "$dir/.git" ]; then echo "$(basename $dir)"; fi
   done
   ```

2. **Read existing per-MS docs** from each service repo (`{service}/docs/`).

3. **If no per-MS docs exist** for a service, do a lightweight scan:
   - Read `package.json` for name/description/deps
   - Read main entry point for route definitions
   - Read Docker/K8s config for infrastructure context

4. **Generate** using `templates/system-overview.md`:
   - Service inventory (name, purpose, tech stack, integrations)
   - Architecture diagram (mermaid)
   - Communication patterns
   - Domain glossary

5. **Save** to `docs-microservices/engineering/` (coordinate with existing `Global_Architecture_Map.md`).

---

## Global Rules

### Accuracy Rules
1. **Every factual claim must be grounded in code or commits.** No hallucination. Read the actual code.
2. **If uncertain, flag with ⚠️.** Always better to say "unclear" than to guess.
3. **Include provenance.** Every doc section should be traceable to specific files or commits.

### Quality Rules
- **No fluff**: Every sentence carries information. Cut filler.
- **Trace to code**: Every claim references a file, commit, or config.
- **Tables over prose**: For endpoints, env vars, dependencies — always tables.
- **Be honest**: If the diff reveals tech debt, set `status: debt`. Living docs tell the truth.
- **Aliases matter**: Include concept name, Spanish translation, common abbreviations.
- **Omit empty sections**: Don't include template sections that have no content for this component.

### Safety Rules
1. **NEVER delete existing documentation** without explicit user confirmation
2. **NEVER auto-commit or auto-push** — always generate locally and let the user review
3. **NEVER include secrets, tokens, or credentials** even if found in code — flag them as security issues instead
4. **Preserve manual edits**: If a doc section has been manually edited, flag it and ask before overwriting
5. **Sacred Documents**: Never overwrite content authored by [[Erick Blangino]] or [[Jorge Cruz]]. Append, don't replace.

### Formatting Rules
1. **All docs use frontmatter** (see `references/frontmatter-schema.md`)
2. **Status values**: `active` | `debt` | `zombie` | `gap` (per-MS docs). `draft` | `verified` | `needs-review` | `stale` (for doc lifecycle).
3. **Language**: Generate docs in English. Include Spanish translations in `aliases` field.
4. **Mermaid diagrams**: Required for any flow with 3+ steps or any architecture with 3+ components.
5. **Code references**: Use format `service-name/path/to/file.ts:functionName` or `service-name/path/to/file.ts:L42`.
6. **Audience tag**: Always include `audience` field per CTO's distribution model.

### Per-Microservice Execution Rules (mandatory)

For every selected microservice repository:

1. Validate repo: `git -C <repo-path> rev-parse --is-inside-work-tree`
2. Write docs only inside that repo: `<repo-path>/docs/`
3. Never create docs outside a git repo
4. Never create shared docs in workspace root
5. Update `<repo-path>/docs/index.md` for that repo

If multiple microservices are selected, repeat the full workflow per repo and present a grouped summary.

---

## Large Diff Strategy

When the diff is large (100+ files changed or output exceeds ~50KB):

1. **Start with `--stat` only** — Use the file list and change counts to plan
2. **Read full diff only for high-impact files** — APIs, schemas, configs, contracts, new files
3. **Read only changed hunks for medium-impact files** — Business logic, services
4. **Skip full diff for low-impact files** — Tests, formatting, comments
5. **Split by directory** — If still too large, analyze one component/service at a time

```bash
# Start with stat only
bash <skill-path>/scripts/extract-diff-repo.sh <repo-path> --branch feature/X --stat
```

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

1. **New OAuth service** (oauth.ts, 120 lines) → High impact → Component Doc
2. **Route changes** (auth.ts, 45 lines) → Public API change → Component Doc + Changelog
3. **New major dependency** (passport-google-oauth20) → Technical Guide
4. **New tests with different expectations** → Confirms business logic change

### Output: Generated Docs

- `docs/components/react_comp_auth.md` — Updated: added OAuth endpoints
- `docs/changelogs/react_cl_2026-03-01.md` — New: 2 features, 1 fix
- `docs/guides/react_guide_oauth_google.md` — New: Google OAuth integration guide
- `docs/technical/react_tech_oauth_architecture.md` — New: OAuth flow deep-dive

---

## Resources

- `scripts/extract-diff.sh` — Extract structured diff data (file stats, commit log, full diff)
- `scripts/extract-diff-repo.sh` — Extract diff with automatic repository name detection
- `scripts/get-repo-name.sh` — Get the current git repository name
- `scripts/detect-changes.sh` — Categorize changes by type with priority levels
- `scripts/check-freshness.sh` — Compare doc timestamps vs last code change
- `scripts/sync-to-central.sh` — Sync per-MS docs to docs-microservices (CTO structure)
- `references/analysis-patterns.md` — How to classify changes from diffs
- `references/documentation-layers.md` — The 4-layer documentation system
- `references/frontmatter-schema.md` — Frontmatter schema and validation rules
- `references/central-mapping.md` — Mapping from per-MS paths to docs-microservices paths
- `references/ci-integration.md` — GitHub Actions workflow examples
- `templates/` — All document templates
