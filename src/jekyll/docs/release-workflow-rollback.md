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