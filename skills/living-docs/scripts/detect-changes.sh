#!/bin/bash
# detect_changes.sh - Categorize changes in a commit range
# Usage: bash detect_changes.sh --repo /path/to/repo --from SHA1 --to SHA2

set -euo pipefail

REPO=""
FROM_SHA=""
TO_SHA=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) REPO="$2"; shift 2 ;;
    --from) FROM_SHA="$2"; shift 2 ;;
    --to) TO_SHA="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [[ -z "$REPO" || -z "$FROM_SHA" || -z "$TO_SHA" ]]; then
  echo "Usage: bash detect_changes.sh --repo /path/to/repo --from SHA --to SHA"
  exit 1
fi

cd "$REPO"

echo "=== Change Detection Report ==="
echo "Repo: $(basename "$(pwd)")"
echo "Range: ${FROM_SHA:0:8}..${TO_SHA:0:8}"
echo "Date: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo ""

# Get all changed files
CHANGED_FILES=$(git diff --name-only "$FROM_SHA".."$TO_SHA" 2>/dev/null)

if [[ -z "$CHANGED_FILES" ]]; then
  echo "No changes detected in this range."
  exit 0
fi

# Categorize files
ENDPOINTS=""
BUSINESS_LOGIC=""
CONFIG=""
DEPENDENCIES=""
INFRASTRUCTURE=""
DATA_MODELS=""
ERROR_HANDLING=""
TESTS=""
QUEUES=""
OTHER=""

while IFS= read -r file; do
  # Skip empty lines
  [[ -z "$file" ]] && continue

  case "$file" in
    # Endpoints / Controllers / Routes
    *controller*|*controllers/*|*routes/*|*handlers/*|*resolver*|*gateway*)
      ENDPOINTS="$ENDPOINTS\n  - $file"
      ;;
    # Tests
    *test*|*spec*|*__tests__*|*.test.*|*.spec.*)
      TESTS="$TESTS\n  - $file"
      ;;
    # Queue / Event related
    *queue*|*consumer*|*producer*|*subscriber*|*publisher*|*worker*|*job*|*bull*)
      QUEUES="$QUEUES\n  - $file"
      ;;
    # Data models
    *model*|*entity*|*entities/*|*schema*|*dto*|*migration*|*prisma*)
      DATA_MODELS="$DATA_MODELS\n  - $file"
      ;;
    # Configuration
    *.env*|*config/*|*configuration*|*.yaml|*.yml|*helm/*|*values*)
      CONFIG="$CONFIG\n  - $file"
      ;;
    # Dependencies
    *package.json|*package-lock*|*yarn.lock|*pnpm-lock*)
      DEPENDENCIES="$DEPENDENCIES\n  - $file"
      ;;
    # Infrastructure
    *Dockerfile*|*docker-compose*|*.github/*|*Jenkinsfile*|*k8s/*|*kubernetes/*|*terraform/*|*tilt*|*skaffold*)
      INFRASTRUCTURE="$INFRASTRUCTURE\n  - $file"
      ;;
    # Error handling (heuristic - files with error/exception in name)
    *error*|*exception*|*middleware*|*interceptor*|*filter*)
      ERROR_HANDLING="$ERROR_HANDLING\n  - $file"
      ;;
    # Business logic (services, use-cases, domain)
    *service*|*services/*|*use-case*|*domain/*|*core/*|*lib/*|*utils/*|*helpers/*)
      BUSINESS_LOGIC="$BUSINESS_LOGIC\n  - $file"
      ;;
    # Everything else
    *)
      OTHER="$OTHER\n  - $file"
      ;;
  esac
done <<< "$CHANGED_FILES"

# Print categorized results
print_category() {
  local name="$1"
  local emoji="$2"
  local files="$3"
  local priority="$4"

  if [[ -n "$files" ]]; then
    echo "$emoji $name [$priority priority]"
    echo -e "$files"
    echo ""
  fi
}

print_category "ENDPOINTS" "🔴" "$ENDPOINTS" "CRITICAL"
print_category "QUEUES" "🔴" "$QUEUES" "CRITICAL"
print_category "BUSINESS LOGIC" "🟡" "$BUSINESS_LOGIC" "HIGH"
print_category "DATA MODELS" "🟡" "$DATA_MODELS" "HIGH"
print_category "ERROR HANDLING" "🟡" "$ERROR_HANDLING" "HIGH"
print_category "CONFIGURATION" "🟢" "$CONFIG" "MEDIUM"
print_category "INFRASTRUCTURE" "🟢" "$INFRASTRUCTURE" "MEDIUM"
print_category "DEPENDENCIES" "⚪" "$DEPENDENCIES" "LOW"
print_category "TESTS" "⚪" "$TESTS" "LOW"
print_category "OTHER" "⚪" "$OTHER" "LOW"

# Summary
TOTAL=$(echo "$CHANGED_FILES" | wc -l)
echo "=== Summary ==="
echo "Total files changed: $TOTAL"
echo ""
echo "Doc update recommendation:"
[[ -n "$ENDPOINTS" ]] && echo "  → Update: API / Endpoints section"
[[ -n "$QUEUES" ]] && echo "  → Update: Queue Consumers/Producers sections + CHECK FLOW DOCS"
[[ -n "$BUSINESS_LOGIC" ]] && echo "  → Update: Modules / Internal Architecture section"
[[ -n "$DATA_MODELS" ]] && echo "  → Update: Data Models section"
[[ -n "$ERROR_HANDLING" ]] && echo "  → Update: Error Handling section"
[[ -n "$CONFIG" ]] && echo "  → Update: Configuration section"
[[ -n "$INFRASTRUCTURE" ]] && echo "  → Update: Infrastructure section"
