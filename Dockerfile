# syntax=docker/dockerfile:1.7
ARG RUST_VERSION=1-slim
FROM rust:${RUST_VERSION}

# Ensure Cargo is on PATH
ENV PATH="/usr/local/cargo/bin:${PATH}"
ENV LANG=C.UTF-8

# Minimal build deps (optional but useful)
RUN apt-get update && apt-get install -y --no-install-recommends \
      bash ca-certificates git curl build-essential pkg-config libssl-dev \
 && rm -rf /var/lib/apt/lists/*

# Add a non-root user for bind mounts
RUN useradd -ms /bin/bash -u 1000 rust

# Workdir is the project root
WORKDIR /workspace

# Use non-root by default
USER rust

# Prove cargo/rustc exist at build time
RUN cargo --version && rustc --version
