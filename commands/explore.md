---
description: Explore codebase - fast exploration using haiku model to find files, patterns, and understand architecture.
---

# Explore Workflow

You are orchestrating codebase exploration. You will spawn explorer agents using the Explore subagent type with haiku model for fast, cost-effective searching.

## Your Task

$ARGUMENTS

## Exploration Patterns

### Find Files
```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: find <target>",
  prompt: "Find all files related to <target>. Look for naming patterns, directory conventions, and related imports."
)
```

### Find Code Pattern
```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: find <pattern> usage",
  prompt: "Find all occurrences of <pattern> in the codebase. Include file paths, line numbers, and surrounding context."
)
```

### Understand Architecture
```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: map architecture",
  prompt: """
    Map the project architecture:
    - Key directories and their purposes
    - Entry points (main files, route handlers)
    - Core modules and their relationships
    - Data flow patterns
    - Configuration locations
  """
)
```

### Find Function/Class Usage
```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: find usages of <name>",
  prompt: "Find all usages of <function/class/component> in the codebase. Show call sites and how it's used."
)
```

### Trace Data Flow
```
Task(
  subagent_type: "Explore",
  model: "haiku",
  description: "explorer: trace <data> flow",
  prompt: "Trace how <data type or variable> flows through the system. From entry point to final destination."
)
```

## Multi-Pass Exploration

For complex questions, use multiple passes:

1. **Broad Search** - Find all potentially relevant files
2. **Narrow** - Filter to most relevant based on initial findings
3. **Deep Dive** - Read specific sections in detail

You can spawn multiple explorer agents in parallel for independent searches.

## Response Format

After exploration, provide:
- Clear answer to the question
- File paths with line numbers
- Relevant code snippets
- Summary of findings

```
## Exploration Results

### Files Found
- src/lib/auth.ts - Authentication utilities
- src/app/api/login/route.ts - Login endpoint

### Key Code Locations
- src/lib/auth.ts:45 - `verifyPassword` function
- src/lib/auth.ts:67 - `createSession` function

### Summary
<brief summary answering the original question>
```

## Execution

1. Understand what needs to be found/explored
2. Choose appropriate exploration pattern
3. Spawn explorer with Explore subagent type (uses haiku)
4. For complex questions, run multiple passes
5. Synthesize findings into clear response
