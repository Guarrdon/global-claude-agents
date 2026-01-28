---
description: Git workflow - branching, commits, and PRs using project-specific git conventions.
---

# Git Workflow

You are orchestrating git operations. You will spawn a git-manager agent using haiku model for fast git operations.

## Your Task

$ARGUMENTS

## CRITICAL: Check Project Workflow First

Before ANY git operations, you MUST:

1. **Read project's CLAUDE.md** for git workflow section
2. **Check for `scripts/git-workflow.sh`** - If present, USE IT
3. **Check for worktree workflow** - Some projects use git worktrees

## Workflow Detection

### If Project Has Worktree Workflow
```bash
# Check status
scripts/git-workflow.sh status

# Switch to/create feature branch (creates worktree)
scripts/git-workflow.sh switch feature/my-feature

# The working directory changes!
# Inform user of directory change

# Commit WIP before switching contexts
scripts/git-workflow.sh commit-wip
```

### Standard Git Workflow
```bash
# ALWAYS start from latest main to avoid merge conflicts
git fetch origin
git checkout main && git pull origin main

# Create feature branch
git checkout -b feature/my-feature

# Stage and commit
git add -A
git commit -m "type: description

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push and create PR
git push -u origin feature/my-feature
gh pr create --title "type: description" --body "..."
```

## How to Spawn Git Manager

```
Task(
  subagent_type: "git-manager",
  model: "haiku",
  description: "git-manager: <operation>",
  prompt: """
    Perform git operations for this project.

    ## Task
    <what git operation to perform>

    ## Project Git Workflow
    Worktree: <yes/no - from CLAUDE.md>
    Script: <scripts/git-workflow.sh if present>
    Current branch: <from git status>

    ## Branch Naming Convention
    - feature/ - New features
    - fix/ - Bug fixes
    - docs/ - Documentation
    - refactor/ - Code refactoring
    - test/ - Test additions

    ## Commit Message Format
    type: brief description

    Longer explanation if needed.

    Co-Authored-By: Claude <noreply@anthropic.com>

    Types: feat, fix, docs, refactor, test, chore

    ## NEVER Do
    - Push directly to main/master
    - Force push (unless explicitly requested)
    - Skip project workflow scripts
    - Amend commits (unless explicitly requested)
  """
)
```

## Common Operations

### Create Branch
```
/git create branch for <feature description>
```

### Commit Changes
```
/git commit changes with message <message>
```

### Create PR
```
/git create PR for current branch
```

### Switch Context
```
/git switch to <branch or feature>
```

## PR Creation Format

```bash
gh pr create --title "type: description" --body "$(cat <<'EOF'
## Summary
- Bullet point summary of changes

## Test plan
- [ ] Test step 1
- [ ] Test step 2

Generated with Claude Code
EOF
)"
```

## GitHub Project Board

If working with issues, include board updates:
- Starting work: Set status to "In Progress"
- Completing work: Set status to "Done"

Reference project's CLAUDE.md for board field IDs.

## Execution

1. Check project CLAUDE.md for git workflow
2. Determine if worktree workflow is used
3. Spawn git-manager with project context
4. Inform user of any directory changes
5. Report completion with PR URL if created
