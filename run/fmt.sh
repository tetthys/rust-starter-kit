#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

CHECK=0; EXTRA_ARGS=()
while [[ $# -gt 0 ]]; do case "$1" in
  --check) CHECK=1; shift ;;
  *) EXTRA_ARGS+=("$1"); shift ;;
esac; done

with_section "Format" \
  bash -lc '
    if (( '"$CHECK"' == 1 )); then
      with_spinner "cargo fmt --check" in_container cargo fmt --all -- --check '"${EXTRA_ARGS[*]}"'
    else
      with_spinner "cargo fmt (apply)" in_container cargo fmt --all '"${EXTRA_ARGS[*]}"'
    fi
  '
