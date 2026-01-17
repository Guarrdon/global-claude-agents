# Global Claude Agents

A shareable configuration repository for Claude Code global agents, settings, and workflows. Clone this repo and run the install script to set up a consistent Claude Code environment across machines or share with teammates.

## Quick Start

```bash
# Clone the repository
git clone git@github.com:Guarrdon/global-claude-agents.git

# Run the installer
cd global-claude-agents
./install.sh
```

The installer will:
1. Prompt for your Claude config directory (defaults to `~/.claude`)
2. Back up any existing configuration
3. Merge agents, settings, and documentation

## What's Included

### Agents (`agents/`)

A hierarchical agent system with managers and workers:

```
agents/
├── AGENT_MAP.md          # Visual architecture diagram
├── managers/             # Orchestration agents
│   ├── global-manager.md
│   ├── dev-manager.md
│   ├── project-manager.md
│   ├── discovery-manager.md
│   └── environment-manager.md
└── workers/              # Execution agents
    ├── WORKERS.md        # Worker reference
    └── git-manager.md
```

**Key Concepts:**
- **Managers orchestrate, workers execute** - Managers never write code directly
- **Two-level hierarchy** - global-manager → domain-manager → worker
- **Model tiering** - Opus for analysis, Sonnet for work, Haiku for speed

### Agent Archive (`agents-bk/`)

Optional archive of additional specialized agents organized by category:
- Core Development (fullstack, backend, frontend, mobile)
- Language Specialists (TypeScript, Python, Go, Java, etc.)
- Infrastructure (DevOps, Cloud, Kubernetes, Terraform)
- Quality & Security (code review, testing, security audit)
- And more...

### Configuration Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Global instructions loaded for all conversations |
| `settings.json` | Claude Code settings (status line, etc.) |
| `statusline.sh` | Custom status line showing model, directory, cost |

### Documentation

| File | Purpose |
|------|---------|
| `AGENT_SELECTION_GUIDE.md` | How to choose the right agent |
| `DOCUMENTATION_AGENT_HIERARCHY.md` | Detailed hierarchy docs |
| `DOC_MASTER_GUIDE.md` | Documentation standards |
| `SETUP_SUMMARY.md` | Setup and configuration guide |

## Model Tiers

The agent system uses three model tiers:

| Model | Cost | Use For | Agents |
|-------|------|---------|--------|
| **opus** | $$$ | Deep analysis, complex debugging | code-reviewer, debugger |
| **sonnet** | $$ | Standard development tasks | All managers, most workers |
| **haiku** | $ | Fast exploration, simple ops | explorer, git-manager |

## Usage

Start interactions with the global manager:

```
Ask global-manager to implement a login feature
```

Or invoke specific capabilities:

```
use @agents
```

The system will route requests through the appropriate manager to qualified workers.

## Customization

### Personal Overrides

Create files with `.local` suffix (gitignored) for personal customizations:
- `CLAUDE.local.md` - Personal instructions
- `settings.local.json` - Personal settings

### Project-Specific Agents

Projects can have their own agents in `<project>/.claude/agents/` that override or extend the global agents.

## Updating

Pull the latest changes and re-run the installer:

```bash
cd global-claude-agents
git pull
./install.sh
```

The installer will offer to merge new files while preserving your existing configuration.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Repository Structure

```
.
├── README.md                         # This file
├── install.sh                        # Installation/merge script
├── .gitignore                        # Excludes sensitive data
├── CLAUDE.md                         # Global instructions
├── settings.json                     # Claude Code settings
├── statusline.sh                     # Status line script
├── AGENT_SELECTION_GUIDE.md          # Agent selection guide
├── DOCUMENTATION_AGENT_HIERARCHY.md  # Hierarchy documentation
├── DOC_MASTER_GUIDE.md               # Documentation standards
├── SETUP_SUMMARY.md                  # Setup guide
├── agents/                           # Active agents
│   ├── AGENT_MAP.md
│   ├── managers/
│   └── workers/
└── agents-bk/                        # Agent archive (optional)
```

## License

MIT - Feel free to use and modify for your own workflows.
