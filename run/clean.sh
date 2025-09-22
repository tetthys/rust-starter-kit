#!/usr/bin/env bash
# Clean target dir.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo clean
