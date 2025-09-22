#!/usr/bin/env bash
# Build the project (supports normal args like --release)
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

ARGS=("$@")

with_section "Build" \
  with_spinner "cargo build ${ARGS[*]}" in_container cargo build "${ARGS[@]}"
