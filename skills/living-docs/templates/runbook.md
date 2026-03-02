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

## Risks & Inconsistencies

<!-- Optional. Include when operational analysis reveals possible bugs/issues/inconsistencies. -->
<!-- Reuse structure from templates/section-risk-observations.md -->

## Related

- [[Service Doc]]
- [[ADR-NNN]]
