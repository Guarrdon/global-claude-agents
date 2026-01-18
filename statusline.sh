#!/bin/bash
# Claude Code Status Line - Enhanced with context usage and vim mode
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | split("/")[-1] // "unknown"')
REMAINING=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
VIM_MODE=$(echo "$input" | jq -r '.vim.mode // empty')

# Build status line components
STATUS="[$MODEL]"

# Add vim mode if present
if [ -n "$VIM_MODE" ]; then
  STATUS="$STATUS [$VIM_MODE]"
fi

# Add context remaining if available
if [ -n "$REMAINING" ]; then
  REMAINING_INT=$(printf "%.0f" "$REMAINING")
  STATUS="$STATUS ctx:${REMAINING_INT}%"
fi

# Add directory
STATUS="$STATUS $DIR"

echo "$STATUS"
