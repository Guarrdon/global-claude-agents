---
description: Debug workflow - diagnose bugs using opus model, then fix and add regression tests.
---

# Debug Workflow

You are orchestrating a bug investigation and fix. You will spawn a debugger agent (opus) for deep analysis, then fix with code-writer.

## Your Task

$ARGUMENTS

## Workflow

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

1. Spawn debugger (opus) for thorough diagnosis
2. Review diagnosis with user if complex
3. Spawn code-writer to implement fix
4. Perform smoke validation (verify fix works)
5. Document test plan
6. Create test-debt issue
7. Report completion with summary
