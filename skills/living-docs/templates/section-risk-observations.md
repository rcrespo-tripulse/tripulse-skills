## Risks & Inconsistencies

<!-- Optional. Include only when evidence indicates possible issues, bugs, mismatches, or fragile behavior. -->
<!-- Every row must reference real evidence (file:line, commit, test failure, or runtime signal). -->

| Severity | Finding | Evidence | Impact | Recommended Action | Owner |
|----------|---------|----------|--------|--------------------|-------|
| low | [Concise finding] | `service/src/file.ts:L42` | [Possible impact] | [Action] | [[Owner Name]] |

Severity guide:
- `critical`: Production outage, data corruption, security exposure, or legal/compliance risk
- `high`: Major functionality broken, repeated incidents, or high operational risk
- `medium`: Behavior mismatch or reliability issue with moderate user/business impact
- `low`: Minor inconsistency, edge-case weakness, or documentation-code mismatch

Escalation rule:
- If severity is `high` or `critical`, create/update `docs/bugs/{repo}_bug_{slug}.md` and link it in the parent doc.
