#!/usr/bin/env bash
# Bonero build loop - uses Claude to implement tasks from IMPLEMENTATION_PLAN.md
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"
PLAN_FILE="$SCRIPT_DIR/IMPLEMENTATION_PLAN.md"
PROMPT_FILE="$SCRIPT_DIR/PROMPT_build.md"
LOG_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOG_DIR"

echo "=== Bonero Build Loop ==="
echo "  Plan:   $PLAN_FILE"
echo "  Root:   $REPO_ROOT"

# Find first incomplete task
TASK=$(grep -m1 '^\- \[ \]' "$PLAN_FILE" || echo "")

if [[ -z "$TASK" ]]; then
    echo "No incomplete tasks found!"
    exit 0
fi

echo "  Task:   $TASK"
echo ""

# Run claude with the task
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$LOG_DIR/run-$TIMESTAMP.log"

claude -p "$(cat "$PROMPT_FILE")

Current task to implement:
$TASK

Work in $REPO_ROOT. Follow the implementation plan." 2>&1 | tee "$LOG_FILE"

echo "Log saved to $LOG_FILE"
