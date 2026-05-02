#!/bin/bash
set -e

BRANCH_NAME="$1"

if [[ -z "$BRANCH_NAME" ]]; then
  echo "❌ Error: Branch name required"
  echo "Usage: $0 <branch-name>"
  exit 1
fi

echo "🔍 Checking if remote branch exists: $BRANCH_NAME"

# Check if branch exists on remote
if git ls-remote --heads origin "$BRANCH_NAME" | grep -q "$BRANCH_NAME"; then
  echo ""
  echo "❌ Error: Branch '$BRANCH_NAME' already exists on remote."
  echo ""
  echo "Action required:"
  echo "1. Delete the remote branch:"
  echo "   git push origin --delete $BRANCH_NAME"
  echo ""
  echo "2. Or wait for the existing PR to merge, then retry."
  echo ""
  echo "Workflow stopped to prevent conflicts."
  exit 1
else
  echo "✅ Branch '$BRANCH_NAME' does not exist on remote. Safe to proceed."
  exit 0
fi