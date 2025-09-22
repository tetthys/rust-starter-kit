#!/usr/bin/env bash
# Initialize the current folder as a Cargo project (bin by default).
# Use this when there is no Cargo.toml yet.
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo init --bin
