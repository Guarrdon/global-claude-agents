# Claude Agents System

Command-driven workflow architecture for Claude Code.

---

## Architecture

```
User → /command → Claude reads command → Spawns workers via Task tool
```

- Slash commands inject workflow instructions into Claude's context
- Claude orchestrates and spawns appropriate workers
- Workers appear as **visible colored subprocesses**
- Workers cannot spawn other workers (Claude Code limitation)

---

## Worker Agents

### Development (sonnet)
| Worker | Purpose | subagent_type |
|--------|---------|---------------|
| code-writer | Implementation | `code-writer` |
| test-automator | Write/run tests | `test-automator` |
| refactorer | Code improvement | `refactorer` |

### Review & Debug (opus)
| Worker | Purpose | subagent_type |
|--------|---------|---------------|
| code-reviewer | Quality review | `code-reviewer` |
| debugger | Root cause analysis | `debugger` |

### Exploration & Git (haiku)
| Worker | Purpose | subagent_type |
|--------|---------|---------------|
| explorer | Fast codebase search | `Explore` |
| git-manager | Git operations | `git-manager` |

### Infrastructure (sonnet)
| Worker | Purpose | subagent_type |
|--------|---------|---------------|
| db-engineer | Database operations | `db-engineer` |
| deploy-engineer | Deployment | `deploy-engineer` |
| cloud-engineer | Cloud infrastructure | `cloud-engineer` |
| infra-engineer | CI/CD, Docker | `infra-engineer` |

### Analysis (sonnet)
| Worker | Purpose | subagent_type |
|--------|---------|---------------|
| analyst | Requirements analysis | `analyst` |
| product-analyst | Feature prioritization | `product-analyst` |
| researcher | Technical research | `researcher` |
| doc-writer | Documentation | `doc-writer` |

### Audit (sonnet/opus)
| Worker | Purpose | subagent_type | Model |
|--------|---------|---------------|-------|
| functional-auditor | Spec compliance audit | `analyst` | sonnet |
| ux-auditor | User experience audit | `code-reviewer` | opus |

*Note: Auditors use compatible built-in types. Read their .md files for full instructions.*

### Specialized
| Worker | Purpose | subagent_type |
|--------|---------|---------------|
| github-issue-resolver | Issue resolution | `github-issue-resolver` |

---

## Spawning Patterns

### Standard Worker
```
Task(
  subagent_type: "<worker-type>",
  model: "sonnet",
  description: "<worker>: <brief task>",
  prompt: "<details>"
)
```

### Explorer (haiku with Explore type)
```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: <brief task>",
  prompt: "<what to find>"
)
```

### Review/Debug (opus)
```
Task(
  subagent_type: "code-reviewer",  # or "debugger"
  model: "opus",
  description: "<worker>: <brief task>",
  prompt: "<details>"
)
```

### Audit Workers
Read ~/.claude/agents/functional-auditor.md or ux-auditor.md first for full instructions.
```
Task(
  subagent_type: "analyst",  # Uses analyst tools
  model: "sonnet",
  description: "functional-auditor: audit [feature]",
  prompt: "You are a functional-auditor. Read ~/.claude/agents/functional-auditor.md..."
)

Task(
  subagent_type: "code-reviewer",  # For deep/UX audits, uses code-reviewer tools
  model: "opus",
  description: "ux-auditor: deep audit [feature]",
  prompt: "You are a ux-auditor. Read ~/.claude/agents/ux-auditor.md..."
)
```

---

## Workflow Patterns

### Discovery-First Pattern (REQUIRED for all implementation workflows)

**Every workflow that modifies code MUST include a discovery phase:**

```
DISCOVERY → [existing workflow]

Discovery Phase:
1. Read WORKER_CONTEXT.md (condensed project context)
2. Spawn explorer to find related code/patterns
3. Understand CI/CD implications
4. Document findings before proceeding
```

**Why:** Workers without context produce inconsistent results, miss patterns, and don't understand CI/CD implications.

**Sequential** (most common):
```
discovery → code-writer → test-automator → code-reviewer
```

**Parallel** (independent tasks):
```
explorer (find X) ─┬→ synthesize
explorer (find Y) ─┘
```

**Conditional** (based on results):
```
discovery → debugger → simple? → code-writer
                     → complex? → report findings
```

**Audit workflow** (multi-phase):
```
Standard:  functional-auditor → doc-writer → git-manager
Deep/UX:   ux-auditor → functional-auditor → doc-writer → git-manager
```

**Issue Resolution workflow** (`/issue`):
```
0. Validate → git-worktree-workflow validate (ALWAYS FIRST)
1. Detect   → Read project CLAUDE.md for board config
2. Track    → Set issue to "In Progress" on project board
3. Branch   → git-worktree-workflow start <branch> && cd <path>
4. Verify   → git-worktree-workflow validate (confirm in worktree)
5. Fix      → debugger → code-writer → test-automator
6. PR       → Create PR with "Fixes #<number>"
7. Complete → Update board to "Done" (after merge)
```

---

## Project Board Integration

Projects can define GitHub Project Board configuration in their CLAUDE.md:

```yaml
github_project:
  owner: <github-username-or-org>
  number: <project-number>
  project_id: <PROJECT_ID>

  fields:
    status:
      id: <STATUS_FIELD_ID>
      options:
        todo: <OPTION_ID>
        in_progress: <OPTION_ID>
        done: <OPTION_ID>
```

**Commands for board updates:**
```bash
# Get item ID for an issue
gh project item-list <NUMBER> --owner <OWNER> --format json | \
  jq -r '.items[] | select(.content.number == <ISSUE>) | .id'

# Update status
gh project item-edit --project-id <PROJECT_ID> --id <ITEM_ID> \
  --field-id <STATUS_FIELD_ID> --single-select-option-id <OPTION_ID>
```

If no board config exists, workflows skip board updates and warn the user.

---

## Worktree Integration (CRITICAL)

**Always use worktrees for feature development to enable parallel work.**

The global `git-worktree-workflow` command (installed to `~/.local/bin`) provides safe parallel development. Never work on feature branches in the main repo - this causes conflicts between Claude sessions.

### Workflow Commands

```bash
# 1. ALWAYS validate before starting work
git-worktree-workflow validate

# 2. Create worktree for a feature branch
git-worktree-workflow start feat/issue-123-description

# 3. IMPORTANT: cd to the worktree (command outputs the path)
cd /path/to/project-worktrees/feat-issue-123-description

# 4. Verify you're in the worktree
git-worktree-workflow validate

# 5. After PR is merged, cleanup
git-worktree-workflow cleanup
```

### Key Rules

1. **Never work on feature branches in the main repo** - always use worktrees
2. **Always run `validate` first** - it catches violations before they cause problems
3. **Working directory CHANGES** when using worktrees - inform the user
4. **Main repo should always be on main/master** - ready to create new worktrees

### Validation States

| State | Action |
|-------|--------|
| Main repo on main | Ready to create worktree |
| In a worktree | Good - session is isolated |
| Main repo on feature branch | **VIOLATION** - stash, checkout main, create worktree |

### Fallback (if git-worktree-workflow not available)

```bash
git fetch origin && git checkout main && git pull origin main
git worktree add ../project-worktrees/branch-name -b branch-name
cd ../project-worktrees/branch-name
```

---

## Git Workflow (CRITICAL)

**All code changes MUST go through Pull Requests.**

### Creating Feature Branches (Preferred: Worktrees)

**Use `git-worktree-workflow` for isolated parallel development:**

```bash
# Validate, create worktree, and cd to it
git-worktree-workflow validate
git-worktree-workflow start <prefix>/issue-<number>-<slug>
cd <worktree-path>  # Path shown in output
```

### Creating Feature Branches (Fallback: Standard Git)

Only use this if worktrees are not available:

```bash
# 1. Fetch latest from remote
git fetch origin

# 2. Ensure local main is up to date
git checkout main
git pull origin main

# 3. Create feature branch from updated main
git checkout -b <prefix>/issue-<number>-<slug>
```

**Never skip the pull step** - branching from stale local main causes unnecessary merge conflicts.

### Branch Prefixes
| Type | Prefix |
|------|--------|
| Feature | `feature/` |
| Bug fix | `fix/` |
| Config | `config/` |
| Docs | `docs/` |

### PR Workflow
1. Commit changes with descriptive message
2. Push branch: `git push -u origin <branch>`
3. Create PR: `gh pr create`
4. Merge via PR (not direct push)

**Always check project CLAUDE.md** for custom git workflows.

---

## File Structure

```
~/.claude/
├── CLAUDE.md           # Global instructions (quick reference)
├── CLAUDE.agents.md    # This file (technical details)
├── commands/           # Slash command definitions
│   ├── dev.md, review.md, debug.md, test.md
│   ├── explore.md, git.md, docs.md, audit.md
│   ├── deploy.md, infra.md, issue.md, analyze.md
│   └── commands.md     # Lists all available commands
└── agents/             # Worker agent definitions
    └── [worker].md     # Individual worker configs
```

---

## Critical Rules

1. **Use slash commands** to start workflows
2. **DISCOVERY FIRST** - Always run discovery phase before implementation workers
3. **Spawn visible agents** using Task tool with correct subagent_type
4. **Use correct models** - opus for review/debug, haiku for explore/git, sonnet for rest
5. **Read WORKER_CONTEXT.md first** (if exists), then project CLAUDE.md
6. **Use PRs** - never push directly to main/master
7. **Sequential spawning** - wait for each worker to complete before spawning next

---

## Worker Context Files

Projects can provide condensed context for workers:

### WORKER_CONTEXT.md (Project-Level)

A condensed (~100 line) quick-reference containing:
- **CI/CD Process Summary** - How deployments work, what triggers them
- **Critical Constraints** - Database patterns, architecture rules
- **Key Patterns** - File locations, naming conventions
- **Pre-Implementation Checklist** - What to verify before coding

**Workflows should read this BEFORE spawning implementation workers.**

```bash
# Check for worker context
cat WORKER_CONTEXT.md 2>/dev/null || cat CLAUDE.md | head -150
```

If WORKER_CONTEXT.md doesn't exist, fall back to reading the top of CLAUDE.md.
