#!/bin/bash
# extract-diff-repo.sh - Extract structured diff data with repository info
# Usage: bash scripts/extract-diff-repo.sh <repo-path> [options]
# Example: bash scripts/extract-diff-repo.sh /home/user/project/react --branch feature/XYZ
# Example: bash scripts/extract-diff-repo.sh . --commits 10

REPO_PATH="${1:-.}"
shift || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_NAME=$("$SCRIPT_DIR/get-repo-name.sh" "$REPO_PATH")

if [ -z "$REPO_NAME" ]; then
    echo "Error: Could not determine repository name" >&2
    exit 1
fi

DEFAULT_BRANCH=$(git -C "$REPO_PATH" rev-parse --abbrev-ref origin/Develop 2>/dev/null || \
                 git -C "$REPO_PATH" rev-parse --abbrev-ref origin/main 2>/dev/null || \
                 git -C "$REPO_PATH" rev-parse --abbrev-ref origin/master 2>/dev/null || \
                 echo "main")

BRANCH=""
COMMITS=""
PATH_FILTER=""
STAT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --commits)
            COMMITS="$2"
            shift 2
            ;;
        --path)
            PATH_FILTER="$2"
            shift 2
            ;;
        --stat)
            STAT_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "=== REPO: $REPO_NAME ==="

if [ -n "$BRANCH" ]; then
    echo "=== BRANCH: $BRANCH vs $DEFAULT_BRANCH ==="
    echo "=== COMMIT RANGE: $(git -C "$REPO_PATH" rev-parse "$BRANCH" 2>/dev/null | head -c 7)..$(git -C "$REPO_PATH" rev-parse "$DEFAULT_BRANCH" 2>/dev/null | head -c 7) ==="
    
    if [ "$STAT_ONLY" = true ]; then
        git -C "$REPO_PATH" diff --stat "$BRANCH".."$DEFAULT_BRANCH" -- "$PATH_FILTER"
    else
        echo ""
        echo "=== FILE STATS ==="
        git -C "$REPO_PATH" diff --stat "$BRANCH".."$DEFAULT_BRANCH" -- "$PATH_FILTER"
        
        echo ""
        echo "=== COMMIT LOG ==="
        git -C "$REPO_PATH" log --oneline "$BRANCH".."$DEFAULT_BRANCH" -- "$PATH_FILTER"
        
        echo ""
        echo "=== DIFF ==="
        git -C "$REPO_PATH" diff "$BRANCH".."$DEFAULT_BRANCH" -- "$PATH_FILTER"
    fi
elif [ -n "$COMMITS" ]; then
    echo "=== LAST $COMMITS COMMITS ==="
    echo "=== COMMIT RANGE: $(git -C "$REPO_PATH" HEAD~$COMMITS --format=%h | tail -1)..$(git -C "$REPO_PATH" HEAD --format=%h | head -c 7) ==="
    
    if [ "$STAT_ONLY" = true ]; then
        git -C "$REPO_PATH" diff --stat HEAD~$COMMITS..HEAD -- "$PATH_FILTER"
    else
        echo ""
        echo "=== FILE STATS ==="
        git -C "$REPO_PATH" diff --stat HEAD~$COMMITS..HEAD -- "$PATH_FILTER"
        
        echo ""
        echo "=== COMMIT LOG ==="
        git -C "$REPO_PATH" log --oneline -n "$COMMITS" -- "$PATH_FILTER"
        
        echo ""
        echo "=== DIFF ==="
        git -C "$REPO_PATH" diff HEAD~$COMMITS..HEAD -- "$PATH_FILTER"
    fi
else
    echo "Error: Specify --branch <branch> or --commits <N>" >&2
    exit 1
fi
