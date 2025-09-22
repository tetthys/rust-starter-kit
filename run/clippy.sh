#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

ALLOW_WARN=0; AFTER_DASH=()
while [[ $# -gt 0 ]]; do case "$1" in
  --allow-warnings) ALLOW_WARN=1; shift ;;
  --) shift; AFTER_DASH+=("$@"); break ;;
  *)  AFTER_DASH+=("$1"); shift ;;
esac; done

with_section "Clippy" \
  bash -lc '
    if (( '"$ALLOW_WARN"' == 1 )); then
      with_spinner "cargo clippy (relaxed)" in_container cargo clippy --all-targets --all-features -- '"${AFTER_DASH[*]}"'
    else
      with_spinner "cargo clippy (strict)"  in_container cargo clippy --all-targets --all-features -- -D warnings '"${AFTER_DASH[*]}"'
    fi
  '
