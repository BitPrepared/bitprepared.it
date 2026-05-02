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

# Use awk to properly move [Unreleased] content to new version
awk -v new_version="$NEXT_VERSION" -v today="$TODAY" '
  # Start processing
  BEGIN { in_unreleased = 0; unreleased_content = "" }

  # Match [Unreleased] header
  /^## \[Unreleased\]/ {
    in_unreleased = 1
    # Print new version header
    print "## [" new_version "] - " today
    print ""
    next
  }

  # Match next version header (end of [Unreleased] section)
  /^## \[/ && in_unreleased {
    in_unreleased = 0
    # Print the collected unreleased content
    printf "%s", unreleased_content
    # Print current line
    print
    next
  }

  # Inside [Unreleased] section, collect content
  in_unreleased {
    unreleased_content = unreleased_content $0 "\n"
    next
  }

  # All other lines, print as-is
  { print }
' "$CHANGELOG_FILE" > "$TEMP_FILE"

# Replace file
mv "$TEMP_FILE" "$CHANGELOG_FILE"

# Add new version link before [Unreleased]:
if ! grep -q "^\[$NEXT_VERSION\]:" "$CHANGELOG_FILE"; then
  # Insert new version link
  TEMP_FILE=$(mktemp)
  awk -v new_version="$NEXT_VERSION" -v last_version="$LAST_VERSION" '
    # Match [Unreleased]: link section
    /^\[Unreleased\]:/ {
      # Print new version link first
      print "[" new_version "]: https://github.com/bitprepared/bitprepared.it/compare/v" last_version "...v" new_version
    }
    # Print all lines
    { print }
  ' "$CHANGELOG_FILE" > "$TEMP_FILE"
  mv "$TEMP_FILE" "$CHANGELOG_FILE"
fi

echo "✅ Version bumped to $NEXT_VERSION"
echo "📝 CHANGELOG updated"
echo "🏷️  Tag will be: v$NEXT_VERSION"

# Export for GitHub Actions
if [ -n "$GITHUB_ENV" ]; then
  echo "NEXT_VERSION=$NEXT_VERSION" >> "$GITHUB_ENV"
  echo "TAG_NAME=v$NEXT_VERSION" >> "$GITHUB_ENV"
fi

exit 0
