---
description: Development workflow - implement features, fix bugs, write tests, review code. Spawns specialized workers for each phase.
---

# Development Workflow

You are orchestrating a development workflow. You will spawn specialized worker agents directly using the Task tool.

## Your Task

$ARGUMENTS

## Workflow Selection

Based on the task, choose the appropriate workflow:

### New Feature Implementation
1. **code-writer** (sonnet) - Implement the feature
2. **test-automator** (sonnet) - Add comprehensive tests
3. **code-reviewer** (opus) - Review for quality and security

### Bug Fix
1. **debugger** (opus) - Diagnose root cause
2. **code-writer** (sonnet) - Implement the fix
3. **test-automator** (sonnet) - Add regression test

### Code Refactoring
1. **test-automator** (sonnet) - Ensure test coverage exists
2. **code-writer** (sonnet) - Perform refactoring
3. **code-reviewer** (opus) - Verify no regressions

### Quick Implementation (small changes)
1. **code-writer** (sonnet) - Implement directly
2. Verify with type-check and lint

## How to Spawn Workers

Use the Task tool with these configurations:

### code-writer
```
Task(
  subagent_type: "code-writer",
  model: "sonnet",
  description: "code-writer: <brief task>",
  prompt: "<implementation details with project context>"
)
```

### code-reviewer
```
Task(
  subagent_type: "code-reviewer",
  model: "opus",
  description: "code-reviewer: <brief task>",
  prompt: "<what to review, focus areas>"
)
```

### debugger
```
Task(
  subagent_type: "debugger",
  model: "opus",
  description: "debugger: <brief task>",
  prompt: "<bug description, symptoms, affected areas>"
)
```

### test-automator
```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: <brief task>",
  prompt: "<what to test, coverage expectations>"
)
```

## Quality Gates

Before reporting completion, verify:
- [ ] All tests pass (`npm test` or equivalent)
- [ ] No type errors (`npm run typecheck` if TypeScript)
- [ ] No lint errors (`npm run lint`)
- [ ] Code reviewed (for features, not quick fixes)

## Project Context

Read the project's `CLAUDE.md` for:
- Tech stack and framework patterns
- Database access patterns
- Code organization conventions
- Testing framework and patterns

## Git Workflow

After code changes:
- Changes should be on a feature branch, not main/master
- Use `/git` command for commits and PRs
- Never push directly to main/master

## Execution

1. Analyze the task to determine workflow type
2. Read project CLAUDE.md for context
3. Spawn workers in sequence (wait for each to complete)
4. Verify quality gates
5. Report completion with summary
