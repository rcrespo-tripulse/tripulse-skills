# The 4-Layer Documentation System

## Why Layers?

A single flat documentation structure doesn't scale for microservice architectures. Different questions require different levels of abstraction:

- "What does our system do?" -- System level
- "What happens when an order comes in?" -- Flow level
- "What endpoints does the SAP service expose?" -- Service level
- "Why did we choose Redis over Pub/Sub?" -- Decision level

## Source of Truth Principle

The most important rule: **per-service docs live with the service code.**

```
ms-root/
├── sap/docs/index.md              <-- SOURCE OF TRUTH (Layer 3)
├── magento/docs/index.md          <-- SOURCE OF TRUTH (Layer 3)
├── integrator/docs/index.md       <-- SOURCE OF TRUTH (Layer 3)
└── docs-microservices/            <-- Obsidian Vault structure (transversal + gathered copies)
    ├── Global_Architecture_Map.md <-- ENTRY POINT (root of navigation)
    ├── CLAUDE.MD.md               <-- Agent rules and vault config
    ├── engineering/               <-- SOURCE OF TRUTH (Layer 1 + Layer 4)
    │   ├── adrs/                  <-- Architecture Decision Records
    │   ├── microservices/         <-- Per-service architecture + task docs
    │   ├── guides/                <-- SOPs, runbooks, user guides
    │   └── ...
    ├── reference/
    │   ├── react/                 <-- GATHERED COPIES (component/technical docs)
    │   ├── integrator/
    │   └── ...
    ├── reports/
    │   ├── changelogs/            <-- GATHERED COPIES (changelogs)
    │   └── ...                    <-- Bug reports
    └── strategy/
        ├── data-flows/            <-- SOURCE OF TRUTH (Layer 2)
        └── ...                    <-- Plans, registries
```

> **Important**: `docs-microservices/` follows the Obsidian Vault structure exactly. The skill must never invent new top-level folders (`engineering/`, `reference/`, `reports/`, `strategy/`, `archive/`, etc. are the only valid top-level directories). Gathered copies are distributed across these directories according to the mapping in `references/central-mapping.md`, NOT mirrored in a flat `services/` directory.

**Why co-locate per-service docs?**
- The doc versions with the code. `git blame` shows when each part changed.
- Checking out a tag gives you the docs for that version.
- Agents working inside a repo have immediate access without leaving the repo.
- PRs that change behavior can include doc changes in the same commit.
- No cross-repo dependency for the most common doc operation (update after code change).

**Why aggregate in docs-microservices?**
- Transversal docs (flows, overview, ADRs) don't belong to any single service.
- The `Global_Architecture_Map.md` needs a single home as the entry point.
- Having gathered copies enables reading all service docs from one repo (useful for overview generation, search, CI).

## Layer 1: System Overview

**Source of truth**: `docs-microservices/engineering/`
**Entry point**: `docs-microservices/Global_Architecture_Map.md`
**Audience**: New team members, architects, management, agents needing broad context
**Update frequency**: When services are added/removed or architecture changes significantly
**Owner**: Tech lead / architect

Contains:
- Architecture diagram
- Service inventory (name, purpose, connections)
- Domain glossary
- Shared infrastructure documentation
- External system integration summary
- Quick reference to key flows

**Key principle**: A reader should be able to understand what the system does and how it's organized after reading just this layer.

## Layer 2: Business Flows

**Source of truth**: `docs-microservices/strategy/data-flows/`
**Audience**: Developers working on features that cross services, QA, product managers
**Update frequency**: When flow behavior changes (flagged by living-docs, updated manually)
**Owner**: Developer most familiar with the flow

Contains:
- End-to-end flow descriptions
- Sequence diagrams
- Data transformation documentation
- Error handling across the flow
- Edge cases and known issues

**Key principle**: A developer should be able to understand and debug any business flow by reading the corresponding flow doc, without needing to read all the code.

**Frontmatter requirement**: Every flow doc MUST declare which services it involves:
```yaml
services: [integrator, sap, magento]
```
This enables automated impact detection when a service changes.

## Layer 3: Per-Service Documentation

**Source of truth**: `{ms-root}/{service}/docs/index.md` (in the service's own git repo)
**Gathered copies**: Distributed across `docs-microservices/` per the Obsidian Vault structure (see central-mapping.md)
**Audience**: Developers working on that specific service, agents executing tasks
**Update frequency**: After every merge to main (automated by living-docs)
**Owner**: living-docs (automated) with human review

Contains:
- Service purpose and position in architecture
- All endpoints, consumers, producers, cron jobs
- Internal module structure
- External integration details
- Configuration and environment variables
- Data models
- Error handling
- Known issues and tech debt

**Key principle**: A developer should be able to contribute to a service after reading its docs + the relevant flow docs, without needing a walkthrough from a senior.

**Co-location benefits**:
- When you're working in `sap/`, the docs are right there at `sap/docs/index.md`
- Your agent (Claude Code, OpenCode, etc.) has immediate context
- Code changes and doc changes can live in the same PR/commit
- `git log -- docs/` shows the doc's history
- `git diff HEAD~5 -- docs/` shows recent doc changes

## Layer 4: Architecture Decision Records (ADRs)

**Source of truth**: `docs-microservices/engineering/adrs/`
**Audience**: Future selves, new architects, anyone asking "but why?"
**Update frequency**: When significant decisions are made
**Owner**: The person who made the decision

Contains:
- Context for the decision
- The decision itself
- Alternatives considered
- Consequences (positive AND negative)

**Key principle**: ADRs are immutable historical records. They are never edited after acceptance -- if a decision is reversed, a new ADR supersedes the old one.

## How Layers Reference Each Other

```
Global_Architecture_Map.md (entry point)
    |
engineering/ (system overview docs)
    | references                    | references
strategy/data-flows/               engineering/adrs/
  order-b2b.md                       001-redis-queue.md
    | references
reference/integrator/index.md      (gathered copy)
    ^ copied from
integrator/docs/index.md           (source of truth)
```

**Rules**:
- Higher layers reference lower layers (overview -> flows -> services)
- Lower layers reference higher layers only for context (service doc -> "part of [Order Flow](../flows/order-b2b.md)")
- ADRs are referenced from any layer where the decision is relevant
- The `Global_Architecture_Map.md` is the universal entry point -- always keep it updated
- Cross-references in docs-microservices use the Vault-structure paths
- Cross-references in per-MS docs use relative paths within the service

## The Gather Process

The `sync` command maps per-MS docs into the Obsidian Vault structure. This is NOT a flat mirror -- each doc type maps to its correct location in the Vault hierarchy:

```
sap/docs/components/*.md ──────────────┐
sap/docs/changelogs/*.md ──────────────┤
sap/docs/adrs/*.md ────────────────────┤
magento/docs/components/*.md ──────────┤  sync-to-central.sh
integrator/docs/components/*.md ───────┤  (maps per doc type)
integrator/docs/tasks/*.md ────────────┘
                                        |
                                        v
                          docs-microservices/
                          ├── engineering/
                          │   ├── adrs/              <-- ADRs from all services
                          │   └── microservices/
                          │       └── integrator/    <-- task docs
                          ├── reference/
                          │   ├── sap/               <-- component/technical docs
                          │   ├── magento/
                          │   └── integrator/
                          └── reports/
                              └── changelogs/        <-- changelogs from all services
```

- `sync-to-central.sh` maps each doc type to its correct Vault path (see `references/central-mapping.md`)
- It does NOT commit -- human review required
- If the gathered copy has been manually edited (drift), the script warns and skips
- Manual edits to gathered copies should be moved to the source of truth
- Run after any per-MS doc update to keep everything in sync
