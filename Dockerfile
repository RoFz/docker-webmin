FROM debian:bookworm-slim AS base

WORKDIR /app

# --- builder stage (add build dependencies here) ---
FROM base AS builder

# COPY . .
# RUN make build

# --- final stage ---
FROM base AS final

# Copy built artifacts from builder
# COPY --from=builder /app/bin/app /usr/local/bin/app

# Run as non-root
RUN useradd -r -s /bin/false appuser
USER appuser

ENTRYPOINT ["/bin/sh"]
