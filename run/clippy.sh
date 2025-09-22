#!/usr/bin/env bash
# Run clippy and fail on warnings.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root

echo "[clippy.sh] Running cargo clippy..."
in_container cargo clippy --all-targets --all-features -- -D warnings "$@"
echo "[clippy.sh] Done: cargo clippy finished successfully."
