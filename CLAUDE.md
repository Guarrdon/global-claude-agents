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
| `/issue` | GitHub issue resolution (board + worktree + fix + PR) | debugger, code-writer, test-automator, git-manager |
| `/analyze` | Business/technical analysis | analyst, product-analyst, researcher |
| `/audit` | Feature audit (functional + optional UX) | functional-auditor, ux-auditor (opus), doc-writer, git-manager |
| `/release` | Create a release (tag + push → CI/CD) | (direct git commands) |
| `/port` | Local dev port registry, collision check, clean URLs | portwarden skill (direct) |
| `/commands` | List all commands and agents | (none - displays info) |

### Model Usage

| Model | Cost | Use For |
|-------|------|---------|
| **opus** | $$$ | Deep analysis: /review, /debug, /audit (UX only) |
| **sonnet** | $$ | Development: /dev, /test, /docs, /deploy, /infra, /issue, /analyze, /audit |
| **haiku** | $ | Fast tasks: /explore, /git |

### Key Rules

1. **Use slash commands** to start workflows
2. **All code changes** must go through Pull Requests (never push to main/master)
3. **Check project CLAUDE.md** for project-specific rules that override these

### Skills

Skills live in `~/.claude/skills/` and are auto-invoked by description, or forced via a command.

| Skill | Command | Purpose |
|-------|---------|---------|
| `portwarden` | `/port` | Local dev port registry + collision checker, with optional Caddy bridge for clean `<app>.localhost` URLs |

**portwarden** ships a single stdlib-only script (`~/.claude/skills/portwarden/portwarden.py`).
State lives in `~/.portwarden/` (`registry.json` + generated `Caddyfile`). Subcommands:
`list`, `register <app> <port>`, `deregister <app|port>`, `check <port>`, `free [--start N]`, `caddy`.

**Caddy (clean URLs — important setup):** `.localhost` names resolve to `127.0.0.1` for free,
but routing a portless URL to the right backend needs Caddy on :80/:443.

1. Install Caddy once: `brew install caddy`.
2. Register apps, then run `/port caddy` (or `portwarden.py caddy`) to (re)generate `~/.portwarden/Caddyfile`.
3. **One-time privileged start** (binds 80/443 — the *only* step needing sudo; the user runs it themselves,
   ideally with a leading `!` so it runs in-session):
   ```
   sudo caddy start --config ~/.portwarden/Caddyfile --adapter caddyfile
   ```
4. After that, every `caddy` regen hot-reloads **without** sudo via Caddy's local admin API, so
   registering a new app + `caddy` is enough to make `https://<app>.localhost` live.

Without Caddy, `<app>.localhost:<port>` still works with zero setup — just keep the port in the URL.
Never use `.local` on macOS (hijacked by mDNS/Bonjour); never edit `/etc/hosts` for this.

### Project Integration (auto-detected from project CLAUDE.md)

| Feature | Config Key | Used By |
|---------|------------|---------|
| GitHub Project Board | `github_project` | `/issue` sets In Progress/Done |
| Git Worktrees | `~/.local/bin/git-worktree-workflow` | `/issue`, `/git` use worktrees |

These features are optional - workflows adapt when config is missing.

### Technical Details

See `~/.claude/CLAUDE.agents.md` for:
- Worker spawning patterns
- Workflow orchestration
- Git workflow requirements

---

## Personal Instructions

Add your personal global instructions below this line.

---

