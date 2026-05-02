# Deployment

`deployment.sh` deploys StagedSpec assets (commands, skills, agents, hooks) from this repo into the config directories of supported agentic IDEs. Running it without arguments prints the available parameters and usage examples. Use `--global` to deploy into global config directories (`~/.claude`, `~/.cursor`, etc.), or `--project-dir` to redirect deployment into a single project directory instead. It uses symlinks where possible so edits to source files take effect immediately, and falls back to copying or format conversion when a target requires it. `deployment.conf` can also force a copied deployment for selected paths and replace placeholders in the deployed copy.

## Supported Targets

| Target | Config directory | Identifier |
| :--- | :--- | :--- |
| VS Code GitHub Copilot | `~/.copilot` plus VS Code user prompts folder | `vscode` |
| Claude Code | `~/.claude` | `claude` |
| Cursor | `~/.cursor` | `cursor` |
| OpenAI Codex | `~/.codex` | `codex` |
| Gemini CLI | `~/.gemini` | `gemini` |
| Antigravity | `~/.gemini/antigravity` | `antigravity` |

## Prerequisites

- **jq** -- required for merging hook configs into JSON settings files. The script exits immediately if `jq` is not installed.
- **Target config directories** -- the script creates missing subdirectories (`commands/`, `skills/`, `agents/`, `hooks/`) automatically, but the base config directory for each IDE should already exist from a normal installation.
- **Bash 4+** -- the script uses associative arrays and other Bash 4 features.

## How It Works

### Asset discovery

The script scans four top-level folders in the repo root. The folder name determines the artifact type:

| Folder | Artifact type | Discovery rule |
| :--- | :--- | :--- |
| `commands/` | command | Each file is one artifact |
| `agents/` | agent | Each file is one artifact |
| `hooks/` | hook | Each file is one artifact |
| `skills/` | skill | Each subdirectory containing `SKILL.md` is one artifact |

### Deployment methods by target

Not every IDE consumes the same file format. The script adapts automatically:

| Artifact | VS Code | Claude Code | Cursor | Codex | Gemini CLI | Antigravity |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| command | symlink or copy to user prompts as `.prompt.md` | symlink to `commands/` | symlink to `commands/` | symlink to `prompts/` | generates `.toml` in `commands/` | generates workflow `.md` in `workflows/` |
| skill | symlink to `~/.copilot/skills/` | symlink to `skills/` | symlink to `skills/` | symlink to `skills/` | symlink to `skills/` | symlink to `skills/` |
| agent | rewritten copy to `~/.copilot/agents/*.agent.md` | symlink to `agents/` | copy to `agents/` | generates `.toml` in `agents/` | symlink to `agents/` | not supported |
| hook | copies files to `~/.copilot/hooks/` | merges JSON into `settings.json`, copies `.sh` scripts | copies `hooks.json` and `.sh` scripts | not currently deployed by this repo | not supported | not supported |

Cursor agents are copied rather than symlinked because Cursor's file watcher does not follow symlinks.

VS Code agents are written as `.agent.md` files in `~/.copilot/agents/`. The frontmatter rewriter now understands `VSCODE_` vendor-prefixed fields alongside `CURSOR_`, `CLAUDE_`, `CODEX_`, and the other target prefixes. Matching `VSCODE_` fields are stripped to their native VS Code field names during deployment, and vendor-prefixed blocks for other tools are removed.

Hook deployment for Claude Code merges the `hooks` key from the source JSON into `settings.json` using `jq`, and rewrites relative `./hooks/` script paths. In global mode, paths are rewritten to absolute paths (e.g., `~/.claude/hooks/protect-guardrails.sh`). In `--project-dir` mode, paths are rewritten to project-root-relative paths (e.g., `.claude/hooks/protect-guardrails.sh`) so the repo stays portable.

Codex itself supports experimental `hooks.json` files at user and project scope, but this deployment script does not currently generate or install Codex hook assets. The Codex target therefore excludes `hooks/*` in `deployment.conf` until the repo adds and tests that deployment path.

When a `replace:` rule matches an asset path, the script stops using symlinks for that deployed asset. It copies the file or directory into the target config directory and then scans the copied content for placeholders in the form `$VARIABLE_NAME$`, replacing each one with the configured value. For skills, the copy and replacement pass runs recursively across the deployed skill directory.

### Backups

Every global deployment run backs up the config directories of activated targets before making changes. Backups are timestamped copies placed in `$HOME` as `<name>_<timestamp>`. `<name>` defaults to the basename of the target directory; for VS Code's user-prompts dir on macOS (`~/Library/Application Support/Code/User/prompts`) the basename `prompts` would collide visually with unrelated directories, so the script overrides it to `.vscode-prompts`:

```text
~/.claude                                                      ->  ~/.claude_20260330_141500
~/.cursor                                                      ->  ~/.cursor_20260330_141500
~/Library/Application Support/Code/User/prompts (macOS)        ->  ~/.vscode-prompts_20260330_141500
```

Use `--clear-backups` to remove old backups before creating new ones.

Backups are disabled in `--project-dir` mode because project files are expected to be under version control. If `--clear-backups` is passed together with `--project-dir`, the script prints a notice and ignores the flag.

### Artifact log

Every deployed artifact is recorded in `scripts/deployed_artefacts.log` as a tab-separated line:

```text
<deployed_path>    <target_id>    <artifact_type>    <source_path>
```

For JSON key merges, the deployed path uses bracket notation (e.g., `~/.claude/settings.json[hooks]`). The log is deduplicated on exit.

The `--uninstall` flag reads this log to cleanly remove previously deployed artifacts. For regular files and symlinks it deletes them; for JSON key merges it strips the merged key from the settings file. Entries that no longer match active targets or type filters are preserved in the log.

## Per-Tool Config (`deployment.conf`)

`deployment.conf` defines per-tool deployment configuration and uses a `robots.txt`-style format:

```text
#tool
disallow:path
replace:path VAR=value
```

- **Section heading** (`#tool`) -- sets the target for subsequent rules. Must be one of: `vscode`, `cursor`, `claude`, `codex`, `gemini`, `antigravity`.
- **Disallow directive** (`disallow:path`) -- excludes a repo-relative path for the current tool. Glob patterns are supported (`*` matches within a segment, `**` matches across segments).
- **Replace directive** (`replace:path VAR=value`) -- matches a repo-relative path, forces copied deployment for matching assets, and replaces every `$VAR$` occurrence in the deployed copy with `value`. Multiple `replace:` lines can target the same path. A trailing slash such as `agents/` applies to every artifact beneath that subtree.
- **Double-hash comments** (`## ...`) -- ignored.

Assets not listed under a tool section are deployed to that tool. Only listed assets are skipped.

### Examples

Exclude a single agent from Codex:

```text
#codex
disallow:agents/check_spec_composer.md
```

Exclude all hooks from Gemini CLI:

```text
#gemini
disallow:hooks/*
```

Current repo policy also excludes hooks from Codex until Codex hook deployment is implemented and tested:

```text
#codex
disallow:hooks/*
```

Replace an agent placeholder for every deployed agent under `agents/`:

```text
#vscode
replace:agents/auto_spec_check.md AUTO_SPEC_CHECK_A=check_spec_composer
```

Allow everything for Cursor (empty section or omit the section entirely):

```text
#cursor
```

## Usage

Run the script from anywhere; it resolves paths relative to the repo root automatically.

```bash
# Show usage and available parameters
./scripts/deployment.sh

# Deploy all artifacts to all targets (global)
./scripts/deployment.sh --global

# Preview what would happen without writing anything
./scripts/deployment.sh --global --dry-run

# Deploy only skills and commands
./scripts/deployment.sh --global --type skills,commands

# Deploy only to VS Code and Cursor
./scripts/deployment.sh --global --target vscode,cursor

# Combine filters
./scripts/deployment.sh --global --type commands --target gemini --dry-run

# Deploy into a single project directory instead of global config
./scripts/deployment.sh --project-dir /path/to/repo --target claude

# Remove old backups before creating fresh ones
./scripts/deployment.sh --global --clear-backups

# Uninstall all previously deployed artifacts
./scripts/deployment.sh --uninstall

# Uninstall only hooks from Claude Code
./scripts/deployment.sh --uninstall --type hook --target claude

# Show help
./scripts/deployment.sh --help
```

### Make shortcuts

A top-level `Makefile` wraps the most common runs:

| Target | Equivalent |
| :--- | :--- |
| `make deploy` (alias `make install`, `make global`) | `./scripts/deployment.sh --global` |
| `make uninstall` | `./scripts/deployment.sh --uninstall` |

Use the script directly when you need flags beyond these two cases (`--dry-run`, `--type`, `--target`, `--project-dir`, `--clear-backups`).

### Flags

| Flag | Description |
| :--- | :--- |
| `--global` | Deploy into global config dirs. This is the previous no-argument behavior. |
| `--type TYPES` | Comma-separated artifact types to deploy: `command`, `skill`, `agent`, `hook` |
| `--target TARGETS` | Comma-separated targets: `vscode`, `claude`, `cursor`, `codex`, `gemini`, `antigravity` |
| `--project-dir DIR` | Deploy into a project directory instead of global config dirs. Backups are disabled in this mode. |
| `--dry-run` | Preview all actions without writing to disk |
| `--uninstall` | Remove previously deployed artifacts using the artifact log |
| `--clear-backups` | Remove old timestamped backups before creating new ones (ignored in project-dir mode) |
| `-h`, `--help` | Print usage summary |

## Common Workflows

### First-time setup

```bash
# Preview first to see what will be deployed
./scripts/deployment.sh --global --dry-run

# Deploy everything
./scripts/deployment.sh --global
```

### Updating after source changes

Since most artifacts are symlinked, changes to source files in `commands/`, `skills/`, and `agents/` take effect immediately for targets that use symlinks. Re-run the script only when:

- You added or removed artifact files
- You changed `deployment.conf` rules
- You changed source files for assets deployed via `replace:` rules, because those assets are copied instead of symlinked
- You modified hook configs (hooks are copied, not symlinked)

```bash
./scripts/deployment.sh --global
```

### Per-project deployment

Use `--project-dir` to deploy assets into a single project instead of globally. This keeps skills, agents, and hooks scoped to repos that actually use staged specs, avoiding latency and clutter in unrelated projects.

```bash
# Deploy Claude Code and Cursor assets into a specific repo
./scripts/deployment.sh --project-dir /path/to/repo --target claude,cursor

# Preview per-project deployment for all supported targets
./scripts/deployment.sh --project-dir /path/to/repo --dry-run
```

In project-dir mode the script uses each IDE's native project-level config path convention instead of the global home-directory paths:

| Target | Global path | Project path |
| :--- | :--- | :--- |
| Claude Code | `~/.claude/` | `<project>/.claude/` |
| Cursor | `~/.cursor/` | `<project>/.cursor/` |
| Codex | `~/.codex/` (skills: `~/.codex/skills/`) | `<project>/.codex/` (skills: `<project>/.agents/skills/`) |
| VS Code | `~/.copilot/`, user prompts dir | `<project>/.github/` (agents, skills, hooks, prompts) |
| Gemini CLI | skipped | No documented project-level convention — needs research and testing |
| Antigravity | skipped | No documented project-level convention — needs research and testing |

Backups are disabled because project files are expected to be version-controlled. Symlinked assets still point back to this repo, so source edits take effect immediately; re-run the script only when adding or removing artifacts.

**Hooks in project-dir mode.** Claude Code hooks are written to `<project>/.claude/settings.json` with relative script paths (e.g., `.claude/hooks/protect-guardrails.sh`) so the repo stays portable across machines. In global mode, absolute paths are used instead. Cursor hooks use `./hooks/` paths relative to the `.cursor/` directory, which works in both modes without changes.

### Uninstalling

```bash
# Preview what would be removed
./scripts/deployment.sh --uninstall --dry-run

# Remove all deployed artifacts
./scripts/deployment.sh --uninstall

# Remove only artifacts for a specific target
./scripts/deployment.sh --uninstall --target cursor
```

### Cleaning up backups

Backups accumulate over time. Remove old ones before a fresh deploy:

```bash
./scripts/deployment.sh --global --clear-backups
```

This removes only backups that match the managed naming pattern (`~/<config>_YYYYMMDD_HHMMSS`).
