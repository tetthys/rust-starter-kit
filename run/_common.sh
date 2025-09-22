#!/usr/bin/env bash
# Shared helpers for run-scripts.
set -euo pipefail

# Docker Compose service name (matches docker-compose.yaml)
SERVICE="${SERVICE:-rust}"

# Compose command (override with DOCKER_COMPOSE if needed)
DC="${DOCKER_COMPOSE:-docker compose}"

# Non-interactive by default; scripts that need a TTY will drop -T
NON_TTY_FLAGS=(-T)

# Wrapper to run a command inside the container at /workspace (repo root).
# Usage: in_container <cmd...>
in_container() {
  # shellcheck disable=SC2068
  ${DC} run --rm "${NON_TTY_FLAGS[@]}" "${SERVICE}" "$@"
}

# Same, but keep TTY (interactive; no -T)
in_container_tty() {
  ${DC} run --rm "${SERVICE}" "$@"
}

# Ensure we are in the repo root (where docker-compose.yaml lives)
require_compose_root() {
  if [[ ! -f "docker-compose.yaml" ]]; then
    echo "ERROR: Run these scripts from the repo root (docker-compose.yaml not found)." >&2
    exit 1
  fi
}
