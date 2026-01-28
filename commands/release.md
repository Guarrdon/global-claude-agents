---
description: Create a release by tagging and pushing to trigger CI/CD deployment.
---

# Release Workflow

You are creating a release by tagging a commit and pushing it to trigger CI/CD.

## Your Task

$ARGUMENTS

## Supported Tag Formats

| Application | Tag Format | Example |
|-------------|------------|---------|
| CRM App | `crm-v*` | `crm-v0.2.2` |
| Admin Site | `admin-v*` | `admin-v0.1.0` |
| Corporate Site | `corporate-v*` | `corporate-v0.1.0` |

## Workflow

### Step 1: Parse the tag argument

Extract the tag from the arguments. Valid formats:
- `crm-v0.2.2` or `crm-v1.0.0`
- `admin-v0.1.0` or `admin-v1.0.0`
- `corporate-v0.1.0` or `corporate-v1.0.0`

If no argument provided or invalid format, ask the user:
```
What would you like to release?

Examples:
  /release crm-v0.2.2
  /release admin-v0.1.0
  /release corporate-v0.1.0
```

### Step 2: Validate current state

```bash
# Ensure we're on master and up to date
git fetch origin
git status

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "master" ] && [ "$CURRENT_BRANCH" != "main" ]; then
  echo "WARNING: Not on master/main branch. Currently on: $CURRENT_BRANCH"
  # Ask user if they want to proceed
fi

# Check if tag already exists
git tag -l "<TAG>"
```

### Step 3: Show what will be released

```bash
# Show the commit that will be tagged
git log -1 --oneline

# Show recent commits since last tag of same type
# For crm-v*, find last crm-v* tag
git log $(git describe --tags --match "crm-v*" --abbrev=0 2>/dev/null || echo "HEAD~10")..HEAD --oneline
```

### Step 4: Confirm with user

Before creating the tag, confirm:

```
Ready to release:

  Tag: <TAG>
  Commit: <SHA> <message>

This will:
  1. Create git tag: <TAG>
  2. Push tag to origin
  3. Trigger CI/CD deployment
  4. Create GitHub Release

Proceed? (The CI/CD will deploy automatically once the tag is pushed)
```

### Step 5: Create and push the tag

```bash
# Create the tag
git tag <TAG>

# Push the tag
git push origin <TAG>
```

### Step 6: Report success

```
## Release Created Successfully

**Tag:** <TAG>
**Commit:** <SHA>

### What's happening now:
1. CI/CD workflow triggered
2. Building and deploying...
3. GitHub Release will be created

### Monitor deployment:
- GitHub Actions: https://github.com/<owner>/<repo>/actions
- Releases: https://github.com/<owner>/<repo>/releases

### Deployment target:
- crm-v* → demo01.streamlinesalescrm.com
- admin-v* → admin.streamlinesalescrm.com
- corporate-v* → streamlinesalescrm.com
```

## Commands Reference

| Usage | Description |
|-------|-------------|
| `/release crm-v0.2.2` | Release CRM app version 0.2.2 |
| `/release admin-v0.1.0` | Release Admin site version 0.1.0 |
| `/release corporate-v0.1.0` | Release Corporate site version 0.1.0 |
| `/release` | Interactive - asks which app and version |

## Validation Rules

1. **Tag format must match:** `<app>-v<semver>` where app is `crm`, `admin`, or `corporate`
2. **Must be on master/main:** Warn if on different branch
3. **Tag must not exist:** Error if tag already exists
4. **Must have clean working tree:** Warn if uncommitted changes

## Rollback

If a release needs to be rolled back:

```bash
# Option 1: Deploy previous version via GitHub Actions manually
# Go to Actions → Select workflow → Run workflow → Enter previous version

# Option 2: Create a new tag pointing to the old commit
git checkout <old-commit-sha>
git tag crm-v0.2.3
git push origin crm-v0.2.3
git checkout master
```

## Error Handling

### Tag already exists
```bash
# Delete and recreate if intentional
git tag -d <TAG>
git push origin --delete <TAG>
git tag <TAG>
git push origin <TAG>
```

### Wrong commit tagged
```bash
# Delete the tag
git tag -d <TAG>
git push origin --delete <TAG>

# Checkout correct commit and re-tag
git checkout <correct-sha>
git tag <TAG>
git push origin <TAG>
git checkout master
```
