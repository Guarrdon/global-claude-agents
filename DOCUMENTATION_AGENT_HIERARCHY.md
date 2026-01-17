# Documentation Agent Hierarchy

## Your Clean Agent Architecture

You have **128+ agents**, but doc-master uses a **clean subset** with **no duplicates or confusion**.

## Three-Tier Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ TIER 1: User Interface                                       │
│                                                               │
│  You say:                                                     │
│  "Document the feature"                                       │
│  "Prepare release v1.2.0"                                     │
│  "Run weekly doc sync"                                        │
│                                                               │
│  ↓ invokes ↓                                                  │
│                                                               │
│  doc-master                                                   │
│  (High-level orchestrator - understands commands)            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ TIER 2: Orchestration Layer                                  │
│                                                               │
│  agent-organizer                                              │
│  (Decomposes tasks, selects agents, coordinates execution)   │
│                                                               │
│  Responsibilities:                                            │
│  - Break workflow into tasks                                 │
│  - Select right agents for each task                         │
│  - Launch agents in parallel/sequential                      │
│  - Collect and synthesize results                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ TIER 3: Specialized Workers (Do the actual work)             │
│                                                               │
│  Investigation & Analysis:                                    │
│  ├─ Explore (fast code discovery)                            │
│  ├─ research-analyst (deep research, version comparison)     │
│  ├─ architect-reviewer (architecture & technical decisions)  │
│  ├─ business-analyst (requirements extraction)               │
│  └─ Plan (design new features)                               │
│                                                               │
│  Quality Assurance:                                           │
│  ├─ security-auditor (security reviews)                      │
│  ├─ performance-engineer (performance audits)                │
│  ├─ accessibility-tester (a11y compliance)                   │
│  ├─ test-automator (test coverage)                           │
│  └─ code-reviewer (code quality)                             │
│                                                               │
│  Documentation:                                               │
│  ├─ documentation-engineer (create/maintain docs)            │
│  ├─ technical-writer (polish & clarity)                      │
│  └─ api-documenter (API-specific docs)                       │
│                                                               │
│  Problem Solving:                                             │
│  ├─ debugger (single bug investigation)                      │
│  └─ error-detective (multi-bug pattern analysis)             │
└─────────────────────────────────────────────────────────────┘
```

## Agent Selection: No Confusion

### Before (Potential Confusion)
❌ "Should I use architect-reviewer or Plan?"
❌ "business-analyst or product-manager?"
❌ "documentation-engineer or technical-writer?"
❌ "Which orchestrator: agent-organizer, multi-agent-coordinator, or workflow-orchestrator?"

### After (Crystal Clear)
✅ **Orchestration:** agent-organizer (always)
✅ **Existing architecture:** architect-reviewer
✅ **New feature design:** Plan
✅ **Requirements:** business-analyst
✅ **Write docs:** documentation-engineer
✅ **Polish docs:** technical-writer (optional)

## Decision Matrix

### "Which agent should I use?"

**Ask yourself:**

1. **"What am I trying to do?"**
   - Orchestrate workflow → agent-organizer
   - Find code → Explore
   - Analyze architecture → architect-reviewer
   - Design new feature → Plan
   - Extract requirements → business-analyst
   - Write docs → documentation-engineer
   - Audit security → security-auditor
   - Debug → debugger

2. **"Is this existing or new?"**
   - Existing code/architecture → architect-reviewer
   - New design/feature → Plan

3. **"Fast or deep?"**
   - Fast discovery → Explore
   - Deep research → research-analyst

4. **"What type of audit?"**
   - Security → security-auditor
   - Performance → performance-engineer
   - Accessibility → accessibility-tester
   - Code quality → code-reviewer

## Example: Feature Documentation Workflow

```
User: "Document the email campaign feature"
  ↓
doc-master: Identifies Feature Documentation Workflow
  ↓
agent-organizer: Decomposes task
  ↓
  ├─ [PARALLEL PHASE]
  │  ├─ Explore: "Find email campaign code"
  │  ├─ architect-reviewer: "Extract technical decisions"
  │  └─ business-analyst: "Extract requirements"
  │
  ├─ [SYNTHESIS PHASE]
  │  └─ agent-organizer: Combines findings
  │
  └─ [DOCUMENTATION PHASE]
     └─ documentation-engineer: "Create docs/business/requirements/email-campaigns.md"
```

**Result:** Feature documented with NO duplicate effort, NO wrong agents, NO confusion.

## Example: Release Preparation Workflow

```
User: "Prepare release documentation for v1.3.0"
  ↓
doc-master: Identifies Release Preparation Workflow
  ↓
agent-organizer: Orchestrates multi-phase workflow
  ↓
  ├─ [INVESTIGATION PHASE - PARALLEL]
  │  ├─ Explore: "Find changes since last release"
  │  └─ research-analyst: "Compare v1.2.0 to v1.3.0"
  │
  ├─ [AUDIT PHASE - PARALLEL BACKGROUND]
  │  ├─ security-auditor: "Security review"
  │  ├─ performance-engineer: "Performance audit"
  │  ├─ accessibility-tester: "A11y check"
  │  └─ test-automator: "Test coverage"
  │
  ├─ [SYNTHESIS PHASE]
  │  └─ agent-organizer: Combines all findings
  │
  └─ [DOCUMENTATION PHASE - SEQUENTIAL]
     ├─ documentation-engineer: "Create release docs"
     └─ technical-writer: "Polish for clarity" (optional)
```

**Result:** Complete release package with all audits, NO duplicate work.

## Enforcement Mechanisms

### 1. Explicit Workflow Definitions
Each workflow in doc-master specifies EXACT agents to use.

### 2. Selection Guide Reference
Doc-master MUST consult AGENT_SELECTION_GUIDE.md before launching agents.

### 3. No Generic Fallbacks
If the right agent isn't available, FAIL and report. Never use "general-purpose" as backup.

### 4. One Agent, One Job
Each agent has a specific responsibility. No overlapping duties.

## What You Don't Use (For Documentation)

These agents exist in your library but are NOT used by doc-master:

**Orchestrators (not for docs):**
- ❌ multi-agent-coordinator (for distributed systems, not docs)
- ❌ workflow-orchestrator (for state machines, not docs)

**Business (not for requirements):**
- ❌ product-manager (strategy, not requirements)

**Quality (wrong specialty):**
- ❌ penetration-tester (offensive security, not audits)
- ❌ qa-expert (manual testing, not automation)
- ❌ chaos-engineer (resilience testing, not docs)

**Meta (not needed):**
- ❌ context-manager
- ❌ error-coordinator
- ❌ performance-monitor
- ❌ task-distributor
- ❌ knowledge-synthesizer

**Generic (never use):**
- ❌ general-purpose

## Benefits of This Architecture

✅ **Clear Roles:** Each tier has distinct responsibility
✅ **No Duplicates:** Each agent has one job
✅ **Predictable:** Same workflow = same agents
✅ **Efficient:** No wasted effort
✅ **Maintainable:** Easy to understand and modify
✅ **Scalable:** Add new workflows without confusion

## Quick Reference Card

```
ORCHESTRATION
└─ agent-organizer (always)

INVESTIGATION
├─ Fast discovery → Explore
├─ Deep research → research-analyst
├─ Existing arch → architect-reviewer
├─ New design → Plan
└─ Requirements → business-analyst

DOCUMENTATION
├─ Create/update → documentation-engineer
├─ Polish (opt) → technical-writer
└─ APIs only → api-documenter

QUALITY ASSURANCE
├─ Security → security-auditor
├─ Performance → performance-engineer
├─ A11y → accessibility-tester
├─ Tests → test-automator
└─ Code quality → code-reviewer

DEBUGGING
├─ Single bug → debugger
└─ Patterns → error-detective
```

## Verification

### "How do I know it's using the right agents?"

1. **Check workflow execution output**
   - You'll see agent names in the output
   - Compare to AGENT_SELECTION_GUIDE.md

2. **Check agent descriptions**
   - Each agent announces itself with description
   - Match description to ~/.claude/agents/{category}/{name}.md

3. **Check results**
   - Right agents produce expected results
   - Wrong agents produce off-target output

### "What if I want to use a different agent?"

1. **Update AGENT_SELECTION_GUIDE.md** with rationale
2. **Update doc-master.md** workflow definitions
3. **Test the workflow**
4. **Document the change**

**Never:** Just swap agents without updating the guide.

## Summary

You have **128+ agents** organized into:
- **Tier 1:** doc-master (user interface)
- **Tier 2:** agent-organizer (orchestration)
- **Tier 3:** ~15 specialized workers (actual work)

**Result:** Clean hierarchy, no confusion, no duplicates, predictable results.

**Your setup is now enforced and documented.**
