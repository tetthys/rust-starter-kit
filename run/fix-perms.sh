#!/usr/bin/env bash
# Fix ownership of cargo registry/git volumes so UID 1000 can write.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

with_section "Fix Permissions" \
  with_spinner "chown -R 1000:1000 /usr/local/cargo" \
    ${DC} run --rm --user root -T "${SERVICE}" bash -lc '
      mkdir -p /usr/local/cargo/registry /usr/local/cargo/git
      chown -R 1000:1000 /usr/local/cargo
    '
