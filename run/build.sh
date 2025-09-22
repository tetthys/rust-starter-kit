#!/usr/bin/env bash
# Build the project (workspace root).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo build "$@"
