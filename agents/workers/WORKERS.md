# Curated Workers

This document maps our curated worker names to Claude Code's built-in agents.

## Principle

Managers only delegate to workers in this list. This keeps the system:
- **Predictable** - Limited, known set of capabilities
- **Maintainable** - Easy to understand and update
- **Efficient** - No decision fatigue from 100+ options

## CRITICAL: Git Workflow Rule

**All code changes MUST go through Pull Requests.** This applies to ALL workers that modify code.

Workers must:
1. Create a feature branch (never work on main/master)
2. Commit changes to the feature branch
3. Create a PR via `gh pr create`
4. Merge via PR (not direct push to master)

Direct pushes to master trigger CI/CD immediately. Only exception: explicit "critical hotfix" requests.

---

## Development Workers

| Curated Name | Maps To | Model | Purpose |
|--------------|---------|-------|---------|
| `code-writer` | `fullstack-developer` | sonnet | Write new code, implement features |
| `code-reviewer` | `code-reviewer` | **opus** | Review code for quality, security, patterns |
| `debugger` | `debugger` | **opus** | Diagnose and fix bugs |
| `test-automator` | `test-automator` | sonnet | Write and run tests |
| `refactorer` | `refactoring-specialist` | sonnet | Improve code structure without changing behavior |

## Infrastructure Workers

| Curated Name | Maps To | Model | Purpose |
|--------------|---------|-------|---------|
| `infra-engineer` | `devops-engineer` | sonnet | CI/CD, automation, infrastructure |
| `cloud-engineer` | `cloud-architect` | sonnet | Cloud architecture, IaC (Terraform, CloudFormation) |
| `deploy-engineer` | `deployment-engineer` | sonnet | Deployment pipelines, releases |
| `db-engineer` | `postgres-pro` | sonnet | Database design, queries, optimization |

## Research Workers

| Curated Name | Maps To | Model | Purpose |
|--------------|---------|-------|---------|
| `explorer` | `Explore` | haiku | Fast codebase exploration |
| `researcher` | `research-analyst` | sonnet | In-depth research, analysis |
| `doc-writer` | `technical-writer` | sonnet | Documentation, guides, READMEs |

## Project Workers

| Curated Name | Maps To | Model | Purpose |
|--------------|---------|-------|---------|
| `git-manager` | `Bash` (general-purpose) | haiku | Git operations, branching, PRs |
| `analyst` | `business-analyst` | sonnet | Requirements analysis, process improvement |
| `product-analyst` | `product-manager` | sonnet | Feature prioritization, user stories |

> **Note:** `git-manager` has a dedicated worker file at `~/.claude/agents/workers/git-manager.md` with detailed instructions for handling project-specific git workflows (worktrees, custom scripts, etc.).

## Language Specialists (On-Demand)

| Curated Name | Maps To | Model | When to Use |
|--------------|---------|-------|-------------|
| `typescript-specialist` | `typescript-pro` | sonnet | Deep TypeScript/JavaScript work |
| `python-specialist` | `python-pro` | sonnet | Python-specific implementation |
| `sql-specialist` | `sql-pro` | sonnet | Complex SQL queries, optimization |
| `react-specialist` | `react-specialist` | sonnet | React-specific patterns, hooks |
| `nextjs-specialist` | `nextjs-developer` | sonnet | Next.js specific features |

---

## Adding New Workers

To add a new curated worker:

1. Identify the need (a gap in current capabilities)
2. Find the best matching Claude Code agent
3. Add to this document with clear purpose
4. Update relevant manager definitions

## Deprecating Workers

To remove a worker:

1. Ensure no managers reference it
2. Move to "Deprecated" section (don't delete immediately)
3. Remove after confirming no issues
