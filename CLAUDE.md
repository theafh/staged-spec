# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**This is a meta-repository.** It contains LLM prompt artifacts (skills, commands, agents, hooks) and a deployment script that transforms and copies them into the correct configuration folders and syntax for each supported agentic coding IDE. Nothing in this repo runs directly — `deployment.sh` is the only executable, and its job is to install these artifacts into the IDE/tool so they are available in any project when working with the supported tools.

StagedSpec is a methodology for producing implementation-ready software specifications through iterative refinement inside agentic coding IDEs (Claude Code, Cursor, Codex, Gemini, Antigravity). Specs are refined via draft-assess-revise cycles until a one-shot AI agent can implement them correctly without follow-up questions.

**This repo builds the StagedSpec tooling — it is not itself developed using staged specs.** The files here are the building blocks that get deployed into other projects, where those projects then follow the staged-spec methodology. Do not apply staged-spec rules (stage files, guardrail documents, `/specs` directories, assessment formats) to this repo's own development. Those rules describe what the tooling produces in target projects, not how this repo is organized or modified.

## Repository Structure

- **`commands/.legacy/`** — Archived slash commands kept for backward compatibility only. No commands are actively deployed — all command functionality has moved to standalone skills. The dotfolder convention prevents discovery by the deployment scanner.
- **`skills/`** — Eight standalone skills (`spec_init`, `spec_audit`, `spec_check`, `spec_derive_intent`, `spec_feature_update`, `spec_implement`, `spec_validate_intent`, `spec_development`) each with their own `SKILL.md`. `spec_development` is the core skill with a `references/` subdirectory containing detailed guidance for stage structure, stage assessment, framework assessment, and intent documents. `spec_init` is a self-contained bootstrap skill for initializing the `/specs` framework in new projects. The other six are thin skills that delegate to `spec_development` references.
- **`agents/`** — Autonomous agent configs. Two orchestration agents plus four model-specific reviewers:
  - `auto_spec_check` — orchestrates 3 reviewers in parallel for majority-vote consensus. The reviewer triplet varies by target IDE (configured via `replace:` directives in `deployment.conf`): VS Code uses Codex/Opus/Gemini, Cursor uses Composer/Codex/Gemini.
  - `auto_shape_specs` — standalone single-model agent for framework-wide assessment and autonomous repair. Works in any IDE supporting agent files.
  - `check_spec_codex` (GPT-5.4), `check_spec_opus` (Claude Opus 4.6), `check_spec_composer` (Composer 2), `check_spec_gemini` (Gemini 3.1 Pro) — independent reviewer agents used as sub-agents by `auto_spec_check`.
  - See `agents/README.md` for model restrictions, IDE-specific triplets, and VS Code cost-multiplier workarounds.
- **`hooks/`** — Guardrail enforcement. `protect-guardrails.sh` blocks edits to guardrail docs unless the branch name contains both `guardrail` and `spec`. JSON configs for Claude Code and Cursor.
- **`scripts/`** — `deployment.sh` adapts and deploys assets to multiple IDEs (symlink for Claude Code/Cursor, copy for Cursor agents, format conversion for Codex/Gemini/Antigravity). Supports both global deployment (`~/.claude`, `~/.cursor`, etc.) and per-project deployment via `--project-dir`. `deployment.conf` configures per-tool exclusion rules and placeholder replacements (e.g., reviewer agent triplet selection).

## Key Concepts (target project behavior, not this repo)

The sections below describe what the tooling produces when deployed into a target project. They are here so you understand the domain when editing prompts — not as rules for this repo itself.

**Five guardrail documents** live in each target project's `/specs` directory: `architecture.md` (index + status), `intent.md` (project identity + boundaries), `features.md` (behavior record), `security.md`, `testing.md`. The last three are guardrails — protected by hooks from casual modification.

**Stage files** follow strict naming: `v<version>-stage-<number>-<short-name>.md` (ordered) or `v<version>-<short-name>.md` (future). Each stage is self-contained with required sections: Status, Goal, Dependencies, Desired behavior, Scope boundary, Implementation steps, Tests & verification, Out of scope.

**Assessment output format** is standardized: general assessment paragraph, then severity-ordered issue list (Critical > High > Medium > Minor). Each issue: title + 1 paragraph (problem, impact, minimum fix).

## Architecture Patterns

- Commands are thin prompts; detailed logic lives in `skills/spec_development/references/`.
- Instruction boundaries use pseudo-XML tags (`<task_block>`, `<role>`, `<objective>`, `<rule>`, `<policy>`, `<output_contract>`) so AI agents follow constraints reliably.
- The committee pattern (3 independent model reviewers) filters for consensus — only issues raised by 2+ reviewers survive.
- Intent violations are classified: fix the spec, flag as `[INTENT VIOLATION]`, or flag as `[INTENT CONFLICT — REQUIRES DECISION]`. Never silently drop details.

## Editing Prompt Files

The primary artifacts in this repo are LLM instruction prompts (skills, commands, agents, references). When editing them:

- **Pseudo-XML tags are structural, not decorative.** Tags like `<task_block>`, `<role>`, `<objective>`, `<rule>`, `<policy>`, `<output_contract>` define instruction boundaries that AI agents rely on to parse and follow constraints. Preserve tag nesting, don't leave unclosed tags, and don't reorder tags without considering how an agent will interpret the new structure.
- **Think from the consumer's perspective.** Every prompt will be interpreted by an AI agent in a target project. When editing, consider: would an agent follow this unambiguously? Could it misread the scope of a rule? Would it skip a constraint because the boundary is unclear?
- **Commands are thin; logic lives in references.** Commands in `commands/` should stay minimal — they delegate to skills and references. Put detailed guidance, policies, and assessment criteria in `skills/spec_development/references/`.
- **Keep instructions self-contained within their scope.** Each reference file should be understandable on its own when loaded by an agent. Don't rely on implicit context from other files unless an explicit cross-reference is included.

## Deployment

Requires **jq**, **Bash 4+**, and **git**.

```bash
# Preview what would be deployed
./scripts/deployment.sh --dry-run

# Deploy all assets to all configured IDEs (global)
./scripts/deployment.sh

# Deploy to a specific tool
./scripts/deployment.sh --target claude-code

# Deploy into a single project instead of globally
./scripts/deployment.sh --project-dir /path/to/repo --target claude

# Deploy specific artifact type
./scripts/deployment.sh --type hooks

# Remove all deployed assets
./scripts/deployment.sh --uninstall

# Clear old backups (global deployment only)
./scripts/deployment.sh --clear-backups
```
