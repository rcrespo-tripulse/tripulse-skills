#!/usr/bin/env bash
# Extract structured diff data for documentation analysis.
# Usage:
#   extract-diff.sh <repo-path> [--branch <target-branch>] [--commits <N>] [--path <filter>] [--max-lines <N>] [--stat] [--no-patch]
#
# Modes:
#   --branch <name>      Compare current branch against <name> (default: auto-detect)
#   --commits <N>        Analyze last N commits on current branch
#
# Options:
#   --path <filter>      Only include changes under this path (useful for monorepos)
#   --max-lines <N>      Truncate full diff output at N lines (default: 5000)
#   --stat               Output file-level summaries only (implies --no-patch)
#   --no-patch           Skip full patch output; keep stats and commit log
#
# Output: Structured summary to stdout (file stats, commit log, full diff)

set -euo pipefail

REPO_PATH="${1:-.}"
MODE="branch"
TARGET_BRANCH=""
COMMIT_COUNT=10
PATH_FILTER=""
MAX_LINES=5000
NO_PATCH=0

shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --branch)
      [[ $# -lt 2 ]] && { echo "ERROR: --branch requires a value" >&2; exit 1; }
      TARGET_BRANCH="$2"; MODE="branch"; shift 2
      ;;
    --commits)
      [[ $# -lt 2 ]] && { echo "ERROR: --commits requires a value" >&2; exit 1; }
      COMMIT_COUNT="$2"; MODE="commits"; shift 2
      ;;
    --path)
      [[ $# -lt 2 ]] && { echo "ERROR: --path requires a value" >&2; exit 1; }
      PATH_FILTER="$2"; shift 2
      ;;
    --max-lines)
      [[ $# -lt 2 ]] && { echo "ERROR: --max-lines requires a value" >&2; exit 1; }
      MAX_LINES="$2"; shift 2
      ;;
    --stat) NO_PATCH=1; shift ;;
    --no-patch) NO_PATCH=1; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

cd "$REPO_PATH"

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Handle detached HEAD
if [[ "$CURRENT_BRANCH" == "HEAD" ]]; then
  CURRENT_BRANCH=$(git rev-parse --short HEAD)
  echo "WARNING: Detached HEAD detected, using commit $CURRENT_BRANCH"
fi

# Auto-detect default branch if not specified
if [[ "$MODE" == "branch" && -z "$TARGET_BRANCH" ]]; then
  TARGET_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)
  if [[ -z "$TARGET_BRANCH" ]]; then
    # Fallback: try common default branch names
    for candidate in main master develop Develop; do
      if git rev-parse --verify "origin/$candidate" &>/dev/null; then
        TARGET_BRANCH="$candidate"
        break
      fi
    done
  fi
  if [[ -z "$TARGET_BRANCH" ]]; then
    echo "ERROR: Cannot auto-detect default branch. Use --branch <name> explicitly." >&2
    exit 1
  fi
fi

echo "=== DIFF EXTRACTION ==="
echo "Repository: $(basename "$(pwd)")"
echo "Current branch: $CURRENT_BRANCH"
echo "Mode: $MODE"

# Build path filter args
PATH_ARGS=()
if [[ -n "$PATH_FILTER" ]]; then
  PATH_ARGS=("--" "$PATH_FILTER")
  echo "Path filter: $PATH_FILTER"
fi

if [[ "$MODE" == "branch" ]]; then
  MERGE_BASE=$(git merge-base "$CURRENT_BRANCH" "$TARGET_BRANCH" 2>/dev/null || echo "")
  if [[ -z "$MERGE_BASE" ]]; then
    echo "ERROR: Cannot find merge base between $CURRENT_BRANCH and $TARGET_BRANCH" >&2
    exit 1
  fi
  RANGE="$MERGE_BASE..HEAD"
  echo "Target branch: $TARGET_BRANCH"
  echo "Merge base: $MERGE_BASE"
else
  RANGE="HEAD~${COMMIT_COUNT}..HEAD"
  echo "Commit count: $COMMIT_COUNT"
fi

echo "Range: $RANGE"
if [[ "$NO_PATCH" -eq 1 ]]; then
  echo "Patch output: disabled (--stat/--no-patch)"
fi
echo ""

echo "=== FILE STATS ==="
git diff --stat "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null || echo "(no changes)"
echo ""

echo "=== NEW FILES ==="
git diff --name-only --diff-filter=A "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null || echo "(none)"
echo ""

echo "=== DELETED FILES ==="
git diff --name-only --diff-filter=D "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null || echo "(none)"
echo ""

echo "=== RENAMED FILES ==="
git diff --name-only --diff-filter=R "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null || echo "(none)"
echo ""

echo "=== COMMIT LOG ==="
if [[ -n "$PATH_FILTER" ]]; then
  git log --oneline --no-merges "$RANGE" -- "$PATH_FILTER" 2>/dev/null || echo "(no commits)"
else
  git log --oneline --no-merges "$RANGE" 2>/dev/null || echo "(no commits)"
fi
echo ""

if [[ "$NO_PATCH" -eq 0 ]]; then
  TOTAL_LINES=$(git diff "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null | wc -l)
  echo "=== FULL DIFF (${TOTAL_LINES} lines, showing up to ${MAX_LINES}) ==="
  if [[ "$TOTAL_LINES" -gt "$MAX_LINES" ]]; then
    git diff "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null | head -n "$MAX_LINES"
    echo ""
    echo "... TRUNCATED (${TOTAL_LINES} total lines, showing first ${MAX_LINES}). Use --max-lines to adjust."
  else
    git diff "$RANGE" "${PATH_ARGS[@]+"${PATH_ARGS[@]}"}" 2>/dev/null || echo "(no diff)"
  fi
else
  echo "=== FULL DIFF ==="
  echo "(skipped)"
fi
