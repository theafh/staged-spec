# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StagedSpec is a methodology and deployment framework for producing implementation-ready software specifications through iterative refinement inside agentic coding IDEs (Claude Code, Cursor, Codex, Gemini, Antigravity). Specs are refined via draft-assess-revise cycles until a one-shot AI agent can implement them correctly without follow-up questions.

**This repo builds the StagedSpec tooling — it is not itself developed using staged specs.** The files here (commands, skills, agents, hooks, scripts) are the building blocks that get deployed into other projects, where those projects then follow the staged-spec methodology. When working in this repo, do not apply staged-spec rules (stage files, guardrail documents, `/specs` directories, assessment formats) to the repo's own development. Those rules describe what the tooling produces in target projects, not how this repo is organized or modified.

## Repository Structure

- **`commands/`** — Slash commands (`spec_check`, `spec_implement`, `spec_audit`, `spec_create_intent`, `spec_validate_intent`, `spec_feature_update`, `assess_all_specs`). Minimal prompts that delegate to skills for detailed guidance.
- **`agents/`** — Autonomous agent configs. `auto_spec_check` orchestrates 3 model-specific reviewers (Opus, Composer, Codex) in parallel for majority-vote consensus. `auto_shape_specs` does framework-wide assessment + autonomous repair.
- **`hooks/`** — Guardrail enforcement. `protect-guardrails.sh` blocks edits to guardrail docs unless the branch name contains both `guardrail` and `spec`. JSON configs for Claude Code and Cursor.
- **`skills/spec_development/`** — Core skill definition (`SKILL.md`) with policy and constraints. `references/` subdirectory has detailed guidance for framework initialization, stage structure, stage assessment, framework assessment, and intent documents.
- **`scripts/`** — `deployment.sh` adapts and deploys assets to multiple IDEs (symlink for Claude Code/Cursor, copy for Cursor agents, format conversion for Codex/Gemini/Antigravity). `deployment.conf` is the per-tool deployment configuration file (currently exclusion rules).

## Key Concepts (target project behavior, not this repo)

The sections below describe what the tooling produces when deployed into a target project. They are here so you understand the domain when editing prompts — not as rules for this repo itself.

**Five guardrail documents** live in each target project's `/specs` directory: `architecture.md` (index + status), `intent.md` (project identity + boundaries), `features.md` (behavior record), `security.md`, `testing.md`. The last three are guardrails — protected by hooks from casual modification.

**Stage files** follow strict naming: `v<version>-stage-<number>-<short-name>.md` (ordered) or `v<version>-<short-name>.md` (future). Each stage is self-contained with required sections: Status, Goal, Dependencies, Desired behavior, Scope boundary, Implementation steps, Tests & verification, Documentation updates, Out of scope.

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

# Deploy all assets to all configured IDEs
./scripts/deployment.sh

# Deploy to a specific tool
./scripts/deployment.sh --target claude-code

# Deploy specific artifact type
./scripts/deployment.sh --type hooks

# Remove all deployed assets
./scripts/deployment.sh --uninstall

# Clear old backups
./scripts/deployment.sh --clear-backups
```
