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

**Sequential** (most common):
```
code-writer → test-automator → code-reviewer
```

**Parallel** (independent tasks):
```
explorer (find X) ─┬→ synthesize
explorer (find Y) ─┘
```

**Conditional** (based on results):
```
debugger → simple? → code-writer
         → complex? → report findings
```

**Audit workflow** (multi-phase):
```
Standard:  functional-auditor → doc-writer → git-manager
Deep/UX:   ux-auditor → functional-auditor → doc-writer → git-manager
```

**Issue Resolution workflow** (`/issue`):
```
1. Detect   → Read project CLAUDE.md for board/worktree config
2. Track    → Set issue to "In Progress" on project board
3. Branch   → Create worktree (or git branch if no worktree script)
4. Fix      → debugger → code-writer → test-automator
5. PR       → Create PR with "Fixes #<number>"
6. Complete → Update board to "Done" (after merge)
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

## Worktree Integration

Projects can use git worktrees for isolated feature work. Check for:

1. **Worktree script**: `scripts/git-workflow.sh`
2. **Worktree config** in project CLAUDE.md

**If worktree script exists:**
```bash
scripts/git-workflow.sh status          # Check current state
scripts/git-workflow.sh switch <branch> # Create/switch worktree
scripts/git-workflow.sh commit-wip      # Save WIP before switching
```

**Key behavior:**
- Working directory CHANGES when switching worktrees
- Always inform user of directory changes
- Auto-commit WIP before switching contexts

If no worktree script, fall back to standard `git checkout -b`.

---

## Git Workflow (CRITICAL)

**All code changes MUST go through Pull Requests.**

1. Create feature branch (never work on main/master)
2. Commit changes
3. Create PR via `gh pr create`
4. Merge via PR (not direct push)

### Branch Prefixes
| Type | Prefix |
|------|--------|
| Feature | `feature/` |
| Bug fix | `fix/` |
| Docs | `docs/` |

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
2. **Spawn visible agents** using Task tool with correct subagent_type
3. **Use correct models** - opus for review/debug, haiku for explore/git, sonnet for rest
4. **Read project CLAUDE.md** - project rules override global defaults
5. **Use PRs** - never push directly to main/master
6. **Sequential spawning** - wait for each worker to complete before spawning next
