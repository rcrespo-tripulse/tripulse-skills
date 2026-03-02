#!/bin/bash
# list-commands.sh - Show living-docs commands with usage guidance
# Usage: bash scripts/list-commands.sh

set -euo pipefail

cat <<'EOF'
Living Docs - Available Commands

Prompt format:
  living-docs:<command>

Examples:
  living-docs:document react
  living-docs:document-branch
  living-docs:document-commits 20

Commands:
  1) document [service]
     What: Generate or update full docs from current code state.
     When: You need complete per-service docs (not commit history).
     Prompt: living-docs:document react

  2) document-branch
     What: Document current branch changes vs base branch.
     When: You finished a feature and want change-focused docs.
     Prompt: living-docs:document-branch

  3) document-commits [N]
     What: Document the last N commits.
     When: You need release notes or changelog from recent commits.
     Prompt: living-docs:document-commits 20

  4) sync
     What: Sync per-service docs into docs-microservices structure.
     When: Per-service docs are ready and you want to publish centrally.
     Prompt: living-docs:sync

  5) migrate-legacy
     What: Detect and migrate old docs to the standard format.
     When: You still have legacy markdown docs without frontmatter/naming.
     Prompt: living-docs:migrate-legacy

  6) audit
     What: Audit freshness of docs vs current code.
     When: You want to detect stale or missing documentation.
     Prompt: living-docs:audit

  7) document-flow [name]
     What: Create/update cross-service business flow documentation.
     When: A workflow spans multiple services and needs end-to-end traceability.
     Prompt: living-docs:document-flow order-b2b

  8) create-adr
     What: Create an Architecture Decision Record.
     When: A relevant technical/architectural decision needs to be captured.
     Prompt: living-docs:create-adr

  9) system-overview
     What: Generate/update top-level system architecture docs.
     When: You need a global map of services, integrations, and patterns.
     Prompt: living-docs:system-overview
EOF
