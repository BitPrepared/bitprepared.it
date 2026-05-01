# Semantic Versioning Guide

## Overview

BitPrepared.it uses [Semantic Versioning](https://semver.org/) for releases.

## Version Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API changes or breaking modifications
- **MINOR**: New functionality (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

Example: `v1.2.3`

## Creating a Release

### 1. Update CHANGELOG.txt

Before creating a PR, update the CHANGELOG with a new `[Unreleased]` section:

```markdown
## [Unreleased]

### Added
- New feature description here
- Another feature

### Fixed
- Bug fix description
```

### 2. Create Pull Request

```bash
git checkout -b feature/my-feature
# Make your changes
git add CHANGELOG.txt
git commit -m "FEATURE: Add my feature"
git push origin feature/my-feature
```

### 3. Add Release Label

On the GitHub PR page, add one of these labels:

- **`release:major`** (red) - For breaking changes
  → MAJOR bump (e.g., v1.2.3 → v2.0.0)

- **`release:minor`** (green) - For new features
  → MINOR bump (e.g., v1.2.3 → v1.3.0)

- **`release:patch`** (blue) - For bug fixes
  → PATCH bump (e.g., v1.2.3 → v1.2.4)

**Default**: If no label is added, `patch` is assumed (safe default).

### 4. Merge PR

When you merge the PR:

1. **Validation workflow** checks CHANGELOG
2. **Release workflow** determines version type from label
3. **Bumps version** in CHANGELOG automatically
4. **Creates Git tag** (e.g., v1.2.4)
5. **Creates GitHub release** with updated CHANGELOG
6. **Builds and deploys** the site

## Examples

### Patch Release (v1.2.3 → v1.2.4)

```bash
# Fix a bug
git commit -m "FIX: Correct typo on homepage"

# Update CHANGELOG.txt
## [Unreleased]
### Fixed
- Typo on homepage corrected

# Create PR
git checkout -b fix/typo
git push origin fix/typo

# On GitHub: add label `release:patch`
# Merge PR
# Result: v1.2.4 released automatically
```

### Minor Release (v1.2.3 → v1.3.0)

```bash
# Add a feature
git commit -m "FEATURE: Add search functionality"

# Update CHANGELOG.txt
## [Unreleased]
### Added
- Search functionality added to navigation

# Create PR
git checkout -b feature/search
git push origin feature/search

# On GitHub: add label `release:minor`
# Merge PR
# Result: v1.3.0 released automatically
```

### Major Release (v1.2.3 → v2.0.0)

```bash
# Breaking change
git commit -m "FEATURE: New navigation structure (BREAKING CHANGE: old menu removed)"

# Update CHANGELOG.txt
## [Unreleased]
### Added
- New navigation structure

### Changed
- BREAKING CHANGE: Old menu structure removed, use new navigation

# Create PR
git checkout -b refactor/navigation
git push origin feature/navigation

# On GitHub: add label `release:major`
# Merge PR
# Result: v2.0.0 released automatically
```

## Local Testing

Before creating a PR, you can validate locally:

```bash
# Validate CHANGELOG format
make version-validate

# Show current version
make version-show

# Test version bump (dry-run)
make version-bump
# Enter: patch
# Check CHANGELOG.txt was updated correctly
git checkout CHANGELOG.txt  # Revert test changes
```

## Validation

The GitHub Actions workflow validates:

- ✅ CHANGELOG.txt exists
- ✅ `[Unreleased]:` section is present
- ✅ At least one version entry exists
- ❌ **Fails if**: CHANGELOG not updated

If validation fails, the workflow will comment on the PR with instructions.

## CHANGELOG Format

The CHANGELOG follows this format:

```markdown
## [Unreleased]

### Added
- New features here

### Fixed
- Bug fixes here

## [1.2.3] - 2026-04-26
### Added
- Feature description

### Fixed
- Bug fix description

[Unreleased]: https://github.com/bitprepared/bitprepared.it/compare/v1.2.3...HEAD
[1.2.3]: https://github.com/bitprepared/bitprepared.it/compare/v1.2.2...v1.2.3
[1.2.2]: https://github.com/bitprepared/bitprepared.it/compare/v1.2.1...v1.2.2
```

## Automatic Version Bump

When you merge a PR:

1. Workflow detects release type from labels (or defaults to `patch`)
2. Calculates next version (e.g., v1.2.3 → v1.2.4)
3. Replaces `[Unreleased]` with `[1.2.4] - 2026-04-30`
4. Adds new version link: `[1.2.4]: https://github.com/bitprepared/bitprepared.it/compare/v1.2.3...v1.2.4`
5. Commits: "chore: bump version to 1.2.4"
6. Creates Git tag: `v1.2.4`
7. Creates GitHub release

No manual intervention needed!

## Troubleshooting

### "CHANGELOG validation failed"

**Problem**: CHANGELOG.txt is missing the `[Unreleased]:` section.

**Solution**: Add it to the end of the file:
```markdown
## [Unreleased]

### Added
- Your changes here
```

### "No release label found"

**Problem**: No release label on the PR.

**Solution**: This is OK! The system defaults to `patch` (safe).

### "Version already exists"

**Problem**: Trying to create a tag that already exists.

**Solution**: Check existing tags with `git tag -l`. The system should handle this automatically.

### Workflow failed during release

**Problem**: GitHub Actions failed during the release process.

**Solution**: Check the workflow logs. Common issues:
- Docker build failure
- Accessibility audit errors
- Network issues

You can manually retry by merging another PR or creating a new tag.

## Migration from Timestamp-Based

The project previously used timestamp-based versioning (e.g., `20260426T143522`).

**New format**: Semantic versions (e.g., `v1.2.3`)

**Old tags remain valid** - No need to delete or modify existing releases.

## Best Practices

1. **Always update CHANGELOG** before creating a PR
2. **Use appropriate labels** - Be honest about the impact of your changes
3. **Test locally** - Run `make version-validate` before pushing
4. **Keep CHANGELOG descriptive** - Help users understand what changed
5. **Use conventional commit messages** - This helps with automatic version detection

## Related Documentation

- [WORKFLOW.md](WORKFLOW.md) - General development workflow
- [CHECKLIST.md](CHECKLIST.md) - Pre-commit and pre-merge checklist
- [Semantic Versioning Specification](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)

## Questions?

If you have questions about semantic versioning in this project:

1. Check this guide first
2. Review existing CHANGELOG.txt entries for examples
3. Ask in a PR comment or team channel
4. Check GitHub Actions workflow logs for detailed error messages
