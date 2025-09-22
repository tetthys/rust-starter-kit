#!/usr/bin/env bash
# Pass any cargo subcommand to the container.
# Examples:
#   ./run/cargo.sh --version
#   ./run/cargo.sh new hello --bin
#   ./run/cargo.sh build
#   ./run/cargo.sh run
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo "$@"
