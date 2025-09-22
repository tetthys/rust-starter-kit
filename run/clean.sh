#!/usr/bin/env bash
# Clean build artifacts (optionally confirm)
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

# Optional: ask before cleaning
if confirm "Run 'cargo clean'?"; then
  with_section "Clean" \
    with_spinner "cargo clean" in_container cargo clean
else
  log_warn "Cancelled by user."
  exit 2
fi
