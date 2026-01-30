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
2. TRACK     -> Set issue to "In Progress" (best effort, non-blocking)
3. DISCOVERY -> Explore codebase for context
4. WORKTREE  -> Create isolated worktree for issue branch
5. IMPLEMENT -> Diagnose and fix the issue
6. TEST      -> Run unit tests, add new unit tests
7. PR        -> Create pull request with issue reference
8. CLEANUP   -> Report completion
```

**Key Phase:**
- Phase 0 (VALIDATE) ensures session isolation - prevents conflicts with other Claude sessions

## Required: Track Progress with TodoWrite

**At the start of this workflow, create a todo list to track each phase:**

```
TodoWrite([
  { content: "Validate worktree context", status: "pending", activeForm: "Running worktree validation" },
  { content: "Detect project config", status: "pending", activeForm: "Detecting project config" },
  { content: "Select/validate issue", status: "pending", activeForm: "Selecting issue" },
  { content: "Set issue to In Progress (best effort)", status: "pending", activeForm: "Updating board status" },
  { content: "DISCOVERY: Explore codebase for context", status: "pending", activeForm: "Exploring codebase" },
  { content: "Create worktree for issue branch", status: "pending", activeForm: "Creating worktree" },
  { content: "Verify in worktree", status: "pending", activeForm: "Verifying worktree" },
  { content: "Diagnose issue", status: "pending", activeForm: "Diagnosing issue" },
  { content: "Implement fix", status: "pending", activeForm: "Implementing fix" },
  { content: "Run unit tests", status: "pending", activeForm: "Running unit tests" },
  { content: "Add unit tests for fix", status: "pending", activeForm: "Adding unit tests" },
  { content: "Smoke validation", status: "pending", activeForm: "Validating fix" },
  { content: "Create pull request", status: "pending", activeForm: "Creating pull request" },
  { content: "Report completion", status: "pending", activeForm: "Reporting completion" }
])
```

Mark each todo as `in_progress` when starting and `completed` when done.

## Phase 0: Validate Worktree Context (HARD BLOCKER - ALWAYS FIRST)

**🚨 THIS PHASE IS A HARD BLOCKER. YOU MUST ACTUALLY RUN THE VALIDATION COMMAND.**

**DO NOT skip this. DO NOT assume. ACTUALLY RUN IT.**

```bash
# MANDATORY: Run the validation command FIRST
~/.local/bin/git-worktree-workflow validate
```

**You MUST check the output and verify one of these states:**
- ✅ **Main repo on master/main** → Ready to create worktree (continue to Phase 1)
- ✅ **Already in a worktree** → Already isolated (continue to Phase 1)
- 🚨 **Main repo on feature branch** → **STOP! DO NOT PROCEED!**

**If validation shows feature branch in main repo:**
1. Run: `git checkout main` (or `git checkout master`)
2. Re-run: `~/.local/bin/git-worktree-workflow validate`
3. **ONLY proceed when validation explicitly passes**

**FAILURE TO VALIDATE = WORKFLOW VIOLATION**
- Working on a feature branch in the main repo breaks parallel work
- Other Claude sessions may conflict with your changes
- This is the #1 cause of workflow failures

## Phase 1: Project Detection

**BEFORE any work, detect project capabilities:**

```bash
# 1. Read project CLAUDE.md for configuration
cat CLAUDE.md 2>/dev/null | head -200

# 2. Check for worktree script
ls ~/.local/bin/git-worktree-workflow 2>/dev/null

# 3. Extract from CLAUDE.md (if present):
#    - github_project.project_id
#    - github_project.fields.status.id (status field ID)
#    - github_project.fields.status.options.in_progress
#    - github_project.fields.status.options.done
#    - Worktree script location
```

**Store detected config for use throughout workflow.**

## Phase 1.5: Discovery (MANDATORY before implementation)

**This phase ensures workers have sufficient context before writing code.**

### Step 1: Load Worker Context
```bash
# Read the condensed worker context summary
cat WORKER_CONTEXT.md 2>/dev/null
```

If WORKER_CONTEXT.md exists, extract and understand:
- CI/CD process (how deployments work, what triggers them)
- Critical constraints (database, patterns, no-go areas)
- Key file locations for the type of change being made

### Step 2: Explore Related Code

Spawn an explorer to understand the codebase area affected by this issue:

```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: find code related to issue #<NUMBER>",
  prompt: """
    Explore the codebase to find code related to this issue:

    Issue: <TITLE>
    Description: <BODY>

    Find and report:
    1. Files that will likely need modification
    2. Related files that might be affected
    3. Existing patterns in those files to follow
    4. Database tables involved (if any)
    5. API endpoints affected (if any)
    6. Potential breaking change risks

    Be thorough - this context will guide the implementation.
  """
)
```

### Step 3: Understand CI/CD Implications

Based on the issue and exploration, verify:
- [ ] Changes won't break the build (`npm run build`)
- [ ] Changes won't break type checking (`npm run typecheck`)
- [ ] API changes won't break health checks (`/api/healthz`)
- [ ] Database changes have migration strategy (if needed)

### Step 4: Document Discovery Summary

Before proceeding to Phase 2, document:
```
## Discovery Summary for Issue #<NUMBER>

### Files to Modify
- <file>:<line> - <what to change>

### Related Files (check for impact)
- <file> - <why it might be affected>

### Patterns to Follow
- <pattern observed in codebase>

### CI/CD Considerations
- Build impact: <none/low/high>
- Database changes: <yes/no - migration needed?>
- API changes: <yes/no - backwards compatible?>

### Risks Identified
- <potential risk and mitigation>
```

**ONLY AFTER discovery is complete → proceed to Phase 2 (Issue Selection)**

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

## Phase 3: Set "In Progress" on Project Board (Best Effort)

**Board tracking is best-effort - attempt to update but continue if it fails.**

If project board config exists in CLAUDE.md:

```bash
# 1. Get the item ID for this issue on the project board
ITEM_ID=$(gh project item-list <PROJECT_NUMBER> --owner <OWNER> --format json 2>/dev/null | \
  jq -r '.items[] | select(.content.number == <ISSUE_NUMBER>) | .id' 2>/dev/null)

# 2. If found, update status to "In Progress"
if [ -n "$ITEM_ID" ]; then
  gh project item-edit \
    --project-id <PROJECT_ID> \
    --id $ITEM_ID \
    --field-id <STATUS_FIELD_ID> \
    --single-select-option-id <IN_PROGRESS_OPTION_ID> 2>/dev/null && \
  echo "✓ Issue #<NUMBER> marked as In Progress on project board" || \
  echo "⚠ Board update failed - continuing anyway"
else
  echo "⚠ Issue not found on project board - continuing anyway"
fi
```

### Handling Failures

Board update failures should NOT block the workflow:
- Log a warning message
- Continue to Phase 4 immediately
- Board can be updated manually later if needed

**If no project board config:**
- Log: "No project board config - skipping board tracking"
- Continue immediately (no user confirmation needed)

## Phase 4: Create Worktree for Issue (HARD BLOCKER)

**🚨 IF `~/.local/bin/git-worktree-workflow` EXISTS, YOU MUST USE IT. NO EXCEPTIONS.**

### Step 1: Check for Worktree Script
```bash
# Check if worktree script exists
ls ~/.local/bin/git-worktree-workflow 2>/dev/null && echo "WORKTREE SCRIPT EXISTS - MUST USE IT"
```

### Step 2a: If Worktree Script Exists (MANDATORY)

**DO NOT use `git checkout -b`. USE THE SCRIPT.**

```bash
# Generate branch name from issue (feat/ for features, fix/ for bugs)
BRANCH="feat/issue-<NUMBER>-<slug-from-title>"
# or: BRANCH="fix/issue-<NUMBER>-<slug-from-title>"

# Create the worktree using the script
~/.local/bin/git-worktree-workflow start $BRANCH

# CRITICAL: The script outputs a worktree path - you MUST cd to it
# Example output: "Worktree created at /path/to/project-worktrees/feat/issue-123-description"
cd <WORKTREE_PATH_FROM_OUTPUT>

# MANDATORY VERIFICATION: Confirm you're in the worktree
~/.local/bin/git-worktree-workflow validate
# Must show: "worktree" type, NOT "main repo"
```

**VERIFICATION CHECKPOINT:**
After running `~/.local/bin/git-worktree-workflow validate`, confirm:
- Output shows you are in a **worktree** (not main repo)
- The branch matches your issue branch
- **If verification fails, DO NOT PROCEED with implementation**

### Step 2b: Standard Git (ONLY if no worktree script exists)

**Only use this fallback if `~/.local/bin/git-worktree-workflow` does NOT exist:**

```bash
# Ensure on latest main/master
git fetch origin
git checkout main && git pull origin main

# Create feature branch
BRANCH="fix/issue-<NUMBER>-<slug-from-title>"
git checkout -b $BRANCH

echo "Created branch: $BRANCH"
echo "WARNING: No worktree isolation - parallel sessions may conflict"
```

**⚠️ Standard git workflow doesn't provide session isolation. Multiple Claude sessions WILL conflict.**

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

**Step 3: Unit Testing & Validation**

This step ensures fast feedback during development while deferring slow integration/system tests to dedicated sessions.

**Testing Philosophy:**
- **Unit tests (mock-style)** = Fast, run every time, required for PR
- **Integration/System tests** = Slow, planned via P5 issues, implemented in dedicated sessions

```
A. RUN EXISTING UNIT TESTS (Regression Check)

First, check if the project has unit tests and run them:

# Check for test configuration
ls package.json jest.config.* vitest.config.* 2>/dev/null

# Look for existing unit tests
find src -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | head -5

# Run unit tests (project-specific command)
# Common commands - use what's configured in package.json:
npm test              # Default
npm run test:unit     # If separate unit test script exists
jest --testPathPattern="unit|__tests__"  # Jest specific
vitest run            # Vitest specific

If tests exist and ANY fail:
1. STOP - Do not proceed
2. Determine if failure is:
   - Pre-existing (not caused by this fix) → Document in PR, continue
   - Caused by this fix → Fix the code or update the test
3. All unit tests must pass before proceeding
```

```
B. ADD UNIT TESTS FOR NEW FUNCTIONALITY

Spawn test-automator to add relevant unit tests for the fix:

Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: add unit tests for #<NUMBER>",
  prompt: """
    Add unit tests for the fix implemented in issue #<NUMBER>.

    Fix summary: <BRIEF DESCRIPTION OF WHAT WAS FIXED>
    Files modified: <LIST OF MODIFIED FILES>

    Requirements:
    - Write UNIT tests only (mock dependencies, fast execution)
    - Focus on the specific functionality fixed/added
    - Use existing test patterns in the codebase
    - Tests must be parallelization-safe (no shared state)
    - Target: 2-5 focused tests, not comprehensive coverage

    Do NOT write:
    - Integration tests (those go in a separate P5 issue)
    - E2E tests (those go in a separate P5 issue)
    - Tests requiring database or external services

    After writing tests, run them to verify they pass.
  """
)

If no test infrastructure exists:
- Skip this step (don't block on setting up test framework)
- Note in PR: "No unit test infrastructure - tests documented in P5 issue"
```

```
C. SMOKE VALIDATION (Do this directly, no agent spawn needed)

Smoke Validation Checklist:
- [ ] Verified fix resolves the issue
- [ ] Checked related functionality still works
- [ ] No console errors / server errors introduced
- [ ] Build succeeds (npm run build)
- [ ] Type check passes (npm run typecheck)
- [ ] All unit tests pass (from step A)
- [ ] New unit tests pass (from step B)

Validation method: <describe what you did>
```

```
D. DOCUMENT INTEGRATION/SYSTEM TEST PLAN (For future implementation)

If integration or system tests would be valuable for this fix, document them:

## Integration/System Test Plan for #<NUMBER>

### Integration Tests (require real dependencies)
- [ ] Test: <description>
  - Dependencies: <database, API, etc.>
  - Setup required: <what needs to be configured>

### System/E2E Tests
- [ ] Test: <user flow description>
  - Preconditions: <required state>
  - Steps: <user actions>
  - Expected: <outcome>

### Notes
- Estimated complexity: Simple / Medium / Complex
- Requires test environment: Yes / No
```

```
E. CREATE P5 TEST ISSUE (If integration/system tests documented)

Only create this issue if integration/system tests were documented in step D:

# Get project board priority field info (if configured in CLAUDE.md)
# Use P5: Testing priority for test-debt issues

gh issue create \
  --title "Tests: Integration/System tests for #<ORIGINAL_NUMBER>" \
  --label "test-debt,P5-testing,automated" \
  --body "## Background
This issue tracks **integration and system test** implementation for #<ORIGINAL_NUMBER>.

Unit tests were added as part of the original fix.

## Test Plan
<Integration/System test plan from step D>

## Acceptance Criteria
- [ ] Integration tests implemented and passing
- [ ] System/E2E tests implemented and passing (if applicable)
- [ ] Tests added to CI pipeline

## Notes
This is a P5 (Testing) priority issue. Implementation should be done in a dedicated testing session, not during feature development.

---
*Auto-generated by /issue workflow*"

# If project board is configured, add issue and set Priority to P5
# (See CLAUDE.md for project-specific field IDs)
```

**Why this approach:**
- **Fast feedback:** Unit tests run in seconds, catch regressions immediately
- **No blocking:** Don't wait for slow integration tests during development
- **Batched work:** Integration/system tests are implemented in dedicated sessions (P5 priority)
- **Clear separation:** Unit tests = part of fix, Integration tests = separate tracked work

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

## Testing
- [x] Unit tests pass (regression check)
- [x] Unit tests added for new functionality
- [x] Build and typecheck pass
- [ ] Integration/system tests: <P5 issue link if created, or "N/A">

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

## Phase 8: Cleanup & Handoff

After PR is created, prepare for session end:

### Report Completion to User

```
## Issue #<NUMBER> Resolution Complete

**PR Created:** <PR_URL>

### Summary
- Root cause: <brief description>
- Fix: <what was changed>
- Unit tests: <added/updated/existing pass>

### Next Steps
1. Review and merge PR: <PR_URL>
2. Board will auto-update to "Done" when PR merges (via `Fixes #<NUMBER>`)
3. Integration/system tests: <P5_ISSUE_URL or "N/A">

### Worktree Status
Currently in: /path/to/worktree/$BRANCH
To cleanup after merge: `~/.local/bin/git-worktree-workflow cleanup`
```

### Return to Main Repo (Optional)

If continuing with other work in this session:

```bash
# Return to main repo on master
~/.local/bin/git-worktree-workflow main

# Verify back in main repo
~/.local/bin/git-worktree-workflow validate
```

### Worktree Cleanup (After PR Merge)

Worktrees should be cleaned up after their PRs are merged:

```bash
# From main repo, clean up merged worktrees
~/.local/bin/git-worktree-workflow cleanup
```

**Note:** Don't cleanup worktrees with unmerged PRs - the work would be lost.

**Without worktree script:**
```bash
cd /path/to/main/repo
git checkout master
git worktree remove /path/to/worktree  # Only if merged
git branch -d $BRANCH                   # Only if merged
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

- [ ] Worktree context validated (Phase 0)
- [ ] Project config detected
- [ ] Issue selected and details fetched
- [ ] Board status update attempted (best effort - ok if skipped)
- [ ] Discovery completed (explored related code)
- [ ] Worktree created using `~/.local/bin/git-worktree-workflow start`
- [ ] Verified working in worktree (ran validate)
- [ ] Root cause identified and documented
- [ ] Fix implemented (minimal scope)
- [ ] Unit tests pass (regression check)
- [ ] Unit tests added for new functionality
- [ ] Smoke validation passed
- [ ] Build and type check passing
- [ ] PR created with `Fixes #<NUMBER>`
- [ ] PR URL reported to user

## Fallback Behavior

The workflow adapts to available project tooling:

| Missing Config | Behavior |
|----------------|----------|
| No board config | Skip board updates, warn user |
| No worktree script | Use standard `git checkout -b` (ONLY if script truly doesn't exist) |
| No gh CLI | Provide manual git/GitHub instructions |

**⚠️ IMPORTANT:** "No worktree script" means `~/.local/bin/git-worktree-workflow` literally does not exist.
If the script EXISTS, you MUST use it. Do NOT fall back to `git checkout -b` by choice.

## Anti-Patterns to AVOID

### 🚨 CRITICAL VIOLATIONS (Break parallel work)
- **Using `git checkout -b` when `~/.local/bin/git-worktree-workflow` exists** - This is the #1 workflow violation. If the script exists, USE IT.
- **Not actually running Phase 0 validation** - You must EXECUTE `~/.local/bin/git-worktree-workflow validate`, not just acknowledge it exists
- **Skipping Phase 0 (validate)** - Always validate worktree context first to avoid session conflicts
- **Working in main repo on a feature branch** - Creates conflicts with other Claude sessions
- **Forgetting to cd to worktree** - After `start`, you MUST cd to the worktree directory
- **Not verifying worktree after creation** - Run `~/.local/bin/git-worktree-workflow validate` AFTER creating worktree to confirm isolation

### Board Tracking (Best Effort)
- Board updates are best-effort, not blocking gates
- If board update fails, log warning and continue
- Manual board updates can be done later if needed

### Testing Violations
- **Skipping unit test regression check** - Always run existing unit tests before PR
- **Writing integration tests during /issue** - These belong in P5 issues for dedicated sessions
- **Blocking on missing test infrastructure** - Document tests, don't block the fix

### Other
- **Skipping cleanup/handoff** - Always report completion and worktree status
- Fixing multiple issues in one PR
- Skipping smoke validation
- Scope creep / "while I'm here" changes
- Not using `Fixes #` syntax in PR (misses auto-close)
