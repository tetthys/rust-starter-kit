# Run Script Usage Guide

This project provides a `run/` directory with Bash wrappers around Docker Compose.
They allow you to use Rust (`cargo`, `rustc`, `rustup`) **without installing Rust locally**—everything runs inside the container.

Make sure scripts are executable:

```bash
chmod +x run/*.sh
```

---

## Shared Notes

* All scripts assume you are in the repo root (where `docker-compose.yaml` lives).
* Under the hood, they run:

  ```bash
  docker compose run --rm rust <command>
  ```
* Add `--help` or pass extra arguments just like you would with native `cargo`.

---

## Scripts

### `run/_common.sh`

Internal helpers, not called directly.
Provides functions to run commands inside the container.

---

### `run/bench.sh`

Run benchmarks (requires nightly toolchain or `criterion` in `dev-dependencies`).

```bash
./run/bench.sh
./run/bench.sh -- --nocapture
```

---

### `run/build.sh`

Compile the project.

```bash
./run/build.sh
./run/build.sh --release
```

---

### `run/cargo.sh`

Pass any `cargo` command to the container.

```bash
./run/cargo.sh --version
./run/cargo.sh check
./run/cargo.sh install cargo-edit
```

---

### `run/clean.sh`

Clean build artifacts.

```bash
./run/clean.sh
```

---

### `run/clippy.sh`

Run `clippy` and fail on warnings.

```bash
./run/clippy.sh
./run/clippy.sh -- -W clippy::pedantic
```

---

### `run/doc.sh`

Build documentation (`target/doc` inside container, or bind-mounted).

```bash
./run/doc.sh
./run/doc.sh --open
```

---

### `run/fmt.sh`

Format the codebase with `rustfmt`.

```bash
./run/fmt.sh
./run/fmt.sh -- --check
```

---

### `run/init.sh`

Initialize the repo root as a new Cargo project.

```bash
./run/init.sh         # default: binary crate
./run/init.sh --lib   # create library crate
```

---

### `run/new.sh`

Create a new crate inside the repo.

```bash
./run/new.sh hello --bin
./run/new.sh utils --lib
```

---

### `run/run.sh`

Run the binary.

```bash
./run/run.sh
./run/run.sh -p rust-starter-kit
./run/run.sh --bin my-binary
```

---

### `run/rust.sh`

Run arbitrary commands inside the container.

```bash
./run/rust.sh rustc --version
./run/rust.sh rustup show
./run/rust.sh cargo install cargo-watch
```

---

### `run/sh.sh`

Open an interactive shell inside the container.

```bash
./run/sh.sh
```

---

### `run/test.sh`

Run tests.

```bash
./run/test.sh
./run/test.sh -- --nocapture
```

---

### `run/watch.sh`

Auto re-run checks/tests on file changes (requires `cargo-watch` installed inside container).

```bash
# One-time install inside container:
./run/rust.sh cargo install cargo-watch

# Then:
./run/watch.sh
```

---

### `run/which.sh`

Quick diagnostics for environment and tool versions.

```bash
./run/which.sh
```

---

## Typical Workflow

```bash
# Build and run
./run/build.sh
./run/run.sh

# Test
./run/test.sh

# Check code style
./run/fmt.sh
./run/clippy.sh

# Explore inside container
./run/sh.sh
```