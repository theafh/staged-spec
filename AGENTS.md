# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**This is a meta-repository.** It contains LLM prompt artifacts (skills, commands, agents, hooks) and a deployment script that transforms and copies them into the correct configuration folders and syntax for each supported agentic coding IDE. Nothing in this repo runs directly — `deployment.sh` is the only executable, and its job is to install these artifacts into the IDE/tool so they are available in any project when working with the supported tools.

StagedSpec is a methodology for producing implementation-ready software specifications through iterative refinement inside agentic coding IDEs (Claude Code, Cursor, Codex, Gemini, Antigravity). Specs are refined via draft-assess-revise cycles until a one-shot AI agent can implement them correctly without follow-up questions.

**This repo builds the StagedSpec tooling — it is not itself developed using staged specs.** The files here are the building blocks that get deployed into other projects, where those projects then follow the staged-spec methodology. Do not apply staged-spec rules (stage files, guardrail documents, `/specs` directories, assessment formats) to this repo's own development. Those rules describe what the tooling produces in target projects, not how this repo is organized or modified.

## Repository Structure

- **`commands/.legacy/`** — Archived slash commands kept for backward compatibility only. No commands are actively deployed — all command functionality has moved to standalone skills. The dotfolder convention prevents discovery by the deployment scanner.
- **`skills/`** — Eight standalone skills (`spec_init`, `spec_audit`, `spec_check`, `spec_derive_intent`, `spec_feature_update`, `spec_implement`, `spec_validate_intent`, `spec_development`) each with their own `SKILL.md`. `spec_development` is the core skill with a `references/` subdirectory containing detailed guidance for stage structure, stage assessment, framework assessment, and intent documents. `spec_init` is a self-contained bootstrap skill for initializing the `/specs` framework in new projects. The other six are thin skills that delegate to `spec_development` references.
- **`agents/`** — Autonomous agent configs. `auto_spec_check` orchestrates 3 model-specific reviewers in parallel for majority-vote consensus, but it is not deployed to Codex; `auto_shape_specs` is the Codex-relevant standalone agent. The reviewer triplet for `auto_spec_check` varies by IDE and is configured via `deployment.conf`. See `agents/README.md` for model restrictions and IDE-specific details.
- **`hooks/`** — Guardrail enforcement assets. This repo currently ships tested hook configs for Claude Code and Cursor. Codex has experimental `hooks.json` support, but this repo does not deploy Codex hooks yet and `deployment.conf` explicitly excludes `hooks/*` for the Codex target.
- **`scripts/`** — `deployment.sh` adapts and deploys assets to multiple IDEs. Supports both global deployment and per-project deployment via `--project-dir`. For Codex, skills are symlinked into `~/.codex/skills/` (or `<project>/.codex/skills/`), commands are symlinked into `~/.codex/prompts/`, and agents are rewritten into `.toml` files under `~/.codex/agents/`. `deployment.conf` configures per-tool exclusion rules and placeholder replacements (e.g. reviewer agent triplet selection).

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

## Codex Deployment Notes

- **Codex consumes deployed artifacts, not repo files directly, for agents.** Changes under `agents/` require `./scripts/deployment.sh` to regenerate the Codex `.toml` files. Reading the source Markdown plus `scripts/README.md` is often necessary to understand what Codex will actually receive after transformation.
- **Most non-agent Codex artifacts are symlinked.** Changes to `skills/` and most `commands/` source files usually take effect immediately in Codex once deployed; re-run deployment when you add/remove artifacts, change `deployment.conf`, or modify assets that are copied instead of symlinked.
- **Codex support in this repo is intentionally narrower than Codex itself.** Codex has experimental project and user hook support, but this repo does not wire it up yet. If work touches hooks or the committee-style `auto_spec_check` flow, verify first whether the feature is implemented in this repo's deployment path before editing or relying on it.

## Deployment

Requires **jq**, **Bash 4+**, and **git**.

```bash
# Preview what would be deployed
./scripts/deployment.sh --dry-run

# Deploy all assets to all configured IDEs (global)
./scripts/deployment.sh

# Deploy to a specific tool
./scripts/deployment.sh --target codex

# Deploy into a single project instead of globally
./scripts/deployment.sh --project-dir /path/to/repo --target codex

# Deploy specific artifact type
./scripts/deployment.sh --type hooks

# Remove all deployed assets
./scripts/deployment.sh --uninstall

# Clear old backups (global deployment only)
./scripts/deployment.sh --clear-backups
```
