---
description: Audit workflow - functional audit of feature specs, optional deep UX audit. Documents findings and creates GitHub issues for gaps.
---

# Audit Workflow

You are orchestrating an audit workflow. You will spawn specialized auditor agents, document findings, and create GitHub issues for any gaps or problems discovered.

## Your Task

$ARGUMENTS

## Audit Type Detection

Determine the audit type from the user's request:

### Standard Audit (default)
Spawn **functional-auditor** only. Used when:
- No special keywords mentioned
- User just says "audit [feature]"
- Focus is on specs/requirements compliance

### Deep/UX Audit
Spawn **both** ux-auditor AND functional-auditor. Used when user mentions:
- "deep audit"
- "experience audit"
- "user audit"
- "UX audit"
- "full audit"
- "comprehensive audit"
- Any emphasis on user perspective or experience

## Workflow Phases

### Phase 1: Context Gathering
Before spawning auditors:
1. Read project `CLAUDE.md` for context
2. Identify the feature/area to audit
3. Find any existing specs, requirements, or documentation
4. Determine audit scope

### Phase 2: Audit Execution

#### Standard Audit Sequence:
```
1. functional-auditor → Audit report
2. doc-writer → Document in docs/audit/
3. git-manager → Create issues for gaps (if any)
```

#### Deep/UX Audit Sequence:
```
1. ux-auditor → UX audit report (opus model)
2. functional-auditor → Functional audit report
3. doc-writer → Document combined findings in docs/audit/
4. git-manager → Create issues for all gaps (if any)
```

### Phase 3: Documentation
After audits complete, spawn doc-writer to create documentation:

**Output location:** `docs/audit/[feature-name]-audit-[date].md`

Documentation should include:
- Audit metadata (date, type, feature)
- Executive summary
- Detailed findings from each audit
- Combined recommendations
- Issues to be created

### Phase 4: Issue Creation
If gaps or issues were identified, spawn git-manager to:
- Create GitHub issues for each identified gap/problem
- Apply appropriate labels (bug, enhancement, accessibility, etc.)
- Set priority based on severity
- Link issues in audit documentation

## How to Spawn Agents

### functional-auditor
Use the `analyst` subagent_type (read-only analysis tools).
First read `~/.claude/agents/functional-auditor.md` for full instructions.
```
Task(
  subagent_type: "analyst",
  model: "sonnet",
  description: "functional-auditor: audit [feature]",
  prompt: """
    You are a **functional-auditor**. Read ~/.claude/agents/functional-auditor.md for your full role and output format.

    Conduct a functional audit of [feature].

    ## Feature Context
    [Feature description and location]

    ## Known Specs/Requirements
    [Any documented requirements]

    ## Scope
    [What to audit]

    Provide a comprehensive audit report following the functional-auditor output format.
    Include specific issues to create for any gaps found.
  """
)
```

### ux-auditor (for deep audits only)
Use the `code-reviewer` subagent_type (has Bash for running accessibility checks).
First read `~/.claude/agents/ux-auditor.md` for full instructions.
```
Task(
  subagent_type: "code-reviewer",
  model: "opus",
  description: "ux-auditor: deep audit [feature]",
  prompt: """
    You are a **ux-auditor**. Read ~/.claude/agents/ux-auditor.md for your full role and output format.

    Conduct a deep user experience audit of [feature].

    ## Feature Context
    [Feature description and location]

    ## User Flows to Analyze
    [Primary user journeys involving this feature]

    ## Scope
    [What to audit from UX perspective]

    Provide a comprehensive UX audit report following the ux-auditor output format.
    Include specific issues to create for any UX gaps found.
  """
)
```

### doc-writer (documentation phase)
```
Task(
  subagent_type: "doc-writer",
  model: "sonnet",
  description: "doc-writer: document audit findings",
  prompt: """
    Create audit documentation in docs/audit/

    ## Audit Results
    [Include findings from auditor(s)]

    ## Documentation Requirements
    - Create file: docs/audit/[feature-name]-audit-[YYYY-MM-DD].md
    - Include executive summary
    - Include all findings and recommendations
    - List all issues to be created
    - Ensure docs/audit/ directory exists

    Follow standard documentation format.
  """
)
```

### git-manager (issue creation phase)
```
Task(
  subagent_type: "git-manager",
  model: "haiku",
  description: "git-manager: create audit issues",
  prompt: """
    Create GitHub issues for the following audit findings:

    ## Issues to Create
    [List each issue with title, type, priority, description]

    ## Requirements
    - Use gh cli to create issues
    - Apply appropriate labels
    - Include audit report reference in issue body
    - Do NOT push any code changes

    Report back the created issue numbers.
  """
)
```

## Quality Gates

Before completing:
- [ ] Appropriate auditor(s) spawned based on audit type
- [ ] Audit documentation created in docs/audit/
- [ ] GitHub issues created for all identified gaps
- [ ] Summary provided to user

## Project Context

Check the project's `CLAUDE.md` for:
- Feature locations and patterns
- Existing documentation standards
- GitHub issue conventions
- Any project-specific audit requirements

## Execution Summary

1. Parse task to determine audit type (standard vs deep)
2. Gather context about feature to audit
3. Spawn auditor(s) sequentially, collect reports
4. Spawn doc-writer to create audit documentation
5. If issues identified, spawn git-manager to create them
6. Report summary to user with:
   - Audit pass/fail status
   - Link to audit documentation
   - List of created issue numbers

## Output to User

After completion, provide:
```
## Audit Complete

**Feature:** [Feature name]
**Type:** [Standard/Deep UX] Audit
**Result:** [Pass/Pass with observations/Fail]

### Summary
[Key findings in 2-3 sentences]

### Documentation
Created: docs/audit/[filename].md

### Issues Created
- #[number]: [title]
- #[number]: [title]

### Next Steps
[Recommendations based on findings]
```
