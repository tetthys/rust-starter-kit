#!/usr/bin/env bash
# Generic cargo passthrough with pretty output
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

if [[ $# -eq 0 ]]; then
  log_warn "No cargo subcommand provided. Example: ./run/cargo.sh test"
  exit 1
fi

CMD_LABEL="cargo $*"
with_section "Cargo" \
  with_spinner "$CMD_LABEL" in_container cargo "$@"
