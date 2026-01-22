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
2. **Smoke validation** - Verify feature works, document test plan
3. **code-reviewer** (opus) - Review for quality and security
4. **Create test-debt issue** - Track tests for later implementation

### Bug Fix
1. **debugger** (opus) - Diagnose root cause
2. **code-writer** (sonnet) - Implement the fix
3. **Smoke validation** - Verify fix works, document test plan
4. **Create test-debt issue** - Track regression test for later

### Code Refactoring
1. **code-writer** (sonnet) - Perform refactoring
2. **Smoke validation** - Verify behavior unchanged
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

### Smoke Validation (instead of test-automator for most tasks)

For early-stage projects, replace comprehensive testing with smoke validation:

```
## Smoke Validation Checklist
- [ ] Verified change works as expected
- [ ] Checked related functionality still works
- [ ] Build succeeds (npm run build)
- [ ] Type check passes (npm run typecheck)
- [ ] Lint passes (npm run lint)

## Test Plan (Document, don't implement)
- Proposed unit tests: <list>
- Proposed integration tests: <list>
- Edge cases: <list>

## Create Test-Debt Issue
gh issue create --title "Tests: <feature/fix>" --label "test-debt,automated"
```

### test-automator (use sparingly during early development)
```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: <brief task>",
  prompt: "<what to test, coverage expectations>"
)
```

**When to use test-automator:** Only when project has reached functional completeness milestone, or for critical path functionality that MUST have tests before merge.

## Quality Gates

Before reporting completion, verify:
- [ ] Smoke validation passed
- [ ] No type errors (`npm run typecheck` if TypeScript)
- [ ] No lint errors (`npm run lint`)
- [ ] Test plan documented
- [ ] Test-debt issue created (if applicable)
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
