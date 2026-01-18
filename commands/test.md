---
description: Testing workflow - write and run tests with comprehensive coverage.
---

# Testing Workflow

You are orchestrating a testing task. You will spawn a test-automator agent to write and run tests.

## Your Task

$ARGUMENTS

## Workflow Options

### Write New Tests
For adding test coverage to existing code:

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: add tests for <target>",
  prompt: """
    Write comprehensive tests for the specified code.

    ## Target
    <files/functions to test>

    ## Testing Strategy

    ### Unit Tests
    - Test individual functions in isolation
    - Mock external dependencies
    - Cover happy path and edge cases
    - Test error handling

    ### Integration Tests (if applicable)
    - Test component interactions
    - Test API endpoints
    - Test database operations

    ## Test Quality Standards
    - Descriptive test names that explain what's being tested
    - Arrange-Act-Assert pattern
    - One assertion concept per test
    - Independent tests (no shared state)

    ## Project Context
    Read CLAUDE.md for:
    - Testing framework (Jest, Vitest, Playwright, etc.)
    - Test file locations and naming conventions
    - Mocking patterns
    - Test database setup

    ## Deliverables
    - Test files with comprehensive coverage
    - All tests passing
    - Coverage summary
  """
)
```

### Run Existing Tests
For running the test suite:

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: run test suite",
  prompt: """
    Run the project's test suite and report results.

    ## Tasks
    1. Identify the test command (check package.json or CLAUDE.md)
    2. Run the full test suite
    3. Report results with:
       - Total tests passed/failed
       - Failed test details with error messages
       - Coverage summary if available

    ## If Tests Fail
    - Analyze failure patterns
    - Identify likely causes
    - Suggest fixes or further investigation
  """
)
```

### Fix Failing Tests
For fixing broken tests:

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: fix failing tests",
  prompt: """
    Fix the failing tests in this project.

    ## Approach
    1. Run tests to identify failures
    2. Analyze each failure:
       - Is the test wrong? (update test)
       - Is the code wrong? (flag for /debug or /dev)
       - Is it a flaky test? (fix reliability)
    3. Fix test issues
    4. Re-run to verify

    ## Important
    - Only fix test issues, not production code
    - If production code is buggy, report it for /debug workflow
    - Maintain test intent - don't just make tests pass incorrectly
  """
)
```

## Quality Gates

Before reporting completion:
- [ ] All tests pass
- [ ] New tests follow project conventions
- [ ] Coverage maintained or improved
- [ ] No flaky tests introduced

## Execution

1. Determine testing task type (write, run, fix)
2. Read project CLAUDE.md for testing conventions
3. Spawn test-automator with appropriate prompt
4. Report results with coverage summary
