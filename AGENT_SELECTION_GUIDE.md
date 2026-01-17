# Agent Selection Guide for Documentation Master

## Problem: Too Many Similar Agents

You have 128+ agents with some overlapping functionality. This guide ensures doc-master uses the **RIGHT** agents for each task.

## Agent Selection Matrix

### Orchestration Layer (Choose ONE per workflow)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **agent-organizer** | Documentation workflows, task decomposition, agent selection | Complex distributed systems, state machines |
| **multi-agent-coordinator** | Large-scale parallel coordination (50+ agents), distributed systems | Simple workflows, single-project docs |
| **workflow-orchestrator** | State machine workflows, business process automation with states | Documentation workflows |

**Doc-Master Decision:** Use **agent-organizer** for all documentation workflows (best for task decomposition and agent selection).

---

### Code Exploration (Choose ONE)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **Explore** (built-in) | Fast codebase exploration, finding files/functions | Deep architectural analysis |
| **research-analyst** | Deep research, comparing versions, analyzing changes | Quick file searches |

**Doc-Master Decision:**
- Use **Explore** for feature discovery (fast)
- Use **research-analyst** for release comparisons (deep)

---

### Architecture Analysis (Choose ONE)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **architect-reviewer** | Analyzing architectural decisions, patterns, technical debt | Planning new implementations |
| **Plan** (built-in) | Designing new features, planning implementations | Reviewing existing architecture |

**Doc-Master Decision:**
- Use **architect-reviewer** for documenting existing features
- Use **Plan** for impact analysis of new features

---

### Business Requirements (Choose ONE)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **business-analyst** | Extracting requirements from code, solution design | Product strategy, roadmap planning |
| **product-manager** | Product strategy, feature prioritization, roadmap | Technical requirements gathering |

**Doc-Master Decision:** Use **business-analyst** for all feature documentation (requirements focus).

---

### Documentation Writing (Choose ONE)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **documentation-engineer** | Creating/maintaining technical docs, doc systems, structure | Polishing prose, API-specific docs |
| **technical-writer** | Polishing documentation, improving clarity | Creating doc structure, automation |
| **api-documenter** | API documentation, OpenAPI/Swagger specs | General feature docs, architecture docs |

**Doc-Master Decision:**
- Use **documentation-engineer** for all doc creation/updates (structure focus)
- Use **technical-writer** ONLY for final polish phase (optional)
- Use **api-documenter** ONLY when documenting APIs specifically

---

### Quality Assurance (Choose by audit type)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **security-auditor** | Pre-release security reviews, vulnerability scans | Code quality, performance issues |
| **performance-engineer** | Performance audits, bottleneck identification | Security issues, accessibility |
| **accessibility-tester** | A11y compliance, WCAG validation | Backend services, APIs |
| **test-automator** | Test coverage validation, test creation | Manual testing, exploratory testing |
| **code-reviewer** | Code quality, best practices, patterns | Security audits, performance tuning |

**Doc-Master Decision:** Use specific agent for specific audit type (no overlaps).

---

### Debugging & Error Analysis (Choose ONE)

| Agent | Use When | DON'T Use When |
|-------|----------|----------------|
| **error-detective** | Complex error pattern analysis, correlation | Simple bug fixes |
| **debugger** | Bug investigation, root cause analysis | Pattern analysis across system |

**Doc-Master Decision:**
- Use **error-detective** for complex bugs with patterns
- Use **debugger** for single bug root cause analysis

---

## Documentation Master Workflow Agent Usage

### Workflow 1: Feature Documentation
```
Orchestrator: agent-organizer
Workers:
  ├─ Explore (code discovery)
  ├─ architect-reviewer (technical decisions)
  ├─ business-analyst (requirements)
  └─ documentation-engineer (write docs)
```

### Workflow 2: Release Preparation
```
Orchestrator: agent-organizer
Workers:
  ├─ Explore (changes since last release)
  ├─ research-analyst (version comparison)
  ├─ security-auditor (security review)
  ├─ performance-engineer (performance audit)
  ├─ accessibility-tester (a11y check)
  ├─ test-automator (test coverage)
  └─ documentation-engineer (release docs)
```

### Workflow 3: Weekly Sync
```
Orchestrator: agent-organizer
Workers:
  ├─ architect-reviewer (pattern changes)
  ├─ documentation-engineer (broken links, gaps)
  └─ (optional) technical-writer (polish)
```

### Workflow 4: Impact Analysis
```
Orchestrator: agent-organizer
Workers:
  ├─ Explore (current architecture)
  ├─ architect-reviewer (affected systems)
  ├─ Plan (design approach)
  └─ documentation-engineer (decision doc)
```

### Workflow 5: Bug Fix Documentation
```
Orchestrator: agent-organizer
Workers:
  ├─ error-detective (root cause, if complex)
  ├─ debugger (bug analysis)
  └─ documentation-engineer (troubleshooting docs)
```

### Workflow 6: Production Audit
```
Orchestrator: agent-organizer
Workers (parallel):
  ├─ security-auditor
  ├─ performance-engineer
  ├─ accessibility-tester
  ├─ compliance-auditor
  ├─ code-reviewer
  └─ documentation-engineer (audit report)
```

---

## Decision Rules for Doc-Master

### Rule 1: One Orchestrator Per Workflow
**Always:** `agent-organizer` for documentation workflows

### Rule 2: Exploration Agents
- **Fast discovery:** Explore (built-in)
- **Deep research:** research-analyst

### Rule 3: Analysis Agents
- **Existing code:** architect-reviewer
- **New design:** Plan

### Rule 4: Requirements Agents
- **Always:** business-analyst (not product-manager)

### Rule 5: Documentation Agents
- **Primary:** documentation-engineer (structure)
- **Polish (optional):** technical-writer (clarity)
- **APIs only:** api-documenter

### Rule 6: Audit Agents
- One agent per audit type (no substitutions)

### Rule 7: Avoid Generic Agents
- **Never use:** general-purpose agent
- **Always use:** Specific specialized agents

---

## Agent Hierarchy

```
Level 1: doc-master (you invoke this)
    ↓
Level 2: agent-organizer (orchestrates workflow)
    ↓
Level 3: Specialized workers (do the actual work)
    ├─ Explore / research-analyst
    ├─ architect-reviewer / Plan
    ├─ business-analyst
    ├─ documentation-engineer
    ├─ security-auditor
    ├─ performance-engineer
    └─ ... others as needed
```

**Key Principle:** Each level has a clear responsibility. No level does the work of another level.

---

## How Doc-Master Enforces This

Doc-master's workflow definitions now specify **exact agents** using this guide:

```yaml
Feature Documentation:
  orchestrator: agent-organizer
  workers:
    - Explore  # Fast discovery
    - architect-reviewer  # Technical decisions
    - business-analyst  # Requirements
    - documentation-engineer  # Write docs
```

**No ambiguity.** Each workflow knows exactly which agents to use.

---

## Benefits of This Approach

✅ **Clear roles:** Each agent has specific responsibility
✅ **No duplicates:** Never confused which agent to use
✅ **Predictable:** Same workflow always uses same agents
✅ **Maintainable:** Easy to understand what each workflow does
✅ **Efficient:** No wasted agent invocations

---

## When to Update This Guide

Update this guide when:
1. You add new specialized agents
2. You discover agent overlaps
3. Workflow patterns change
4. You want to optimize agent selection

---

## Quick Reference

**"Which agent for...?"**

- Task decomposition → `agent-organizer`
- Find files → `Explore`
- Deep research → `research-analyst`
- Architecture review → `architect-reviewer`
- Design planning → `Plan`
- Requirements → `business-analyst`
- Write docs → `documentation-engineer`
- Polish docs → `technical-writer`
- Security audit → `security-auditor`
- Performance audit → `performance-engineer`
- A11y check → `accessibility-tester`
- Test validation → `test-automator`
- Code quality → `code-reviewer`
- Bug analysis → `debugger` or `error-detective`

**Remember:** One agent, one job, one workflow.
