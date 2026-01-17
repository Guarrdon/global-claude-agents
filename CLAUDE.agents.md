# Global Claude Agents System

This file defines the agent system for Claude Code. It is automatically loaded and provides instructions for agent invocation, model selection, and workflow patterns.

---

## Agent System Overview

This system uses a **hierarchical agent architecture**:

```
User Request
    ↓
global-manager (entry point)
    ↓
domain-manager (dev, project, discovery, environment)
    ↓
worker (code-writer, debugger, explorer, etc.)
```

**Core Principles:**
1. **Managers orchestrate, workers execute** - Managers never write code directly
2. **Two-level hierarchy** - global-manager → domain-manager → worker
3. **Model tiering** - Use the right model for the task complexity

---

## Model Tiering (CRITICAL)

When spawning agents via the Task tool, you **MUST** use the correct model:

| Model | Cost | Use For | Agents |
|-------|------|---------|--------|
| **opus** | $$$ | Deep analysis, complex debugging, security review | code-reviewer, debugger |
| **sonnet** | $$ | Standard development, coordination | All managers, most workers |
| **haiku** | $ | Fast exploration, simple operations | explorer, git-manager |

### How to Determine the Model

1. **Read the agent file** before spawning (if unsure)
2. **Parse the YAML frontmatter** at the top (between `---` markers)
3. **Extract the `model` field** value
4. **Pass that value** to the Task tool's `model` parameter

### Worker-to-Model Quick Reference

**Opus (expensive, critical analysis):**
- `code-reviewer` - Code quality, security review
- `debugger` - Complex bug diagnosis

**Sonnet (standard, most work):**
- All managers (`global-manager`, `dev-manager`, `project-manager`, etc.)
- `code-writer`, `test-automator`, `refactorer`
- `infra-engineer`, `cloud-engineer`, `deploy-engineer`, `db-engineer`
- `researcher`, `doc-writer`, `analyst`, `product-analyst`
- All language specialists

**Haiku (fast, simple tasks):**
- `explorer` - Codebase exploration (maps to `Explore` subagent_type)
- `git-manager` - Git operations

---

## Agent Invocation Pattern

When spawning agents via the Task tool:

```
Task tool with:
  - subagent_type: "general-purpose" (or "Explore" for explorer)
  - model: "<model from agent's frontmatter>"
  - description: "<agent-name>: <brief task>"
  - prompt: [detailed instructions]
```

### Agent Name Display (IMPORTANT)

**Always prefix the description with the agent name** so it shows in the terminal:

```
// Good - agent name visible
description: "code-writer: implement login"
description: "explorer: find auth files"
description: "debugger: trace null error"

// Bad - no agent context
description: "implement login feature"
description: "find authentication files"
```

**Format:** `"<agent-name>: <brief task>"`

---

## Manager Inventory

### Global Managers (`~/.claude/agents/managers/`)

| Manager | Model | Purpose | Delegates To |
|---------|-------|---------|--------------|
| `global-manager` | sonnet | Entry point, routes all requests | All other managers |
| `dev-manager` | sonnet | Code writing, review, debugging, testing | code-writer, code-reviewer, debugger, test-automator, refactorer |
| `project-manager` | sonnet | Git, docs, task tracking | git-manager, doc-writer, analyst |
| `discovery-manager` | sonnet | Codebase exploration, research | explorer, researcher |
| `environment-manager` | sonnet | Infrastructure, deployment, databases | infra-engineer, cloud-engineer, deploy-engineer, db-engineer |

### Project Managers (`<project>/.claude/agents/managers/`)

| Manager | Model | Purpose | Delegates To |
|---------|-------|---------|--------------|
| `business-manager` | sonnet | Requirements, priorities, domain logic | analyst, product-analyst |
| `technical-manager` | sonnet | Architecture, patterns, implementation | code-writer, code-reviewer, language specialists |
| `deploy-manager` | sonnet | Project-specific deployment workflows | deploy-engineer, infra-engineer |

---

## Worker Inventory

### Development Workers

| Worker | Model | Purpose |
|--------|-------|---------|
| `code-writer` | sonnet | Write new code, implement features |
| `code-reviewer` | **opus** | Review code for quality, security, patterns |
| `debugger` | **opus** | Diagnose and fix bugs |
| `test-automator` | sonnet | Write and run tests |
| `refactorer` | sonnet | Improve code structure |

### Infrastructure Workers

| Worker | Model | Purpose |
|--------|-------|---------|
| `infra-engineer` | sonnet | CI/CD, automation, infrastructure |
| `cloud-engineer` | sonnet | Cloud architecture, IaC |
| `deploy-engineer` | sonnet | Deployment pipelines, releases |
| `db-engineer` | sonnet | Database design, queries, optimization |

### Research Workers

| Worker | Model | Purpose |
|--------|-------|---------|
| `explorer` | haiku | Fast codebase exploration |
| `researcher` | sonnet | In-depth research, analysis |
| `doc-writer` | sonnet | Documentation, guides, READMEs |

### Project Workers

| Worker | Model | Purpose |
|--------|-------|---------|
| `git-manager` | haiku | Git operations, branching, PRs |
| `analyst` | sonnet | Requirements analysis |
| `product-analyst` | sonnet | Feature prioritization, user stories |

### Language Specialists (On-Demand)

| Worker | Model | When to Use |
|--------|-------|-------------|
| `typescript-specialist` | sonnet | Deep TypeScript/JavaScript work |
| `python-specialist` | sonnet | Python-specific implementation |
| `sql-specialist` | sonnet | Complex SQL queries |
| `react-specialist` | sonnet | React patterns, hooks |
| `nextjs-specialist` | sonnet | Next.js specific features |

---

## Routing Rules

When a user makes a request, route based on the request type:

| Request Type | Route To |
|--------------|----------|
| Write code, fix bugs, review code, write tests | `dev-manager` |
| Git operations, documentation, task tracking | `project-manager` |
| Explore codebase, research questions, find files | `discovery-manager` |
| Infrastructure, deployment, databases, CI/CD | `environment-manager` |
| Business requirements, priorities, domain questions | `business-manager` (project) |
| Architecture decisions, technical patterns | `technical-manager` (project) |
| Project-specific deployment | `deploy-manager` (project) |

---

## Git Workflow (CRITICAL)

**All code changes MUST go through Pull Requests.** This applies to ALL workers that modify code.

### Required Workflow

1. **Create feature branch** - Never work on main/master directly
2. **Commit changes** to the feature branch
3. **Create PR** via `gh pr create`
4. **Merge via PR** - Not direct push to master

### Why This Matters

- Direct pushes to master trigger CI/CD deployment immediately
- PRs allow for review and controlled merges
- This applies to ALL changes, even "simple" fixes

### Branch Naming Convention

| Work Type | Prefix | Example |
|-----------|--------|---------|
| New feature | `feature/` | `feature/add-dark-mode` |
| Bug fix | `fix/` | `fix/login-validation-error` |
| Documentation | `docs/` | `docs/api-endpoints` |
| Refactoring | `refactor/` | `refactor/auth-module` |
| Testing | `test/` | `test/unit-coverage` |

### Only Exception

Direct master commits only allowed when user explicitly requests a "critical hotfix" for production emergencies.

---

## Project-Specific Overrides

**IMPORTANT:** Always check for project-specific configuration:

1. Project's `CLAUDE.md` file (root of repo)
2. Project's `.claude/agents/` directory

Project configurations may include:
- Custom agents and workflows
- Worktree-based development
- Custom scripts (e.g., `scripts/git-workflow.sh`)
- Specific branch protection rules

**When a project has local rules, those take precedence over these global defaults.**

---

## Example Invocations

### Spawning code-reviewer (opus):
```
Task tool with:
  - subagent_type: "general-purpose"
  - model: "opus"
  - description: "code-reviewer: review auth changes"
  - prompt: "Review the authentication changes in src/auth/..."
```

### Spawning explorer (haiku):
```
Task tool with:
  - subagent_type: "Explore"
  - model: "haiku"
  - description: "explorer: find API endpoints"
  - prompt: "Find all API endpoint definitions in the codebase"
```

### Spawning dev-manager (sonnet):
```
Task tool with:
  - subagent_type: "general-purpose"
  - model: "sonnet"
  - description: "dev-manager: implement login feature"
  - prompt: "Coordinate implementation of login feature..."
```

---

## Critical Rules Summary

1. **Never default to a single model** - Always check the agent's specification
2. **Cost matters** - Opus is expensive, only use where specified
3. **Speed matters** - Haiku is fast, use for exploration and simple git ops
4. **Read before spawn** - If unsure, read the agent file to check its model field
5. **Always use PRs** - Never push directly to main/master
6. **Project rules override global** - Check for project-specific configuration
