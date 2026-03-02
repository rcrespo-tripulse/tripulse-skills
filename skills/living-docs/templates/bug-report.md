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
