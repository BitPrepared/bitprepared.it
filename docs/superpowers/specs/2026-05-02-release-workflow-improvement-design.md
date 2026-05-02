# Release Workflow Improvement Design

**Date:** 2026-05-02
**Status:** Draft - Pending User Review
**Author:** Claude Sonnet

## Problem Statement

Current release workflow fails when branch `chore/bump-version-X.X.X` already exists remotely. This happens when:
- Workflow is re-run after a previous attempt
- Multiple PRs are merged in quick succession
- Manual cleanup hasn't been completed

Error:
```
! [rejected] chore/bump-version-1.0.0 -> chore/bump-version-1.0.0 (non-fast-forward)
error: failed to push some refs
```

Additionally, version detection produces invalid output: `Unreleased.Unreleased.1`

## Requirements

1. **Manual trigger only** - no automatic execution on PR merge
2. **Pre-flight validation** - fail fast if branch exists
3. **Environment approval** - require human approval before release
4. **Clear error messages** - actionable guidance on failures
5. **No personal tokens** - use `GITHUB_TOKEN` only
6. **Maintain branch protections** - don't disable protection rules

## Design: 3-Stage Workflow

### Architecture

```
┌─────────────────┐
│  manual trigger │  workflow_dispatch with release_type input
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  pre-check job  │  Verify branch doesn't exist
└────────┬────────┘  FAIL if exists with clear message
         │
         ▼
┌─────────────────┐
│  build + audit  │  Jekyll build + accessibility audit
└────────┬────────┘  Upload artifacts, NO git changes
         │
         ▼
┌─────────────────┐
│  wait approval  │  Environment protection rule
└────────┬────────┘  Human review required
         │
         ▼
┌─────────────────┐
│  release job    │  Version bump, PR, tag, GitHub release
└─────────────────┘
```

### Job 1: Pre-check

**Purpose:** Fail fast if target branch already exists

**Steps:**
1. Checkout repository
2. Determine next version
3. Check if remote branch exists: `git ls-remote --heads origin chore/bump-version-${VERSION}`
4. If exists:
   - Exit with error code 1
   - Display message: "Branch chore/bump-version-${VERSION} already exists. Please delete it manually or wait for the existing PR to merge."
5. If not exists: continue

**Error handling:**
- Clear, actionable error message
- Suggest specific git command to fix
- No git mutations in this job

### Job 2: Build and Audit

**Purpose:** Validate build quality before making any changes

**Steps:**
1. Checkout repository
2. Determine next version (reuse existing logic from workflow)
3. Validate CHANGELOG format
4. Bump version in CHANGELOG (local only)
5. Build Jekyll site
6. Run accessibility audit
7. Upload reports as artifacts
8. **STOP** - no git commits or pushes

**Separation of concerns:**
- Build validation separate from git operations
- Early feedback on build failures
- Artifacts available for review before approval

### Job 3: Release

**Purpose:** Execute release after human approval

**Configuration:**
```yaml
environment: production  # Triggers approval requirement
permissions:
  contents: write
```

**Steps:**
1. Checkout repository
2. Re-run version bump in CHANGELOG
3. Create branch: `git checkout -b chore/bump-version-${VERSION}`
4. Commit CHANGELOG changes
5. Push branch to origin
6. Create PR via `gh` cli:
   - Title: "Release ${VERSION} - Version Bump"
   - Body: Automated description
   - Base: `master`
   - Head: `${BRANCH_NAME}`
   - Label: `release:automated`
7. Create annotated tag: `git tag -a v${VERSION}`
8. Push tag: `git push origin v${VERSION}`
9. Create GitHub release with artifact

**Error handling:**
- If push fails (race condition): fail with clear message
- If PR creation fails: fail with error details
- Tag already exists: fail with message

### Trigger Configuration

```yaml
on:
  workflow_dispatch:
    inputs:
      release_type:
        description: 'Release type'
        required: true
        type: choice
        options:
          - major
          - minor
          - patch
        default: patch
```

**Usage:**
1. Navigate to Actions tab in GitHub
2. Select "Release Site" workflow
3. Click "Run workflow"
4. Select release type from dropdown
5. Click "Run workflow" button

### Environment Protection Setup

**One-time configuration** (GitHub UI):

Repository → Settings → Environments → New environment → `production`

**Required settings:**
- **Required reviewers:** Add users/teams who can approve releases
- **Deployment branches:** Restrict to `master` branch only
- **Wait timer:** Optional (0-5 minutes for reflection time)

**Approval flow:**
1. Workflow reaches `release` job
2. GitHub pauses execution
3. Notifies all required reviewers
4. Reviewers check:
   - Build artifacts (accessibility reports)
   - CHANGELOG changes
   - Version number correctness
5. Reviewer clicks "Approve" in GitHub UI
6. Workflow continues execution

### Error Messages

**Pre-check failure:**
```
❌ Error: Branch 'chore/bump-version-1.0.0' already exists on remote.

Action required:
1. Delete the remote branch:
   git push origin --delete chore/bump-version-1.0.0

2. Or wait for the existing PR to merge, then retry.

Workflow stopped to prevent conflicts.
```

**Build failure:**
```
❌ Build or audit failed.

Check the "build-and-audit" job logs for details.
No git changes have been made.

Artifacts available in the workflow run summary.
```

**Version detection failure:**
```
❌ Unable to determine next version from CHANGELOG.

Ensure CHANGELOG.txt has:
- A valid [Unreleased] section
- At least one previous version header (e.g., [1.0.0])

Current last version detected: ${LAST_VERSION}
```

### File Changes

1. **`.github/workflows/site-release.yml`**
   - Replace existing workflow with 3-stage design
   - Add `workflow_dispatch` trigger
   - Add `environment: production` to release job
   - Reorganize into 3 separate jobs with `needs` dependencies

2. **`scripts/check-branch-exists.sh`** (NEW)
   - Check if remote branch exists
   - Return appropriate exit code
   - Display user-friendly message

3. **`scripts/bump-version.sh`**
   - Reuse existing script (no changes needed)
   - Called from release job

### Version Detection Fix

Current bug: `NEXT_VERSION: Unreleased.Unreleased.1`

**Root cause:** When CHANGELOG has no released versions (only `[Unreleased]`), the grep returns nothing.

**Fix in workflow:**
```bash
LAST_VERSION=$(grep "^## \[" CHANGELOG.txt | grep -v "^## \[Unreleased\]" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/')

# Fallback for first release
if [[ -z "$LAST_VERSION" ]]; then
  echo "⚠️  No previous version found, assuming initial release"
  NEXT_VERSION="1.0.0"
else
  # ... existing version bump logic
fi
```

## Testing Strategy

1. **Pre-check validation:**
   - Create branch manually, run workflow → should fail immediately
   - Delete branch, run workflow → should pass pre-check

2. **Environment approval:**
   - Run workflow, verify it pauses at release job
   - Approve manually, verify completion
   - Reject, verify workflow stops

3. **Release creation:**
   - Patch release: verify version bump correct
   - Verify PR created with correct label
   - Verify tag and release created
   - Verify CHANGELOG updated

4. **Error handling:**
   - Run workflow twice without cleanup → verify pre-check fails
   - Break build intentionally → verify no git changes made
   - Test with missing CHANGELOG versions → verify fallback to 1.0.0

## Rollback Plan

If workflow has issues:
1. Revert to previous workflow file from git history
2. Delete any `chore/bump-version-*` branches created
3. Delete any tags created (if needed)
4. Re-run releases manually if necessary

## Future Improvements

1. **Automated version detection:** Auto-detect release type from conventional commits
2. **Release notes generation:** Auto-generate release notes from merged PRs
3. **Slack notifications:** Notify team when approval is needed
4. **Rollback workflow:** Automated rollback if critical issues found
