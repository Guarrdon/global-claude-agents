---
description: Code review workflow - thorough review for quality, security, and best practices using opus model.
---

# Code Review Workflow

You are orchestrating a code review. You will spawn a code-reviewer agent using the opus model for deep analysis.

## Your Task

$ARGUMENTS

## What to Review

If not specified, review:
- Recent git changes (`git diff HEAD~1` or staged changes)
- Specific files mentioned in the task
- PR changes if a PR number is provided

## How to Spawn Code Reviewer

```
Task(
  subagent_type: "code-reviewer",
  model: "opus",
  description: "code-reviewer: <what's being reviewed>",
  prompt: """
    You are a senior code reviewer. Review the following for quality, security, and best practices.

    ## Review Focus
    <specific concerns if any>

    ## Files to Review
    <list of files or "recent changes">

    ## Review Checklist

    ### Security (CRITICAL)
    - SQL injection vulnerabilities
    - XSS (cross-site scripting)
    - Command injection
    - Sensitive data exposure
    - Authentication/authorization issues

    ### Code Quality
    - Code clarity and readability
    - Proper error handling
    - Type safety
    - Code duplication

    ### Architecture
    - Follows project patterns
    - Proper separation of concerns
    - Maintainability

    ### Performance
    - Unnecessary database queries
    - N+1 query problems
    - Inefficient algorithms

    ## Output Format

    Provide review in this format:

    ## Code Review Summary

    ### Critical Issues (must fix)
    - [File:Line] Issue description

    ### Warnings (should fix)
    - [File:Line] Issue description

    ### Suggestions (nice to have)
    - [File:Line] Suggestion

    ### Security Concerns
    - List any security issues

    ### Approval Status
    [ ] Approved
    [ ] Approved with comments
    [ ] Changes requested
  """
)
```

## After Review

Based on review findings:
- If changes requested, suggest using `/dev` to implement fixes
- If approved, ready for `/git` to create PR or merge

## Execution

1. Determine what needs to be reviewed
2. Gather the files or changes
3. Spawn code-reviewer with opus model
4. Present review findings to user
5. Suggest next steps based on findings
