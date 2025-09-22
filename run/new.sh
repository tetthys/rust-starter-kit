#!/usr/bin/env bash
# Create a new crate in the current repo root (bin by default).
# Examples:
#   ./run/new.sh hello --bin
#   ./run/new.sh mylib --lib
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root

if [[ $# -lt 1 ]]; then
  echo "Usage: ./run/new.sh <crate-name> [--bin|--lib]" >&2
  exit 1
fi

in_container cargo new "$@"
