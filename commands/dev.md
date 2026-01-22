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

## Phase 0: Discovery (MANDATORY before spawning workers)

**Before spawning ANY implementation worker, complete this discovery phase.**

### Step 1: Load Worker Context

```bash
# Read the condensed worker context (if it exists)
cat WORKER_CONTEXT.md 2>/dev/null
```

From WORKER_CONTEXT.md (or CLAUDE.md if not available), understand:
- **CI/CD process** - How do deployments work? What will happen when this merges?
- **Critical constraints** - Database patterns, no-ORM rule, Server Components preference
- **Key file locations** - Where should this code live?

### Step 2: Explore Related Code

**For any non-trivial task**, spawn an explorer first:

```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: find related code for <task>",
  prompt: """
    Explore the codebase to understand existing patterns for this task:

    Task: <TASK_DESCRIPTION>

    Find and report:
    1. Similar features/code that already exist
    2. Patterns used in those files (naming, structure, imports)
    3. Database tables involved (if any)
    4. API routes affected (if any)
    5. Components that might need updates
    6. Files that import/depend on areas being changed

    This context will be passed to the code-writer.
  """
)
```

### Step 3: Verify CI/CD Readiness

Before implementation, confirm understanding of:
- [ ] Build will pass after changes (`npm run build`)
- [ ] Type check will pass (`npm run typecheck`)
- [ ] No breaking changes to health check endpoints
- [ ] Database changes (if any) have a plan

### Step 4: Document Discovery Summary

```
## Discovery Summary

### Task Understanding
- What needs to be built/changed: <summary>
- Why: <business/technical reason>

### Existing Patterns Found
- Pattern 1: <file> - <how it's done>
- Pattern 2: <file> - <how it's done>

### Files to Create/Modify
- <file> - <what to do>

### CI/CD Impact
- Build risk: Low/Medium/High
- Breaking changes: None/Backwards-compatible/Breaking

### Dependencies
- Files that depend on changes: <list>
- External dependencies: <if any>
```

**ONLY AFTER discovery is complete → proceed to spawn workers**

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

**Read in this order:**

1. **WORKER_CONTEXT.md** (if exists) - Condensed quick-reference with CI/CD summary
2. **CLAUDE.md** - Full project configuration and patterns

Key information to extract:
- CI/CD process (what happens when code merges to master)
- Tech stack and framework patterns
- Database access patterns (PostgreSQL, executeQuery())
- Code organization conventions
- Testing strategy (smoke validation vs comprehensive)

## Git Workflow

After code changes:
- Changes should be on a feature branch, not main/master
- Use `/git` command for commits and PRs
- Never push directly to main/master

## Execution

1. Analyze the task to determine workflow type
2. **DISCOVERY PHASE (mandatory):**
   - Read WORKER_CONTEXT.md and/or CLAUDE.md
   - Spawn explorer to find related code and patterns
   - Understand CI/CD implications
   - Document discovery summary
3. Spawn workers in sequence (wait for each to complete)
   - Pass discovery context to each worker
4. Verify quality gates
5. Report completion with summary

**Critical:** Do NOT skip the discovery phase. Workers without context produce inconsistent results.
