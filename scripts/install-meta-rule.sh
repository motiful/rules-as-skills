#!/usr/bin/env bash
# install-meta-rule.sh — inject the rule-skill hard-constraint meta-rule into
# detected agent platforms' global rule files.
#
# Usage:
#   ./install-meta-rule.sh install [--yes] [--force] [--dry-run]
#   ./install-meta-rule.sh uninstall [--yes] [--dry-run]
#   ./install-meta-rule.sh status
#
# See references/meta-rule-content.md for the canonical meta-rule text.
# See SKILL.md §Platform Adaptation for the target path table.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONTENT_FILE="${SKILL_ROOT}/references/meta-rule-content.md"

MARKER_START="<!-- rules-as-skills-meta:start -->"
MARKER_END="<!-- rules-as-skills-meta:end -->"

# -----------------------------------------------------------------------------
# Platform registry — (name, detect_dir, target_file, status)
# Status: primary | experimental
# -----------------------------------------------------------------------------

PLATFORMS=(
  "claude-code|${HOME}/.claude|${HOME}/.claude/rules/rules-as-skills-meta.md|primary"
  "codex|${HOME}/.codex|${HOME}/.codex/rules/rules-as-skills-meta.rules|primary"
  "openclaw|${HOME}/.openclaw|${HOME}/.openclaw/AGENTS-RULES.md|experimental"
  "cursor|${HOME}/.cursor|${HOME}/.cursor/rules/rules-as-skills-meta.mdc|experimental"
  "windsurf|${HOME}/.codeium/windsurf|${HOME}/.codeium/windsurf/global_rules.md|experimental"
)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

log() { printf '%s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
err() { printf 'error: %s\n' "$*" >&2; exit 1; }

extract_injection_block() {
  # Pull the fenced markdown block between MARKER_START and MARKER_END out of
  # meta-rule-content.md. That block IS the meta-rule, byte-for-byte.
  [[ -f "${CONTENT_FILE}" ]] || err "missing content file: ${CONTENT_FILE}"

  awk -v start="${MARKER_START}" -v end="${MARKER_END}" '
    $0 == start { inside = 1 }
    inside      { print }
    $0 == end   { inside = 0 }
  ' "${CONTENT_FILE}"
}

platform_installed() {
  local dir="$1"
  [[ -d "${dir}" ]]
}

file_has_markers() {
  local file="$1"
  [[ -f "${file}" ]] && grep -qF "${MARKER_START}" "${file}" && grep -qF "${MARKER_END}" "${file}"
}

confirm() {
  local prompt="$1"
  if [[ "${ASSUME_YES}" == "1" ]]; then
    return 0
  fi
  read -r -p "${prompt} [y/N] " reply
  [[ "${reply,,}" == "y" || "${reply,,}" == "yes" ]]
}

preflight_table() {
  printf '%-14s %-14s %-12s %s\n' "PLATFORM" "STATUS" "DETECTED" "TARGET"
  printf '%-14s %-14s %-12s %s\n' "--------" "------" "--------" "------"
  local row name detect target level detected
  for row in "${PLATFORMS[@]}"; do
    IFS='|' read -r name detect target level <<< "${row}"
    if platform_installed "${detect}"; then detected="yes"; else detected="no"; fi
    printf '%-14s %-14s %-12s %s\n' "${name}" "${level}" "${detected}" "${target}"
  done
}

# -----------------------------------------------------------------------------
# Actions
# -----------------------------------------------------------------------------

do_install_platform() {
  local name="$1" target="$2" force="$3" dry="$4"
  local block parent

  block="$(extract_injection_block)"
  [[ -n "${block}" ]] || err "extraction produced empty block — check markers in ${CONTENT_FILE}"

  parent="$(dirname "${target}")"

  if file_has_markers "${target}" && [[ "${force}" != "1" ]]; then
    log "  [${name}] already installed — skipping (use --force to replace)"
    return 0
  fi

  if [[ "${dry}" == "1" ]]; then
    log "  [${name}] DRY-RUN would write to: ${target}"
    return 0
  fi

  mkdir -p "${parent}"

  if file_has_markers "${target}"; then
    # --force: replace existing block
    local tmp
    tmp="$(mktemp)"
    awk -v start="${MARKER_START}" -v end="${MARKER_END}" -v repl="${block}" '
      BEGIN { skip = 0 }
      $0 == start { print repl; skip = 1; next }
      $0 == end   { skip = 0; next }
      skip == 0   { print }
    ' "${target}" > "${tmp}"
    mv "${tmp}" "${target}"
    log "  [${name}] replaced meta-rule block in ${target}"
  else
    # Append (with a blank line separator if file already has content)
    if [[ -s "${target}" ]]; then
      printf '\n%s\n' "${block}" >> "${target}"
    else
      printf '%s\n' "${block}" >> "${target}"
    fi
    log "  [${name}] injected meta-rule into ${target}"
  fi
}

do_uninstall_platform() {
  local name="$1" target="$2" dry="$3"

  if ! file_has_markers "${target}"; then
    log "  [${name}] no meta-rule block found — skipping"
    return 0
  fi

  if [[ "${dry}" == "1" ]]; then
    log "  [${name}] DRY-RUN would remove block from: ${target}"
    return 0
  fi

  local tmp
  tmp="$(mktemp)"
  awk -v start="${MARKER_START}" -v end="${MARKER_END}" '
    BEGIN { skip = 0 }
    $0 == start { skip = 1; next }
    $0 == end   { skip = 0; next }
    skip == 0   { print }
  ' "${target}" > "${tmp}"
  mv "${tmp}" "${target}"
  log "  [${name}] removed meta-rule block from ${target}"
}

cmd_install() {
  local force="${FORCE}"
  local dry="${DRY_RUN}"
  local include_exp="${INCLUDE_EXPERIMENTAL}"

  log "Preflight — detected platforms:"
  preflight_table
  log ""
  if [[ "${include_exp}" != "1" ]]; then
    log "Note: experimental platforms are skipped by default."
    log "      Pass --include-experimental to inject them too."
    log ""
  fi

  if [[ "${dry}" != "1" ]]; then
    confirm "Proceed with install?" || { log "aborted"; exit 0; }
  fi

  local row name detect target level
  for row in "${PLATFORMS[@]}"; do
    IFS='|' read -r name detect target level <<< "${row}"
    if ! platform_installed "${detect}"; then
      continue
    fi
    if [[ "${level}" == "experimental" && "${include_exp}" != "1" ]]; then
      log "  [${name}] experimental — skipped (use --include-experimental)"
      continue
    fi
    do_install_platform "${name}" "${target}" "${force}" "${dry}"
  done

  log ""
  log "Done. Run './install-meta-rule.sh status' to verify."
}

cmd_uninstall() {
  local dry="${DRY_RUN}"

  log "Preflight — platforms with meta-rule block:"
  local row name detect target level any=0
  for row in "${PLATFORMS[@]}"; do
    IFS='|' read -r name detect target level <<< "${row}"
    if file_has_markers "${target}"; then
      log "  [${name}] ${target}"
      any=1
    fi
  done
  [[ "${any}" == "1" ]] || { log "  (none)"; exit 0; }
  log ""

  if [[ "${dry}" != "1" ]]; then
    confirm "Remove meta-rule from these platforms?" || { log "aborted"; exit 0; }
  fi

  for row in "${PLATFORMS[@]}"; do
    IFS='|' read -r name detect target level <<< "${row}"
    do_uninstall_platform "${name}" "${target}" "${dry}"
  done
}

cmd_status() {
  log "Platform status:"
  local row name detect target level installed
  for row in "${PLATFORMS[@]}"; do
    IFS='|' read -r name detect target level <<< "${row}"
    if ! platform_installed "${detect}"; then
      installed="n/a (platform not installed)"
    elif file_has_markers "${target}"; then
      installed="installed"
    else
      installed="not installed"
    fi
    printf '  [%-14s] %-14s %s\n' "${name}" "${level}" "${installed}"
  done
}

# -----------------------------------------------------------------------------
# Arg parsing
# -----------------------------------------------------------------------------

ASSUME_YES=0
FORCE=0
DRY_RUN=0
INCLUDE_EXPERIMENTAL=0
ACTION="${1:-}"
shift || true

for arg in "$@"; do
  case "${arg}" in
    --yes|-y) ASSUME_YES=1 ;;
    --force)  FORCE=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --include-experimental) INCLUDE_EXPERIMENTAL=1 ;;
    *) err "unknown flag: ${arg}" ;;
  esac
done

case "${ACTION}" in
  install)   cmd_install ;;
  uninstall) cmd_uninstall ;;
  status)    cmd_status ;;
  ""|-h|--help|help)
    cat <<EOF
install-meta-rule.sh — activate the rule-skill hard-constraint meta-rule.

Usage:
  ./install-meta-rule.sh install [--yes] [--force] [--dry-run] [--include-experimental]
  ./install-meta-rule.sh uninstall [--yes] [--dry-run]
  ./install-meta-rule.sh status

Flags:
  --yes, -y                 Skip confirmation prompt (for CI / scripting)
  --force                   Replace an existing block instead of skipping
  --dry-run                 Show what would happen without writing files
  --include-experimental    Inject into experimental platforms too (default: skip)

See references/meta-rule-content.md for the injected text and
SKILL.md §Platform Adaptation for per-platform target paths.
EOF
    ;;
  *) err "unknown action: ${ACTION} (try 'help')" ;;
esac
