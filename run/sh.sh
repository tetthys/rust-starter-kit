#!/usr/bin/env bash
# Open an interactive shell inside the container at /workspace.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root

log_title "Shell"
in_container_tty bash
