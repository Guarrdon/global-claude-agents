---
description: List all available slash commands and their worker agents.
---

# Available Commands

Display this formatted list of all available slash commands and their workers to the user.

## Output Format

Print the following information directly to the user (do NOT spawn any agents):

```
╭──────────────────────────────────────────────────────────────────────╮
│                     CLAUDE CODE SLASH COMMANDS                       │
╰──────────────────────────────────────────────────────────────────────╯

┌──────────────────────────────────────┐
│  DEVELOPMENT                         │
├──────────────────────────────────────┤
│                                      │
│  Command: /dev                       │
│  Purpose: Development workflow       │
│  Workers: code-writer, test-automator│
│           code-reviewer (opus)       │
│  ──────────────────────────────────  │
│  Command: /test                      │
│  Purpose: Write and run tests        │
│  Workers: test-automator             │
│  ──────────────────────────────────  │
│  Command: /review                    │
│  Purpose: Code review                │
│  Workers: code-reviewer (opus)       │
│  ──────────────────────────────────  │
│  Command: /debug                     │
│  Purpose: Bug investigation & fix    │
│  Workers: debugger (opus),           │
│           code-writer, test-automator│
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  QUALITY & AUDIT                     │
├──────────────────────────────────────┤
│                                      │
│  Command: /audit                     │
│  Purpose: Feature audit              │
│  Workers: functional-auditor         │
│           ux-auditor (opus, optional)│
│           doc-writer, git-manager    │
│  Usage:                              │
│    /audit <feature>     - Functional │
│    /audit deep <feature> - + UX      │
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  EXPLORATION & ANALYSIS              │
├──────────────────────────────────────┤
│                                      │
│  Command: /explore                   │
│  Purpose: Search codebase            │
│  Workers: explorer (haiku)           │
│  ──────────────────────────────────  │
│  Command: /analyze                   │
│  Purpose: Business/technical analysis│
│  Workers: analyst, product-analyst,  │
│           researcher                 │
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  GIT & DOCUMENTATION                 │
├──────────────────────────────────────┤
│                                      │
│  Command: /git                       │
│  Purpose: Git operations (PRs, etc.) │
│  Workers: git-manager (haiku)        │
│  ──────────────────────────────────  │
│  Command: /docs                      │
│  Purpose: Documentation              │
│  Workers: doc-writer                 │
│  ──────────────────────────────────  │
│  Command: /issue                     │
│  Purpose: GitHub issue resolution    │
│  Workers: github-issue-resolver      │
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  INFRASTRUCTURE & DEPLOYMENT         │
├──────────────────────────────────────┤
│                                      │
│  Command: /deploy                    │
│  Purpose: Deployment                 │
│  Workers: deploy-engineer            │
│  ──────────────────────────────────  │
│  Command: /infra                     │
│  Purpose: Infrastructure (DB, CI/CD) │
│  Workers: db-engineer, cloud-engineer│
│           infra-engineer             │
│                                      │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│  MODEL USAGE                         │
├──────────────────────────────────────┤
│                                      │
│  opus   ($$$) - Deep analysis        │
│                 /review, /debug      │
│                 /audit (UX only)     │
│                                      │
│  sonnet ($$)  - Development          │
│                 /dev, /test, /docs   │
│                 /deploy, /infra      │
│                 /issue, /analyze     │
│                 /audit (functional)  │
│                                      │
│  haiku  ($)   - Fast tasks           │
│                 /explore, /git       │
│                                      │
└──────────────────────────────────────┘

Tip: Use /commands to see this list anytime.
```

## Instructions

Simply output the formatted list above. Do not spawn any agents or perform any other actions.
