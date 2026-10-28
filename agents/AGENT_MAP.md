# Agent Architecture Map - Flattened Structure

This document defines the agent architecture for Claude Code interactions. There are two setups: command-driven workflows (below) and the [Phased Build](#phased-build).

## Key Concept: Command-Driven Workflows

Instead of a hierarchical manager → worker structure, we use **slash commands** as workflow entry points that spawn workers directly.

```
User → /command → Claude (reads command) → Spawns workers directly
```

**Why this works:**
- Claude (main conversation) CAN spawn multiple subagents
- Subagents can spawn subagents (Claude Code allows nesting), but in this setup workers do not
- Commands inject workflow instructions into Claude's context
- Claude follows instructions to spawn appropriate workers

---

## Phased Build

A second setup, for building a project from a spec in phases, with work run in parallel. It has no slash command of its own. Name the role in a plain session ("spec builder, start the spec", "phase developer, continue"), or invoke the skill as `/spec-builder` or `/phase-developer`.

| Role | Kind | Model | Purpose |
|------|------|-------|---------|
| `spec-builder` | skill (runs in your session) | session model | Writes and changes the spec with you: architecture, interfaces, decisions, security, scale, testing, deployment. Writes no code |
| `phase-developer` | skill (runs in your session) | session model | Plans phases (milestones) and issues, triages issues and bugs, owns branches and worktrees, runs executors and verifiers in parallel, opens the phase PR. The only role that changes the plan |
| `executor` | agent | opus | Builds one issue in its worktree to the issue's done-when checks; commits on that branch |
| `verifier` | agent | opus | Read-only. Answers one question about work it did not write, for an issue or a phase: did it meet the expectation? Yes or no, with the explanation. Builds no tests; runs only functional unit tests, under 30 s |

The two roles are skills because they talk to you and launch subagents. A subagent cannot ask you questions.

Flow:
```
spec branch → spec PR (you merge = spec approved)
phase-N branch ─┬─ feat/issue-a worktree → executor → verifier → merge into phase-N
                ├─ feat/issue-b worktree → executor → verifier → merge into phase-N   (in parallel, up to 3)
                └─ ...
phase-N gate (offline check, verifier on the phase, live run if planned) → phase PR (you merge) → next phase
```

Rules that differ from the command setup:
- GitHub milestones and issues are the plan. Only the phase developer changes them.
- One PR per phase, not per issue. Issue branches merge locally into the phase branch.
- Workers run in parallel, not one at a time.
- Unit tests only during a phase: offline, self-contained, seconds each.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     SLASH COMMANDS                               │
│                   (Workflow Entry Points)                        │
├─────────────────────────────────────────────────────────────────┤
│  /dev      /review    /debug     /test      /explore            │
│  /git      /docs      /deploy    /infra     /issue    /analyze  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    CLAUDE (MAIN CONVERSATION)                    │
│                    Reads command, spawns workers                 │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│  WORKER AGENTS  │ │  WORKER AGENTS  │ │  WORKER AGENTS  │
│   (Task tool)   │ │   (Task tool)   │ │   (Task tool)   │
└─────────────────┘ └─────────────────┘ └─────────────────┘
```

---

## Command Reference

| Command | Purpose | Workers Spawned |
|---------|---------|-----------------|
| `/dev` | Development workflow | code-writer, test-automator, code-reviewer |
| `/review` | Code review | code-reviewer (opus) |
| `/debug` | Bug investigation | debugger (opus), code-writer, test-automator |
| `/test` | Testing workflow | test-automator |
| `/explore` | Codebase exploration | explorer (Explore type, haiku) |
| `/git` | Git operations | git-manager (haiku) |
| `/docs` | Documentation | doc-writer |
| `/deploy` | Deployment | deploy-engineer |
| `/infra` | Infrastructure | db-engineer, cloud-engineer, infra-engineer |
| `/issue` | GitHub issue resolver | github-issue-resolver |
| `/analyze` | Business analysis | analyst, product-analyst, researcher |

---

## Worker Inventory

### Development Workers

| Worker | Model | subagent_type | Tools | Purpose |
|--------|-------|---------------|-------|---------|
| `code-writer` | sonnet | code-writer | Read, Write, Edit, Bash, Glob, Grep | Implement features |
| `code-reviewer` | **opus** | code-reviewer | Read, Bash, Glob, Grep | Review code quality |
| `debugger` | **opus** | debugger | Read, Bash, Glob, Grep | Diagnose bugs |
| `test-automator` | sonnet | test-automator | Read, Write, Edit, Bash, Glob, Grep | Write/run tests |
| `refactorer` | sonnet | general-purpose | Read, Write, Edit, Bash, Glob, Grep | Improve structure |

### Infrastructure Workers

| Worker | Model | subagent_type | Tools | Purpose |
|--------|-------|---------------|-------|---------|
| `db-engineer` | sonnet | general-purpose | Read, Write, Edit, Bash, Glob, Grep | Database operations |
| `deploy-engineer` | sonnet | general-purpose | Read, Bash, Glob, Grep | Execute deployments |
| `cloud-engineer` | sonnet | general-purpose | Read, Write, Edit, Bash, Glob, Grep | Cloud infrastructure |
| `infra-engineer` | sonnet | general-purpose | Read, Write, Edit, Bash, Glob, Grep | CI/CD, Docker |

### Research Workers

| Worker | Model | subagent_type | Tools | Purpose |
|--------|-------|---------------|-------|---------|
| `explorer` | haiku | **Explore** | Read, Bash, Glob, Grep | Fast codebase search |
| `researcher` | sonnet | general-purpose | Read, Glob, Grep, WebSearch, WebFetch | In-depth research |
| `doc-writer` | sonnet | general-purpose | Read, Write, Edit, Glob, Grep | Documentation |

### Project Workers

| Worker | Model | subagent_type | Tools | Purpose |
|--------|-------|---------------|-------|---------|
| `git-manager` | haiku | git-manager | Read, Bash, Glob | Git operations |
| `analyst` | sonnet | general-purpose | Read, Glob, Grep | Requirements analysis |
| `product-analyst` | sonnet | general-purpose | Read, Glob, Grep | Feature prioritization |

### Specialized Workers

| Worker | Model | subagent_type | Purpose |
|--------|-------|---------------|---------|
| `github-issue-resolver` | sonnet | github-issue-resolver | Complete issue resolution |

---

## Model Tiers

| Model | Cost | Use For | Workers |
|-------|------|---------|---------|
| **opus** | $$$ | Deep reasoning, complex analysis | code-reviewer, debugger |
| **sonnet** | $$ | Standard tasks, implementation | Most workers |
| **haiku** | $ | Fast, procedural tasks | explorer, git-manager |

---

## Directory Structure

```
~/.claude/
├── commands/                    # Workflow entry points
│   ├── dev.md                   # /dev - development
│   ├── review.md                # /review - code review
│   ├── debug.md                 # /debug - bug investigation
│   ├── test.md                  # /test - testing
│   ├── explore.md               # /explore - codebase exploration
│   ├── git.md                   # /git - git operations
│   ├── docs.md                  # /docs - documentation
│   ├── deploy.md                # /deploy - deployment
│   ├── infra.md                 # /infra - infrastructure
│   ├── issue.md                 # /issue - GitHub issues
│   └── analyze.md               # /analyze - analysis
├── agents/                      # Worker definitions
│   ├── AGENT_MAP.md             # This file
│   ├── code-writer.md
│   ├── code-reviewer.md
│   ├── debugger.md
│   ├── test-automator.md
│   ├── explorer.md
│   ├── git-manager.md
│   ├── doc-writer.md
│   ├── db-engineer.md
│   ├── deploy-engineer.md
│   ├── cloud-engineer.md
│   ├── infra-engineer.md
│   ├── analyst.md
│   ├── product-analyst.md
│   ├── researcher.md
│   ├── refactorer.md
│   ├── executor.md              # Phased build
│   └── verifier.md              # Phased build
├── skills/
│   ├── spec-builder/SKILL.md    # Phased build role
│   └── phase-developer/SKILL.md # Phased build role
└── CLAUDE.agents.md             # System instructions
```

---

## Usage Examples

### Develop a Feature
```
/dev add user authentication with JWT
```
Claude will:
1. Read `/dev` command instructions
2. Spawn code-writer to implement
3. Spawn test-automator to add tests
4. Spawn code-reviewer to review

### Review Code
```
/review the changes in src/lib/auth.ts
```
Claude will spawn code-reviewer (opus) for deep analysis.

### Debug a Bug
```
/debug the login form validation error
```
Claude will:
1. Spawn debugger (opus) for root cause analysis
2. Spawn code-writer to fix
3. Spawn test-automator for regression test

### Explore Codebase
```
/explore how the AI scoring engine works
```
Claude will spawn explorer (haiku, Explore type) for fast search.

### Git Operations
```
/git create PR for current branch
```
Claude will spawn git-manager (haiku) with project workflow context.

---

## Workflow Patterns

### Sequential (Most Common)
Workers run one at a time, each building on the previous:
```
code-writer → test-automator → code-reviewer
```

### Parallel (Independent Tasks)
Multiple workers for unrelated tasks:
```
explorer (search auth) ─┬─> synthesize
explorer (search api)  ─┘
```

### Conditional
Branch based on findings:
```
debugger → if simple fix → code-writer
         → if complex   → report for discussion
```

---

## Migration from Hierarchical System

| Old (Broken) | New (Works) |
|--------------|-------------|
| `@agent` → global-manager → dev-manager → workers | `/dev` → Claude → workers |
| Managers spawn workers | Claude spawns workers directly |
| 3-level hierarchy | 2-level (command → workers) |
| Invisible worker spawning | Visible colored subprocesses |

---

## Key Principles

1. **Commands are entry points** - Each workflow has a dedicated command
2. **Claude orchestrates** - Main conversation spawns all workers
3. **Workers execute** - Subagents do the actual work
4. **No nesting** - Workers do not spawn other workers (a choice of this setup; Claude Code allows it)
5. **Model tiering** - Use appropriate model for task complexity
6. **Visible progress** - All spawned agents appear as colored subprocesses
