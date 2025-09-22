#!/usr/bin/env bash
# Quick diagnostics for versions, PATH, and cargo metadata.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

with_section "Environment" \
  with_spinner "diagnostics" in_container bash -lc '
    set -e
    whoami; pwd
    echo "--- versions ---"
    rustc -V
    cargo -V
    echo "--- PATH ---"
    echo "$PATH"
    echo "--- toolchain ---"
    rustup show
    echo "--- cargo metadata ---"
    cargo metadata --no-deps --format-version=1 >/dev/null && echo "cargo metadata: OK"
  '
