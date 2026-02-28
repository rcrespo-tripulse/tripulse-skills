#!/bin/bash
# get-doc-category.sh - Determine destination category for docs-microservices
# Usage: bash scripts/get-doc-category.sh <change-type>
# Example: bash scripts/get-doc-category.sh api-change

CHANGE_TYPE="${1:-unknown}"

case "$CHANGE_TYPE" in
    api-change|new-feature|refactor)
        echo "reference"
        ;;
    bug-fix|hotfix)
        echo "reports"
        ;;
    infra-change|configuration|deployment)
        echo "engineering"
        ;;
    decision|architecture|migration)
        echo "engineering"
        ;;
    plan|roadmap|strategy)
        echo "strategy"
        ;;
    release|version)
        echo "reports"
        ;;
    *)
        echo "reference"
        ;;
esac
