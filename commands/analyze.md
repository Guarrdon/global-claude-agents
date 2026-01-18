---
description: Analysis workflow - business analysis, requirements analysis, and technical research.
---

# Analysis Workflow

You are orchestrating an analysis task. You will spawn analyst agents for research and recommendations.

## Your Task

$ARGUMENTS

## Analysis Types

### Business Analysis
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "analyst: business analysis for <topic>",
  prompt: """
    You are a business analyst. Analyze the business requirements and provide recommendations.

    ## Task
    <what to analyze>

    ## Analysis Framework
    1. Current State - What exists today?
    2. Desired State - What should exist?
    3. Gap Analysis - What's missing?
    4. Recommendations - How to close the gap?
    5. Prioritization - What order to address?

    ## For Feature Analysis
    - User impact (who benefits?)
    - Business value (revenue, efficiency, satisfaction)
    - Effort estimate (complexity, dependencies)
    - Priority recommendation

    ## For Process Analysis
    - Current workflow steps
    - Pain points and bottlenecks
    - Improvement opportunities
    - Automation potential

    ## Output Format
    - Executive summary
    - Detailed findings
    - Recommendations with rationale
    - Priority matrix
  """
)
```

### Requirements Analysis
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "analyst: requirements for <feature>",
  prompt: """
    Analyze and document requirements for this feature.

    ## Feature
    <feature description>

    ## Requirements Template

    ### Functional Requirements
    - What must the system do?
    - User stories (As a... I want... So that...)
    - Acceptance criteria

    ### Non-Functional Requirements
    - Performance expectations
    - Security requirements
    - Scalability needs
    - Accessibility requirements

    ### Constraints
    - Technical limitations
    - Time constraints
    - Budget considerations

    ### Dependencies
    - External systems
    - Internal modules
    - Data requirements

    ### Out of Scope
    - What this feature does NOT include
  """
)
```

### Technical Research
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "researcher: research <topic>",
  prompt: """
    Research this technical topic and provide findings.

    ## Topic
    <what to research>

    ## Research Scope
    - Explore existing codebase patterns
    - Research industry best practices
    - Evaluate alternative approaches
    - Consider trade-offs

    ## Output Format
    - Summary of findings
    - Options with pros/cons
    - Recommendation with rationale
    - Implementation considerations
  """
)
```

### Product Analysis
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "product-analyst: analyze <area>",
  prompt: """
    Analyze from a product perspective.

    ## Area
    <what to analyze>

    ## Analysis Areas
    - User needs and pain points
    - Feature prioritization
    - Competitive landscape
    - Market fit

    ## Output Format
    - User stories
    - Priority recommendations
    - Success metrics
    - Risks and mitigations
  """
)
```

## Project-Specific Context

For StreamlineSales CRM, consider:
- **User Roles**: Admin, Manager, Sales Rep
- **Core Features**: Contacts, Companies, Deals, Tasks
- **AI Features**: Lead scoring, forecasting, recommendations (heuristic-based)
- **Business Metrics**: Conversion rates, deal velocity, forecast accuracy

## Execution

1. Determine analysis type needed
2. Read project CLAUDE.md for domain context
3. Spawn appropriate analyst with context
4. Review findings with user
5. Document recommendations for action
