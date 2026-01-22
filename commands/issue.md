---
description: GitHub issue resolver - complete workflow with board status, worktree, implementation, and PR.
---

# GitHub Issue Resolution Workflow

You are orchestrating the complete resolution of a GitHub issue. This workflow handles ONE issue at a time with full project integration.

## Your Task

$ARGUMENTS

## Workflow Overview

```
0. VALIDATE  -> Validate git worktree context (ALWAYS FIRST)
1. SETUP     -> Detect project config, select/validate issue
2. TRACK     -> Set issue to "In Progress" on project board
   ├── BLOCKING: Must succeed before proceeding
   └── VERIFY: Confirm status update before continuing
3. WORKTREE  -> Create isolated worktree for issue branch
4. IMPLEMENT -> Spawn dev workers for the fix
5. PR        -> Create pull request with issue reference
6. COMPLETE  -> Update board to "Done" (after PR merged)
```

**CRITICAL WORKFLOW GATES:**
- Phase 0 (VALIDATE) ensures session isolation - prevents conflicts with other Claude sessions
- Phase 2 (TRACK) prevents duplicate work by signaling issue is being worked on

## Required: Track Progress with TodoWrite

**At the start of this workflow, create a todo list to track each phase:**

```
TodoWrite([
  { content: "Validate git worktree context", status: "pending", activeForm: "Validating worktree context" },
  { content: "Detect project config", status: "pending", activeForm: "Detecting project config" },
  { content: "Select/validate issue", status: "pending", activeForm: "Selecting issue" },
  { content: "Set issue to In Progress on board", status: "pending", activeForm: "Setting issue to In Progress" },
  { content: "CHECKPOINT: Verify In Progress succeeded", status: "pending", activeForm: "Verifying In Progress status" },
  { content: "Create worktree for issue", status: "pending", activeForm: "Creating worktree" },
  { content: "Diagnose issue (debugger)", status: "pending", activeForm: "Diagnosing issue" },
  { content: "Implement fix (code-writer)", status: "pending", activeForm: "Implementing fix" },
  { content: "Smoke validation & test planning", status: "pending", activeForm: "Validating fix and documenting tests" },
  { content: "Create test-debt issue", status: "pending", activeForm: "Creating test-debt issue" },
  { content: "Create pull request", status: "pending", activeForm: "Creating pull request" }
])
```

Mark each todo as `in_progress` when starting and `completed` when done.

## Phase 0: Validate Worktree Context (ALWAYS FIRST)

**This phase runs BEFORE any other work. It ensures session isolation.**

```bash
# Run the validation command
scripts/git-workflow.sh validate
```

**Expected outcomes:**
- ✅ **Main repo on master** → Ready to create worktree (continue to Phase 1)
- ✅ **Already in a worktree** → Already isolated (continue to Phase 1)
- 🚨 **Main repo on feature branch** → STOP! Fix before proceeding

**If validation fails (feature branch in main repo):**
1. Run: `git checkout master`
2. Re-run: `scripts/git-workflow.sh validate`
3. Only proceed when validation passes

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

## Phase 4: Create Worktree for Issue

### If Project Has Worktree Script (`scripts/git-workflow.sh`) - PREFERRED

```bash
# Generate branch name from issue
BRANCH="fix/issue-<NUMBER>-<slug-from-title>"

# Create the worktree (from main repo on master)
scripts/git-workflow.sh start $BRANCH

# CRITICAL: Change to worktree directory
# The script outputs the path - you MUST cd to it
cd /path/to/StreamlineSales-worktrees/$BRANCH

# Verify you're in the worktree (should show "worktree" type)
scripts/git-workflow.sh validate
```

**Important:** The `start` command outputs the cd command you need to run. You MUST change to the worktree directory before proceeding. All subsequent work happens in the worktree, NOT the main repo.

### Standard Git (No Worktree Script) - Fallback

```bash
# Ensure on latest main/master
git fetch origin
git checkout main && git pull origin main

# Create feature branch
BRANCH="fix/issue-<NUMBER>-<slug-from-title>"
git checkout -b $BRANCH

echo "Created branch: $BRANCH"
```

**Note:** Standard git workflow doesn't provide session isolation. Multiple Claude sessions may conflict.

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

**Step 3: Smoke Validation & Test Planning**

Instead of implementing full regression tests, perform smoke validation and document tests for later:

```
A. SMOKE VALIDATION (Do this directly, no agent spawn needed)

Smoke Validation Checklist:
- [ ] Verified fix resolves the issue
- [ ] Checked related functionality still works
- [ ] No console errors / server errors introduced
- [ ] Build succeeds (npm run build)
- [ ] Type check passes (npm run typecheck)

Validation method: <describe what you did>
```

```
B. TEST PLAN DOCUMENTATION (Document, don't implement)

## Proposed Tests for #<NUMBER>

### Unit Tests
- [ ] Test: <description>
  - Input: <what to test>
  - Expected: <expected outcome>

### Integration Tests
- [ ] Test: <description>

### Edge Cases
- [ ] <edge case identified during fix>

### Notes
- Parallelization safe: Yes/No
- Priority: Critical/Standard/Nice-to-have
```

```
C. CREATE TEST-DEBT ISSUE (Automatic)

gh issue create \
  --title "Tests: <original issue title>" \
  --label "test-debt,automated" \
  --body "## Background
This issue tracks test implementation for #<ORIGINAL_NUMBER>.

## Test Plan
<Test plan from above>

## Acceptance Criteria
- [ ] Tests implemented and passing
- [ ] Added to CI pipeline"
```

**Why this approach:** Until a project reaches functional completeness, focus on validating fixes work rather than blocking delivery on comprehensive test coverage. Test implementation is batched and scheduled separately.

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
- [ ] Smoke validation passed (fix verified working)
- [ ] Build and type check passing
- [ ] Test plan documented
- [ ] Test-debt issue created (if tests needed)
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

- **Skipping Phase 0 (validate)** - Always validate worktree context first to avoid session conflicts
- **Working in main repo on a feature branch** - Creates conflicts with other Claude sessions
- **Forgetting to cd to worktree** - After `start`, you MUST cd to the worktree directory
- **Starting code work BEFORE setting "In Progress"** - The TRACK phase is a BLOCKING GATE
- **Skipping the checkpoint verification** - Always verify the status update succeeded
- **Proceeding after board update failure** without explicit user confirmation
- Fixing multiple issues in one PR
- Skipping smoke validation
- Skipping test plan documentation
- Blocking fix on comprehensive test implementation (during early dev)
- Scope creep / "while I'm here" changes
- Not using `Fixes #` syntax in PR (misses auto-close)
