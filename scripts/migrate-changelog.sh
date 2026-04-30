#!/bin/bash
set -e

echo "🔄 Migrating CHANGELOG.txt to semantic versioning format..."
echo "⚠️  This is a one-time migration script"
echo ""

CHANGELOG_FILE="CHANGELOG.txt"

# Check if CHANGELOG exists
if [ ! -f "$CHANGELOG_FILE" ]; then
  echo "❌ ERROR: $CHANGELOG_FILE not found"
  exit 1
fi

# Backup original
BACKUP_FILE="${CHANGELOG_FILE}.backup"
if [ ! -f "$BACKUP_FILE" ]; then
  cp "$CHANGELOG_FILE" "$BACKUP_FILE"
  echo "📦 Backup created: $BACKUP_FILE"
else
  echo "⚠️  Backup already exists: $BACKUP_FILE"
  echo "   Skipping backup (already migrated?)"
  read -p "   Continue anyway? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted"
    exit 1
  fi
fi

# Read current version from Git tags (or default to 1.0.0)
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [ -z "$LAST_TAG" ]; then
  CURRENT_VERSION="1.0.0"
  echo "📌 No git tags found, starting from v1.0.0"
else
  CURRENT_VERSION=${LAST_TAG#v}
  echo "📌 Current version from git: $CURRENT_VERSION"
fi

echo ""
echo "📝 Migrating CHANGELOG to new format..."
echo ""

# Create new format with header
TEMP_FILE=$(mktemp)

# Add new header
cat > "$TEMP_FILE" << 'EOF'
Changelog BitPrepared.it
========================

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

EOF

# Append old entries (convert date-based to version-based)
echo "📝 Converting old entries to first version..."

# Extract first date from old changelog
FIRST_DATE=$(grep -m 1 "^### [0-9]" "$BACKUP_FILE" | sed 's/^### \([0-9-]*\).*/\1/')

if [ -n "$FIRST_DATE" ]; then
  echo "## [$CURRENT_VERSION] - $FIRST_DATE" >> "$TEMP_FILE"
  echo "" >> "$TEMP_FILE"

  # Append all content after first date header
  sed -n "/^### $FIRST_DATE/,$ p" "$BACKUP_FILE" >> "$TEMP_FILE"
fi

# Add version links at the end
cat >> "$TEMP_FILE" << EOF

[Unreleased]: https://github.com/bitprepared/bitprepared.it/compare/v$CURRENT_VERSION...HEAD
[$CURRENT_VERSION]: https://github.com/bitprepared.bitprepared.it/releases/tag/v$CURRENT_VERSION
EOF

# Replace original file
mv "$TEMP_FILE" "$CHANGELOG_FILE"

echo ""
echo "✅ Migration complete!"
echo ""
echo "📝 Please review CHANGELOG.txt and ensure:"
echo "   1. All entries are properly formatted"
echo "   2. The [Unreleased] section is present"
echo "   3. Version links are correct"
echo ""
echo "📦 Original file backed up to: $BACKUP_FILE"
echo ""
echo "📋 Next steps:"
echo "   1. Review the migrated CHANGELOG.txt"
echo "   2. Make any manual adjustments needed"
echo "   3. Commit: git add CHANGELOG.txt && git commit -m 'Migrate to semantic versioning'"
echo "   4. Optionally create first git tag: git tag -a v$CURRENT_VERSION -m 'Release v$CURRENT_VERSION'"
