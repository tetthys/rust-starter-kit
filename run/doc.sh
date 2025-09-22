#!/usr/bin/env bash
# Build docs with pretty output (spinner + summary)
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

ARGS=("$@")
# default: --no-deps (speed). User can override by passing explicit args.
if [[ ${#ARGS[@]} -eq 0 ]]; then
  ARGS=(--no-deps)
fi

with_section "Docs" \
  with_spinner "cargo doc ${ARGS[*]}" in_container cargo doc "${ARGS[@]}"
