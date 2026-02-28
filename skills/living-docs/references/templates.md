# Document Templates

All documents use YAML frontmatter with the standard metadata header. Use wiki-links (`[[...]]`) for cross-references.

## Frontmatter Schema

```yaml
---
aliases: [Keyword 1, Keyword 2, Spanish Name]
type: service | library | frontend | infrastructure | database | cli-tool | sop | changelog | guide | technical | bug | plan | task
layer: Backend | Frontend | Infrastructure | Data | Shared | SOP | Store (Magento) | ERP (SAP) | Frontend (React)
status: active | debt | zombie | gap
owner: "[[Person Name]]"
tech_stack: "[[Technology 1]], [[Technology 2]]"
last_updated: YYYY-MM-DD
source_branch: branch-name
commit_range: abc1234..def5678
---
```

> **Project-specific extensions**: If your project has additional types (e.g., `magento-module`, `protocol`) or layers (e.g., `Store (Magento)`, `Frontend (NextJS)`), add them alongside the core values. The core set above should cover most projects.

### Field Rules

| Field | Required | Notes |
|-------|----------|-------|
| aliases | Yes | Include English name + Spanish equivalent + key concepts |
| type | Yes | Match the component's architectural role |
| layer | Yes | Match the project's folder/layer structure |
| status | Yes | `active` = live, `debt` = needs refactor, `zombie` = deprecated, `gap` = missing |
| owner | Yes | Wiki-link to the responsible person. If unknown, use `"[[TBD]]"` |
| tech_stack | Yes | Wiki-links to each technology. Infer from file extensions and manifests |
| last_updated | Yes | Auto-set to generation date |
| source_branch | Yes | Branch analyzed |
| commit_range | Yes | Commit range analyzed |

### Inferring Frontmatter from Diffs

| Field | Heuristic |
|-------|-----------|
| **owner** | Most frequent committer in `git log` for the changed files. If unclear, set `"[[TBD]]"` and flag to user |
| **tech_stack** | Detect from file extensions (.ts → TypeScript, .py → Python, .go → Go), manifests (package.json, go.mod, Cargo.toml), and framework imports |
| **type** | Dockerfile + main entry → `service`; package with exports, no server → `library`; next.config/vite.config → `frontend`; Terraform/Helm → `infrastructure`; migrations → `database` |
| **layer** | Infer from project directory structure or monorepo workspace layout |

---

## Template 1: Component Doc (Service / App)

Use when: New service or application detected, significant API changes, new endpoints, dependency changes.

Sections marked `<!-- if applicable -->` should be **included only when relevant** to this component. Omit entire sections that don't apply rather than leaving them empty.

```markdown
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
```

---

## Template 1b: Component Doc (Library / Shared Package)

Use when: New shared library or package detected, or significant changes to a reusable module.

```markdown
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
```

---

## Template 2: Changelog / Release Notes

Use when: User requests release notes, or significant milestone detected across multiple commits.

```markdown
---
aliases: [Changelog, Release Notes, Notas de Version]
type: changelog
layer: SOP
status: active
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: feature/XYZ
commit_range: abc..def
---

# Changelog — [Service/Scope] — [Date or Version]

## Highlights

- [Most impactful change in one sentence]
- [Second most impactful change]

## Breaking Changes

> None | List breaking changes with migration steps

## New Features

- **[Feature Name]**: [What it does and why it matters]

## Bug Fixes

- **[Fix summary]**: [What was broken, what's fixed] (`commit-hash`)

## Improvements

- **[Improvement]**: [What improved and measurable impact if any]

## Internal / Refactoring

- [Changes that don't affect external behavior but matter for maintainability]

## Dependencies Updated

| Package | From | To | Why |
|---------|------|----|-----|
| express | 4.18 | 4.19 | Security patch |
```

---

## Template 3: Architecture Decision Record (ADR)

Use when: Structural pattern change detected (new dependency, new communication pattern, schema migration, significant refactor).

```markdown
---
aliases: [ADR, Decision Record, Registro de Decision]
type: sop
layer: SOP
status: active
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: feature/XYZ
commit_range: abc..def
---

# ADR-[NNN]: [Decision Title]

## Status

Accepted | Proposed | Deprecated | Superseded by ADR-[NNN]

## Context

[What situation or problem prompted this decision? Include technical constraints and business drivers detected from the diff.]

## Decision

[What was decided. Be specific about the chosen approach.]

## Consequences

### Positive

- [Benefit 1]
- [Benefit 2]

### Negative

- [Tradeoff 1]
- [Risk 1]

### Neutral

- [Side effect that's neither good nor bad]

## Evidence from Code

[Specific files/patterns from the diff that support this ADR]

| File | Change | Relevance |
|------|--------|-----------|
| `src/config/redis.ts` | New file | Introduces Redis as cache layer |
```

---

## Template 4: Runbook / SOP

Use when: New deployment config, new error handling patterns, new integration points, infrastructure changes detected.

```markdown
---
aliases: [Runbook, SOP, Procedimiento]
type: sop
layer: SOP
status: active
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: feature/XYZ
commit_range: abc..def
---

# Runbook: [Operation Name]

> When to use this: [One sentence describing the trigger condition]

## Prerequisites

- [ ] Access to [system/tool]
- [ ] Environment variable `X` configured

## Procedure

### 1. [Step Name]

```bash
# command to run
```

**Expected output**: [what you should see]
**If it fails**: [what to do]

### 2. [Step Name]

[instructions]

## Rollback

If something goes wrong:

1. [Rollback step 1]
2. [Rollback step 2]

## Monitoring

| What to Watch | Where | Alert Threshold |
|--------------|-------|-----------------|
| Error rate | Grafana/Datadog | > 5% |
| Response time | APM | > 2s p95 |

## Related

- [[Service Doc]]
- [[ADR-NNN]]
```

---

## Template 5: Technical Guide

Use when: Deep technical documentation needed - architecture patterns, design decisions, complex integrations, system overview.

```markdown
---
aliases: [Technical Guide, Guía Técnica, Technical Documentation]
type: technical
layer: Backend | Frontend | Infrastructure | SOP
status: active | debt | gap
owner: "[[Owner Name]]"
tech_stack: "[[Technology 1]], [[Technology 2]]"
last_updated: YYYY-MM-DD
source_branch: branch-name
commit_range: abc..def
---

# Technical Guide: [Title]

> One-line description of what this guide covers.

## Overview

[2-3 paragraphs explaining the technical concept, pattern, or architecture this guide documents.]

## Prerequisites

- [Prerequisite 1]
- [Prerequisite 2]

## Architecture

### High-Level Diagram

[Describe the components and their relationships]

### Components

| Component | Responsibility | Key Files |
|-----------|---------------|-----------|
| [[Component A]] | Does X | `src/a.ts` |
| [[Component B]] | Does Y | `src/b.ts` |

## Implementation Details

### [Section 1]

[Code examples, configuration, or detailed explanation]

### [Section 2]

[More implementation details]

## Usage Examples

### Example 1: [Use Case]

```bash
# Command or code example
```

### Example 2: [Another Use Case]

```bash
# Command or code example
```

## Related

- [[Component Doc]]
- [[ADR-NNN]]
- [[Runbook: Operation]]
```

---

## Template 6: User Guide

Use when: Documentation for developers/users on how to use a feature, integrate with a service, or accomplish a task.

```markdown
---
aliases: [User Guide, Guía de Usuario, How-To, Tutorial]
type: guide
layer: Backend | Frontend | SOP
status: active
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: branch-name
commit_range: abc..def
---

# Guide: [Feature/Integration Name]

> Brief description of what the user will learn or accomplish.

## What You'll Learn

- [Learning outcome 1]
- [Learning outcome 2]

## Getting Started

### Prerequisites

- [Requirement 1]
- [Requirement 2]

### Setup

[Step-by-step setup instructions]

## Step-by-Step

### Step 1: [Action]

[Instructions]

```bash
# Example command
```

### Step 2: [Action]

[Instructions]

### Step 3: [Action]

[Instructions]

## Configuration

| Option | Description | Default |
|--------|-------------|---------|
| `OPTION_NAME` | What it does | default value |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| [Problem 1] | [Solution 1] |
| [Problem 2] | [Solution 2] |

## Related

- [[Technical Guide]]
- [[API Documentation]]
- [[Runbook]]
```

---

## Template 7: Bug Report

Use when: Documenting a significant bug that was found and fixed, or a known issue that requires context.

```markdown
---
aliases: [Bug Report, Reporte de Bug, Issue, Incidente]
type: bug
layer: Backend | Frontend | Infrastructure
status: active | resolved | wontfix
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: branch-name
commit_range: abc..def
---

# Bug: [Bug Title]

> One-line summary of the bug.

## Summary

[Brief description of what the bug was and its impact.]

## Environment

- **Service**: [[Service Name]]
- **Version/Commit**: [version or commit]
- **Environment**: production | staging | development
- **Frequency**: Always | Intermittent | One-time

## Symptoms

- [Symptom 1]
- [Symptom 2]

## Root Cause

[Explanation of what caused the bug - include relevant code snippets if helpful]

```
[Code snippet showing the bug]
```

## Resolution

[How the bug was fixed]

```diff
- // buggy code
+ // fixed code
```

## Impact

- **Severity**: Critical | High | Medium | Low
- **Affected Users**: [percentage or count]
- **Data Impact**: [if applicable]

## Prevention

- [How to prevent this bug in the future]
- [Tests added]

## Related

- [[Commit: fix-hash]]
- [[Related ADR]]
```

---

## Template 8: Plan

Use when: Documenting migration plans, roadmaps, or large-scale technical initiatives.

```markdown
---
aliases: [Plan, Roadmap, Migration Plan, Plan de Migración]
type: plan
layer: Backend | Frontend | Infrastructure | SOP
status: proposed | in_progress | completed | cancelled
owner: "[[Owner Name]]"
tech_stack: "[[Technology 1]], [[Technology 2]]"
last_updated: YYYY-MM-DD
source_branch: branch-name
commit_range: abc..def
---

# Plan: [Initiative Name]

> One-line description of the plan objective.

## Overview

[High-level description of what this plan aims to accomplish and why.]

## Goals

- [Primary goal 1]
- [Primary goal 2]

## Scope

### In Scope

- [Item 1]
- [Item 2]

### Out of Scope

- [Item 1]
- [Item 2]

## Timeline

| Phase | Description | Start | End | Owner |
|-------|-------------|-------|-----|-------|
| Phase 1 | [Description] | YYYY-MM-DD | YYYY-MM-DD | [[Owner]] |
| Phase 2 | [Description] | YYYY-MM-DD | YYYY-MM-DD | [[Owner]] |
| Phase 3 | [Description] | YYYY-MM-DD | YYYY-MM-DD | [[Owner]] |

## Resources

- **Budget**: [if applicable]
- **Team**: [[Team Member 1]], [[Team Member 2]]
- **Dependencies**: [[Dependency 1]], [[Dependency 2]]

## Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | High/Medium/Low | [Mitigation strategy] |
| [Risk 2] | High/Medium/Low | [Mitigation strategy] |

## Success Criteria

- [Criteria 1]
- [Criteria 2]

## Related

- [[ADR-NNN]]
- [[Technical Guide]]
- [[Previous Plan]]
```

---

## Template 9: Task Doc

Use when: Documenting a specific task, especially one-time tasks or small but significant changes.

```markdown
---
aliases: [Task, Tarea, Ticket]
type: task
layer: Backend | Frontend | Infrastructure
status: pending | in_progress | completed
owner: "[[Owner Name]]"
tech_stack: "[[Technology]]"
last_updated: YYYY-MM-DD
source_branch: branch-name
commit_range: abc..def
---

# Task: [Task Name]

> One-line description of the task.

## Description

[What needs to be done and why.]

## Context

[Background information - why this task exists, related issues, dependencies]

## Requirements

- [Requirement 1]
- [Requirement 2]

## Implementation Notes

[Technical details about how to implement this task]

## Commands

```bash
# Command to run
```

## Verification

- [ ] [Verification step 1]
- [ ] [Verification step 2]

## Notes

[Any additional notes or observations]

## Related

- [[Task: Related Task]]
- [[Commit: relevant-commit]]
```
