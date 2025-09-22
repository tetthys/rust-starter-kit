#!/usr/bin/env bash
# Build docs (opens on host manually; inside container only builds).
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo doc --no-deps "$@"
