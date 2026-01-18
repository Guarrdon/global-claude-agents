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

### Phase 3: Regression Test (sonnet)
Add test to prevent bug recurrence:

```
Task(
  subagent_type: "test-automator",
  model: "sonnet",
  description: "test-automator: regression test for <bug>",
  prompt: """
    Add a regression test for this bug fix.

    ## Bug Description
    <what was wrong>

    ## Fix Applied
    <what was changed>

    ## Test Requirements
    - Test that reproduces the original bug condition
    - Verify the fix prevents the issue
    - Cover edge cases identified during diagnosis
  """
)
```

## Quality Gates

Before reporting completion:
- [ ] Root cause identified
- [ ] Fix implemented and verified
- [ ] Regression test added
- [ ] All existing tests still pass
- [ ] No new lint/type errors

## Execution

1. Spawn debugger (opus) for thorough diagnosis
2. Review diagnosis with user if complex
3. Spawn code-writer to implement fix
4. Spawn test-automator for regression test
5. Verify all tests pass
6. Report completion with summary
