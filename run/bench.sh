#!/usr/bin/env bash
# Run benchmarks (requires nightly or criterion in dev-deps).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo bench "$@"
