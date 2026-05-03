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