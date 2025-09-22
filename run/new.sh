#!/usr/bin/env bash
# Create a new crate under current repo (pass-through to cargo new).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

if [[ $# -lt 1 ]]; then
  log_warn "Usage: ./run/new.sh <crate-name> [--bin|--lib]"
  exit 2
fi

with_section "New Crate" \
  with_spinner "cargo new $*" in_container cargo new "$@"
