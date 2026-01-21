---
description: GitHub issue resolver - complete workflow with board status, worktree, implementation, and PR.
---

# GitHub Issue Resolution Workflow

You are orchestrating the complete resolution of a GitHub issue. This workflow handles ONE issue at a time with full project integration.

## Your Task

$ARGUMENTS

## Workflow Overview

```
1. SETUP     -> Detect project config, select/validate issue
2. TRACK     -> Set issue to "In Progress" on project board
   ├── BLOCKING: Must succeed before proceeding
   └── VERIFY: Confirm status update before continuing
3. BRANCH    -> Create/switch to worktree or feature branch
4. IMPLEMENT -> Spawn dev workers for the fix
5. PR        -> Create pull request with issue reference
6. COMPLETE  -> Update board to "Done" (after PR merged)
```

**CRITICAL WORKFLOW GATE:** Phase 2 (TRACK) is a **blocking checkpoint**. You MUST NOT proceed to Phase 3 (BRANCH) or any subsequent phase until the issue has been successfully marked "In Progress" on the project board. This prevents duplicate work by signaling to other team members that the issue is being actively worked on.

## Required: Track Progress with TodoWrite

**At the start of this workflow, create a todo list to track each phase:**

```
TodoWrite([
  { content: "Detect project config", status: "pending", activeForm: "Detecting project config" },
  { content: "Select/validate issue", status: "pending", activeForm: "Selecting issue" },
  { content: "Set issue to In Progress on board", status: "pending", activeForm: "Setting issue to In Progress" },
  { content: "CHECKPOINT: Verify In Progress succeeded", status: "pending", activeForm: "Verifying In Progress status" },
  { content: "Create worktree/branch", status: "pending", activeForm: "Creating worktree/branch" },
  { content: "Diagnose issue (debugger)", status: "pending", activeForm: "Diagnosing issue" },
  { content: "Implement fix (code-writer)", status: "pending", activeForm: "Implementing fix" },
  { content: "Add regression test (test-automator)", status: "pending", activeForm: "Adding regression test" },
  { content: "Create pull request", status: "pending", activeForm: "Creating pull request" }
])
```

Mark each todo as `in_progress` when starting and `completed` when done. **The CHECKPOINT todo enforces the blocking gate.**

## Phase 1: Project Detection

**BEFORE any work, detect project capabilities:**

```bash
# 1. Read project CLAUDE.md for configuration
cat CLAUDE.md 2>/dev/null | head -200

# 2. Check for worktree script
ls scripts/git-workflow.sh 2>/dev/null

# 3. Extract from CLAUDE.md (if present):
#    - github_project.project_id
#    - github_project.fields.status.id (status field ID)
#    - github_project.fields.status.options.in_progress
#    - github_project.fields.status.options.done
#    - Worktree script location
```

**Store detected config for use throughout workflow.**

## Phase 2: Issue Selection

If no issue number provided:
```bash
# List open issues with labels
gh issue list --state open --json number,title,labels,createdAt --limit 20

# Priority order (check labels):
# 1. P1/Critical/bug labels
# 2. P2/High labels
# 3. P3/Medium labels
# 4. Oldest issue as tie-breaker
```

If issue number provided (e.g., `/issue #123` or `/issue 123`):
```bash
# Fetch issue details
gh issue view <NUMBER> --json number,title,body,labels
```

## Phase 3: Set "In Progress" on Project Board (BLOCKING GATE)

**CRITICAL: This phase is a BLOCKING GATE. No code work may begin until this completes successfully.**

If project board config exists in CLAUDE.md:

```bash
# 1. Get the item ID for this issue on the project board
ITEM_ID=$(gh project item-list <PROJECT_NUMBER> --owner <OWNER> --format json | \
  jq -r '.items[] | select(.content.number == <ISSUE_NUMBER>) | .id')

# 2. Verify we found the item
if [ -z "$ITEM_ID" ]; then
  echo "ERROR: Could not find issue #<NUMBER> on project board"
  echo "BLOCKING: Cannot proceed until issue is on the board"
  exit 1
fi

# 3. Update status to "In Progress"
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id $ITEM_ID \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <IN_PROGRESS_OPTION_ID>

echo "Issue #<NUMBER> marked as In Progress on project board"
```

### Error Handling (REQUIRED)

If the board update fails:
1. **DO NOT proceed** to Phase 4 or any subsequent phase
2. **Report the error** to the user with the specific failure message
3. **Ask the user** how to proceed:
   - Retry the board update
   - Manually update the board and confirm
   - Skip board tracking (user accepts risk of duplicate work)

**If no project board config:**
- Inform user: "No project board config found in CLAUDE.md - skipping board status update"
- **Ask user to confirm** they want to proceed without board tracking
- Only continue after user explicitly confirms

## Phase 3.5: CHECKPOINT - Verify "In Progress" Status

**This checkpoint is MANDATORY. Do not skip.**

Before proceeding to Phase 4, verify the status was set:

```bash
# Verify the status update took effect
CURRENT_STATUS=$(gh project item-list <PROJECT_NUMBER> --owner <OWNER> --format json | \
  jq -r '.items[] | select(.content.number == <ISSUE_NUMBER>) | .status')

echo "Issue #<NUMBER> current status: $CURRENT_STATUS"

# Confirm it shows "In Progress" (or your configured status name)
```

**Only after verification succeeds:**
- Mark the "CHECKPOINT: Verify In Progress succeeded" todo as completed
- Proceed to Phase 4

## Phase 4: Create Worktree/Branch

### If Project Has Worktree Script (`scripts/git-workflow.sh`)
```bash
# Generate branch name from issue
BRANCH="fix/issue-<NUMBER>-<slug-from-title>"

# Check current status
scripts/git-workflow.sh status

# Switch to worktree (creates if needed, auto-commits WIP on current branch)
scripts/git-workflow.sh switch $BRANCH

# IMPORTANT: Working directory changes!
cd <WORKTREE_PATH>

# Inform user of new working directory
```

### Standard Git (No Worktree Script)
```bash
# Ensure on latest main/master
git fetch origin
git checkout main && git pull origin main

# Create feature branch
BRANCH="fix/issue-<NUMBER>-<slug-from-title>"
git checkout -b $BRANCH

echo "Created branch: $BRANCH"
```

## Phase 5: Implementation

Spawn development workers based on issue type:

### Bug Fix (default for issues)

**Step 1: Diagnose**
```
Task(
  subagent_type: "debugger",
  model: "opus",
  description: "debugger: diagnose issue #<NUMBER>",
  prompt: """
    Diagnose GitHub issue #<NUMBER>: <TITLE>

    Issue description:
    <BODY>

    Find the root cause. Output:
    - Root cause explanation
    - Affected files
    - Proposed fix approach
  """
)
```

**Step 2: Implement Fix**
```
Task(
  subagent_type: "code-writer",
  model: "sonnet",
  description: "code-writer: fix issue #<NUMBER>",
  prompt: """
    Implement fix for issue #<NUMBER> based on diagnosis:
    <DEBUGGER_OUTPUT>

    Requirements:
    - Minimal, scoped fix
    - Follow existing patterns
    - No scope creep
    - No "while I'm here" changes
  """
)
```

**Step 3: Add Regression Test**
```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: regression test for #<NUMBER>",
  prompt: """
    Add regression test for issue #<NUMBER>:
    <ISSUE_DESCRIPTION>

    The fix was:
    <CODE_WRITER_SUMMARY>

    Ensure the bug cannot recur.
  """
)
```

### Feature Request (if issue has enhancement/feature label)
Use: code-writer -> test-automator -> code-reviewer sequence.

## Phase 6: Create Pull Request

```bash
# Stage and commit changes
git add -A
git commit -m "fix: <issue title summary> (#<NUMBER>)

<Brief description of root cause and fix>

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push branch
git push -u origin $BRANCH

# Create PR with issue reference (Fixes # auto-closes on merge)
gh pr create \
  --title "fix: <issue title> (#<NUMBER>)" \
  --body "$(cat <<'EOF'
## Summary
Fixes #<NUMBER>

<Brief description of the fix>

## Root Cause
<What caused the issue>

## Changes
- <Change 1>
- <Change 2>

## Test Plan
- [ ] Regression test added
- [ ] All existing tests pass
- [ ] Manual verification

Generated with Claude Code
EOF
)"
```

**Report PR URL to user.**

## Phase 7: Update Board to "Done"

The board is typically updated to "Done" after the PR is merged.

**Option A: Automatic** - If using `Fixes #<NUMBER>` in PR, GitHub auto-closes the issue on merge.

**Option B: Manual** - User runs `/issue done #123` after merge:

```bash
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <DONE_OPTION_ID>

echo "Issue #<NUMBER> marked as Done on project board"
```

## Commands Reference

| Usage | Description |
|-------|-------------|
| `/issue` | Pick highest priority open issue and resolve it |
| `/issue #123` | Resolve specific issue number 123 |
| `/issue 123` | Same as above (# is optional) |
| `/issue done #123` | Mark issue as Done on board (run after PR merge) |
| `/issue status` | Show current git/worktree status |

## Execution Checklist

Before reporting completion, verify:

- [ ] Project config detected (board IDs, worktree script)
- [ ] Issue selected and details fetched
- [ ] **GATE: Board status set to "In Progress"** (or user confirmed to skip)
- [ ] **GATE: Checkpoint verification completed** (status confirmed)
- [ ] Worktree/branch created for the fix
- [ ] Root cause identified and documented
- [ ] Fix implemented (minimal scope)
- [ ] Regression test added
- [ ] All tests pass
- [ ] PR created with `Fixes #<NUMBER>`
- [ ] PR URL reported to user

## Fallback Behavior

The workflow adapts to available project tooling:

| Missing Config | Behavior |
|----------------|----------|
| No board config | Skip board updates, warn user |
| No worktree script | Use standard `git checkout -b` |
| No gh CLI | Provide manual git/GitHub instructions |

## Anti-Patterns to AVOID

- **Starting code work BEFORE setting "In Progress"** - This is the #1 violation. The TRACK phase is a BLOCKING GATE.
- **Skipping the checkpoint verification** - Always verify the status update succeeded before continuing
- **Proceeding after board update failure** without explicit user confirmation
- Working directly on main/master branch
- Fixing multiple issues in one PR
- Skipping the regression test
- Scope creep / "while I'm here" changes
- Forgetting to inform user of directory changes (worktree)
- Not using `Fixes #` syntax in PR (misses auto-close)
