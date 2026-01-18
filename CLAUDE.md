# Global Claude Code Instructions

These instructions apply to all projects and conversations.

## Slash Commands

Use these commands to trigger specialized workflows. Each spawns worker agents with appropriate models.

| Command | Purpose | Workers |
|---------|---------|---------|
| `/dev` | Development (implement, test, review) | code-writer, test-automator, code-reviewer |
| `/review` | Code review | code-reviewer (opus) |
| `/debug` | Bug investigation and fix | debugger (opus), code-writer, test-automator |
| `/test` | Write and run tests | test-automator |
| `/explore` | Search codebase | explorer (haiku, Explore type) |
| `/git` | Git operations (branches, PRs) | git-manager (haiku) |
| `/docs` | Documentation | doc-writer |
| `/deploy` | Deployment | deploy-engineer |
| `/infra` | Infrastructure (DB, CI/CD, cloud) | db-engineer, cloud-engineer, infra-engineer |
| `/issue` | GitHub issue resolution | github-issue-resolver |
| `/analyze` | Business/technical analysis | analyst, product-analyst, researcher |

### Model Usage

| Model | Cost | Use For |
|-------|------|---------|
| **opus** | $$$ | Deep analysis: /review, /debug |
| **sonnet** | $$ | Development: /dev, /test, /docs, /deploy, /infra, /issue, /analyze |
| **haiku** | $ | Fast tasks: /explore, /git |

### Key Rules

1. **Use slash commands** to start workflows
2. **All code changes** must go through Pull Requests (never push to main/master)
3. **Check project CLAUDE.md** for project-specific rules that override these

### Technical Details

See `~/.claude/CLAUDE.agents.md` for:
- Worker spawning patterns
- Workflow orchestration
- Git workflow requirements

---

## Personal Instructions

Add your personal global instructions below this line.

---

