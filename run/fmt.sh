#!/usr/bin/env bash
# Format the entire workspace with rustfmt.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root

echo "[fmt.sh] Running cargo fmt..."
in_container cargo fmt --all "$@"
echo "[fmt.sh] Done: cargo fmt finished successfully."
