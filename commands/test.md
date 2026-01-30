---
description: Testing workflow - dedicated sessions for integration/system test implementation (P5 issues).
---

# Testing Workflow

You are orchestrating a dedicated testing session. This workflow is used to implement integration and system tests from P5 test-debt issues, or to run/fix existing tests.

## Your Task

$ARGUMENTS

## Workflow Overview

```
0. VALIDATE  -> Validate git worktree context (ALWAYS FIRST)
1. SETUP     -> Detect project config, identify test task
2. TRACK     -> Set issue to "In Progress" on board (if working on P5 issue)
3. WORKTREE  -> Create isolated worktree for test branch
4. IMPLEMENT -> Write integration/system tests
5. VERIFY    -> Run all tests, ensure passing
6. PR        -> Create pull request
7. CLEANUP   -> Update board, cleanup worktree
```

## Required: Track Progress with TodoWrite

**At the start of this workflow, create a todo list:**

```
TodoWrite([
  { content: "Validate git worktree context", status: "pending", activeForm: "Validating worktree context" },
  { content: "Detect project test config", status: "pending", activeForm: "Detecting test config" },
  { content: "Identify test task (P5 issue or ad-hoc)", status: "pending", activeForm: "Identifying test task" },
  { content: "Set issue to In Progress (if P5)", status: "pending", activeForm: "Setting issue to In Progress" },
  { content: "Create worktree for tests", status: "pending", activeForm: "Creating worktree" },
  { content: "Implement tests", status: "pending", activeForm: "Implementing tests" },
  { content: "Run full test suite", status: "pending", activeForm: "Running test suite" },
  { content: "Create pull request", status: "pending", activeForm: "Creating pull request" },
  { content: "Update board and cleanup", status: "pending", activeForm: "Cleaning up" }
])
```

## Phase 0: Validate Worktree Context (ALWAYS FIRST)

**This phase runs BEFORE any other work.**

```bash
# Run the validation command
~/.local/bin/git-worktree-workflow validate
```

**Expected outcomes:**
- ✅ **Main repo on master** → Ready to create worktree (continue to Phase 1)
- ✅ **Already in a worktree** → Already isolated (continue to Phase 1)
- 🚨 **Main repo on feature branch** → STOP! Run `git checkout master` first

## Phase 1: Project Detection & Test Configuration

```bash
# 1. Read project CLAUDE.md for test configuration
cat CLAUDE.md 2>/dev/null | grep -A 50 "Testing Strategy\|test\|Test"

# 2. Check for test infrastructure
ls package.json jest.config.* vitest.config.* playwright.config.* 2>/dev/null

# 3. Check for existing test directories
ls -la src/**/__tests__/ tests/ test/ e2e/ 2>/dev/null

# 4. Identify test commands in package.json
cat package.json | jq '.scripts | to_entries[] | select(.key | contains("test"))' 2>/dev/null
```

**Determine test types available:**
- Unit tests: `npm test`, `npm run test:unit`, `jest`, `vitest`
- Integration tests: `npm run test:integration`
- E2E tests: `npm run test:e2e`, `playwright test`

## Phase 2: Identify Test Task

### Option A: P5 Test Issue (Preferred)

If working on a P5 test-debt issue:

```bash
# List P5 test issues
gh issue list --label "P5-testing,test-debt" --state open --json number,title

# Get specific issue details
gh issue view <NUMBER> --json number,title,body,labels
```

Extract the test plan from the issue body - it was documented by `/issue` workflow.

### Option B: Ad-hoc Testing

If no specific issue, determine task type:
- **Write new tests** - Add coverage to specified code
- **Run tests** - Execute test suite and report
- **Fix failing tests** - Diagnose and fix broken tests

## Phase 3: Set "In Progress" (P5 Issues Only)

If working on a P5 test issue and project board is configured:

```bash
# Get item ID
ITEM_ID=$(gh project item-list <PROJECT_NUMBER> --owner <OWNER> --format json | \
  jq -r '.items[] | select(.content.number == <ISSUE_NUMBER>) | .id')

# Update status
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id $ITEM_ID \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <IN_PROGRESS_OPTION_ID>
```

## Phase 4: Create Worktree

```bash
# Generate branch name
BRANCH="test/issue-<NUMBER>-<description>"  # For P5 issues
# OR
BRANCH="test/<target-description>"          # For ad-hoc

# Create worktree
~/.local/bin/git-worktree-workflow start $BRANCH

# CRITICAL: Change to worktree directory
cd /path/to/worktrees/$BRANCH

# Verify
~/.local/bin/git-worktree-workflow validate
```

**Without worktree script (fallback):**
```bash
git fetch origin
git checkout master && git pull origin master
git checkout -b $BRANCH
```

## Phase 5: Implement Tests

### For P5 Test Issues (Integration/System Tests)

The P5 issue contains a test plan. Implement it:

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: implement P5 tests for #<NUMBER>",
  prompt: """
    Implement integration and system tests from P5 issue #<NUMBER>.

    ## Test Plan (from issue)
    <PASTE TEST PLAN FROM ISSUE BODY>

    ## Requirements
    - Implement ALL tests documented in the plan
    - Follow existing test patterns in the codebase
    - Integration tests may use real database/services (not mocks)
    - System/E2E tests should simulate real user flows
    - Tests must be parallelization-safe where possible

    ## Test Categories

    ### Integration Tests
    - Test component interactions with real dependencies
    - Test API endpoints with test database
    - Test service layer with actual implementations

    ### System/E2E Tests (if applicable)
    - Use Playwright or similar for browser testing
    - Test critical user flows end-to-end
    - Include setup and teardown for test state

    ## Quality Standards
    - Descriptive test names
    - Proper test isolation
    - Cleanup after tests
    - Reasonable timeouts
    - Clear failure messages

    After implementing, run the tests to verify they pass.
  """
)
```

### For Ad-hoc Test Writing

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: write tests for <target>",
  prompt: """
    Write tests for the specified target.

    ## Target
    <files/functions/features to test>

    ## Test Scope
    Determine appropriate test types:
    - Unit tests (fast, mocked) - for isolated logic
    - Integration tests (slower, real deps) - for component interaction
    - E2E tests (slowest, full stack) - for user flows

    ## Project Context
    Read CLAUDE.md for testing conventions, frameworks, and patterns.

    ## Deliverables
    - Test files following project conventions
    - All tests passing
    - Coverage summary
  """
)
```

### For Running Tests Only

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: run test suite",
  prompt: """
    Run the project's test suite and report results.

    ## Tasks
    1. Identify test commands (check package.json, CLAUDE.md)
    2. Run tests by category:
       - Unit tests first (fast feedback)
       - Integration tests second
       - E2E tests last (if applicable)
    3. Report results:
       - Total passed/failed per category
       - Failed test details
       - Coverage summary if available

    ## If Tests Fail
    - Analyze failure patterns
    - Categorize: test bug vs code bug vs flaky test
    - Suggest fixes or flag for /debug
  """
)
```

### For Fixing Failing Tests

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: fix failing tests",
  prompt: """
    Fix failing tests in the project.

    ## Approach
    1. Run tests to identify all failures
    2. Analyze each failure:
       - Test is wrong → Update test
       - Code is wrong → Flag for /debug (don't fix production code here)
       - Flaky test → Fix reliability issues
    3. Fix test issues only
    4. Re-run to verify

    ## Important
    - Only fix TEST code, not production code
    - Maintain test intent - don't just make tests pass incorrectly
    - If production code is buggy, create an issue or flag for /debug
  """
)
```

## Phase 6: Verify All Tests Pass

Before creating PR, run full test suite:

```bash
# Run all test types
npm test                    # Unit tests
npm run test:integration    # Integration tests (if exists)
npm run test:e2e           # E2E tests (if exists)

# OR single comprehensive command if available
npm run test:all

# Check for coverage thresholds
npm run test:coverage
```

**All tests must pass before proceeding.**

## Phase 7: Create Pull Request

```bash
# Stage and commit
git add -A
git commit -m "test: add integration/system tests for #<NUMBER>

Implements test plan from P5 issue #<NUMBER>.

Tests added:
- <list key tests added>

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push branch
git push -u origin $BRANCH

# Create PR
gh pr create \
  --title "test: integration/system tests for #<NUMBER>" \
  --body "$(cat <<'EOF'
## Summary
Implements tests from P5 issue #<NUMBER>.

Closes #<NUMBER>

## Tests Added
- [ ] Integration tests: <count>
- [ ] System/E2E tests: <count>

## Test Results
```
<paste test output summary>
```

## Verification
- [x] All unit tests pass
- [x] All integration tests pass
- [x] E2E tests pass (if applicable)
- [x] No flaky tests introduced

Generated with Claude Code
EOF
)"
```

**Report PR URL to user.**

## Phase 8: Cleanup

### Update Board to Done (P5 Issues)

If working on a P5 test issue:

```bash
# Update status to Done
gh project item-edit \
  --project-id <PROJECT_ID> \
  --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> \
  --single-select-option-id <DONE_OPTION_ID>

echo "Issue #<NUMBER> marked as Done"
```

### Worktree Cleanup

After PR is merged (or if abandoning work):

```bash
# Return to main repo
~/.local/bin/git-worktree-workflow main

# Clean up merged worktrees
~/.local/bin/git-worktree-workflow cleanup
```

**Without worktree script:**
```bash
cd /path/to/main/repo
git checkout master
git branch -d $BRANCH  # Only if merged
```

## Commands Reference

| Usage | Description |
|-------|-------------|
| `/test` | Interactive - asks what type of testing task |
| `/test #123` | Implement tests from P5 issue #123 |
| `/test run` | Run the full test suite |
| `/test fix` | Fix failing tests |
| `/test <path>` | Write tests for specific file/directory |

## Execution Checklist

Before reporting completion:

- [ ] Worktree context validated
- [ ] Project test config detected
- [ ] Test task identified (P5 issue or ad-hoc)
- [ ] Board updated to "In Progress" (if P5)
- [ ] Worktree created for test branch
- [ ] Tests implemented per plan
- [ ] All tests passing (unit + integration + E2E)
- [ ] PR created with test summary
- [ ] Board updated to "Done" (if P5)
- [ ] PR URL reported to user

## Test Type Guidelines

| Test Type | Speed | Dependencies | When to Write |
|-----------|-------|--------------|---------------|
| Unit | < 1s each | Mocked | During `/issue` (always) |
| Integration | 1-10s each | Real DB/services | During `/test` (P5 issues) |
| System/E2E | 10-60s each | Full stack | During `/test` (critical flows) |

## Anti-Patterns to AVOID

- **Skipping worktree validation** - Always validate first
- **Working in main repo** - Use worktrees for isolation
- **Writing integration tests during /issue** - Those belong here in /test
- **Mixing test fixes with production fixes** - Tests only in this workflow
- **Skipping cleanup** - Always update board and clean worktrees
- **Committing failing tests** - All tests must pass before PR
