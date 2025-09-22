#!/usr/bin/env bash
set -euo pipefail
# Ensure cargo registry/git volumes are writable by UID 1000 (rust user).
docker compose run --rm --user root -T rust bash -lc \
  'mkdir -p /usr/local/cargo/registry /usr/local/cargo/git && chown -R 1000:1000 /usr/local/cargo'
echo "[fix-perms.sh] Ownership adjusted for /usr/local/cargo/*"
