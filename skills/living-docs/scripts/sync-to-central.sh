#!/bin/bash
# sync-to-central.sh - Sync per-MS docs to docs-microservices (CTO Vault structure)
#
# Maps per-service documentation to the CTO's centralized Vault structure.
# This is NOT a simple copy — each doc type goes to a different location.
#
# Mapping:
#   {service}/docs/components/*.md  → $DOCS_REPO/reference/{service}/
#   {service}/docs/changelogs/*.md  → $DOCS_REPO/reports/changelogs/
#   {service}/docs/adrs/*.md        → $DOCS_REPO/engineering/adrs/
#   {service}/docs/runbooks/*.md    → $DOCS_REPO/engineering/guides/
#   {service}/docs/guides/*.md      → $DOCS_REPO/engineering/guides/
#   {service}/docs/technical/*.md   → $DOCS_REPO/reference/{service}/
#   {service}/docs/bugs/*.md        → $DOCS_REPO/reports/
#   {service}/docs/plans/*.md       → $DOCS_REPO/strategy/
#   {service}/docs/tasks/*.md       → $DOCS_REPO/engineering/microservices/{service}/
#   {service}/docs/index.md         → NOT synced (local navigation only)
#
# Usage:
#   bash sync-to-central.sh --repos-dir /path/to/ms-root --docs-repo /path/to/docs-microservices
#   bash sync-to-central.sh --repos-dir /path/to/ms-root --docs-repo /path/to/docs-microservices --service sap
#   bash sync-to-central.sh --repos-dir /path/to/ms-root --docs-repo /path/to/docs-microservices --dry-run

set -euo pipefail

REPOS_DIR=""
DOCS_REPO=""
SINGLE_SERVICE=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --repos-dir) REPOS_DIR="$2"; shift 2 ;;
    --docs-repo) DOCS_REPO="$2"; shift 2 ;;
    --service) SINGLE_SERVICE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$REPOS_DIR" || -z "$DOCS_REPO" ]]; then
  echo "Usage: bash sync-to-central.sh --repos-dir /path/to/ms-root --docs-repo /path/to/docs-microservices [--service name] [--dry-run]"
  exit 1
fi

echo "=== Sync to Central (CTO Vault) ==="
echo "Source repos: $REPOS_DIR"
echo "Target docs:  $DOCS_REPO"
echo "Dry run:      $DRY_RUN"
[[ -n "$SINGLE_SERVICE" ]] && echo "Single service: $SINGLE_SERVICE"
echo ""

SYNCED=0
SKIPPED_SAME=0
SKIPPED_SACRED=0
NO_DOCS=0
ERRORS=0

# Naming convention for docs created by this skill: {REPO}_{TYPE}_{SLUG}.md
# Files NOT matching this convention in the target are "sacred" and won't be overwritten.
is_sacred_document() {
  local target_file="$1"
  local service_name="$2"

  [[ ! -f "$target_file" ]] && return 1  # File doesn't exist, not sacred

  local basename
  basename=$(basename "$target_file")

  # Check if filename starts with the service name prefix (our naming convention)
  # Convention: {service}_{type}_{slug}.md — e.g., sap_component_auth-module.md
  if [[ "$basename" == "${service_name}_"* ]]; then
    return 1  # Our file, not sacred
  fi

  # File exists but doesn't follow our naming convention → sacred
  return 0
}

# Resolve the target directory for a given doc type
get_target_dir() {
  local doc_type="$1"
  local service_name="$2"

  case "$doc_type" in
    components) echo "$DOCS_REPO/reference/$service_name" ;;
    changelogs) echo "$DOCS_REPO/reports/changelogs" ;;
    adrs)       echo "$DOCS_REPO/engineering/adrs" ;;
    runbooks)   echo "$DOCS_REPO/engineering/guides" ;;
    guides)     echo "$DOCS_REPO/engineering/guides" ;;
    technical)  echo "$DOCS_REPO/reference/$service_name" ;;
    bugs)       echo "$DOCS_REPO/reports" ;;
    plans)      echo "$DOCS_REPO/strategy" ;;
    tasks)      echo "$DOCS_REPO/engineering/microservices/$service_name" ;;
    *)          echo "" ;;  # Unknown type, skip
  esac
}

# Sync a single file from source to target
sync_file() {
  local source_file="$1"
  local target_dir="$2"
  local service_name="$3"
  local doc_type="$4"

  local filename
  filename=$(basename "$source_file")
  local target_file="$target_dir/$filename"

  # Check sacred document protection
  if is_sacred_document "$target_file" "$service_name"; then
    echo "    ⛔ $filename — SACRED: exists but doesn't follow naming convention, skipping"
    SKIPPED_SACRED=$((SKIPPED_SACRED + 1))
    return
  fi

  # Check if files are identical
  if [[ -f "$target_file" ]] && diff -q "$source_file" "$target_file" &>/dev/null; then
    SKIPPED_SAME=$((SKIPPED_SAME + 1))
    return
  fi

  local action="new"
  [[ -f "$target_file" ]] && action="update"

  if [[ "$DRY_RUN" == "true" ]]; then
    echo "    📝 $filename → $doc_type/ ($action, dry-run)"
  else
    mkdir -p "$target_dir"
    cp "$source_file" "$target_file"
    echo "    📝 $filename → $doc_type/ ($action)"
  fi
  SYNCED=$((SYNCED + 1))
}

# Sync all docs for a single service
sync_service() {
  local service_name="$1"
  local docs_dir="$REPOS_DIR/$service_name/docs"

  # Check if service has any docs
  if [[ ! -d "$docs_dir" ]]; then
    echo "  ⚪ $service_name — no docs/ directory"
    NO_DOCS=$((NO_DOCS + 1))
    return
  fi

  # Check if there are any .md files beyond index.md
  local has_docs=false
  for doc_type_dir in "$docs_dir"/*/; do
    [[ ! -d "$doc_type_dir" ]] && continue
    for md_file in "$doc_type_dir"*.md; do
      [[ -f "$md_file" ]] && has_docs=true && break
    done
    [[ "$has_docs" == "true" ]] && break
  done

  if [[ "$has_docs" == "false" ]]; then
    echo "  ⚪ $service_name — docs/ exists but no typed subdirectories with .md files"
    NO_DOCS=$((NO_DOCS + 1))
    return
  fi

  echo "  🔄 $service_name"

  # Iterate over known doc type subdirectories
  for doc_type in components changelogs adrs runbooks guides technical bugs plans tasks; do
    local source_dir="$docs_dir/$doc_type"
    [[ ! -d "$source_dir" ]] && continue

    local target_dir
    target_dir=$(get_target_dir "$doc_type" "$service_name")

    if [[ -z "$target_dir" ]]; then
      echo "    ⚠️  Unknown doc type: $doc_type, skipping"
      ERRORS=$((ERRORS + 1))
      continue
    fi

    for md_file in "$source_dir"/*.md; do
      [[ ! -f "$md_file" ]] && continue
      sync_file "$md_file" "$target_dir" "$service_name" "$doc_type"
    done
  done
}

# Process services
if [[ -n "$SINGLE_SERVICE" ]]; then
  if [[ ! -d "$REPOS_DIR/$SINGLE_SERVICE" ]]; then
    echo "Error: Service directory not found: $REPOS_DIR/$SINGLE_SERVICE"
    exit 1
  fi
  sync_service "$SINGLE_SERVICE"
else
  for repo_dir in "$REPOS_DIR"/*/; do
    [[ ! -d "$repo_dir/.git" ]] && continue
    service_name=$(basename "$repo_dir")
    # Skip docs-microservices itself
    [[ "$service_name" == "docs-microservices" ]] && continue
    sync_service "$service_name"
  done
fi

echo ""
echo "=== Summary ==="
echo "Synced:           $SYNCED"
echo "Already in sync:  $SKIPPED_SAME"
echo "Sacred (skipped): $SKIPPED_SACRED"
echo "No docs:          $NO_DOCS"
echo "Errors:           $ERRORS"

if [[ "$DRY_RUN" == "true" ]]; then
  echo ""
  echo "This was a dry run. No files were modified."
  echo "Run without --dry-run to apply changes."
fi

if [[ "$SKIPPED_SACRED" -gt 0 ]]; then
  echo ""
  echo "⛔ SACRED DOCUMENTS DETECTED"
  echo "Some target files exist but don't follow the naming convention ({service}_{type}_{slug}.md)."
  echo "These were NOT overwritten to protect manually-created content."
  echo "To sync these, rename them to follow the convention or remove them first."
fi

if [[ "$DRY_RUN" == "false" && "$SYNCED" -gt 0 ]]; then
  echo ""
  echo "Files synced. Remember to review and commit in docs-microservices:"
  echo "  cd $DOCS_REPO && git diff"
fi
