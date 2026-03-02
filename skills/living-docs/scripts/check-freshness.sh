#!/bin/bash
# check_freshness.sh - Compare doc timestamps vs last code changes
#
# Reads docs from each service's source of truth ({service}/docs/index.md)
# and compares last_documented_sha against the repo's current HEAD.
# Also checks if per-MS docs exist in vault.
#
# Usage: bash check_freshness.sh --repos-dir /path/to/ms-root [--docs-repo /path/to/vault]

set -euo pipefail

REPOS_DIR=""
DOCS_REPO=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --repos-dir) REPOS_DIR="$2"; shift 2 ;;
    --docs-repo) DOCS_REPO="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$REPOS_DIR" ]]; then
  echo "Usage: bash check_freshness.sh --repos-dir /path/to/ms-root [--docs-repo /path/to/vault]"
  exit 1
fi

# Auto-detect docs repo if not specified
if [[ -z "$DOCS_REPO" && -d "$REPOS_DIR/vault" ]]; then
  DOCS_REPO="$REPOS_DIR/vault"
fi

echo "=== Documentation Freshness Report ==="
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Source: per-service docs ({service}/docs/index.md)"
echo ""

# Table header
printf "| %-25s | %-12s | %-12s | %-15s | %-12s |\n" "Service" "Doc SHA" "Current HEAD" "Commits Behind" "Status"
printf "|%-27s|%-14s|%-14s|%-17s|%-14s|\n" "---------------------------" "--------------" "--------------" "-----------------" "--------------"

TOTAL_SERVICES=0
DOCUMENTED=0
CURRENT=0
STALE=0
NO_DOCS=0

# Find all git repos in the repos directory
for repo_dir in "$REPOS_DIR"/*/; do
  [[ ! -d "$repo_dir/.git" ]] && continue

  SERVICE_NAME=$(basename "$repo_dir")

  # Skip vault itself
  [[ "$SERVICE_NAME" == "vault" ]] && continue

  TOTAL_SERVICES=$((TOTAL_SERVICES + 1))

  # Get current HEAD
  CURRENT_HEAD=$(cd "$repo_dir" && git rev-parse HEAD 2>/dev/null)
  CURRENT_HEAD_SHORT="${CURRENT_HEAD:0:8}"

  # Check if docs exist in the service repo (source of truth)
  DOC_FILE="$repo_dir/docs/index.md"

  if [[ ! -f "$DOC_FILE" ]]; then
    printf "| %-25s | %-12s | %-12s | %-15s | %-12s |\n" "$SERVICE_NAME" "—" "$CURRENT_HEAD_SHORT" "∞" "❌ No docs"
    NO_DOCS=$((NO_DOCS + 1))
    continue
  fi

  DOCUMENTED=$((DOCUMENTED + 1))

  # Extract last_documented_sha from frontmatter
  DOC_SHA=$(grep -m1 'last_documented_sha:' "$DOC_FILE" 2>/dev/null | sed 's/.*: *"\?\([^"]*\)"\?/\1/' | tr -d ' ')
  DOC_SHA_SHORT="${DOC_SHA:0:8}"

  if [[ -z "$DOC_SHA" || "$DOC_SHA" == "null" || "$DOC_SHA" == "{full-sha}" ]]; then
    printf "| %-25s | %-12s | %-12s | %-15s | %-12s |\n" "$SERVICE_NAME" "no SHA" "$CURRENT_HEAD_SHORT" "?" "⚠️ No SHA"
    STALE=$((STALE + 1))
    continue
  fi

  # Count commits behind
  BEHIND=$(cd "$repo_dir" && git rev-list --count "$DOC_SHA".."$CURRENT_HEAD" 2>/dev/null || echo "?")

  if [[ "$BEHIND" == "0" ]]; then
    printf "| %-25s | %-12s | %-12s | %-15s | %-12s |\n" "$SERVICE_NAME" "$DOC_SHA_SHORT" "$CURRENT_HEAD_SHORT" "0" "✅ Current"
    CURRENT=$((CURRENT + 1))
  else
    printf "| %-25s | %-12s | %-12s | %-15s | %-12s |\n" "$SERVICE_NAME" "$DOC_SHA_SHORT" "$CURRENT_HEAD_SHORT" "$BEHIND" "⚠️ STALE"
    STALE=$((STALE + 1))
  fi
done

echo ""
echo "=== Summary ==="
echo "Total services: $TOTAL_SERVICES"
echo "Documented: $DOCUMENTED / $TOTAL_SERVICES"
echo "Current: $CURRENT"
echo "Stale: $STALE"
echo "No docs: $NO_DOCS"

# Check which per-MS docs exist in vault
if [[ -n "$DOCS_REPO" && -d "$DOCS_REPO" ]]; then
  echo ""
  echo "=== Per-MS Docs in vault ==="
  echo "(checking which services have synced docs in the CTO Vault)"
  echo ""

  HAS_DOCS=0
  MISSING_DOCS=0

  for repo_dir in "$REPOS_DIR"/*/; do
    [[ ! -d "$repo_dir/.git" ]] && continue
    SERVICE_NAME=$(basename "$repo_dir")
    [[ "$SERVICE_NAME" == "vault" ]] && continue

    # Check if this service has any docs in vault (any of the target paths)
    FOUND=false
    for check_dir in \
      "$DOCS_REPO/reference/$SERVICE_NAME" \
      "$DOCS_REPO/engineering/microservices/$SERVICE_NAME"; do
      if [[ -d "$check_dir" ]]; then
        FOUND=true
        break
      fi
    done

    if [[ "$FOUND" == "true" ]]; then
      echo "  ✅ $SERVICE_NAME — docs present in vault"
      HAS_DOCS=$((HAS_DOCS + 1))
    else
      # Only report missing if the service has source docs to sync
      if [[ -d "$REPOS_DIR/$SERVICE_NAME/docs" ]]; then
        echo "  ❌ $SERVICE_NAME — not synced (run sync-to-central.sh)"
        MISSING_DOCS=$((MISSING_DOCS + 1))
      fi
    fi
  done

  echo ""
  echo "  Synced: $HAS_DOCS | Not synced: $MISSING_DOCS"
fi

# Check flow docs for references to stale services
if [[ -n "$DOCS_REPO" && -d "$DOCS_REPO/strategy/data-flows" ]]; then
  echo ""
  echo "=== Flow Doc Impact ==="

  for flow_file in "$DOCS_REPO"/strategy/data-flows/*.md; do
    [[ ! -f "$flow_file" ]] && continue

    FLOW_NAME=$(basename "$flow_file" .md)
    # Extract services from frontmatter
    FLOW_SERVICES=$(grep -m1 'services:' "$flow_file" 2>/dev/null | sed 's/.*\[//;s/\].*//;s/,/ /g;s/"//g' || echo "")

    if [[ -n "$FLOW_SERVICES" ]]; then
      STALE_REFS=""
      for svc in $FLOW_SERVICES; do
        svc=$(echo "$svc" | tr -d ' ')
        [[ -z "$svc" ]] && continue

        # Check the SOURCE OF TRUTH (not the gathered copy)
        DOC_FILE="$REPOS_DIR/$svc/docs/index.md"
        REPO_DIR="$REPOS_DIR/$svc"

        if [[ ! -f "$DOC_FILE" ]]; then
          STALE_REFS="$STALE_REFS $svc(no-docs)"
        elif [[ -d "$REPO_DIR/.git" ]]; then
          DOC_SHA=$(grep -m1 'last_documented_sha:' "$DOC_FILE" 2>/dev/null | sed 's/.*: *"\?\([^"]*\)"\?/\1/' | tr -d ' ')
          HEAD=$(cd "$REPO_DIR" && git rev-parse HEAD 2>/dev/null)
          if [[ -n "$DOC_SHA" && "$DOC_SHA" != "null" && "$DOC_SHA" != "{full-sha}" && "$DOC_SHA" != "$HEAD" ]]; then
            STALE_REFS="$STALE_REFS $svc(stale)"
          fi
        fi
      done

      if [[ -n "$STALE_REFS" ]]; then
        echo "  ⚠️  $FLOW_NAME → references stale services:$STALE_REFS"
      else
        echo "  ✅  $FLOW_NAME → all referenced services current"
      fi
    fi
  done
fi
