# Release Workflow Improvement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix release workflow to prevent branch conflicts and add manual approval

**Architecture:** 3-stage GitHub Actions workflow: pre-check → build+audit → release (with environment approval gate)

**Tech Stack:** GitHub Actions, Bash, Jekyll, gh cli

---

## Task 1: Create Branch Existence Check Script

**Files:**
- Create: `scripts/check-branch-exists.sh`

- [ ] **Step 1: Write the branch check script**

```bash
cat > scripts/check-branch-exists.sh << 'EOF'
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
EOF
```

- [ ] **Step 2: Make script executable**

```bash
chmod +x scripts/check-branch-exists.sh
```

- [ ] **Step 3: Test the script with non-existent branch**

```bash
./scripts/check-branch-exists.sh "chore/bump-version-1.0.0"
```

Expected: `✅ Branch 'chore/bump-version-1.0.0' does not exist on remote. Safe to proceed.`

- [ ] **Step 4: Test the script with existing branch (if any)**

First, create a test branch:
```bash
git branch test-branch-123
git push origin test-branch-123
```

Then test:
```bash
./scripts/check-branch-exists.sh "test-branch-123"
```

Expected: Error message with cleanup instructions

Cleanup:
```bash
git push origin --delete test-branch-123
git branch -D test-branch-123 || true
```

- [ ] **Step 5: Commit the script**

```bash
git add scripts/check-branch-exists.sh
git commit -m "feat: add branch existence check script for release workflow"
```

---

## Task 2: Backup Current Workflow

**Files:**
- Read: `.github/workflows/site-release.yml`

- [ ] **Step 1: Create backup of current workflow**

```bash
cp .github/workflows/site-release.yml .github/workflows/site-release.yml.backup
```

- [ ] **Step 2: Verify backup exists**

```bash
ls -lh .github/workflows/site-release.yml.backup
```

Expected: File exists with size > 0

- [ ] **Step 3: Commit backup**

```bash
git add .github/workflows/site-release.yml.backup
git commit -m "chore: backup current release workflow before rewrite"
```

---

## Task 3: Write New Workflow File - Job 1 (Pre-check)

**Files:**
- Replace: `.github/workflows/site-release.yml`

- [ ] **Step 1: Write workflow header and pre-check job**

```yaml
cat > .github/workflows/site-release.yml << 'EOF'
name: Release Site

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

jobs:
  pre-check:
    runs-on: ubuntu-latest
    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
    outputs:
      next-version: ${{ steps.detect-version.outputs.version }}
      tag-name: ${{ steps.detect-version.outputs.tag }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Detect next version
        id: detect-version
        run: |
          RELEASE_TYPE="${{ github.event.inputs.release_type }}"

          # Get last version from CHANGELOG (skip [Unreleased])
          LAST_VERSION=$(grep "^## \[" CHANGELOG.txt | grep -v "^## \[Unreleased\]" | head -1 | sed 's/^## \[\([^]]*\)\].*/\1/')

          echo "📌 Last version: $LAST_VERSION"

          # Fallback for first release
          if [[ -z "$LAST_VERSION" ]]; then
            echo "⚠️  No previous version found, assuming initial release"
            NEXT_VERSION="1.0.0"
          else
            # Check if old timestamp format
            if [[ "$LAST_VERSION" == *"T"* ]]; then
              echo "⚠️  Old timestamp format detected, migrating to semver"
              NEXT_VERSION="1.0.0"
            else
              # Parse current version
              CURRENT_MAJOR=$(echo "$LAST_VERSION" | cut -d. -f1)
              CURRENT_MINOR=$(echo "$LAST_VERSION" | cut -d. -f2)
              CURRENT_PATCH=$(echo "$LAST_VERSION" | cut -d. -f3)

              # Calculate next version based on type
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
            fi
          fi

          echo "version=$NEXT_VERSION" >> $GITHUB_OUTPUT
          echo "tag=v$NEXT_VERSION" >> $GITHUB_OUTPUT

          echo "📌 Release type: $RELEASE_TYPE"
          echo "📌 Next version: $NEXT_VERSION"
          echo "🏷️  Tag: v$NEXT_VERSION"

      - name: Check if release branch exists
        run: |
          VERSION="${{ steps.detect-version.outputs.version }}"
          BRANCH_NAME="chore/bump-version-${VERSION}"
          chmod +x ./scripts/check-branch-exists.sh
          ./scripts/check-branch-exists.sh "$BRANCH_NAME"

      - name: Show release info
        run: |
          echo "📦 Release Information:"
          echo "   Type: ${{ github.event.inputs.release_type }}"
          echo "   Version: ${{ steps.detect-version.outputs.version }}"
          echo "   Tag: ${{ steps.detect-version.outputs.tag }}"
EOF
```

- [ ] **Step 2: Verify file was created**

```bash
cat .github/workflows/site-release.yml
```

Expected: YAML with workflow trigger and pre-check job

- [ ] **Step 3: Validate YAML syntax**

```bash
# Check if yamllint is available, otherwise skip
if command -v yamllint &> /dev/null; then
  yamllint .github/workflows/site-release.yml
else
  echo "⚠️  yamllint not available, skipping YAML validation"
fi
```

Expected: No errors (if yamllint available)

- [ ] **Step 4: Commit partial workflow**

```bash
git add .github/workflows/site-release.yml
git commit -m "feat: add pre-check job to release workflow"
```

---

## Task 4: Add Job 2 (Build and Audit)

**Files:**
- Modify: `.github/workflows/site-release.yml` (append)

- [ ] **Step 1: Append build-and-audit job**

```bash
cat >> .github/workflows/site-release.yml << 'EOF'

  build-and-audit:
    needs: pre-check
    runs-on: ubuntu-latest
    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
    outputs:
      next-version: ${{ needs.pre-check.outputs.next-version }}
      tag-name: ${{ needs.pre-check.outputs.tag-name }}
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Show release info
        run: |
          echo "📦 Building release:"
          echo "   Type: ${{ github.event.inputs.release_type }}"
          echo "   Version: ${{ needs.pre-check.outputs.next-version }}"
          echo "   Tag: ${{ needs.pre-check.outputs.tag-name }}"

      - name: Validate CHANGELOG
        run: |
          chmod +x ./scripts/validate-changelog.sh
          ./scripts/validate-changelog.sh
        env:
          RELEASE_TYPE: ${{ github.event.inputs.release_type }}

      - name: Bump version in CHANGELOG (local only)
        run: |
          chmod +x ./scripts/bump-version.sh
          ./scripts/bump-version.sh ${{ github.event.inputs.release_type }}
        env:
          CHANGELOG_FILE: "CHANGELOG.txt"

      - name: Build the site in the jekyll/builder container
        run: |
          docker run \
          -v ${{ github.workspace }}:/srv/jekyll -v ${{ github.workspace }}/_site:/srv/jekyll/_site \
          jekyll/builder:latest /bin/bash -c "chmod -R 777 /srv/jekyll && jekyll build --future"

      - name: Run accessibility audit
        run: |
          # Build a11y Docker image
          docker build -t bitprepared-a11y:latest -f docker/accessibility/Dockerfile .
          # Start Jekyll in background
          docker run -d \
            --name bitprepared-jekyll \
            -v ${{ github.workspace }}:/srv/jekyll \
            -p 4000:4000 \
            jekyll/jekyll:latest \
            jekyll serve --config _config.yml,_config_dev.yml --host 0.0.0.0
          # Wait for Jekyll to be ready
          for i in {1..30}; do
            if curl -f -s -o /dev/null http://localhost:4000; then
              echo "Jekyll ready"
              break
            fi
            sleep 1
          done
          # Run accessibility audit
          mkdir -p docs/accessibility/reports
          docker run --rm --init \
            -v ${{ github.workspace }}/docs/accessibility/reports:/app/reports \
            --add-host=host.docker.internal:host-gateway \
            -e SITE_URL=http://host.docker.internal:4000 \
            bitprepared-a11y:latest \
            bash /app/scripts/accessibility-full-audit.sh
          # Stop Jekyll
          docker stop bitprepared-jekyll || true
          docker rm bitprepared-jekyll || true

      - name: Generate accessibility summary
        run: |
          ./scripts/analyze-a11y-reports.sh docs/accessibility/reports > docs/accessibility/reports/summary.md

      - uses: montudor/action-zip@v1
        with:
          args: zip -qq -r release.zip _site

      - name: Upload accessibility summary as artifact
        uses: actions/upload-artifact@v4
        with:
          name: accessibility-report
          path: docs/accessibility/reports/summary.md

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: release-site
          path: release.zip
EOF
```

- [ ] **Step 2: Verify job was appended**

```bash
grep -A 5 "build-and-audit:" .github/workflows/site-release.yml
```

Expected: Job definition with `needs: pre-check`

- [ ] **Step 3: Validate YAML syntax**

```bash
if command -v yamllint &> /dev/null; then
  yamllint .github/workflows/site-release.yml
else
  echo "⚠️  yamllint not available, skipping YAML validation"
fi
```

Expected: No errors

- [ ] **Step 4: Commit build job**

```bash
git add .github/workflows/site-release.yml
git commit -m "feat: add build and audit job to release workflow"
```

---

## Task 5: Add Job 3 (Release with Environment Approval)

**Files:**
- Modify: `.github/workflows/site-release.yml` (append)

- [ ] **Step 1: Append release job with environment protection**

```bash
cat >> .github/workflows/site-release.yml << 'EOF'

  release:
    needs: build-and-audit
    runs-on: ubuntu-latest
    env:
      FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true
    environment: production
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Show release info
        run: |
          echo "📦 Releasing:"
          echo "   Version: ${{ needs.build-and-audit.outputs.next-version }}"
          echo "   Tag: ${{ needs.build-and-audit.outputs.tag-name }}"

      - name: Bump version in CHANGELOG
        run: |
          chmod +x ./scripts/bump-version.sh
          ./scripts/bump-version.sh ${{ github.event.inputs.release_type }}
        env:
          CHANGELOG_FILE: "CHANGELOG.txt"

      - name: Commit version bump to branch
        run: |
          VERSION="${{ needs.build-and-audit.outputs.next-version }}"
          BRANCH_NAME="chore/bump-version-${VERSION}"

          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"

          # Create new branch
          git checkout -b "$BRANCH_NAME"

          # Commit version bump
          git add CHANGELOG.txt
          git commit -m "chore: bump version to $VERSION"

          # Push branch
          git push origin "$BRANCH_NAME"

          # Create PR using gh cli
          gh pr create \
            --title "Release $VERSION - Version Bump" \
            --body "Automated version bump to $VERSION. This PR was created by the release workflow." \
            --base master \
            --head "$BRANCH_NAME" \
            --label "release:automated"

        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Create Git Tag
        run: |
          git tag -a ${{ needs.build-and-audit.outputs.tag-name }} -m "Release ${{ needs.build-and-audit.outputs.tag-name }}"
          git push origin ${{ needs.build-and-audit.outputs.tag-name }}

      - name: Download build artifact
        uses: actions/download-artifact@v4
        with:
          name: release-site
          path: .

      - uses: ncipollo/release-action@v1
        with:
          artifacts: "release.zip"
          removeArtifacts: true
          makeLatest: true
          tag: ${{ needs.build-and-audit.outputs.tag-name }}
          bodyFile: "CHANGELOG.txt"
          generateReleaseNotes: false
EOF
```

- [ ] **Step 2: Verify complete workflow**

```bash
cat .github/workflows/site-release.yml
```

Expected: Complete workflow with 3 jobs: pre-check, build-and-audit, release

- [ ] **Step 3: Validate YAML syntax**

```bash
if command -v yamllint &> /dev/null; then
  yamllint .github/workflows/site-release.yml
else
  echo "⚠️  yamllint not available, skipping YAML validation"
fi
```

Expected: No errors

- [ ] **Step 4: Verify job dependencies**

```bash
grep -E "(needs:|environment:)" .github/workflows/site-release.yml
```

Expected:
- `build-and-audit` has `needs: pre-check`
- `release` has `needs: build-and-audit`
- `release` has `environment: production`

- [ ] **Step 5: Commit release job**

```bash
git add .github/workflows/site-release.yml
git commit -m "feat: add release job with environment approval gate"
```

---

## Task 6: Create Environment Setup Documentation

**Files:**
- Create: `docs/github-environment-setup.md`

- [ ] **Step 1: Write environment setup guide**

```markdown
cat > docs/github-environment-setup.md << 'EOF'
# GitHub Environment Protection Setup

This document describes how to configure the `production` environment for release approval.

## One-Time Setup

### Step 1: Create Environment

1. Navigate to repository on GitHub
2. Go to **Settings** → **Environments**
3. Click **New environment**
4. Name it: `production`
5. Click **Configure environment**

### Step 2: Configure Protection Rules

In the environment configuration page:

#### Required Reviewers
- Add users or teams who must approve releases
- All listed reviewers must approve before workflow continues
- Recommended: Add at least 2 senior developers or team leads

#### Deployment Branches
- Select: "Only branches matching filter"
- Add branch: `master`
- This ensures releases can only deploy from master branch

#### Wait Timer (Optional)
- Set wait time: 0-5 minutes
- Gives reviewers time to notice and intervene if needed
- Recommended: 2 minutes

#### Deployment Safety (Optional)
- Enable if you want additional safeguards
- Not required for this workflow

### Step 3: Save Configuration

Click **Save changes** to apply the protection rules.

## How Approval Works

When a release workflow runs:

1. **Pre-check job** validates branch doesn't exist
2. **Build job** runs Jekyll build and accessibility audit
3. **Release job** pauses at environment gate
4. GitHub notifies all required reviewers
5. Reviewers check:
   - Build artifacts (accessibility reports)
   - CHANGELOG changes
   - Version number correctness
6. Reviewer clicks **Approve** in GitHub UI
7. Workflow continues and creates release

## Approval UI

Reviewers can approve/reject from:
- **Actions tab** → Workflow run → Review pending deployments
- **Pull Request** (if PR was created from workflow)
- **Repository notifications** → Deployment waiting for approval

## Troubleshooting

### No approval prompted
- Verify environment name in workflow matches GitHub (`production`)
- Check that user is listed as required reviewer
- Ensure workflow is running on `master` branch

### Can't approve
- Only users/teams listed as required reviewers can approve
- Repository admins can always approve
- Check repository permissions if needed

### Workflow stuck
- Check Actions tab for pending deployments
- Reviewers must actively approve (no auto-approval)
- Can reject and re-run workflow if needed
EOF
```

- [ ] **Step 2: Verify documentation created**

```bash
cat docs/github-environment-setup.md
```

Expected: Complete setup guide

- [ ] **Step 3: Commit documentation**

```bash
git add docs/github-environment-setup.md
git commit -m "docs: add GitHub environment protection setup guide"
```

---

## Task 7: Test Pre-check Job

**Files:**
- Test: Workflow execution

- [ ] **Step 1: Push workflow to remote**

```bash
git push origin feature/fase3-accessibility-seo-images
```

Expected: Push succeeds

- [ ] **Step 2: Verify workflow appears in GitHub Actions**

1. Go to repository on GitHub
2. Navigate to **Actions** tab
3. Verify "Release Site" workflow appears

Expected: Workflow visible with "Run workflow" button

- [ ] **Step 3: Run workflow with patch release**

1. Click **Release Site** workflow
2. Click **Run workflow** button
3. Select branch: `feature/fase3-accessibility-seo-images`
4. Select release type: `patch`
5. Click **Run workflow**

- [ ] **Step 4: Monitor pre-check job**

Watch the workflow run in GitHub Actions.

Expected:
- Pre-check job runs successfully
- Shows next version and tag
- Branch check passes (branch doesn't exist yet)

- [ ] **Step 5: Verify build-and-audit job runs**

Expected:
- Job starts after pre-check succeeds
- Runs Jekyll build
- Runs accessibility audit
- Uploads artifacts
- Stops (does not create release)

- [ ] **Step 6: Check release job is waiting**

Expected:
- Release job shows "Waiting for approval"
- Yellow dot indicates pending deployment
- Environment `production` shows pending approval

- [ ] **Step 7: Approve or reject the deployment**

1. Go to **Environments** → **production**
2. Find the pending deployment
3. Click **Review pending deployments**
4. Choose **Approve** or **Reject**

For testing, you can reject since this is a feature branch.

---

## Task 8: Test Branch Conflict Detection

**Files:**
- Test: Pre-check error handling

- [ ] **Step 1: Manually create a bump branch**

```bash
VERSION="1.0.0"
BRANCH_NAME="chore/bump-version-${VERSION}"
git checkout -b "$BRANCH_NAME"
echo "Test" > test.txt
git add test.txt
git commit -m "Test commit"
git push origin "$BRANCH_NAME"
git checkout master
```

- [ ] **Step 2: Run workflow again**

1. Go to GitHub Actions
2. Run "Release Site" workflow with `patch` release type

- [ ] **Step 3: Verify pre-check fails**

Expected:
- Pre-check job fails immediately
- Shows error: "Branch 'chore/bump-version-1.0.0' already exists on remote"
- Provides cleanup command
- Build job does not run

- [ ] **Step 4: Cleanup test branch**

```bash
git push origin --delete chore/bump-version-1.0.0
git branch -D chore/bump-version-1.0.0 || true
```

- [ ] **Step 5: Re-run workflow to verify success**

1. Run "Release Site" workflow again

Expected: Pre-check passes (branch no longer exists)

---

## Task 9: Verify Version Detection Fix

**Files:**
- Test: Version parsing logic

- [ ] **Step 1: Check current CHANGELOG state**

```bash
head -30 CHANGELOG.txt | grep "^## \["
```

Note: Current versions in CHANGELOG

- [ ] **Step 2: Run workflow and check version detection**

1. Run "Release Site" workflow with `patch` release type
2. Check pre-check job logs for version output

Expected:
- Correct version number (not "Unreleased.Unreleased.1")
- Shows "Last version: X.Y.Z" or fallback message

- [ ] **Step 3: Test with first release scenario**

If CHANGELOG has no released versions (only `[Unreleased]`):

Expected:
- Shows: "⚠️ No previous version found, assuming initial release"
- Sets NEXT_VERSION="1.0.0"

- [ ] **Step 4: Test version bump types**

Run workflow three times with different release types:
1. `patch` - should increment patch version
2. `minor` - should increment minor version
3. `major` - should increment major version

Check logs each time to verify correct version calculation.

---

## Task 10: Final Integration Test

**Files:**
- Test: Complete release flow

- [ ] **Step 1: Merge workflow to master**

First, create a PR for the workflow changes:

```bash
git checkout master
git pull origin master
git merge feature/fase3-accessibility-seo-images
git push origin master
```

Or create PR via GitHub UI and merge it.

- [ ] **Step 2: Run complete release from master**

1. Go to GitHub Actions on master branch
2. Run "Release Site" workflow with `patch` release type

- [ ] **Step 3: Monitor all three jobs**

Expected sequence:
1. **Pre-check**: Passes, shows version info
2. **Build-and-audit**: Passes, uploads artifacts
3. **Release**: Waits for approval

- [ ] **Step 4: Approve the deployment**

1. Review the accessibility report artifact
2. Check the version number in logs
3. Approve in Environments → production

- [ ] **Step 5: Verify release creation**

Expected:
- Branch `chore/bump-version-X.X.X` created
- PR created with `release:automated` label
- Tag `vX.X.X` pushed
- GitHub release created with artifact
- CHANGELOG updated with new version

- [ ] **Step 6: Verify PR contents**

1. Open the created PR
2. Check CHANGELOG changes
3. Verify version bump is correct
4. Merge the PR

- [ ] **Step 7: Cleanup test releases (if needed)**

If these were test releases, clean up:

```bash
# Delete test tags
git push origin --delete v1.0.0

# Delete test release (via GitHub UI or gh cli)
gh release delete v1.0.0 -y
```

---

## Task 11: Update Design Spec Status

**Files:**
- Modify: `docs/superpowers/specs/2026-05-02-release-workflow-improvement-design.md`

- [ ] **Step 1: Update spec status to Implemented**

```bash
sed -i 's/\*\*Status:\*\* Draft - Pending User Review/\*\*Status:\*\* Implemented/' docs/superpowers/specs/2026-05-02-release-workflow-improvement-design.md
```

- [ ] **Step 2: Verify status change**

```bash
grep "Status:" docs/superpowers/specs/2026-05-02-release-workflow-improvement-design.md
```

Expected: `**Status:** Implemented`

- [ ] **Step 3: Commit spec update**

```bash
git add docs/superpowers/specs/2026-05-02-release-workflow-improvement-design.md
git commit -m "docs: mark release workflow improvement spec as implemented"
```

---

## Task 12: Create Rollback Documentation

**Files:**
- Create: `docs/release-workflow-rollback.md`

- [ ] **Step 1: Write rollback guide**

```markdown
cat > docs/release-workflow-rollback.md << 'EOF'
# Release Workflow Rollback Guide

If the new release workflow has issues, follow these steps to rollback.

## Quick Rollback

### Step 1: Revert Workflow File

```bash
git checkout master
git pull origin master
git revert <commit-hash-of-new-workflow>
git push origin master
```

Or restore from backup:

```bash
cp .github/workflows/site-release.yml.backup .github/workflows/site-release.yml
git add .github/workflows/site-release.yml
git commit -m "rollback: restore previous release workflow"
git push origin master
```

### Step 2: Clean Up Partial Releases

If any release jobs completed partially:

```bash
# Delete bump branch
git push origin --delete chore/bump-version-X.X.X

# Delete tag (if created)
git push origin --delete vX.X.X

# Delete release (via GitHub UI or gh cli)
gh release delete vX.X.X -y
```

### Step 3: Verify Rollback

Run a test release to verify old workflow works:

1. Go to Actions tab
2. Run "Release Site" workflow
3. Verify it uses old logic (auto-trigger on PR merge)

## Alternative: Branch Restoration

If multiple commits need rollback:

```bash
# Create rollback branch
git checkout -b rollback/release-workflow

# Reset to commit before new workflow
git reset --hard <commit-before-workflow-changes>

# Force push (be careful!)
git push origin rollback/release-workflow --force
```

Then create PR to merge rollback branch to master.

## Verify Environment Configuration

After rollback, verify environment is still configured:

1. Go to Settings → Environments
2. Check `production` environment exists
3. Verify required reviewers are set
4. Check deployment branch rules

## Known Issues and Workarounds

### Issue: Workflow not triggering
- Check trigger conditions in workflow file
- Verify branch matches deployment rules
- Check GitHub Actions permissions

### Issue: Approval not required
- Verify `environment: production` in release job
- Check environment protection rules are active
- Ensure user is not an admin (admins bypass rules if configured)

### Issue: Version detection fails
- Verify CHANGELOG has proper format
- Check for `[Unreleased]` section
- Ensure at least one previous version exists (or use fallback)

## Contact

If rollback doesn't resolve issues, contact:
- Repository maintainer
- DevOps team
- Create GitHub issue with details
EOF
```

- [ ] **Step 2: Verify documentation**

```bash
cat docs/release-workflow-rollback.md
```

Expected: Complete rollback guide

- [ ] **Step 3: Commit rollback documentation**

```bash
git add docs/release-workflow-rollback.md
git commit -m "docs: add release workflow rollback guide"
```

---

## Task 13: Final Cleanup and Verification

**Files:**
- Cleanup: Backup files, test branches

- [ ] **Step 1: Remove backup file**

```bash
rm .github/workflows/site-release.yml.backup
git add .github/workflows/site-release.yml.backup
git commit -m "chore: remove workflow backup file after successful implementation"
```

- [ ] **Step 2: Verify all changes are committed**

```bash
git status
```

Expected: No uncommitted changes (or only intentional untracked files)

- [ ] **Step 3: Verify workflow syntax one final time**

```bash
if command -v yamllint &> /dev/null; then
  yamllint .github/workflows/site-release.yml
else
  echo "⚠️  yamllint not available, skipping final validation"
fi
```

Expected: No errors

- [ ] **Step 4: Check all scripts are executable**

```bash
ls -l scripts/check-branch-exists.sh scripts/bump-version.sh scripts/validate-changelog.sh
```

Expected: All have `-rwxr-xr-x` permissions (executable)

- [ ] **Step 5: Verify documentation is complete**

```bash
ls -lh docs/*release* docs/*environment*
```

Expected:
- `docs/github-environment-setup.md` exists
- `docs/release-workflow-rollback.md` exists

- [ ] **Step 6: Create summary of changes**

```bash
echo "## Release Workflow Improvement - Summary" > release-workflow-summary.md
echo "" >> release-workflow-summary.md
echo "### Files Created" >> release-workflow-summary.md
echo "- scripts/check-branch-exists.sh" >> release-workflow-summary.md
echo "- docs/github-environment-setup.md" >> release-workflow-summary.md
echo "- docs/release-workflow-rollback.md" >> release-workflow-summary.md
echo "- docs/superpowers/plans/2026-05-02-release-workflow-implementation.md" >> release-workflow-summary.md
echo "" >> release-workflow-summary.md
echo "### Files Modified" >> release-workflow-summary.md
echo "- .github/workflows/site-release.yml (complete rewrite)" >> release-workflow-summary.md
echo "- docs/superpowers/specs/2026-05-02-release-workflow-improvement-design.md (status updated)" >> release-workflow-summary.md
echo "" >> release-workflow-summary.md
echo "### Key Changes" >> release-workflow-summary.md
echo "1. Manual trigger via workflow_dispatch" >> release-workflow-summary.md
echo "2. Pre-check job to prevent branch conflicts" >> release-workflow-summary.md
echo "3. Build and audit separated from git operations" >> release-workflow-summary.md
echo "4. Environment approval gate before release" >> release-workflow-summary.md
echo "5. Fixed version detection bug" >> release-workflow-summary.md
echo "6. Clear error messages with actionable guidance" >> release-workflow-summary.md
```

- [ ] **Step 7: Review summary**

```bash
cat release-workflow-summary.md
```

- [ ] **Step 8: Final commit**

```bash
git add release-workflow-summary.md
git commit -m "docs: add release workflow improvement summary"
```

- [ ] **Step 9: Push all changes to remote**

```bash
git push origin feature/fase3-accessibility-seo-images
```

- [ ] **Step 10: Create final PR (if not already merged)**

```bash
gh pr create \
  --title "feat: improve release workflow with manual approval and conflict prevention" \
  --body "## Summary

This PR improves the release workflow to prevent branch conflicts and adds manual approval before releases.

## Changes

- Manual trigger via workflow_dispatch with release type selection
- Pre-check job validates target branch doesn't exist
- Build and audit separated from release operations
- Environment approval gate (requires production environment setup)
- Fixed version detection bug that produced 'Unreleased.Unreleased.1'
- Clear error messages with actionable guidance

## Documentation

- Environment setup guide: docs/github-environment-setup.md
- Rollback guide: docs/release-workflow-rollback.md
- Design spec: docs/superpowers/specs/2026-05-02-release-workflow-improvement-design.md
- Implementation plan: docs/superpowers/plans/2026-05-02-release-workflow-implementation.md

## Testing

Tested pre-check, build, and release jobs. Verified branch conflict detection and version detection fixes.

## Setup Required

Before using this workflow, configure the production environment:
- Settings → Environments → New environment → 'production'
- Add required reviewers
- Set deployment branch rule to 'master'

See docs/github-environment-setup.md for details." \
  --base master \
  --head feature/fase3-accessibility-seo-images
```

---

## Self-Review Checklist

- [ ] **Spec Coverage**: All requirements from design spec are implemented
  - Manual trigger: ✓ (workflow_dispatch)
  - Pre-flight validation: ✓ (pre-check job)
  - Environment approval: ✓ (environment: production)
  - Clear error messages: ✓ (in check-branch-exists.sh and workflow)
  - No personal tokens: ✓ (uses GITHUB_TOKEN only)
  - Branch protections: ✓ (maintained, not disabled)

- [ ] **Placeholder Scan**: No TBD, TODO, or incomplete steps found

- [ ] **Type Consistency**: All variable names and references match
  - VERSION used consistently
  - BRANCH_NAME format consistent
  - Output references match (next-version, tag-name)

- [ ] **File Structure**: Clear separation of concerns
  - check-branch-exists.sh: Single responsibility (branch check)
  - Workflow: 3 distinct jobs with clear dependencies
  - Documentation: Setup and rollback guides separate

- [ ] **Testing**: Each task includes verification steps
  - Script testing before use
  - Workflow job testing
  - Integration testing
  - Error case testing

- [ ] **Rollback**: Explicit rollback procedure documented

---

## Notes

- This plan assumes environment `production` will be created manually in GitHub UI
- First execution requires manual environment setup before workflow can complete
- Script permissions are set executable during implementation
- All commits follow conventional commit format for clarity
- Workflow uses existing scripts (validate-changelog.sh, bump-version.sh) without modification
