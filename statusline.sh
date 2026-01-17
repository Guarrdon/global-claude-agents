#!/bin/bash
# Claude Code Status Line - Shows model name and current directory
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir | split("/")[-1] // "unknown"')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Format cost to 4 decimal places
COST_FMT=$(printf "%.4f" "$COST")

echo "[$MODEL] $DIR | \$$COST_FMT"
