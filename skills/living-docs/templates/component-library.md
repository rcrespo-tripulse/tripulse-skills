---
aliases: [Package Name, Nombre Paquete, Key Concept]
type: library
layer: Shared
status: active
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: feature/XYZ
commit_range: abc..def
---

# [Package Name]

> One-line purpose of this library/package.

## What It Does

[2-3 sentences describing the package's responsibility. Focus on *why* it exists and what problem it solves for its consumers.]

## Exported API

| Export | Type | Description |
|--------|------|-------------|
| `validateEmail()` | function | Validates email format |
| `UserDTO` | type/interface | User data transfer object |
| `AUTH_CONSTANTS` | constant | Authentication configuration values |

## Consumers

| Consumer | What It Uses | How |
|----------|-------------|-----|
| [[auth-service]] | `validateEmail`, `UserDTO` | Import from package |
| [[user-service]] | `UserDTO` | Import from package |

## Dependencies

| Dependency | Purpose |
|------------|---------|
| zod | Schema validation |

## Key Files

| Path | Purpose |
|------|---------|
| `src/index.ts` | Public exports (barrel file) |
| `src/validators.ts` | Validation functions |

## Recent Changes

[Auto-generated summary of what changed in the analyzed commits]
