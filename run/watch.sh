#!/usr/bin/env bash
# Dev loop: automatically re-run checks/tests on file changes.
# Requires: cargo-watch installed inside container
#   $ ./run/rust.sh cargo install cargo-watch
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root

# Default: run check + test
CMD="check -x test"
if [[ $# -gt 0 ]]; then
  # allow custom -x sequence, e.g.,: ./run/watch.sh "check -x 'clippy -- -D warnings' -x test"
  CMD="$*"
fi

log_title "Watch"
log_info "cargo watch -x '${CMD}'"
# Interactive streaming output
in_container_tty cargo watch -x "${CMD}"
