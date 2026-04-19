# Agents

Agent definitions for autonomous spec review and repair. Each `.md` file contains vendor-prefixed frontmatter that `deployment.sh` rewrites into the native format for each target IDE.

## Agent Overview

| Agent | Purpose | Multi-model | Deployed to |
| :--- | :--- | :--- | :--- |
| `auto_shape_specs` | Framework-wide assessment and autonomous repair | No (single model) | All targets |
| `auto_spec_check` | Orchestrates three reviewers in parallel for consensus | Yes (delegates to sub-agents) | VS Code, Cursor |
| `check_spec_codex` | Independent reviewer — GPT-5.4 | No | VS Code, Cursor |
| `check_spec_opus` | Independent reviewer — Claude Opus 4.6 | No | VS Code |
| `check_spec_composer` | Independent reviewer — Composer 2 | No | Cursor |
| `check_spec_gemini` | Independent reviewer — Gemini 3.1 Pro | No | VS Code, Cursor |

## Committee Pattern (`auto_spec_check`)

`auto_spec_check` invokes three model-specific reviewer agents in parallel and synthesizes their consensus. The reviewer triplet differs by target IDE — configured via `replace:` directives in `deployment.conf`:

| Target | Reviewer A | Reviewer B | Reviewer C |
| :--- | :--- | :--- | :--- |
| VS Code | `check_spec_codex` (GPT-5.4) | `check_spec_opus` (Claude Opus 4.6) | `check_spec_gemini` (Gemini 3.1 Pro) |
| Cursor | `check_spec_composer` (Composer 2) | `check_spec_codex` (GPT-5.4) | `check_spec_gemini` (Gemini 3.1 Pro) |

Cursor uses Composer 2 because it delivers equivalent reviewer quality at a lower cost multiplier than Claude Opus 4.6. To swap Composer for Opus in Cursor, edit `deployment.conf` and change the commented-out `replace:` line for `AUTO_SPEC_CHECK_A`.

## Single-Model Agent (`auto_shape_specs`)

`auto_shape_specs` runs as a standalone agent on a single model — it performs all assessment and repair within its own execution. It works in any AI coding IDE that supports the agent file format. Currently tested with VS Code, Cursor, Claude Code, and Codex.

## VS Code Model Override Restrictions

VS Code enforces a **cost multiplier guard** on sub-agents: a sub-agent cannot use a model with a higher cost multiplier than the parent agent. If the sub-agent's model is more expensive, VS Code silently falls back to the parent's model.

This affects `auto_spec_check` when the parent runs on a cheap model (e.g., GPT-5.4 at 1x) while a reviewer requests Claude Opus 4.6 (3x). The Opus reviewer will silently run on the parent's model instead.

**Workaround:** Select a model with multiplier >= 3 (e.g., Claude Opus 4.6 itself) as the main chat model before invoking `auto_spec_check`. All sub-agents with equal or lower multipliers will then resolve correctly.

## Model Name Format by IDE

Agent files use vendor-prefixed frontmatter fields (`VSCODE_model`, `CURSOR_model`, etc.) that get rewritten during deployment. The accepted model name format differs by target:

| Target | Format | Example |
| :--- | :--- | :--- |
| VS Code | Display name from model picker | `GPT-5.4`, `Claude Opus 4.6`, `Gemini 3.1 Pro (Preview)` |
| Cursor | Cursor model identifier | `composer-2`, `claude-4.6-opus-high-thinking` |
| Claude Code | `inherit` or omit | `inherit` |
| Codex | API model identifier | `gpt-5.4` |
