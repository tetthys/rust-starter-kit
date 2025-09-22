#!/usr/bin/env bash
# Run arbitrary commands in the container.
# --tty    : run with TTY (interactive; no spinner)
# default  : non-TTY with spinner
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root

TTY=0
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tty) TTY=1; shift ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

if [[ ${#ARGS[@]} -eq 0 ]]; then
  log_warn "Usage: ./run/rust.sh [--tty] <command> [args...]"
  exit 2
fi

if (( TTY == 1 )); then
  log_title "Container (TTY)"
  log_info "${ARGS[*]}"
  in_container_tty "${ARGS[@]}"
else
  summary_trap_enable
  with_section "Container" \
    with_spinner "${ARGS[*]}" in_container "${ARGS[@]}"
fi
