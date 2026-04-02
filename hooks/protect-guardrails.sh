#!/usr/bin/env bash
# protect-guardrails.sh
#
# Shared hook script for Claude Code and Cursor.
# Blocks edits to guardrail documents (specs/intent.md, specs/security.md,
# specs/testing.md) unless the current git branch contains both "guardrail"
# and "spec" (e.g. guardrail/spec-security-update).
#
# Both tools pass JSON via stdin with tool_input.file_path and use exit 2
# to block the action.

set -euo pipefail

GUARDRAIL_PATTERNS=(
  "specs/intent.md"
  "specs/security.md"
  "specs/testing.md"
)

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
HOOK_CWD=$(echo "$INPUT" | jq -r '.cwd // .tool_input.cwd // empty')

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

IS_GUARDRAIL=false
for pattern in "${GUARDRAIL_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern" ]]; then
    IS_GUARDRAIL=true
    break
  fi
done

if [[ "$IS_GUARDRAIL" != "true" ]]; then
  exit 0
fi

REPO_ROOT=""

if [[ "$FILE_PATH" = /* ]]; then
  REPO_ROOT=$(git -C "$(dirname "$FILE_PATH")" rev-parse --show-toplevel 2>/dev/null || true)
fi

if [[ -z "$REPO_ROOT" && -n "$HOOK_CWD" ]]; then
  REPO_ROOT=$(git -C "$HOOK_CWD" rev-parse --show-toplevel 2>/dev/null || true)
fi

if [[ -z "$REPO_ROOT" ]]; then
  REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || true)
fi

BRANCH=""
if [[ -n "$REPO_ROOT" ]]; then
  BRANCH=$(git -C "$REPO_ROOT" symbolic-ref --short HEAD 2>/dev/null || true)
fi

if [[ "$BRANCH" == *guardrail* && "$BRANCH" == *spec* ]]; then
  exit 0
fi

echo "BLOCKED: $(basename "$FILE_PATH") is a guardrail document. Switch to a branch containing 'guardrail' and 'spec' in the name to allow edits (e.g. guardrail/spec-security-update)." >&2
exit 2
