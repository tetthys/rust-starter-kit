#!/usr/bin/env bash
# Shared helpers for run-scripts (color, logging, timing, summaries, docker wrap, spinner, sections, confirm).
set -euo pipefail

# -----------------------------
# Compose / Service
# -----------------------------
SERVICE="${SERVICE:-rust}"
DC="${DOCKER_COMPOSE:-docker compose}"
NON_TTY_FLAGS=(-T)

require_compose_root() {
  if [[ ! -f "docker-compose.yaml" ]]; then
    echo "ERROR: Run these scripts from the repo root (docker-compose.yaml not found)." >&2
    exit 1
  fi
}

# Run inside container (non-interactive)
in_container() {
  # shellcheck disable=SC2068
  ${DC} run --rm "${NON_TTY_FLAGS[@]}" "${SERVICE}" $@
}

# Run inside container (interactive TTY)
in_container_tty() {
  ${DC} run --rm "${SERVICE}" "$@"
}

# -----------------------------
# Colors / Logging
# -----------------------------
_init_colors() {
  if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    B="$(tput bold)"; D="$(tput dim)"; R="$(tput sgr0)"
    RED="$(tput setaf 1)"; GRN="$(tput setaf 2)"; YEL="$(tput setaf 3)"
    BLU="$(tput setaf 4)"; MAG="$(tput setaf 5)"; CYN="$(tput setaf 6)"
  else
    B=""; D=""; R=""; RED=""; GRN=""; YEL=""; BLU=""; MAG=""; CYN=""
  fi
}
_init_colors

log_ok()    { printf "%b✔%b %s\n" "${GRN}${B}" "${R}" "$*"; }
log_fail()  { printf "%b✘%b %s\n" "${RED}${B}" "${R}" "$*"; }
log_info()  { printf "%b➜%b %s\n" "${CYN}${B}" "${R}" "$*"; }
log_warn()  { printf "%b!%b %s\n"  "${YEL}${B}" "${R}" "$*"; }

# Pretty top-level title
log_title(){ printf "\n%b%s%b\n" "${MAG}${B}" "──── $* ────" "${R}"; }

# -----------------------------
# Sections (nested headings)
# -----------------------------
# Use section_open/section_close to visually group steps with indentation.
__SECTION_DEPTH=0
section_open() {
  __SECTION_DEPTH=$((__SECTION_DEPTH+1))
  local indent
  indent="$(printf '%*s' $(( (__SECTION_DEPTH-1)*2 )) '')"
  printf "\n%s%s %s%s\n" "${indent}" "${B}${MAG}›${R}" "${B}$*${R}" ""
}
section_close() {
  if (( __SECTION_DEPTH > 0 )); then
    __SECTION_DEPTH=$((__SECTION_DEPTH-1))
  fi
}
# Convenience: run a command group inside a section.
# Usage: with_section "Title" <commands...>
with_section() {
  local title="$1"; shift
  section_open "$title"
  # shellcheck disable=SC2068
  { "$@" ; } || { section_close; return 1; }
  section_close
}

# -----------------------------
# Timing / Summary
# -----------------------------
ts() { date +%s; }
_start_timer() { __START_TS="$(ts)"; }
_elapsed() { echo $(( $(ts) - __START_TS )); }

# Install a pretty summary trap for the whole script
summary_trap_enable() {
  __START_TS="$(ts)"
  trap '__code=$?; __dur=$(( $(ts) - __START_TS ));
    if [[ $__code -eq 0 ]]; then
      printf "\n%bALL GOOD%b ✅  %b(total: %ds)%b\n\n" "${GRN}${B}" "${R}" "${D}" "$__dur" "${R}"
    else
      printf "\n%bFAILED%b ❌  %b(total: %ds, exit %d)%b\n\n" "${RED}${B}" "${R}" "${D}" "$__dur" "$__code" "${R}"
    fi' EXIT
}

# Step runner with timing and nice logs
# Usage: step "Title" cmd arg...
step() {
  local name="$1"; shift
  log_title "$name"
  _start_timer
  if "$@"; then
    log_ok "$name ($(_elapsed)s)"
  else
    local code=$?
    log_fail "$name (exit $code)"
    return "$code"
  fi
}

# -----------------------------
# Spinner
# -----------------------------
# Show a spinner while a command runs. Useful for long operations.
# Usage: with_spinner "Label" <command...>
with_spinner() {
  local label="$1"; shift
  local pid tmpout
  tmpout="$(mktemp -t spinner.XXXXXX)"
  # Run command in background, redirect combined output to tmp
  { "$@" >"$tmpout" 2>&1 & } ; pid=$!

  local spin='|/-\' i=0
  printf "%b%s%b " "${CYN}${B}" "${label}" "${R}"
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    printf "\r%b%s%b %s" "${CYN}${B}" "${label}" "${R}" "${spin:$i:1}"
    sleep 0.1
  done
  wait "$pid"; local code=$?

  # Clear spinner line
  printf "\r\033[K"
  if [[ $code -eq 0 ]]; then
    log_ok "${label}"
  else
    log_fail "${label}"
    printf "%b--- output ---\n" "${D}"
    sed -e 's/^/  /' "$tmpout" || true
    printf "%b-----------%b\n" "${D}" "${R}"
  fi
  rm -f "$tmpout"
  return "$code"
}

# -----------------------------
# Confirm (y/n)
# -----------------------------
# Usage: confirm "Are you sure?" || exit 1
confirm() {
  local prompt="${1:-Are you sure?}"
  local answer
  printf "%b%s [y/N]: %b" "${YEL}${B}" "${prompt}" "${R}"
  read -r answer || true
  case "${answer}" in
    y|Y|yes|YES) return 0 ;;
    *)           return 1 ;;
  esac
}
