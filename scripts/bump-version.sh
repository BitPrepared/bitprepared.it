#!/bin/bash
set -e

CHANGELOG_FILE="CHANGELOG.txt"
RELEASE_TYPE="${1:-patch}"

if [[ ! "$RELEASE_TYPE" =~ ^(major|minor|patch)$ ]]; then
  echo "❌ ERROR: Release type must be major, minor, or patch"
  echo "   Usage: $0 [major|minor|patch]"
  exit 1
fi

echo "🔖 Bumping version (type: $RELEASE_TYPE)..."

# Check if CHANGELOG exists
if [ ! -f "$CHANGELOG_FILE" ]; then
  echo "❌ ERROR: $CHANGELOG_FILE not found"
  exit 1
fi

# Get last version (skip [Unreleased])
LAST_VERSION=$(grep "^## \[" "$CHANGELOG_FILE" | grep -v "^## \[Unreleased\]" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/')
if [ -z "$LAST_VERSION" ]; then
  echo "❌ ERROR: No version entry found in $CHANGELOG_FILE"
  exit 1
fi

# Parse current version
CURRENT_MAJOR=$(echo "$LAST_VERSION" | cut -d. -f1)
CURRENT_MINOR=$(echo "$LAST_VERSION" | cut -d. -f2)
CURRENT_PATCH=$(echo "$LAST_VERSION" | cut -d. -f3)

# Calculate next version
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
esac

echo "📌 Current version: $LAST_VERSION"
echo "📌 Next version: $NEXT_VERSION"

# Get today's date
TODAY=$(date +%Y-%m-%d)

# Create temporary file
TEMP_FILE=$(mktemp)

# Replace [Unreleased]: with new version
sed "s/\[Unreleased\]:/[$NEXT_VERSION] - $TODAY\n\n[Unreleased\]:/" "$CHANGELOG_FILE" > "$TEMP_FILE"

# Add new version link before [Unreleased]:
# Check if link already exists
if ! grep -q "^\[$NEXT_VERSION\]:" "$TEMP_FILE"; then
  # Insert new version link
  sed -i "/^\[Unreleased\]:/i [$NEXT_VERSION]: https://github.com/bitprepared/bitprepared.it/compare/v$LAST_VERSION...v$NEXT_VERSION" "$TEMP_FILE"
fi

# Replace file
mv "$TEMP_FILE" "$CHANGELOG_FILE"

echo "✅ Version bumped to $NEXT_VERSION"
echo "📝 CHANGELOG updated"
echo "🏷️  Tag will be: v$NEXT_VERSION"

# Export for GitHub Actions
if [ -n "$GITHUB_ENV" ]; then
  echo "NEXT_VERSION=$NEXT_VERSION" >> "$GITHUB_ENV"
  echo "TAG_NAME=v$NEXT_VERSION" >> "$GITHUB_ENV"
fi

exit 0
