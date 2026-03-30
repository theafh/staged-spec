# StagedSpec

A human-centric methodology for producing implementation-ready software specifications through iterative refinement inside agentic coding IDEs.

## Overview

StagedSpec structures the messy process of turning ideas into buildable specs. A human (or autonomous agent) drives repeated draft-assess-refine cycles on one stage at a time until the spec is good enough for an AI to implement in a single pass. Guardrail documents and verification commands provide the safety boundary that makes both manual and autonomous refinement possible.

## Key Properties

- **Single-file contract** — everything the implementer needs is in one stage file, no cross-referencing multiple artifacts
- **Quality ceiling scales with complexity** — iteration depth matches the stage; simple stages get 2 rounds, complex integrations get 8
- **Minimal artifact overhead** — stage files + five shared files, no per-stage metadata proliferation
- **Organic evolution** — specs sharpen as their turn approaches; future stages remain adjustable
- **Behavior-first documentation** — `features.md` records what the system does from the outside, not how it works inside

## How It Works

The core cycle: human describes intent, AI drafts a stage spec, AI assesses it for implementation readiness, human steers corrections, AI revises. This repeats until the spec is ready. An automated committee agent can replace the human in the loop, using majority-vote consensus across multiple models to filter for real issues. See [METHODOLOGY.md](METHODOLOGY.md) for the full reference.

## Project Structure

```text
staged-spec/
  commands/       # Slash commands for spec workflow operations
  agents/         # Autonomous agent configs (committee reviewers, orchestrator)
  hooks/          # Guardrail enforcement hooks for Claude Code and Cursor
  scripts/        # Deployment script and per-tool target config
  skills/         # Skill definitions for agentic IDE integration
```

When used in a project, specs live in a `/specs` folder alongside five shared files.

## Spec Artifacts

Five shared files provide project-wide context inside `/specs`:

| File | Purpose |
| :--- | :--- |
| `architecture.md` | Index and entry point — links stages, tracks status, lists constraints |
| `intent.md` | Project identity — non-negotiable commitments, boundaries, invariants |
| `features.md` | Behavior-first record of what the system currently does |
| `testing.md` | Project-wide test methodology |
| `security.md` | Cross-cutting security constraints |

Each stage is a single self-contained file: `v<version>-stage-<number>-<short-name>.md` (ordered) or `v<version>-<short-name>.md` (unordered future features). See [METHODOLOGY.md](METHODOLOGY.md) for full artifact descriptions and stage structure.

## Commands

These commands automate common operations within the StagedSpec workflow. They are invoked as slash commands in supported agentic IDEs (e.g. `/spec_check` in Claude Code or Cursor).

| Command | What it does |
| :--- | :--- |
| `spec_check` | Reviews a spec for implementation readiness against quality and structure criteria |
| `spec_audit` | Audits an implementation against its spec, reporting gaps between specified and built |
| `spec_implement` | Implements a spec in a single pass, verifying all details and running tests |
| `spec_feature_update` | Updates `features.md` to reflect actual implemented behavior |
| `spec_create_intent` | Analyzes all `/specs` documents and produces the Project Intent Summary (`intent.md`) |
| `spec_validate_intent` | Validates specs, code, or both against `intent.md` and reports violations by severity |

`spec_create_intent` and `spec_validate_intent` form a project-wide guardrail layer. Individual stage specs ensure each piece is internally sound. The intent document ensures the pieces stay true to the project's identity.

## Deployment

StagedSpec deploys to multiple agentic coding environments — Claude Code, Cursor, Codex, Gemini, and Antigravity. The deployment script (`scripts/deployment.sh`) with a per-tool config (`scripts/target_conf.txt`) controls which assets ship to each tool, since not every tool supports every feature (e.g. hooks and agents are excluded where unsupported).

## Guardrail Enforcement

Guardrail documents (`intent.md`, `security.md`, `testing.md`) define hard boundaries that no spec refinement should cross. Pre-built hooks block edits to these files unless the git branch name signals deliberate intent. Verification commands check specs and code against the guardrails without being able to modify them. See [METHODOLOGY.md](METHODOLOGY.md) for details on hook configuration and enforcement levels.

## License

See [LICENSE](LICENSE).
