#!/usr/bin/env bash
# Live reload dev loop: check + test on file changes.
# First-time (inside container): ./run/sh.sh && cargo install cargo-watch
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
in_container cargo watch -x 'check' -x 'test'
