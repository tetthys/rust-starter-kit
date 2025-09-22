#!/usr/bin/env bash
# Run the binary (no spinner to preserve program output).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
# No summary_trap_enable here—exit code depends on the app runtime; keep clean.

log_title "Run"
log_info "cargo run $*"
# Use interactive output; don't hide with spinner
in_container_tty cargo run "$@"
