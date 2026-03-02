---
aliases: [Component Name, Nombre Componente, Key Concept]
type: service
layer: Backend
status: active
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: feature/XYZ
commit_range: abc..def
---

# [Component Name]

> One-line purpose of this component.

## What It Does

[2-3 sentences describing the component's responsibility in the system. Focus on *why* it exists, not implementation details.]

## API Surface

<!-- Include only the subsections that apply to this component -->

### Endpoints <!-- if HTTP/gRPC service -->

| Method | Path | Purpose |
|--------|------|---------|
| POST | /api/v1/resource | Creates a resource |
| GET | /api/v1/resource/:id | Retrieves a resource |

### Events Published <!-- if event-driven -->

| Event | Channel | Payload Summary |
|-------|---------|-----------------|
| resource.created | resource-exchange | `{ id, name, timestamp }` |

### Events Consumed <!-- if event-driven -->

| Event | Source | Handler |
|-------|--------|---------|
| order.completed | order-exchange | `handleOrderCompleted()` |

### Pages / Routes <!-- if frontend -->

| Route | Component | Purpose |
|-------|-----------|---------|
| /dashboard | `Dashboard.tsx` | Main user dashboard |
| /settings | `Settings.tsx` | User preferences |

## Dependencies

| Dependency | Purpose |
|------------|---------|
| [[Service B]] | Fetches user data |
| [[Redis]] | Session cache |
| [[MySQL]] | Primary persistence |

## Configuration

| Env Var | Purpose | Default |
|---------|---------|---------|
| `PORT` | HTTP listen port | 3000 |
| `DB_HOST` | Database host | localhost |

## Key Files

| Path | Purpose |
|------|---------|
| `src/routes/index.ts` | Route definitions |
| `src/services/main.ts` | Core business logic |

## Recent Changes

[Auto-generated summary of what changed in the analyzed commits]
