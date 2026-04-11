#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# deployment.sh — deploy repo artifacts into global config dirs
#                 for Cursor, Claude Code, OpenAI Codex, Gemini CLI,
#                 and Google Antigravity
#
# Discovery is folder-based: assets live in top-level folders whose name
# determines the artifact type (agents/, commands/, skills/, hooks/).
#
# Exclusions are controlled by target_conf.txt (robots.txt-style):
#   #tool           Section heading
#   disallow:path   Relative path to exclude for that tool
#
# Features:
#   --type TYPES     Filter by artifact type (rule,command,skill,agent)
#   --target TARGETS Filter by deploy target (claude,cursor,codex,gemini,antigravity)
#   --dry-run        Preview changes without applying them
#   --uninstall      Remove previously deployed artifacts from deployed_artefacts.log
#   --clear-backups  Remove old selected backups before creating new ones
#   Logs deployed artifacts to deployed_artefacts.log with target/source metadata
#   Backs up only activated targets
#
# Usage:
#   ./deployment.sh                              # autodiscover all
#   ./deployment.sh --clear-backups              # drop old backups, then create fresh ones
#   ./deployment.sh --uninstall                  # uninstall logged artifacts only
#   ./deployment.sh --type skills,commands       # deploy only skills+commands
#   ./deployment.sh --target claude,cursor       # deploy only to claude+cursor
#   ./deployment.sh --dry-run                    # preview mode
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
DRY_RUN=false
UNINSTALL=false
CLEAR_BACKUPS=false
TYPE_FILTER=""
TARGET_FILTER=""

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --uninstall)
      UNINSTALL=true
      shift
      ;;
    --clear-backups)
      CLEAR_BACKUPS=true
      shift
      ;;
    --type)
      TYPE_FILTER="$2"
      shift 2
      ;;
    --target)
      TARGET_FILTER="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'USAGE'
Usage: deployment.sh [OPTIONS]

Options:
  --type TYPES     Comma-separated artifact types to deploy: command,skill,agent
  --target TARGETS Comma-separated deploy targets: claude,cursor,codex,gemini,antigravity
  --uninstall      Uninstall mode; remove matching logged deployed artifacts after backup
  --clear-backups  Remove old backups for selected targets before creating new backups
  --dry-run        Preview changes without applying them
  -h, --help       Show this help message
USAGE
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOME_DIR="${HOME}"

# jq is required for JSON-merge hook deployment (Claude Code settings.json)
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Asset folders — folder name determines artifact type
# ---------------------------------------------------------------------------
declare -A ASSET_FOLDERS=(
  [agents]="agent"
  [commands]="command"
  [skills]="skill"
  [hooks]="hook"
)

# ---------------------------------------------------------------------------
# Target directories
# ---------------------------------------------------------------------------
CURSOR_DIR="${HOME_DIR}/.cursor"
CLAUDE_DIR="${HOME_DIR}/.claude"
CODEX_DIR="${HOME_DIR}/.codex"
GEMINI_DIR="${HOME_DIR}/.gemini"
ANTIGRAVITY_DIR="${HOME_DIR}/.gemini/antigravity"

# Instruction files that need rule references
CLAUDE_MD="${CLAUDE_DIR}/CLAUDE.md"
AGENTS_MD="${CODEX_DIR}/AGENTS.md"
GEMINI_MD="${GEMINI_DIR}/GEMINI.md"

# Markers for the managed block
MARKER_BEGIN="<!-- BEGIN GLOBAL RULES -->"
MARKER_END="<!-- END GLOBAL RULES -->"
DEPLOYED_ARTIFACTS_LOG="${SCRIPT_DIR}/deployed_artefacts.log"
TARGET_CONF="${SCRIPT_DIR}/target_conf.txt"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf "  \033[34m%-10s\033[0m %s\n" "$1" "$2"; }
ok()    { printf "  \033[32m%-10s\033[0m %s\n" "$1" "$2"; }
warn()  { printf "  \033[33m%-10s\033[0m %s\n" "$1" "$2"; }
err()   { printf "  \033[31m%-10s\033[0m %s\n" "$1" "$2"; }

SUMMARY_BACKUPS=0
SUMMARY_CLEARED_BACKUPS=0
SUMMARY_DEPLOY_ACTIONS=0
SUMMARY_UNINSTALL_ACTIONS=0
SUMMARY_RULE_UPDATES=0

print_summary() {
  local summary_parts=()
  summary_parts+=("${SUMMARY_BACKUPS} backup(s)")
  summary_parts+=("${SUMMARY_CLEARED_BACKUPS} old backup(s) removed")
  summary_parts+=("${SUMMARY_DEPLOY_ACTIONS} deploy action(s)")
  summary_parts+=("${SUMMARY_UNINSTALL_ACTIONS} uninstall action(s)")
  summary_parts+=("${SUMMARY_RULE_UPDATES} instruction update(s)")

  local summary_text
  summary_text="$(printf '%s, ' "${summary_parts[@]}")"
  summary_text="${summary_text%, }"

  if $DRY_RUN; then
    info "summary" "DRY RUN simulated: ${summary_text}"
  else
    ok "summary" "Performed: ${summary_text}"
  fi
}

ensure_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    if $DRY_RUN; then
      info "would-mk" "$dir"
    else
      mkdir -p "$dir"
      ok "created" "$dir"
    fi
  fi
}

append_deployed_artifact_log() {
  local deployed_path="${1:-}"
  local target_id="${2:-}"
  local artifact_type="${3:-}"
  local source_path="${4:-}"
  $DRY_RUN && return 0
  [[ -n "$deployed_path" && -n "$target_id" && -n "$artifact_type" && -n "$source_path" ]] || return 0
  printf '%s\t%s\t%s\t%s\n' "$deployed_path" "$target_id" "$artifact_type" "$source_path" >> "$DEPLOYED_ARTIFACTS_LOG"
}

dedupe_deployed_artifact_log() {
  $DRY_RUN && return 0
  [[ -f "$DEPLOYED_ARTIFACTS_LOG" ]] || return 0

  local tmp
  tmp="$(mktemp)"
  sort -u "$DEPLOYED_ARTIFACTS_LOG" > "$tmp"
  mv "$tmp" "$DEPLOYED_ARTIFACTS_LOG"
}

trap dedupe_deployed_artifact_log EXIT

path_exists() {
  local path="$1"

  # Handle path[key] notation — check the JSON file exists and contains the key
  if [[ "$path" =~ ^(.+)\[([a-zA-Z_][a-zA-Z0-9_]*)\]$ ]]; then
    local json_file="${BASH_REMATCH[1]}"
    local json_key="${BASH_REMATCH[2]}"
    [[ -f "$json_file" ]] && jq -e ".${json_key}" "$json_file" &>/dev/null
    return $?
  fi

  [[ -e "$path" || -L "$path" ]]
}

# ---------------------------------------------------------------------------
# Filter helpers
# ---------------------------------------------------------------------------

# Check if a value is in a comma-separated filter string.
# Returns 0 (true) when the filter is empty (accept all) or the value matches.
matches_filter() {
  local value="$1"
  local filter="$2"

  [[ -z "$filter" ]] && return 0

  local IFS=','
  for item in $filter; do
    item="${item// /}"
    [[ "$item" == "$value" ]] && return 0
  done
  return 1
}

# ---------------------------------------------------------------------------
# target_conf.txt parser
#
# Parses the robots.txt-style config and populates DISALLOW_MAP:
#   DISALLOW_MAP["tool|rel_path"] = 1
# ---------------------------------------------------------------------------
declare -A DISALLOW_MAP=()

parse_target_conf() {
  [[ -f "$TARGET_CONF" ]] || return 0

  local current_tool=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"

    # Skip empty lines and comments (but not section headings)
    [[ -z "$line" ]] && continue
    [[ "$line" == \#\#* ]] && continue  # skip ## double-hash comments

    # Section heading: #tool
    if [[ "$line" =~ ^#([a-zA-Z_][a-zA-Z0-9_-]*)$ ]]; then
      current_tool="${BASH_REMATCH[1]}"
      continue
    fi

    # Disallow directive
    if [[ -n "$current_tool" && "$line" =~ ^disallow:(.+)$ ]]; then
      local disallowed="${BASH_REMATCH[1]}"
      # Strip leading/trailing whitespace
      disallowed="${disallowed#"${disallowed%%[![:space:]]*}"}"
      disallowed="${disallowed%"${disallowed##*[![:space:]]}"}"
      [[ -n "$disallowed" ]] && DISALLOW_MAP["${current_tool}|${disallowed}"]=1
    fi
  done < "$TARGET_CONF"
}

# Check if a relative path is disallowed for a given tool.
# Supports exact match and glob patterns with * and **.
is_disallowed() {
  local tool="$1"
  local rel_path="$2"

  # Exact match
  [[ -n "${DISALLOW_MAP["${tool}|${rel_path}"]+x}" ]] && return 0

  # Check glob patterns
  for key in "${!DISALLOW_MAP[@]}"; do
    local key_tool="${key%%|*}"
    local key_pattern="${key#*|}"
    [[ "$key_tool" == "$tool" ]] || continue

    # Skip exact matches (already handled)
    [[ "$key_pattern" == "$rel_path" ]] && continue

    # Use bash pattern matching for globs
    # shellcheck disable=SC2254
    case "$rel_path" in
      $key_pattern) return 0 ;;
    esac
  done

  return 1
}

# ---------------------------------------------------------------------------
# Validate flags
# ---------------------------------------------------------------------------
VALID_TYPES="command,skill,agent,hook"
VALID_TARGETS="claude,cursor,codex,gemini,antigravity"

if [[ -n "$TYPE_FILTER" ]]; then
  IFS=',' read -ra _type_items <<< "$TYPE_FILTER"
  for _t in "${_type_items[@]}"; do
    _t="${_t// /}"
    if ! matches_filter "$_t" "$VALID_TYPES"; then
      err "abort" "Unknown artifact type '${_t}' in --type (valid: ${VALID_TYPES})"
      exit 1
    fi
  done
  unset _type_items _t
fi

if [[ -n "$TARGET_FILTER" ]]; then
  IFS=',' read -ra _target_items <<< "$TARGET_FILTER"
  for _tgt in "${_target_items[@]}"; do
    _tgt="${_tgt// /}"
    if ! matches_filter "$_tgt" "$VALID_TARGETS"; then
      err "abort" "Unknown deploy target '${_tgt}' in --target (valid: ${VALID_TARGETS})"
      exit 1
    fi
  done
  unset _target_items _tgt
fi

# ---------------------------------------------------------------------------
# App targets: id|label|base_dir
# ---------------------------------------------------------------------------
ALL_APP_TARGETS=(
  "cursor|Cursor|${CURSOR_DIR}"
  "claude|Claude Code|${CLAUDE_DIR}"
  "codex|OpenAI Codex|${CODEX_DIR}"
  "gemini|Gemini CLI|${GEMINI_DIR}"
  "antigravity|Antigravity|${ANTIGRAVITY_DIR}"
)

# Build filtered target list
APP_TARGETS=()
for target in "${ALL_APP_TARGETS[@]}"; do
  IFS='|' read -r app_id _label _dir <<< "$target"
  if matches_filter "$app_id" "$TARGET_FILTER"; then
    APP_TARGETS+=("$target")
  fi
done

if [[ ${#APP_TARGETS[@]} -eq 0 ]]; then
  err "abort" "No matching targets for --target '${TARGET_FILTER}'"
  exit 1
fi

logged_path_matches_active_targets() {
  local target_id="$1"
  local target

  for target in "${APP_TARGETS[@]}"; do
    local active_target_id _label _base_dir
    IFS='|' read -r active_target_id _label _base_dir <<< "$target"
    [[ "$active_target_id" == "$target_id" ]] && return 0
  done

  return 1
}

# ---------------------------------------------------------------------------
# Folder-based autodiscovery
#
# Scans top-level asset folders (agents/, commands/, skills/, hooks/).
# The folder name determines the artifact type.
# For skills: each subdirectory containing SKILL.md is one skill artifact.
# For others: each file in the folder is one artifact.
# ---------------------------------------------------------------------------
discover_artifacts() {
  local discovered=()

  for folder in "${!ASSET_FOLDERS[@]}"; do
    local art_type="${ASSET_FOLDERS[$folder]}"
    local folder_path="${REPO_ROOT}/${folder}"

    # Skip if folder doesn't exist
    [[ -d "$folder_path" ]] || continue

    # Skip if type doesn't match filter
    matches_filter "$art_type" "$TYPE_FILTER" || continue

    if [[ "$art_type" == "skill" ]]; then
      # Skills: each subdirectory with SKILL.md is an artifact
      for skill_dir in "$folder_path"/*/; do
        [[ -d "$skill_dir" ]] || continue
        [[ -f "${skill_dir}SKILL.md" ]] || continue
        local skill_name
        skill_name="$(basename "$skill_dir")"
        local rel_path="${folder}/${skill_name}"
        discovered+=("${skill_name}|${art_type}|${rel_path}")
      done
    else
      # Agents, commands, hooks: each file is an artifact
      for f in "$folder_path"/*; do
        [[ -f "$f" ]] || continue
        local bname
        bname="$(basename "$f")"
        # Skip hidden files
        [[ "$bname" == .* ]] && continue
        local name_no_ext="${bname%.*}"
        local rel_path="${folder}/${bname}"
        discovered+=("${name_no_ext}|${art_type}|${rel_path}")
      done
    fi
  done

  if [[ ${#discovered[@]} -gt 0 ]]; then
    printf '%s\n' "${discovered[@]}"
  fi
}

# ---------------------------------------------------------------------------
# Symlink creation
# ---------------------------------------------------------------------------
create_symlink() {
  local source="$1"
  local target="$2"
  local target_id="$3"
  local artifact_type="$4"

  if [[ ! -e "$source" && ! -d "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  if $DRY_RUN; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-link" "$target -> $source"
    return 0
  fi

  if [[ -L "$target" ]]; then
    rm "$target"
  elif [[ -e "$target" ]]; then
    warn "skip" "$target exists and is not a symlink — refusing to overwrite"
    return 1
  fi

  ln -s "$source" "$target"
  ok "linked" "$target -> $source"
  SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  append_deployed_artifact_log "$target" "$target_id" "$artifact_type" "$source"
}

# ---------------------------------------------------------------------------
# Copy a file (used where a target's file watcher does not follow symlinks)
# ---------------------------------------------------------------------------
copy_file() {
  local source="$1"
  local target="$2"
  local target_id="$3"
  local artifact_type="$4"

  if [[ ! -f "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  if $DRY_RUN; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-copy" "$target <- $source"
    return 0
  fi

  if [[ -L "$target" || -f "$target" ]]; then rm "$target"; fi

  cp "$source" "$target"
  ok "copied" "$target <- $source"
  SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  append_deployed_artifact_log "$target" "$target_id" "$artifact_type" "$source"
}

# ---------------------------------------------------------------------------
# Merge a top-level JSON key from a source file into a target JSON file.
# Creates the target if it doesn't exist. Logs with path[key] notation.
# An optional hooks_dir rewrites relative ./hooks/ command paths to absolute
# paths so the config works from any working directory.
# ---------------------------------------------------------------------------
merge_json_key() {
  local source="$1"
  local target="$2"
  local key="$3"
  local target_id="$4"
  local artifact_type="$5"
  local hooks_dir="${6:-}"

  if [[ ! -f "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  local log_path="${target}[${key}]"

  if $DRY_RUN; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-merge" "${target} <- .${key} from ${source}"
    return 0
  fi

  local existing="{}"
  if [[ -f "$target" ]]; then
    existing="$(cat "$target")"
  fi

  local patch
  patch="$(jq ".${key}" "$source")"

  # Rewrite relative ./hooks/ command paths to absolute paths
  if [[ -n "$hooks_dir" ]]; then
    patch="$(printf '%s' "$patch" | jq --arg dir "$hooks_dir" '
      walk(if type == "object" and .command and (.command | startswith("./hooks/"))
           then .command = ($dir + "/" + (.command | ltrimstr("./hooks/")))
           else . end)')"
  fi

  local merged
  merged="$(printf '%s' "$existing" | jq --argjson patch "$patch" ".${key} = \$patch")"

  printf '%s\n' "$merged" > "$target"
  ok "merged" "${target} <- .${key}"
  SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  append_deployed_artifact_log "$log_path" "$target_id" "$artifact_type" "$source"
}

# ---------------------------------------------------------------------------
# Remove a top-level JSON key from a file. Used during uninstall for
# artifacts logged with path[key] notation.
# ---------------------------------------------------------------------------
strip_json_key() {
  local target="$1"
  local key="$2"

  if [[ ! -f "$target" ]]; then
    return 1
  fi

  if $DRY_RUN; then
    SUMMARY_UNINSTALL_ACTIONS=$((SUMMARY_UNINSTALL_ACTIONS + 1))
    info "would-strip" "${target} .${key}"
    return 0
  fi

  local stripped
  stripped="$(jq "del(.${key})" "$target")"
  printf '%s\n' "$stripped" > "$target"
  ok "stripped" "${target} .${key}"
  SUMMARY_UNINSTALL_ACTIONS=$((SUMMARY_UNINSTALL_ACTIONS + 1))
}

# ---------------------------------------------------------------------------
# Generate a .toml command for Gemini CLI from a .md source
# ---------------------------------------------------------------------------
generate_toml_command() {
  local source="$1"
  local dest="$2"
  local target_id="$3"
  local artifact_type="$4"

  if [[ ! -f "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  local description=""
  local prompt=""
  local in_body=false

  while IFS= read -r line; do
    if [[ -z "$description" && "$line" =~ ^#[[:space:]]+(.*) ]]; then
      description="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ -z "$description" ]]; then continue; fi
    if ! $in_body && [[ -z "$line" ]]; then continue; fi
    in_body=true
    prompt+="${line}"$'\n'
  done < "$source"

  prompt="${prompt%$'\n'}"

  if $DRY_RUN; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-gen" "$dest (.toml)"
    return 0
  fi

  if [[ -L "$dest" || -f "$dest" ]]; then rm "$dest"; fi

  cat > "$dest" <<TOML
description = "${description//\"/\\\"}"
prompt = """
${prompt}
"""
TOML

  ok "generated" "$dest (.toml)"
  SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  append_deployed_artifact_log "$dest" "$target_id" "$artifact_type" "$source"
}

# ---------------------------------------------------------------------------
# Generate a .md workflow for Antigravity from a .md command source
# ---------------------------------------------------------------------------
generate_antigravity_workflow() {
  local source="$1"
  local dest="$2"
  local target_id="$3"
  local artifact_type="$4"

  if [[ ! -f "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  local description=""
  local body=""
  local in_body=false

  while IFS= read -r line; do
    if [[ -z "$description" && "$line" =~ ^#[[:space:]]+(.*) ]]; then
      description="${BASH_REMATCH[1]}"
      continue
    fi
    if [[ -z "$description" ]]; then continue; fi
    if ! $in_body && [[ -z "$line" ]]; then continue; fi
    in_body=true
    body+="${line}"$'\n'
  done < "$source"

  body="${body%$'\n'}"

  if $DRY_RUN; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-gen" "$dest (.md workflow)"
    return 0
  fi

  if [[ -L "$dest" || -f "$dest" ]]; then rm "$dest"; fi

  cat > "$dest" <<WORKFLOW
---
description: ${description}
---

${body}
WORKFLOW

  ok "generated" "$dest (.md workflow)"
  SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  append_deployed_artifact_log "$dest" "$target_id" "$artifact_type" "$source"
}

# ---------------------------------------------------------------------------
# Rewrite agent frontmatter for a specific target tool.
#
# Source .md files may contain vendor-prefixed frontmatter fields:
#   TOOLNAME_fieldname: value
# where TOOLNAME is an UPPERCASE target ID (CURSOR, CLAUDE, CODEX, …).
#
# For target tool X the rewriter:
#   1. Keeps non-prefixed lines unchanged (universal fields)
#   2. Strips the X_ prefix from X_fieldname lines (→ fieldname: value)
#   3. Drops lines prefixed with any other known tool ID
#
# Body content after the closing --- is passed through unchanged.
# ---------------------------------------------------------------------------
rewrite_agent_frontmatter() {
  local source="$1" dest="$2" target_id="$3" quiet="${4:-false}"

  if [[ ! -f "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  # Build uppercase target ID for matching
  local uc_target
  uc_target="$(printf '%s' "$target_id" | tr '[:lower:]' '[:upper:]')"

  # Build list of ALL known uppercase tool IDs from VALID_TARGETS
  local known_prefixes=()
  IFS=',' read -ra _vt <<< "$VALID_TARGETS"
  for _t in "${_vt[@]}"; do
    known_prefixes+=("$(printf '%s' "$_t" | tr '[:lower:]' '[:upper:]')")
  done
  unset _vt _t

  local in_frontmatter=false frontmatter_done=false
  local output=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    if ! $frontmatter_done && [[ "$line" == "---" ]]; then
      output+="---"$'\n'
      if $in_frontmatter; then
        in_frontmatter=false
        frontmatter_done=true
      else
        in_frontmatter=true
      fi
      continue
    fi

    if $in_frontmatter; then
      # Check if the line has a TOOLNAME_ prefix (uppercase letters followed by _)
      if [[ "$line" =~ ^([A-Z]+)_([a-z_]+:[[:space:]]*.+)$ ]]; then
        local prefix="${BASH_REMATCH[1]}"
        local rest="${BASH_REMATCH[2]}"
        # If prefix matches target tool, emit without prefix
        if [[ "$prefix" == "$uc_target" ]]; then
          output+="${rest}"$'\n'
          continue
        fi
        # If prefix matches another known tool, drop the line
        local is_known=false
        for kp in "${known_prefixes[@]}"; do
          if [[ "$prefix" == "$kp" ]]; then
            is_known=true
            break
          fi
        done
        if $is_known; then
          continue
        fi
      fi
      # Non-prefixed line or unknown prefix — keep as-is
      output+="${line}"$'\n'
      continue
    fi

    # Body — pass through unchanged
    output+="${line}"$'\n'
  done < "$source"

  if $DRY_RUN && ! $quiet; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-gen" "$dest (rewritten agent)"
    return 0
  fi

  if [[ -L "$dest" || -f "$dest" ]]; then rm "$dest"; fi

  printf '%s' "$output" > "$dest"
  if ! $quiet; then
    ok "rewritten" "$dest <- $source (target: $target_id)"
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  fi
}

# ---------------------------------------------------------------------------
# Generate a .toml agent for Codex CLI from a vendor-rewritten .md agent
# ---------------------------------------------------------------------------
generate_toml_agent() {
  local source="$1"
  local dest="$2"
  local target_id="$3"
  local artifact_type="$4"

  if [[ ! -f "$source" ]]; then
    err "missing" "source not found: $source"
    return 1
  fi

  # Rewrite vendor-prefixed frontmatter to a temp file first (quiet mode
  # suppresses logging and dry-run short-circuit so the file is always written)
  local tmp_rewritten
  tmp_rewritten="$(mktemp)"
  rewrite_agent_frontmatter "$source" "$tmp_rewritten" "$target_id" true

  local name="" description="" model="" model_reasoning_effort="" readonly="" body=""
  local in_frontmatter=false frontmatter_done=false in_body=false

  while IFS= read -r line; do
    if ! $frontmatter_done && [[ "$line" == "---" ]]; then
      if $in_frontmatter; then
        in_frontmatter=false
        frontmatter_done=true
      else
        in_frontmatter=true
      fi
      continue
    fi

    if $in_frontmatter; then
      if [[ "$line" =~ ^name:[[:space:]]*(.+) ]]; then
        name="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^description:[[:space:]]*(.+) ]]; then
        description="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^model:[[:space:]]*(.+) ]]; then
        model="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^model_reasoning_effort:[[:space:]]*(.+) ]]; then
        model_reasoning_effort="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^readonly:[[:space:]]*(.+) ]]; then
        readonly="${BASH_REMATCH[1]}"
      fi
      continue
    fi

    if $frontmatter_done; then
      if ! $in_body && [[ -z "$line" ]]; then continue; fi
      in_body=true
      body+="${line}"$'\n'
    fi
  done < "$tmp_rewritten"

  rm -f "$tmp_rewritten"
  body="${body%$'\n'}"

  if $DRY_RUN; then
    SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
    info "would-gen" "$dest (.toml agent)"
    return 0
  fi

  if [[ -L "$dest" || -f "$dest" ]]; then rm "$dest"; fi

  {
    [[ -n "$name" ]] && printf 'name = "%s"\n' "${name//\"/\\\"}"
    [[ -n "$description" ]] && printf 'description = "%s"\n' "${description//\"/\\\"}"
    [[ -n "$model" ]] && printf 'model = "%s"\n' "${model//\"/\\\"}"
    [[ -n "$model_reasoning_effort" ]] && printf 'model_reasoning_effort = "%s"\n' "${model_reasoning_effort//\"/\\\"}"
    if [[ "$readonly" == "true" ]]; then
      printf 'sandbox_mode = "read-only"\n'
    fi
    printf 'developer_instructions = """\n%s\n"""\n' "$body"
  } > "$dest"

  ok "generated" "$dest (.toml agent)"
  SUMMARY_DEPLOY_ACTIONS=$((SUMMARY_DEPLOY_ACTIONS + 1))
  append_deployed_artifact_log "$dest" "$target_id" "$artifact_type" "$source"
}

# ---------------------------------------------------------------------------
# Install a single artifact into one app target
# ---------------------------------------------------------------------------
install_for_app() {
  local app_id="$1" app_dir="$2" name="$3" type="$4" source_abs="$5"

  case "$type" in
    command)
      case "$app_id" in
        gemini)
          local dest_dir="${app_dir}/commands"
          ensure_dir "$dest_dir"
          generate_toml_command "$source_abs" "${dest_dir}/${name}.toml" "$app_id" "$type"
          ;;
        antigravity)
          local dest_dir="${app_dir}/workflows"
          ensure_dir "$dest_dir"
          generate_antigravity_workflow "$source_abs" "${dest_dir}/${name}.md" "$app_id" "$type"
          ;;
        codex)
          local dest_dir="${app_dir}/prompts"
          ensure_dir "$dest_dir"
          create_symlink "$source_abs" "${dest_dir}/${name}.md" "$app_id" "$type"
          ;;
        *)
          local dest_dir="${app_dir}/commands"
          ensure_dir "$dest_dir"
          create_symlink "$source_abs" "${dest_dir}/${name}.md" "$app_id" "$type"
          ;;
      esac
      ;;
    skill)
      local dest_dir="${app_dir}/skills"
      ensure_dir "$dest_dir"
      create_symlink "$source_abs" "${dest_dir}/${name}" "$app_id" "$type"
      ;;
    agent)
      case "$app_id" in
        cursor|claude|gemini)
          local dest_dir="${app_dir}/agents"
          ensure_dir "$dest_dir"
          local dest_path="${dest_dir}/${name}.md"
          rewrite_agent_frontmatter "$source_abs" "$dest_path" "$app_id"
          $DRY_RUN || append_deployed_artifact_log "$dest_path" "$app_id" "$type" "$source_abs"
          ;;
        codex)
          local dest_dir="${app_dir}/agents"
          ensure_dir "$dest_dir"
          generate_toml_agent "$source_abs" "${dest_dir}/${name}.toml" "$app_id" "$type"
          ;;
        antigravity)
          info "skip" "[$name] Antigravity does not support agent definitions"
          ;;
      esac
      ;;
    hook)
      local src_ext="${source_abs##*.}"
      case "$app_id" in
        cursor)
          if [[ "$src_ext" == "json" ]]; then
            # Only deploy the Cursor-specific config; skip other JSON configs
            [[ "$source_abs" == *cursor-hooks* ]] || { info "skip" "[$name] not a Cursor hook config"; return 0; }
            copy_file "$source_abs" "${app_dir}/hooks.json" "$app_id" "$type"
          elif [[ "$src_ext" == "sh" ]]; then
            local dest_dir="${app_dir}/hooks"
            ensure_dir "$dest_dir"
            local dest_file="${dest_dir}/$(basename "$source_abs")"
            copy_file "$source_abs" "$dest_file" "$app_id" "$type"
            if ! $DRY_RUN; then chmod +x "$dest_file"; fi
          fi
          ;;
        claude)
          if [[ "$src_ext" == "json" ]]; then
            # Only deploy the Claude Code-specific config; skip other JSON configs
            [[ "$source_abs" == *claude-code-hooks* ]] || { info "skip" "[$name] not a Claude hook config"; return 0; }
            # Merge the hooks key into ~/.claude/settings.json with absolute script paths
            merge_json_key "$source_abs" "${app_dir}/settings.json" "hooks" "$app_id" "$type" "${app_dir}/hooks"
          elif [[ "$src_ext" == "sh" ]]; then
            local dest_dir="${app_dir}/hooks"
            ensure_dir "$dest_dir"
            local dest_file="${dest_dir}/$(basename "$source_abs")"
            copy_file "$source_abs" "$dest_file" "$app_id" "$type"
            if ! $DRY_RUN; then chmod +x "$dest_file"; fi
          fi
          ;;
        *)
          info "skip" "[$name] Hooks not supported for $app_id"
          ;;
      esac
      ;;
    *)
      err "unknown" "artifact type: $type"
      return 1
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Backup — only activated targets
# ---------------------------------------------------------------------------
TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"

is_managed_backup_path() {
  local app_dir="$1"
  local candidate="$2"

  [[ "$candidate" = /* ]] || return 1
  [[ "$(dirname "$candidate")" == "$HOME_DIR" ]] || return 1
  [[ "$candidate" != "$app_dir" ]] || return 1

  local app_name backup_name suffix
  app_name="$(basename "$app_dir")"
  backup_name="$(basename "$candidate")"

  [[ "$backup_name" == "${app_name}_"* ]] || return 1
  suffix="${backup_name#"${app_name}"_}"
  [[ "$suffix" =~ ^[0-9]{8}_[0-9]{6}$ ]]
}

clear_old_backups_for_app_dir() {
  local app_dir="$1"
  local app_name
  app_name="$(basename "$app_dir")"

  local _old_nullglob
  _old_nullglob="$(shopt -p nullglob)" || true
  shopt -s nullglob

  local candidate
  for candidate in "${HOME_DIR}/${app_name}_"*; do
    if ! is_managed_backup_path "$app_dir" "$candidate"; then
      continue
    fi

    if $DRY_RUN; then
      SUMMARY_CLEARED_BACKUPS=$((SUMMARY_CLEARED_BACKUPS + 1))
      info "would-clr" "$candidate"
      continue
    fi

    if [[ -L "$candidate" || -f "$candidate" ]]; then
      rm -f "$candidate"
    elif [[ -d "$candidate" ]]; then
      rm -rf "$candidate"
    else
      continue
    fi

    ok "cleared" "$candidate"
    SUMMARY_CLEARED_BACKUPS=$((SUMMARY_CLEARED_BACKUPS + 1))
  done

  eval "$_old_nullglob"
}

backup_app_dir() {
  local app_dir="$1"
  local app_name
  app_name="$(basename "$app_dir")"
  local backup_dir="${HOME_DIR}/${app_name}_${TIMESTAMP}"

  if [[ ! -d "$app_dir" ]]; then
    info "no backup" "$app_dir does not exist yet"
    return 0
  fi

  if $DRY_RUN; then
    SUMMARY_BACKUPS=$((SUMMARY_BACKUPS + 1))
    info "would-bak" "$app_dir -> $backup_dir"
    return 0
  fi

  cp -a "$app_dir" "$backup_dir"
  ok "backup" "$backup_dir"
  SUMMARY_BACKUPS=$((SUMMARY_BACKUPS + 1))
}

logged_type_matches_filter() {
  local artifact_type="$1"
  matches_filter "$artifact_type" "$TYPE_FILTER"
}

remove_logged_path() {
  local path="$1"

  # Handle path[key] notation — strip a JSON key instead of deleting the file
  if [[ "$path" =~ ^(.+)\[([a-zA-Z_][a-zA-Z0-9_]*)\]$ ]]; then
    local json_file="${BASH_REMATCH[1]}"
    local json_key="${BASH_REMATCH[2]}"
    strip_json_key "$json_file" "$json_key"
    return $?
  fi

  if [[ "$path" == "$REPO_ROOT/"* ]]; then
    local repo_rel="${path#"$REPO_ROOT"/}"
    if git -C "$REPO_ROOT" ls-files --error-unmatch -- "$repo_rel" >/dev/null 2>&1; then
      git -C "$REPO_ROOT" rm -r --force -- "$repo_rel" >/dev/null 2>&1
      return $?
    fi
  fi

  if [[ -L "$path" || -f "$path" ]]; then
    rm -f "$path"
  elif [[ -d "$path" ]]; then
    rm -rf "$path"
  else
    return 1
  fi
}

uninstall_logged_artifacts() {
  echo "Uninstalling logged artifacts..."
  echo ""

  if [[ ! -f "$DEPLOYED_ARTIFACTS_LOG" ]]; then
    info "skip" "No deploy log found at $DEPLOYED_ARTIFACTS_LOG"
    return 0
  fi

  local remaining_entries=()
  local removed_count=0
  local logged_entry=""

  while IFS= read -r logged_entry || [[ -n "$logged_entry" ]]; do
    [[ -n "$logged_entry" ]] || continue

    local logged_path="" logged_target_id="" logged_type="" logged_source=""
    IFS=$'\t' read -r logged_path logged_target_id logged_type logged_source <<< "$logged_entry"

    if [[ -z "$logged_path" || -z "$logged_target_id" || -z "$logged_type" || -z "$logged_source" ]]; then
      warn "skip" "Malformed log entry: $logged_entry"
      remaining_entries+=("$logged_entry")
      continue
    fi

    if ! logged_path_matches_active_targets "$logged_target_id"; then
      if [[ -z "$TARGET_FILTER" ]]; then
        info "stale" "$logged_path targets removed app '$logged_target_id'"
      else
        remaining_entries+=("$logged_entry")
        continue
      fi
    fi

    if ! logged_type_matches_filter "$logged_type"; then
      remaining_entries+=("$logged_entry")
      continue
    fi

    if $DRY_RUN; then
      SUMMARY_UNINSTALL_ACTIONS=$((SUMMARY_UNINSTALL_ACTIONS + 1))
      info "would-rm" "$logged_path"
      remaining_entries+=("$logged_entry")
      continue
    fi

    if ! path_exists "$logged_path"; then
      ok "cleaned" "$logged_path already absent"
      SUMMARY_UNINSTALL_ACTIONS=$((SUMMARY_UNINSTALL_ACTIONS + 1))
      removed_count=$((removed_count + 1))
      continue
    fi

    if ! remove_logged_path "$logged_path"; then
      err "failed" "Could not remove $logged_path"
      remaining_entries+=("$logged_entry")
      continue
    fi

    if path_exists "$logged_path"; then
      err "failed" "$logged_path still exists after removal"
      remaining_entries+=("$logged_entry")
      continue
    fi

    ok "removed" "$logged_path"
    SUMMARY_UNINSTALL_ACTIONS=$((SUMMARY_UNINSTALL_ACTIONS + 1))
    removed_count=$((removed_count + 1))
  done < "$DEPLOYED_ARTIFACTS_LOG"

  if $DRY_RUN; then
    return 0
  fi

  local tmp
  tmp="$(mktemp)"
  if [[ ${#remaining_entries[@]} -gt 0 ]]; then
    printf '%s\n' "${remaining_entries[@]}" > "$tmp"
  fi
  mv "$tmp" "$DEPLOYED_ARTIFACTS_LOG"
  info "log" "Removed ${removed_count} item(s); kept ${#remaining_entries[@]} item(s)"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo ""
echo "Repo root:     $REPO_ROOT"
echo "Home:          $HOME_DIR"
$DRY_RUN && echo "Mode:          DRY RUN (simulated only, no changes written)"
$UNINSTALL && echo "Uninstall:     enabled"
$CLEAR_BACKUPS && echo "Clear backups: enabled"
[[ -n "$TYPE_FILTER" ]] && echo "Types:         $TYPE_FILTER"
[[ -n "$TARGET_FILTER" ]] && echo "Targets:       $TARGET_FILTER"
[[ -f "$TARGET_CONF" ]] && echo "Config:        $TARGET_CONF"
echo ""

# Parse target_conf.txt
parse_target_conf

# ---------------------------------------------------------------------------
# Backup activated targets only
# ---------------------------------------------------------------------------
echo "Backing up activated target directories..."
echo ""

declare -A backed_up=()
for target in "${APP_TARGETS[@]}"; do
  IFS='|' read -r app_id _label base_dir <<< "$target"
  backup_root="$base_dir"
  if [[ "$app_id" == "antigravity" ]]; then
    backup_root="${GEMINI_DIR}"
  fi
  if [[ -z "${backed_up[$backup_root]+x}" ]]; then
    if $CLEAR_BACKUPS; then
      clear_old_backups_for_app_dir "$backup_root"
    fi
    backup_app_dir "$backup_root"
    backed_up["$backup_root"]=1
  fi
done

echo ""

if $UNINSTALL; then
  uninstall_logged_artifacts
  echo ""
  print_summary
  echo ""
  echo "Done."
  exit 0
fi

# ---------------------------------------------------------------------------
# Discover artifacts
# ---------------------------------------------------------------------------
echo "Discovering artifacts..."
echo ""

ARTIFACTS=()
while IFS= read -r line; do
  [[ -n "$line" ]] && ARTIFACTS+=("$line")
done < <(discover_artifacts)

if [[ ${#ARTIFACTS[@]} -eq 0 ]]; then
  warn "empty" "No artifacts found matching the given filters"
  echo ""
  echo "Done (nothing to deploy)."
  exit 0
fi

echo "  Found ${#ARTIFACTS[@]} artifact(s):"
for entry in "${ARTIFACTS[@]}"; do
  IFS='|' read -r name type _rel <<< "$entry"
  printf "    \033[36m%-30s\033[0m %s\n" "$name" "$type"
done
echo ""

# ---------------------------------------------------------------------------
# Ensure base directories exist for activated targets
# ---------------------------------------------------------------------------
for target in "${APP_TARGETS[@]}"; do
  IFS='|' read -r _id _label base_dir <<< "$target"
  ensure_dir "$base_dir"
done

echo ""
echo "Installing artifacts..."
echo ""

for entry in "${ARTIFACTS[@]}"; do
  IFS='|' read -r name type rel_path <<< "$entry"
  source_abs="${REPO_ROOT}/${rel_path}"
  printf "  \033[1m%s\033[0m (%s)\n" "$name" "$type"

  for target in "${APP_TARGETS[@]}"; do
    IFS='|' read -r app_id _ base_dir <<< "$target"

    # Check target_conf.txt disallow rules
    if is_disallowed "$app_id" "$rel_path"; then
      info "disallow" "[$name] excluded for $app_id (target_conf.txt)"
      continue
    fi

    install_for_app "$app_id" "$base_dir" "$name" "$type" "$source_abs"
  done

  echo ""
done

echo ""
print_summary
echo ""
echo "Done."
