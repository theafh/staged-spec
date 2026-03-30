# Deployment

`deployment.sh` deploys StagedSpec assets (commands, skills, agents, hooks) from this repo into the global config directories of supported agentic IDEs. It uses symlinks where possible so edits to source files take effect immediately, and falls back to copying or format conversion when a target requires it.

## Supported Targets

| Target | Config directory | Identifier |
| :--- | :--- | :--- |
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

| Artifact | Claude Code | Cursor | Codex | Gemini CLI | Antigravity |
| :--- | :--- | :--- | :--- | :--- | :--- |
| command | symlink to `commands/` | symlink to `commands/` | symlink to `prompts/` | generates `.toml` in `commands/` | generates workflow `.md` in `workflows/` |
| skill | symlink to `skills/` | symlink to `skills/` | symlink to `skills/` | symlink to `skills/` | symlink to `skills/` |
| agent | symlink to `agents/` | copy to `agents/` | generates `.toml` in `agents/` | symlink to `agents/` | not supported |
| hook | merges JSON into `settings.json`, copies `.sh` scripts | copies `hooks.json` and `.sh` scripts | not supported | not supported | not supported |

Cursor agents are copied rather than symlinked because Cursor's file watcher does not follow symlinks.

Hook deployment for Claude Code merges the `hooks` key from the source JSON into `~/.claude/settings.json` using `jq`, and rewrites relative `./hooks/` script paths to absolute paths so they work from any working directory.

### Backups

Every run backs up the config directories of activated targets before making changes. Backups are timestamped copies placed next to the original directory:

```text
~/.claude          ->  ~/.claude_20260330_141500
~/.cursor          ->  ~/.cursor_20260330_141500
```

Use `--clear-backups` to remove old backups before creating new ones.

### Artifact log

Every deployed artifact is recorded in `scripts/deployed_artefacts.log` as a tab-separated line:

```text
<deployed_path>    <target_id>    <artifact_type>    <source_path>
```

For JSON key merges, the deployed path uses bracket notation (e.g., `~/.claude/settings.json[hooks]`). The log is deduplicated on exit.

The `--uninstall` flag reads this log to cleanly remove previously deployed artifacts. For regular files and symlinks it deletes them; for JSON key merges it strips the merged key from the settings file. Entries that no longer match active targets or type filters are preserved in the log.

## Exclusion Config (`target_conf.txt`)

`target_conf.txt` controls which assets are excluded per target. It uses a `robots.txt`-style format:

```text
#tool
disallow:path
```

- **Section heading** (`#tool`) -- sets the target for subsequent rules. Must be one of: `cursor`, `claude`, `codex`, `gemini`, `antigravity`.
- **Disallow directive** (`disallow:path`) -- a repo-relative path to exclude. Glob patterns are supported (`*` matches within a segment, `**` matches across segments).
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

Allow everything for Cursor (empty section or omit the section entirely):

```text
#cursor
```

## Usage

Run the script from anywhere; it resolves paths relative to the repo root automatically.

```bash
# Deploy all artifacts to all targets
./scripts/deployment.sh

# Preview what would happen without writing anything
./scripts/deployment.sh --dry-run

# Deploy only skills and commands
./scripts/deployment.sh --type skills,commands

# Deploy only to Claude Code and Cursor
./scripts/deployment.sh --target claude,cursor

# Combine filters
./scripts/deployment.sh --type commands --target gemini --dry-run

# Remove old backups before creating fresh ones
./scripts/deployment.sh --clear-backups

# Uninstall all previously deployed artifacts
./scripts/deployment.sh --uninstall

# Uninstall only hooks from Claude Code
./scripts/deployment.sh --uninstall --type hook --target claude

# Show help
./scripts/deployment.sh --help
```

### Flags

| Flag | Description |
| :--- | :--- |
| `--type TYPES` | Comma-separated artifact types to deploy: `command`, `skill`, `agent`, `hook` |
| `--target TARGETS` | Comma-separated targets: `claude`, `cursor`, `codex`, `gemini`, `antigravity` |
| `--dry-run` | Preview all actions without writing to disk |
| `--uninstall` | Remove previously deployed artifacts using the artifact log |
| `--clear-backups` | Remove old timestamped backups before creating new ones |
| `-h`, `--help` | Print usage summary |

## Common Workflows

### First-time setup

```bash
# Preview first to see what will be deployed
./scripts/deployment.sh --dry-run

# Deploy everything
./scripts/deployment.sh
```

### Updating after source changes

Since most artifacts are symlinked, changes to source files in `commands/`, `skills/`, and `agents/` take effect immediately for targets that use symlinks. Re-run the script only when:

- You added or removed artifact files
- You changed `target_conf.txt` exclusions
- You modified hook configs (hooks are copied, not symlinked)

```bash
./scripts/deployment.sh
```

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
./scripts/deployment.sh --clear-backups
```

This removes only backups that match the managed naming pattern (`~/<config>_YYYYMMDD_HHMMSS`).
