#!/bin/bash
# get-repo-name.sh - Get the current git repository name
# Usage: bash scripts/get-repo-name.sh [path]
# Example: bash scripts/get-repo-name.sh /home/user/project/react

REPO_PATH="${1:-.}"

if [ ! -d "$REPO_PATH/.git" ]; then
    echo "Error: Not a git repository: $REPO_PATH" >&2
    exit 1
fi

REPO_NAME=$(git -C "$REPO_PATH" rev-parse --show-toplevel 2>/dev/null | xargs basename)

if [ -z "$REPO_NAME" ]; then
    echo "Error: Could not determine repository name" >&2
    exit 1
fi

echo "$REPO_NAME"
