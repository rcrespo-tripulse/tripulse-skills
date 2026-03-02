# Frontmatter Schema

All documentation files MUST include YAML frontmatter. This enables automated freshness checking, impact detection, and catalog generation.

## Base Fields (all doc types -- required by Obsidian Vault standard)

```yaml
---
aliases: [Keyword 1, Keyword 2, Spanish Name]
type: service | library | frontend | infrastructure | database | cli-tool | sop | changelog | guide | technical | bug | plan | task | adr | microservice | architecture | protocol
layer: Backend | Frontend | Infrastructure | Data | Shared | SOP | Global | Store (Magento) | ERP (SAP) | Frontend (React) | Microservices
status: active | debt | zombie | gap
owner: "[[Person Name]]"
tech_stack: "[[Technology 1]], [[Technology 2]]"
audience: [microservices | magento | nextjs | client | internal-only]
last_updated: YYYY-MM-DD
---
```

## Extended Fields (per-service docs)

These fields are added to per-service documentation to enable incremental updates and traceability:

```yaml
source_branch: branch-name
commit_range: abc1234..def5678
last_documented_sha: "full-40-char-sha"
doc_version: "1.0.0"  # Semver: major=restructure, minor=new sections, patch=updates
```

### `last_documented_sha`

This is the critical field for incremental updates. It tells living-docs where to start the next analysis. When updating docs:
1. Read this value to determine the starting point
2. Analyze commits from this SHA to current HEAD
3. Update this value to current HEAD after updating docs

### `doc_version`

Follows semantic versioning:
- **Major**: Full restructure or rewrite of the document
- **Minor**: New sections added (e.g., new endpoints documented)
- **Patch**: Updates to existing sections (e.g., corrected a description, updated env var)

---

## Per-Service Docs (`{service}/docs/components/{repo}_comp_overview.md`)

```yaml
---
aliases: [integrator, Integrador, ETL Service]
type: service
layer: Backend
status: active
owner: "[[Rodrigo]]"
tech_stack: "[[NestJS]], [[TypeScript]], [[Redis]]"
audience: [microservices]
last_updated: 2026-03-01
source_branch: main
commit_range: abc1234..def5678
last_documented_sha: "abc123def456789012345678901234567890abcd"
doc_version: "1.2.0"
---
```

## Flow Docs (`docs-microservices/strategy/data-flows/{flow-name}.md`)

```yaml
---
aliases: [Order B2B Flow, Flujo Orden B2B]
type: architecture
layer: Microservices
status: active
owner: "[[Developer Name]]"
tech_stack: "[[RabbitMQ]], [[Redis]]"
audience: [microservices]
last_updated: 2026-03-01
services: [integrator, sap, magento]     # REQUIRED. Used for impact detection
entry_point: "magento webhook POST /api/orders"
triggers: [webhook]                       # What initiates: webhook | cron | user-action | queue-message
complexity: high                          # low | medium | high
---
```

### `services` array

This is the critical field for cross-service impact detection. When living-docs updates a service's docs, it checks all flow docs to see if the service appears in any `services` array. If it does, the flow is flagged for review.

## ADR Docs (`docs-microservices/engineering/adrs/{NNN}-{slug}.md`)

```yaml
---
aliases: [ADR 001, Use Redis as Message Queue, Usar Redis como Cola]
type: adr
layer: Backend
status: accepted                          # proposed | accepted | deprecated | superseded
owner: "[[Decision Author]]"
tech_stack: "[[Redis]], [[RabbitMQ]]"
audience: [microservices]
last_updated: 2026-01-15
number: 1                                 # REQUIRED. Unique sequential number
superseded_by: null                       # ADR number if superseded, e.g. 15
services_affected: [integrator, sap]      # Which services this decision impacts
authors: [rodrigo]                        # People who made the decision
---
```

## System Overview (`docs-microservices/engineering/`)

```yaml
---
aliases: [System Overview, Vista General del Sistema]
type: architecture
layer: Global
status: active
owner: "[[Tom]]"
tech_stack: "[[GCP]], [[GKE]], [[NestJS]]"
audience: [microservices]
last_updated: 2026-03-01
---
```

## Entry Point (`docs-microservices/Global_Architecture_Map.md`)

```yaml
---
aliases: [Architecture Map, Mapa de Arquitectura, System Catalog]
type: architecture
layer: Global
status: active
owner: "[[Tom]]"
tech_stack: "[[Magento 2]], [[Next.js 15]], [[GCP]]"
audience: [magento, nextjs, microservices]
last_updated: 2026-03-01
---
```

---

## Field Rules

| Field | Required | Notes |
|-------|----------|-------|
| aliases | Yes | Include English name + Spanish equivalent + key concepts |
| type | Yes | Match the component's architectural role |
| layer | Yes | Match the project's folder/layer structure |
| status | Yes | `active` = live, `debt` = needs refactor, `zombie` = deprecated, `gap` = missing |
| owner | Yes | Wiki-link to the responsible person. If unknown, use `"[[TBD]]"` |
| tech_stack | Yes | Wiki-links to each technology. Infer from file extensions and manifests |
| audience | Yes | Per CTO's distribution model. Determines which downstream repo receives the doc |
| last_updated | Yes | Auto-set to generation date |
| source_branch | Yes (per-MS) | Branch analyzed |
| commit_range | Yes (per-MS) | Commit range analyzed |
| last_documented_sha | Yes (per-MS) | Full 40-char SHA of last analyzed commit |
| services | Yes (flows) | Array of service names involved in the flow |
| number | Yes (ADRs) | Unique sequential integer |

## Inferring Frontmatter from Diffs

| Field | Heuristic |
|-------|-----------|
| **owner** | Most frequent committer in `git log` for the changed files. If unclear, set `"[[TBD]]"` and flag to user |
| **tech_stack** | Detect from file extensions (.ts -> TypeScript, .py -> Python, .go -> Go), manifests (package.json, go.mod, Cargo.toml), and framework imports |
| **type** | Dockerfile + main entry -> `service`; package with exports, no server -> `library`; next.config/vite.config -> `frontend`; Terraform/Helm -> `infrastructure`; migrations -> `database` |
| **layer** | Infer from project directory structure or monorepo workspace layout |
| **audience** | Default to `[microservices]` for backend services. Add `[magento]` if Magento-related, `[nextjs]` if frontend-related |

---

## Status Values

### Component/Service Status (CTO standard)

| Status | Meaning | Action Required |
|--------|---------|----------------|
| `active` | Live and maintained | None |
| `debt` | Works but needs refactoring | Track in Tech Debt Registry |
| `zombie` | Deprecated, should be removed | Plan removal |
| `gap` | Missing documentation or implementation | Generate or implement |

### Document Lifecycle Status (living-docs internal)

| Status | Meaning | Action Required |
|--------|---------|----------------|
| `draft` | Just created, not yet reviewed by a human | Needs human review |
| `verified` | Reviewed and confirmed accurate by a human | None |
| `needs-review` | Flagged by automation as potentially stale | Human should verify |
| `stale` | Confirmed out of date (>N commits behind) | Run living-docs update |

Note: The CTO's standard uses `status` for the component/service health. The living-docs lifecycle status is tracked separately in the `doc_status` field when both are needed. In most cases, use the CTO's standard values.

---

## Validation Rules

1. Frontmatter MUST be valid YAML
2. `aliases`, `type`, `layer`, `status`, `owner`, `tech_stack`, `audience`, and `last_updated` are required on ALL docs
3. `last_documented_sha` is required on per-service docs
4. `services` array is required on flow docs
5. `number` is required on ADRs and must be unique
6. Dates use ISO 8601 format: `YYYY-MM-DD`
7. SHA values must be full 40-character hashes (not short SHAs)
8. `owner` must use wiki-link format: `"[[Person Name]]"`
9. `tech_stack` must use wiki-link format: `"[[Tech1]], [[Tech2]]"`
10. `audience` must contain at least one valid tag from the distribution model

---

## Audience Tag Rules (CTO's Distribution Model)

| Tag | Distributed To | Examples |
|-----|---------------|----------|
| `[magento]` | docs-magento repo | B2B module docs, Magento SOPs, theme architecture |
| `[nextjs]` | docs-nextjs repo | Portal components, React BFF consumer docs |
| `[microservices]` | docs-microservices repo | Service architectures, database schemas, ETL logic |
| `[backend]` | docs-microservices repo | Backend SOPs, testing guides, API contracts |
| `[devops]` | docs-microservices repo | Infrastructure, CI/CD, deployment |
| `[frontend]` | docs-nextjs repo | UI components, state management, i18n |
| `[client]` | docs-client repo | Customer-facing user guides |
| `[internal-only]` | Master vault only | Gap registries, security findings, strategic plans, agent config |
| Multi-audience | Multiple repos | `[microservices, magento]` for cross-layer docs like data flows |

The `audience` tag determines which downstream repository receives a copy of the document via the CTO's Python distribution script. Always set this field correctly -- a missing or wrong audience tag means the doc won't reach its intended team.
