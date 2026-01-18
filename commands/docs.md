---
description: Documentation workflow - create and update documentation, guides, and READMEs.
---

# Documentation Workflow

You are orchestrating documentation work. You will spawn a doc-writer agent to create or update documentation.

## Your Task

$ARGUMENTS

## Documentation Types

### README / Guide
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "doc-writer: create <doc type>",
  prompt: """
    You are a technical documentation writer. Create clear, comprehensive documentation.

    ## Task
    <what to document>

    ## Documentation Type
    <README, guide, API docs, etc.>

    ## Style Guidelines
    - Clear, concise language
    - Use headers for organization
    - Include code examples where helpful
    - Add diagrams or tables for complex concepts
    - Follow existing project documentation style

    ## Structure for READMEs
    1. Title and brief description
    2. Prerequisites
    3. Installation/Setup
    4. Usage with examples
    5. Configuration options
    6. Troubleshooting
    7. Contributing (if applicable)

    ## Structure for Guides
    1. Overview and purpose
    2. Step-by-step instructions
    3. Examples and use cases
    4. Common pitfalls
    5. Reference links

    ## Output
    - Complete markdown documentation
    - Ready to commit
  """
)
```

### API Documentation
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "doc-writer: document API",
  prompt: """
    Document the API endpoints for this project.

    ## Scope
    <which endpoints or all>

    ## Format per Endpoint
    ### `METHOD /path`

    **Description:** What this endpoint does

    **Authentication:** Required/Optional

    **Request:**
    - Headers: ...
    - Body: ...

    **Response:**
    - Success (200): ...
    - Error cases: ...

    **Example:**
    ```bash
    curl ...
    ```

    ## Additional Sections
    - Authentication overview
    - Error code reference
    - Rate limiting (if applicable)
  """
)
```

### Code Comments / JSDoc
```
Task(
  subagent_type: "general-purpose",
  model: "sonnet",
  description: "doc-writer: add code documentation",
  prompt: """
    Add documentation to the specified code files.

    ## Target Files
    <files to document>

    ## Documentation Style
    - JSDoc for TypeScript/JavaScript
    - Docstrings for Python
    - Follow existing project conventions

    ## What to Document
    - Function/method purpose
    - Parameters with types
    - Return values
    - Exceptions/errors
    - Usage examples for complex functions

    ## Important
    - Don't over-document obvious code
    - Focus on the "why" not just the "what"
    - Keep comments concise
  """
)
```

## Quality Standards

Good documentation is:
- **Accurate** - Reflects current code behavior
- **Complete** - Covers all necessary topics
- **Clear** - Easy to understand
- **Maintainable** - Easy to update
- **Discoverable** - Well-organized and searchable

## After Documentation

Use `/git` to commit documentation changes:
```
/git commit docs with message "docs: add/update <what>"
```

## Execution

1. Determine documentation type needed
2. Explore relevant code if documenting features
3. Spawn doc-writer with appropriate template
4. Review output for accuracy
5. Suggest git commit for documentation
