#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/_common.sh"
require_compose_root
summary_trap_enable

RUN_FMT=1; RUN_CLIPPY=1; WATCH=0; CARGO_ARGS=()
while [[ $# -gt 0 ]]; do case "$1" in
  --no-fmt) RUN_FMT=0; shift ;;
  --no-clippy) RUN_CLIPPY=0; shift ;;
  --watch|-w) WATCH=1; shift ;;
  --clean-target) CLEAN_FIRST=1; shift ;;
  --) shift; CARGO_ARGS+=("$@"); break ;;
  *)  CARGO_ARGS+=("$1"); shift ;;
esac; done

log_title "Rust Starter Kit • Test Pipeline"
log_info "Fmt: $([[ $RUN_FMT -eq 1 ]] && echo enabled || echo disabled), Clippy: $([[ $RUN_CLIPPY -eq 1 ]] && echo enabled || echo disabled), Watch: $([[ $WATCH -eq 1 ]] && echo yes || echo no)"

# Optional confirm example
if [[ "${CLEAN_FIRST:-0}" -eq 1 ]]; then
  if confirm "Clean target/ before testing?"; then
    with_section "Clean" with_spinner "cargo clean" in_container cargo clean
  fi
fi

(( RUN_FMT == 1 ))    && with_section "Format Check"  with_spinner "cargo fmt --check" in_container cargo fmt --all -- --check || log_warn "Skip fmt"
(( RUN_CLIPPY == 1 )) && with_section "Clippy Lints"  with_spinner "cargo clippy -D warnings" in_container cargo clippy --all-targets --all-features -- -D warnings || log_warn "Skip clippy"

if (( WATCH == 1 )); then
  with_section "Tests (watch)" in_container cargo watch -x "test ${CARGO_ARGS[*]}"
else
  with_section "Tests"         with_spinner "cargo test" in_container cargo test "${CARGO_ARGS[@]}"
fi
