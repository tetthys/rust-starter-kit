#!/usr/bin/env bash
# Quick diagnostics: versions, paths, target dir.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container bash -lc 'whoami; pwd; echo "---"; rustc -V; cargo -V; echo "---"; echo "PATH=$PATH"; echo "---"; cargo metadata --no-deps --format-version=1 >/dev/null && echo "cargo metadata: OK" || echo "cargo metadata: FAIL"'
