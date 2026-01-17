# Documentation Master - Quick Reference Guide

## What is Documentation Master?

Documentation Master is a high-level orchestrator agent that automates documentation workflows by coordinating teams of specialized agents. Instead of manually running multiple agents and synthesizing their outputs, you invoke Doc-Master with simple commands and it handles all the orchestration.

## Installation

Documentation Master is installed at: `~/.claude/agents/doc-master.md`

It's available globally across all your projects.

**Important Files:**
- `~/.claude/agents/doc-master.md` - Main orchestrator
- `~/.claude/AGENT_SELECTION_GUIDE.md` - Which agent to use when
- `~/.claude/DOCUMENTATION_AGENT_HIERARCHY.md` - Visual hierarchy and architecture
- `~/.claude/DOC_MASTER_GUIDE.md` - This guide

## How to Use

### Basic Invocation Pattern

In Claude Code, simply say:

```
"doc-master: [command]"
```

Or more naturally:

```
"Document the [feature-name] feature"
"Prepare release documentation for v1.2.0"
"Run weekly documentation sync"
"Analyze impact of [change]"
"Document the [bug-name] fix"
"Audit for production readiness"
```

### Available Commands

| Command | Purpose | Time |
|---------|---------|------|
| `Document the [feature] feature` | Full feature documentation | ~2-3 min |
| `Prepare release documentation for v{X.Y.Z}` | Complete release package | ~5-10 min |
| `Run weekly documentation sync` | Update docs with recent changes | ~1-2 min |
| `Analyze impact of [change]` | Pre-implementation impact analysis | ~2-4 min |
| `Document the [bug] fix` | Capture bug root cause and solution | ~1-2 min |
| `Audit for production readiness` | Full production audit suite | ~10-15 min |

## Workflow Examples

### After Building a Feature

```bash
# You just finished implementing "recurring tasks" feature
You: "Document the recurring tasks feature"

# Doc-Master automatically:
# 1. Launches Explore, architect-reviewer, business-analyst (parallel)
# 2. Synthesizes findings
# 3. Creates docs/business/requirements/recurring-tasks.md
# 4. Updates docs/technical/patterns.md (if needed)
# 5. Updates PROJECT_PLAN.md
# 6. Reports back with summary
```

### Before a Release

```bash
# You're ready to release v1.3.0
You: "Prepare release documentation for v1.3.0"

# Doc-Master automatically:
# 1. Analyzes all changes since last release
# 2. Runs security, performance, accessibility audits (parallel, background)
# 3. Creates docs/releases/v1.3.0/ with:
#    - features.md (4 new features)
#    - breaking-changes.md
#    - migration.md
# 4. Updates changelog
# 5. Reports readiness status
```

### Weekly Maintenance (Friday afternoon)

```bash
# End of week cleanup
You: "Run weekly doc sync"

# Doc-Master automatically:
# 1. Scans last 7 days of commits
# 2. Updates technical docs if patterns changed
# 3. Fixes broken links
# 4. Updates PROJECT_PLAN.md
# 5. Reports "No action required" or "Updated X files"
```

### Before Starting Major Work

```bash
# You're considering adding multi-tenancy
You: "Analyze impact of adding multi-tenancy"

# Doc-Master automatically:
# 1. Maps current architecture (Explore agent)
# 2. Identifies affected systems (architect-reviewer)
# 3. Designs implementation approach (Plan agent)
# 4. Creates docs/business/decisions/multi-tenancy-2026-01-13.md
# 5. Lists affected components
# 6. Provides design recommendation
```

### After Fixing a Bug

```bash
# You just fixed a critical forecasting bug
You: "Document the forecasting calculation bug fix"

# Doc-Master automatically:
# 1. Analyzes root cause (error-detective)
# 2. Extracts what was fixed (debugger)
# 3. Updates docs/operations/troubleshooting.md
# 4. Verifies regression tests exist (test-automator)
# 5. Updates release notes if applicable
```

### Pre-Production Audit

```bash
# You're about to deploy to production
You: "Audit for production readiness"

# Doc-Master automatically:
# 1. Runs all audits in parallel (background):
#    - Security audit
#    - Performance audit
#    - Accessibility audit
#    - Compliance audit
#    - Code quality review
# 2. Generates unified report in docs/audits/production-readiness-{date}.md
# 3. Provides prioritized action items
```

## Documentation Structure

Doc-Master maintains this structure in your project:

```
docs/
├── business/
│   ├── requirements/          # What was built and why
│   ├── decisions/             # Technical decisions made (ADR-light)
│   └── assumptions.md         # Known constraints
├── technical/
│   ├── architecture.md        # System design
│   ├── patterns.md            # Code patterns enforced
│   └── data-models.md         # Schema documentation
├── operations/
│   ├── environment-setup.md   # Getting started guide
│   ├── deployment.md          # How to deploy
│   └── troubleshooting.md     # Common issues and solutions
├── releases/
│   ├── v1.0.0/               # Per-release folders
│   │   ├── features.md
│   │   ├── breaking-changes.md
│   │   └── migration.md
│   └── changelog.md          # Rollup
├── audits/
│   ├── security/             # Security audit reports
│   ├── performance/          # Performance audit reports
│   └── accessibility/        # A11y audit reports
├── PROJECT_PLAN.md           # Roadmap and milestones
└── README.md                 # Project entry point
```

## What Agents Does Doc-Master Use?

Doc-Master coordinates these specialized agents (you already have them installed):

**Investigation:**
- `Explore` - Fast codebase exploration
- `architect-reviewer` - Architectural analysis
- `research-analyst` - Change comparison

**Business Context:**
- `business-analyst` - Extract requirements
- `product-manager` - Product decisions

**Quality & Security:**
- `security-auditor` - Security reviews
- `performance-engineer` - Performance analysis
- `accessibility-tester` - A11y compliance
- `test-automator` - Test validation
- `code-reviewer` - Code quality

**Documentation:**
- `documentation-engineer` - Doc writing/maintenance
- `technical-writer` - Polish and clarity

**Problem Solving:**
- `error-detective` - Root cause analysis
- `debugger` - Bug investigation
- `Plan` - Design planning

## Best Practices

### When to Invoke Doc-Master

✅ **DO invoke after:**
- Completing a feature
- Fixing a significant bug
- Making architectural changes
- Weekly (end of sprint/week)
- Before releases
- Before major changes (impact analysis)

❌ **DON'T invoke for:**
- Trivial code changes (typo fixes, formatting)
- Work-in-progress features
- Experimental code
- Temporary debugging code

### Tips for Best Results

1. **Be Specific**: "Document the email campaign feature" vs "Document stuff"
2. **Use After Completion**: Document after implementation, not during
3. **Regular Cadence**: Weekly syncs keep docs fresh with minimal effort
4. **Pre-Release Always**: Always run release prep before tagging
5. **Impact Analysis First**: Run impact analysis before big changes

## Troubleshooting

**Q: Doc-Master takes a long time**
A: Some workflows (release prep, production audit) run audits in background. You can continue working - Doc-Master will notify when complete.

**Q: Documentation seems outdated**
A: Run "weekly doc sync" more frequently. Consider after each feature completion.

**Q: Too much documentation created**
A: Doc-Master focuses on significant changes. If you feel it's excessive, feedback welcome - it can be tuned.

**Q: Where did Doc-Master put the docs?**
A: Always in `docs/` following the structure above. Check the summary report for exact paths.

## Integration with Your Development Flow

### Typical Development Cycle

```
1. Plan Feature
   └─ "Analyze impact of [feature]" → Creates decision doc

2. Implement Feature
   └─ [You write the code]

3. Document Feature
   └─ "Document the [feature] feature" → Creates requirement doc

4. Week Ends
   └─ "Run weekly doc sync" → Keeps docs fresh

5. Prepare Release
   └─ "Prepare release documentation for vX.Y.Z" → Complete release package

6. Deploy
   └─ "Audit for production readiness" → Final validation
```

## Advanced Usage

### Custom Workflows

You can create custom workflows by saying:

```
"Create a custom documentation workflow for [specific-need]"
```

Doc-Master will design a workflow using available agents and save it for reuse.

### Partial Workflows

If you only need part of a workflow:

```
"Run security audit only" (instead of full production audit)
"Update architecture docs only" (instead of full sync)
```

### Background Execution

For long-running workflows, you can say:

```
"Prepare release docs in background"
```

You'll get a notification when complete.

## Getting Help

- **View this guide:** `cat ~/.claude/DOC_MASTER_GUIDE.md`
- **View agent definition:** `cat ~/.claude/agents/doc-master.md`
- **Feedback:** Mention issues during conversation, Doc-Master can adapt

## Quick Command Cheat Sheet

```bash
# Daily work
"Document the [feature] feature"              # After completing feature
"Document the [bug] fix"                      # After fixing bug

# Weekly maintenance
"Run weekly doc sync"                         # End of week

# Before major work
"Analyze impact of [change]"                  # Before big changes

# Before release
"Prepare release documentation for vX.Y.Z"    # Complete release package
"Audit for production readiness"              # Final checks

# Ad-hoc
"Update technical architecture docs"          # Specific doc update
"Run security audit"                          # Specific audit
```

## Real Example: StreamlineSales CRM

```bash
# Current project context
Project: StreamlineSales CRM
Tech Stack: Next.js 15, PostgreSQL, TypeScript
Current Version: v0.2.1

# Example usage today:
You: "Document the sales forecasting engine feature"

Doc-Master:
✓ Explored forecasting implementation (src/lib/sales-forecasting-engine.ts)
✓ Extracted technical decisions (hybrid forecasting methodology)
✓ Documented business requirements (revenue prediction capabilities)
✓ Created docs/business/requirements/sales-forecasting.md
✓ Updated docs/technical/patterns.md (added heuristic AI pattern)
✓ Updated PROJECT_PLAN.md (marked forecasting complete)

Summary: Sales forecasting feature documented. Uses hybrid methodology
(40% pipeline + 30% historical + 20% trend + 10% seasonal) for revenue
predictions. Documentation available at docs/business/requirements/sales-forecasting.md
```

---

**Ready to use!** Just start with: `"Document the [feature-name] feature"`
