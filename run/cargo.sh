#!/usr/bin/env bash
set -euo pipefail
# Run any cargo subcommand inside the container, mapped to the repo root.
# Examples:
#   ./run/cargo.sh init --bin
#   ./run/cargo.sh build
#   ./run/cargo.sh test
#   ./run/cargo.sh run
docker compose run --rm -T rust cargo "$@"
