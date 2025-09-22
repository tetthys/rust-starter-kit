#!/usr/bin/env bash
# Run arbitrary commands in the container (e.g., rustc, rustup, cargo install ...)
# Examples:
#   ./run/rust.sh rustc --version
#   ./run/rust.sh rustup component add clippy rustfmt
#   ./run/rust.sh cargo install cargo-watch
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container "$@"
