---
description: GitHub issue resolver - pick highest priority issue and resolve it completely with testing and documentation.
---

# GitHub Issue Resolver Workflow

You are orchestrating the resolution of a GitHub issue. This workflow handles ONE issue at a time with complete ownership.

## Your Task

$ARGUMENTS

## Workflow Overview

1. **Select** - Pick highest priority open issue
2. **Analyze** - Deep root cause analysis
3. **Plan** - Concrete implementation plan
4. **Implement** - Minimal, scoped fix
5. **Test** - Comprehensive validation
6. **Document** - Complete closure documentation

## How to Spawn Issue Resolver

```
Task(
  subagent_type: "github-issue-resolver",
  model: "sonnet",
  description: "github-issue-resolver: resolve next issue",
  prompt: """
    Resolve the highest priority GitHub issue.

    ## Issue Selection (if not specified)
    1. Query open issues: gh issue list --state open --json number,title,labels
    2. Sort by priority: Critical > High > Medium > Low
    3. Oldest issue as tie-breaker
    4. Select ONE issue only

    ## Project Board Updates (CRITICAL)
    - On start: Update status to "In Progress"
    - On complete: Update status to "Done"

    Reference CLAUDE.md for board field IDs.

    ## Resolution Process

    ### 1. Root Cause Analysis
    - Reproduce the issue
    - Trace code execution
    - Identify exact failure point
    - Understand WHY, not just WHERE

    ### 2. Implementation Plan
    - List exact files to modify
    - Detail logic changes
    - Identify test cases
    - Assess risks

    ### 3. Implementation
    - Minimal changes only
    - Follow existing patterns
    - No scope creep
    - No "while I'm here" changes

    ### 4. Testing
    - Run existing tests
    - Add regression test
    - Verify no regressions

    ### 5. Documentation
    - Root cause summary
    - Fix description
    - Tests added
    - Closing comment

    ## Definition of Done
    - [ ] Root cause identified
    - [ ] Minimal fix implemented
    - [ ] All tests pass
    - [ ] Regression test added
    - [ ] Project board updated to "Done"
    - [ ] GitHub closing comment ready

    ## Anti-Patterns to AVOID
    - Fixing multiple issues at once
    - Refactoring unrelated code
    - "While I'm here" changes
    - Skipping tests
    - Incomplete documentation
  """
)
```

## Specific Issue Resolution

If a specific issue is provided:

```
/issue #123
```

The resolver will:
1. Fetch issue #123 details
2. Update board to "In Progress"
3. Perform full resolution workflow
4. Update board to "Done"
5. Prepare closing comment

## Priority Hierarchy

1. **Critical** - Production broken, data loss, security
2. **High** - Major functionality impaired
3. **Medium** - Minor bugs, UX issues
4. **Low** - Nice-to-have, cosmetic

## Quality Gates

Before marking complete:
- [ ] Root cause verified
- [ ] Fix tested and working
- [ ] No new issues introduced
- [ ] All tests passing
- [ ] Documentation complete
- [ ] Board status updated

## Execution

1. Select issue (highest priority or specified)
2. Update project board to "In Progress"
3. Spawn issue resolver with full context
4. Monitor for completion
5. Verify board updated to "Done"
6. Report resolution summary
