#!/usr/bin/env bash
# Run Criterion benches with pretty output (spinner + summary)
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

# Pass-through args to `cargo bench`
ARGS=("$@")

with_section "Benchmarks" \
  with_spinner "cargo bench ${ARGS[*]}" in_container cargo bench "${ARGS[@]}"
