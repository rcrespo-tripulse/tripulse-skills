# Central Mapping: Per-MS Docs to vault

This reference defines how the `sync` command maps per-microservice documentation to the Obsidian Vault structure in `vault/`.

## Mapping Table

| Per-MS Source | vault Target | Notes |
|---|---|---|
| `docs/index.md` | (not synced) | Navigation index is local to the service repo |
| `docs/components/*.md` | `reference/{repo}/` | Component docs and service overviews |
| `docs/changelogs/*.md` | `reports/changelogs/` | Changelogs grouped by date |
| `docs/adrs/*.md` | `engineering/adrs/` | ADRs centralized across all services |
| `docs/runbooks/*.md` | `engineering/guides/` | Runbooks alongside other SOPs |
| `docs/guides/*.md` | `engineering/guides/` | User guides alongside SOPs |
| `docs/technical/*.md` | `reference/{repo}/` | Technical deep-dives per repo |
| `docs/bugs/*.md` | `reports/` | Bug reports alongside other reports |
| `docs/plans/*.md` | `strategy/` | Plans alongside other strategic docs |
| `docs/tasks/*.md` | `engineering/microservices/{repo}/` | Task docs per service |

## Obsidian Vault Structure Reference

```
vault/
├── CLAUDE.MD.md
├── Global_Architecture_Map.md        <-- Entry point
├── engineering/
│   ├── adrs/                         <-- ADRs from all services
│   ├── microservices/                <-- Per-service architecture + task docs
│   │   ├── react/
│   │   ├── integrator/
│   │   └── ...
│   ├── guides/                       <-- Runbooks, SOPs, user guides
│   ├── diagnostics/                  <-- Troubleshooting runbooks
│   ├── database/                     <-- Schema docs
│   ├── infrastructure/               <-- Infra specs
│   ├── frontend/                     <-- Frontend docs
│   └── onboarding/                   <-- Dev setup
├── reference/
│   ├── react/                        <-- Component docs, technical docs
│   ├── integrator/
│   └── ...
├── reports/
│   ├── changelogs/                   <-- Changelogs
│   └── ...                           <-- Bug reports
└── strategy/
    ├── data-flows/                   <-- Cross-service flow docs
    └── ...                           <-- Plans
```

## Rules

1. **Never create new top-level folders** in vault. Use the existing structure.
2. **Create `reference/{repo}/`** subdirectory if it doesn't exist before syncing component/technical docs.
3. **Create `engineering/microservices/{repo}/`** subdirectory if it doesn't exist before syncing task docs.
4. **Preserve existing files** in the target directories. Only overwrite files that originated from the skill (check naming convention).
5. **Never overwrite Sacred Documents** authored by [[Erick Blangino]] or [[Jorge Cruz]].
6. **Check audience tag**: Only sync docs with `audience` containing `microservices` or `backend`.
