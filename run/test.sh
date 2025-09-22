#!/usr/bin/env bash
# Run tests (integration + unit).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo test "$@"
