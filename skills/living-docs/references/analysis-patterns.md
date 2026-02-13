# Diff Analysis Patterns

How to interpret git diffs and classify changes into documentation-worthy items.
These patterns are **stack-agnostic** — they work for backend services, frontends, libraries, CLIs, and infrastructure.

## Change Classification

### High Impact (MUST document)

| Category | Signals | Doc Type | Why |
|----------|---------|----------|-----|
| New component / module | New directory with 3+ source files, new manifest (package.json, go.mod, Cargo.toml, pyproject.toml) | Component Doc | New unit of work exists |
| Public API change | Modified routes, endpoints, OpenAPI specs, GraphQL schemas, SDK types, public exports | Component Doc + Changelog (Breaking if contract changed) | External consumers affected |
| Inter-service contract change | Modified shared DTOs, event schemas, gRPC protos, message queue contracts, shared packages | Component Doc + notify downstream | Integration surface changed |
| Data model change | New migration, schema change, ORM model change | ADR + Component Doc | Persistence contract changed |
| Business logic change | Modified business rules, changed test expectations, new validation rules, altered status codes | Component Doc + Changelog | Observable behavior changed |
| Major dependency | New framework, new database, new messaging system | ADR | Architectural decision |
| Removed / deprecated component | Deleted service, deprecated module, removed public API | Changelog (Breaking) + Component Doc (`zombie`) | Breaking change |
| Infrastructure change | New/changed Dockerfile, k8s manifests, CI/CD pipelines, Terraform | Runbook | Deployment surface changed |
| Configuration surface change | New env vars, feature flags, config files | Component Doc + Runbook | Runtime behavior can change |

### Medium Impact (Document if significant)

| Category | Signals | Doc Type | Why |
|----------|---------|----------|-----|
| Internal refactor (same behavior) | Code restructured, tests unchanged | Changelog (Internal) | Maintainability signal |
| Test additions / changes | New test files, expanded coverage | Changelog (Improvements) | Quality signal |
| Observability changes | New/changed logging, metrics, tracing | Runbook (Monitoring) | Operational visibility changed |
| Performance optimization | Caching, query optimization, algorithm change | Changelog + ADR if pattern change | Behavior may change |
| Internal interface change | Types used only within same module | Skip unless part of larger pattern | Low blast radius |

### Low Impact (Skip unless part of a pattern)

| Signals | Action |
|---------|--------|
| Formatting / linting fixes | Skip |
| Comment-only changes | Skip |
| Patch version bumps | Skip unless security fix |
| Test-only changes (no logic change) | Skip |
| Typo fixes | Skip |
| File moves with no logic change | Skip |

---

## Key Distinctions

### Business Logic vs Structural Changes

The most important classification decision: **did the observable behavior change?**

| Signal | Classification | Impact |
|--------|---------------|--------|
| Tests modified to expect different outputs | Business logic change | **High** — Component Doc + Changelog |
| New validation rules, new conditions, new branches | Business rule addition | **High** — Component Doc |
| Error messages changed, status codes changed | Behavioral change | **Medium-High** — Changelog |
| Same tests pass, code restructured | Refactor (structural) | **Low** — Changelog (Internal) or skip |
| Code moved between files, no logic change | Reorganization | **Low** — skip |
| New helper/utility extracting existing logic | Extraction refactor | **Low** — skip |

**Heuristic**: If test expectations changed → business logic changed. If only implementation changed but tests remain green → refactor.

### Interface Exposure Levels

Not all interface changes are equal. Classify by **who consumes** the interface:

| Exposure Level | How to Detect | Impact | Doc Action |
|----------------|---------------|--------|------------|
| **External** (public API, SDK, published package) | OpenAPI spec, public routes, exported package types, SDK definitions, README-documented APIs | **Critical** | Component Doc + Changelog (Breaking) + ADR if contract changed |
| **Inter-component** (consumed by other internal services/modules) | Shared packages, event schemas, gRPC protos, types imported across module boundaries | **High** | Component Doc + flag for downstream consumers |
| **Intra-component** (internal to one module) | Types in same directory, unexported functions, private interfaces, internal helpers | **Low** | Skip unless part of larger change |

**Detection heuristics**:
- File in `shared/`, `contracts/`, `packages/`, `libs/`, `sdk/` → inter-component or external
- File referenced in API spec (OpenAPI, GraphQL schema) → external
- Type imported by other services/modules (grep cross-module imports) → inter-component
- File in same module with no external imports → internal

---

## Detection Heuristics

### New Component / Module Detection

```
Signals (any of):
- New directory with 3+ source files
- New manifest file (package.json, go.mod, Cargo.toml, pyproject.toml, pom.xml)
- New barrel/index file (index.ts, __init__.py, mod.rs, lib.rs)
- New entry in workspace config (docker-compose, nx.json, turbo.json, Cargo workspace)
- New directory matching domain patterns: modules/*, domains/*, features/*, services/*, apps/*
→ Action: Generate Component Doc from scratch
→ Consider: Is this a new bounded context? → ADR candidate
```

### Public API Change Detection

```
Signals (any of):
- Modified files matching: **/routes/**, **/controllers/**, **/handlers/**, **/resolvers/**
- Changed OpenAPI/Swagger spec files (openapi.yaml, swagger.json)
- Changed GraphQL schema files (*.graphql, schema.ts)
- Modified public exports in library packages
- Changed request/response types in **/dto/**, **/interfaces/**, **/types/**
- Changed HTTP method, path, or status codes
→ Action: Update Component Doc → API Surface section
→ Check: Is this a breaking change? → Changelog (Breaking Changes)
```

### Architecture Decision Detection

```
Signals (any of):
- New major dependency (not patch/minor update)
- New communication pattern (new queue, new event system, new HTTP client, new gRPC service)
- Database schema migration
- New infrastructure component (Redis, Elasticsearch, message broker, etc.)
- Significant structural refactor (moved >5 files, new module boundaries)
- New architectural pattern (CQRS, event sourcing, saga, etc.)
→ Action: Generate ADR
```

### Operational Change Detection

```
Signals (any of):
- Modified Dockerfile, docker-compose, k8s manifests, Terraform, Helm charts
- New/changed environment variables
- Changed error handling middleware or global error handlers
- Changed health check endpoints or readiness probes
- New/changed monitoring, alerting, or logging configuration
- Changed CI/CD pipeline definitions
→ Action: Generate or update Runbook
```

### Business Logic Change Detection

```
Signals (any of):
- Test expectations changed (assert values different, new test scenarios)
- New conditional branches in core logic (if/switch on business rules)
- Validation rules added or modified
- Status codes or error responses changed
- Pricing, permissions, or workflow logic modified
- New or changed state machine transitions
→ Action: Component Doc (business rules section) + Changelog
→ Distinguish from: Pure refactors where tests don't change
```

---

## Diff Reading Strategy

1. **Start broad**: `git diff --stat` to see which files changed and scope
2. **Identify hotspots**: Files with most changes, new files, deleted files
3. **Classify exposure**: For each changed file, determine if it's external, inter-component, or internal
4. **Read by significance**: High-impact files first (APIs, schemas, configs, contracts), then business logic, skip formatting
5. **Check test changes**: If tests changed expectations → business logic changed; if tests only added → coverage improvement
6. **Cross-reference**: If a public interface changed, check its consumers too
7. **Detect patterns**: Multiple related changes often signal one architectural decision

## Commit Message Mining

Extract intent from commit messages when the diff is ambiguous:

| Commit Prefix | Likely Doc Type |
|---------------|-----------------|
| `feat:` | Component Doc + Changelog (New Features) |
| `fix:` | Changelog (Bug Fixes) |
| `refactor:` | Changelog (Internal) + possibly ADR |
| `chore:` | Usually skip, unless dependency/infra change |
| `breaking:` / `BREAKING CHANGE` | Changelog (Breaking) + ADR + Component Doc update |
| `perf:` | Changelog (Improvements) |
| `docs:` | Skip (already documentation) |
| `ci:` | Runbook if deployment changed, otherwise skip |
| `build:` | Runbook if affects deployment, otherwise skip |

## Scope Determination

When analyzing a diff, determine documentation scope:

- **Single component affected** → Update that component's docs only
- **Multiple components affected** → Update each + consider a cross-cutting ADR
- **Shared package / contract changed** → Update the package doc + flag all consumers
- **Infrastructure change** → Runbook + possibly ADR
- **Global pattern change** → ADR + update all affected Component Docs
