#!/usr/bin/env bash
# Initialize current directory as a Cargo project (defaults to --bin).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

ARGS=("$@")
# If user didn't specify --bin/--lib, default to --bin
if [[ " ${ARGS[*]-} " != *" --bin "* && " ${ARGS[*]-} " != *" --lib "* ]]; then
  ARGS=(--bin "${ARGS[@]}")
fi

with_section "Init" \
  with_spinner "cargo init ${ARGS[*]}" in_container cargo init "${ARGS[@]}"
