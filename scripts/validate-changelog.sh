#!/bin/bash
set -e

CHANGELOG_FILE="CHANGELOG.txt"
RELEASE_TYPE="${RELEASE_TYPE:-patch}"

echo "📋 Validating CHANGELOG.txt..."
echo "   Release type: $RELEASE_TYPE"

# Check if CHANGELOG exists
if [ ! -f "$CHANGELOG_FILE" ]; then
  echo "❌ ERROR: $CHANGELOG_FILE not found"
  exit 1
fi

# Check for [Unreleased] section
if ! grep -q "^\[Unreleased\]:" "$CHANGELOG_FILE"; then
  echo "❌ ERROR: [Unreleased]: link section missing in $CHANGELOG_FILE"
  echo "   Please add a [Unreleased]: section at the end of the file"
  exit 1
fi

# Get last version (skip [Unreleased] section)
LAST_VERSION=$(grep "^\## \[" "$CHANGELOG_FILE" | grep -v "^\## \[Unreleased\]" | head -1 | sed 's/^\## \[\([^]]*\)\].*/\1/')
if [ -z "$LAST_VERSION" ]; then
  echo "❌ ERROR: No version entry found in $CHANGELOG_FILE"
  echo "   Expected format: ## [1.2.3] - YYYY-MM-DD"
  exit 1
fi

echo "✅ Last version: $LAST_VERSION"
echo "✅ CHANGELOG validation passed"

# Calculate next version
# Check if last version is timestamp format (contains T) or semver format
if [[ "$LAST_VERSION" == *"T"* ]]; then
  # Old timestamp format - start fresh with semver
  echo "⚠️  Old timestamp format detected: $LAST_VERSION"
  echo "🔄 Migrating to semantic versioning..."
  NEXT_VERSION="1.0.0"
else
  # Semver format
  CURRENT_MAJOR=$(echo "$LAST_VERSION" | cut -d. -f1)
  CURRENT_MINOR=$(echo "$LAST_VERSION" | cut -d. -f2)
  CURRENT_PATCH=$(echo "$LAST_VERSION" | cut -d. -f3)

  case "$RELEASE_TYPE" in
    major)
      NEXT_MAJOR=$((CURRENT_MAJOR + 1))
      NEXT_VERSION="${NEXT_MAJOR}.0.0"
      ;;
    minor)
      NEXT_MINOR=$((CURRENT_MINOR + 1))
      NEXT_VERSION="${CURRENT_MAJOR}.${NEXT_MINOR}.0"
      ;;
    patch)
      NEXT_PATCH=$((CURRENT_PATCH + 1))
      NEXT_VERSION="${CURRENT_MAJOR}.${CURRENT_MINOR}.${NEXT_PATCH}"
      ;;
    *)
      echo "❌ ERROR: Invalid RELEASE_TYPE: $RELEASE_TYPE"
      echo "   Must be: major, minor, or patch"
      exit 1
      ;;
  esac
fi

echo "📌 Next version will be: v$NEXT_VERSION"

# Export for GitHub Actions
if [ -n "$GITHUB_ENV" ]; then
  echo "NEXT_VERSION=$NEXT_VERSION" >> "$GITHUB_ENV"
  echo "TAG_NAME=v$NEXT_VERSION" >> "$GITHUB_ENV"
fi

exit 0
