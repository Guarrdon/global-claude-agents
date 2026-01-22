---
description: Debug workflow - diagnose bugs using opus model, then fix and add regression tests.
---

# Debug Workflow

You are orchestrating a bug investigation and fix. You will spawn a debugger agent (opus) for deep analysis, then fix with code-writer.

## Your Task

$ARGUMENTS

## Workflow

### Phase 0: Discovery (MANDATORY before diagnosis)

**Before spawning the debugger, gather project context.**

#### Step 1: Load Project Context

```bash
# Read condensed worker context (if exists)
cat WORKER_CONTEXT.md 2>/dev/null

# Or fall back to CLAUDE.md
cat CLAUDE.md 2>/dev/null | head -150
```

Extract and understand:
- **CI/CD process** - What happens when the fix merges?
- **Database patterns** - How are queries structured?
- **Architecture** - Server Components vs Client Components
- **Testing strategy** - Smoke validation vs comprehensive tests

#### Step 2: Quick Exploration

Spawn an explorer to understand the bug's context:

```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: find code related to <bug area>",
  prompt: """
    Quickly explore the codebase to understand this bug's context:

    Bug: <BUG_DESCRIPTION>

    Find:
    1. Files most likely involved in this bug
    2. Recent changes to those files (git log)
    3. Related error handling patterns
    4. Database queries in the affected area
    5. API endpoints involved

    Return a focused list for the debugger to investigate.
  """
)
```

#### Step 3: Document Pre-Debug Context

```
## Pre-Debug Context

### Bug Area
- Primary files: <list>
- Related subsystems: <list>

### Project Patterns
- Database access: <pattern used>
- Error handling: <pattern used>
- Relevant constraints: <from WORKER_CONTEXT.md>

### CI/CD Consideration
- Fix must not break: <build/typecheck/health>
```

**ONLY AFTER discovery → proceed to Phase 1 (Diagnosis)**

### Phase 1: Diagnosis (opus)
Spawn debugger to analyze the bug:

```
Task(
  subagent_type: "debugger",
  model: "opus",
  description: "debugger: <bug summary>",
  prompt: """
    You are a debugging specialist. Diagnose this bug thoroughly.

    ## Bug Description
    <bug details from user>

    ## Symptoms
    <error messages, unexpected behavior>

    ## Debugging Methodology

    1. **Reproduce** - Confirm the bug can be reproduced
    2. **Gather Information** - Read error logs, check recent changes
    3. **Form Hypotheses** - List possible causes ranked by likelihood
    4. **Trace Execution** - Follow code path from entry point
    5. **Identify Root Cause** - Pinpoint exact location and WHY it fails
    6. **Propose Fix** - Design minimal fix with side effect analysis

    ## Output Format

    ## Bug Analysis

    ### Issue Summary
    <brief description>

    ### Reproduction Steps
    1. <step>
    2. <step>

    ### Root Cause Analysis
    <detailed explanation of why the bug occurs>

    ### Affected Files
    - file:line - description

    ### Proposed Fix
    <code or description of minimal fix>

    ### Regression Test
    <test to prevent recurrence>
  """
)
```

### Phase 2: Fix (sonnet)
After diagnosis, spawn code-writer to implement the fix:

```
Task(
  subagent_type: "code-writer",
  model: "sonnet",
  description: "code-writer: fix <bug summary>",
  prompt: """
    Implement this bug fix based on the diagnosis.

    ## Root Cause
    <from debugger analysis>

    ## Files to Modify
    <from debugger analysis>

    ## Fix Description
    <from debugger analysis>

    ## Requirements
    - Minimal changes only
    - Follow existing code patterns
    - Add appropriate error handling
    - Do not refactor unrelated code
  """
)
```

### Phase 3: Smoke Validation & Test Planning
Instead of implementing regression tests, validate the fix and document tests for later:

```
## Smoke Validation Checklist
- [ ] Verified fix resolves the issue
- [ ] Checked related functionality still works
- [ ] No console errors / server errors introduced
- [ ] Build succeeds (npm run build)
- [ ] Type check passes (npm run typecheck)

Validation method: <describe what you did>
```

```
## Test Plan Documentation (don't implement, just document)

### Proposed Regression Tests
- [ ] Test: <test that reproduces original bug condition>
- [ ] Test: <verify the fix prevents the issue>
- [ ] Test: <edge case from diagnosis>

### Notes
- Priority: Critical/Standard/Nice-to-have
- Parallelization safe: Yes/No
```

```
## Create Test-Debt Issue

gh issue create \
  --title "Tests: <bug summary>" \
  --label "test-debt,automated" \
  --body "Tracks regression test for fix in #<ORIGINAL>. See test plan above."
```

**Why this approach:** During early development, focus on shipping fixes quickly with smoke validation. Test implementation is batched and scheduled at functional completeness milestones.

## Quality Gates

Before reporting completion:
- [ ] Root cause identified
- [ ] Fix implemented and verified
- [ ] Smoke validation passed
- [ ] Build and type check passing
- [ ] Test plan documented
- [ ] Test-debt issue created
- [ ] No new lint/type errors

## Execution

1. **DISCOVERY PHASE (mandatory):**
   - Read WORKER_CONTEXT.md and/or CLAUDE.md for project context
   - Spawn explorer to find related code and patterns
   - Understand CI/CD implications
   - Document pre-debug context
2. Spawn debugger (opus) for thorough diagnosis
   - Pass discovery context to debugger
3. Review diagnosis with user if complex
4. Spawn code-writer to implement fix
   - Pass debugger findings AND discovery context
5. Perform smoke validation (verify fix works)
6. Document test plan
7. Create test-debt issue
8. Report completion with summary

**Critical:** The discovery phase helps the debugger focus on the right areas and ensures the fix follows project patterns.
