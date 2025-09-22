#!/usr/bin/env bash
# Run the binary (optionally specify package/bin).
# Examples:
#   ./run/run.sh
#   ./run/run.sh -p rust-starter-kit
#   ./run/run.sh --bin rust-starter-kit
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo run "$@"
