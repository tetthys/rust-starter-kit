#!/usr/bin/env bash
set -euo pipefail
# Open an interactive shell in the container at /workspace (your repo root).
docker compose run --rm rust bash
