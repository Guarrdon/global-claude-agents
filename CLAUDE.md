# Global Claude Code Instructions

These instructions apply to all projects and conversations.

## Agent System Model Enforcement

When invoking agents via the Task tool, you **MUST** respect the model specified in the agent's YAML frontmatter.

### How to Determine the Model

1. **Read the agent file** before spawning it
2. **Parse the YAML frontmatter** at the top of the file (between `---` markers)
3. **Extract the `model` field** value
4. **Pass that value** to the Task tool's `model` parameter

### Model Quick Reference

When spawning agents, use these models:

| Agent Type | Model | Examples |
|------------|-------|----------|
| High-stakes analysis | `opus` | code-reviewer, debugger |
| Standard work | `sonnet` | managers, code-writer, test-automator, researchers |
| Fast/simple tasks | `haiku` | explorer, git-manager |

### Example Invocation Pattern

```
// When spawning code-reviewer (opus worker):
Task tool with:
  - subagent_type: "general-purpose"
  - model: "opus"
  - prompt: [instructions from code-reviewer.md]

// When spawning explorer (haiku worker):
Task tool with:
  - subagent_type: "Explore"
  - model: "haiku"
  - prompt: [exploration task]

// When spawning dev-manager (sonnet manager):
Task tool with:
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - prompt: [instructions from dev-manager.md]
```

### Worker-to-Model Mapping

From `~/.claude/agents/workers/WORKERS.md`:

**Opus (expensive, use for critical analysis):**
- code-reviewer
- debugger

**Sonnet (standard, most work):**
- All managers (global-manager, dev-manager, project-manager, etc.)
- code-writer, test-automator, refactorer
- infra-engineer, cloud-engineer, deploy-engineer, db-engineer
- researcher, doc-writer, analyst, product-analyst
- All language specialists

**Haiku (fast, simple tasks):**
- explorer (maps to Explore subagent_type)
- git-manager

### Critical Rules

1. **Never default to a single model** - always check the agent's specification
2. **Cost matters** - opus is expensive, only use where specified
3. **Speed matters** - haiku is fast, use it for exploration and simple git ops
4. **Read before spawn** - if unsure, read the agent file to check its model field

### Agent Name Display

When spawning agents via the Task tool, **always prefix the description with the agent name** so it shows in the terminal:

```
// Good - agent name is visible in terminal
Task tool with:
  - description: "code-writer: implement login"
  - description: "explorer: find auth files"
  - description: "debugger: trace null error"

// Bad - no agent context visible
Task tool with:
  - description: "implement login feature"
  - description: "find authentication files"
```

**Format:** `"<agent-name>: <brief task>"`

This helps the user see which agent is actively working without reading activity details.

---

## Git Workflow (Global Defaults)

These git workflow principles apply to all projects unless overridden by project-specific CLAUDE.md.

### Core Principles

1. **Always check git status first** at the start of work
2. **Use feature branches** for all non-trivial work (never commit directly to main/master)
3. **One issue = one branch** - tie branches to issues when applicable
4. **Commit WIP before switching** - never leave uncommitted work when changing context

### Branch Naming Convention

| Work Type | Prefix | Example |
|-----------|--------|---------|
| New feature | `feature/` | `feature/add-dark-mode` |
| Bug fix | `fix/` | `fix/login-validation-error` |
| Documentation | `docs/` | `docs/api-endpoints` |
| Refactoring | `refactor/` | `refactor/auth-module` |
| Testing | `test/` | `test/unit-coverage` |

### Standard Workflow

```
1. Check git status
2. Create/switch to appropriate branch
3. Do work
4. Commit with descriptive message
5. Push and create PR
```

### Infer Branch Names

When user describes work, infer the branch name:
- "add user authentication" → `feature/add-user-authentication`
- "fix the login bug" → `fix/login-bug`
- "update the README" → `docs/update-readme`

### Project-Specific Overrides

**IMPORTANT:** Always check for project-specific git workflow in:
1. Project's `CLAUDE.md` file (root of repo)
2. Project's `.claude/` directory

Project workflows may include:
- Worktree-based development (separate directories per branch)
- Custom scripts (e.g., `scripts/git-workflow.sh`)
- Specific branch protection rules
- Required PR templates or processes

**When a project has local git workflow rules, those take precedence over these defaults.**
