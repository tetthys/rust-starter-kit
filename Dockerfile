# syntax=docker/dockerfile:1.7

ARG RUST_VERSION=1-slim
FROM rust:${RUST_VERSION}

ARG HOST_UID=1000
ARG HOST_GID=1000
ARG INSTALL_CARGO_WATCH=false

# Ensure Cargo is on PATH for all users
ENV PATH="/usr/local/cargo/bin:${PATH}"
ENV LANG=C.UTF-8

# (Optional but handy) base tooling for native deps / debugging
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash ca-certificates git curl build-essential pkg-config libssl-dev \
 && rm -rf /var/lib/apt/lists/*

# Create a non-root user matching host UID/GID so bind mounts stay writable
RUN groupadd -g "${HOST_GID}" rust || true && \
    useradd -ms /bin/bash -u "${HOST_UID}" -g "${HOST_GID}" rust

# Prepare cache dirs and give ownership to the dev user
RUN mkdir -p /usr/local/cargo/registry /usr/local/cargo/git /workspace/target && \
    chown -R "${HOST_UID}:${HOST_GID}" /usr/local/cargo/registry /usr/local/cargo/git /workspace

# Workdir is the project root
WORKDIR /workspace

# Install extra components for the default toolchain
RUN rustup component add rustfmt clippy

# (Optional) cargo-watch for live reload in dev
RUN if [ "${INSTALL_CARGO_WATCH}" = "true" ]; then \
      /usr/local/cargo/bin/cargo install cargo-watch ; \
    fi

# Drop privileges by default (matches docker-compose `user:` too)
USER rust

# Sanity check (prove cargo/rustc exist for this user)
RUN cargo --version && rustc --version
