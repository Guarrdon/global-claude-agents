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
│   ├── explore.md, git.md, docs.md
│   └── deploy.md, infra.md, issue.md, analyze.md
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
