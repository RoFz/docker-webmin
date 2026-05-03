# syntax=docker/dockerfile:1.19.0

FROM debian:bookworm-slim@sha256:f9c6a2fd2ddbc23e336b6257a5245e31f996953ef06cd13a59fa0a1df2d5c252

# NOTE: Webmin is designed to run with full root privileges, so root is the intentional runtime default for this image.
# hadolint ignore=DL3002
USER root

# NOTE: Exact APT package version pinning is intentionally not used here because this image tracks
# Debian and Webmin repository updates, and Webmin is intentionally installed with recommends to
# match the upstream Debian installation guidance.
# hadolint ignore=DL3008,DL3015
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
    set -eux; \
    export DEBIAN_FRONTEND=noninteractive; \
    key_tmp="$(mktemp)"; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg; \
    install -d -m 0755 /usr/share/keyrings; \
    curl -fsSL https://download.webmin.com/developers-key.asc -o "$key_tmp"; \
    gpg --dearmor -o /usr/share/keyrings/debian-webmin-developers.gpg "$key_tmp"; \
    rm -f "$key_tmp"; \
    chmod 0644 /usr/share/keyrings/debian-webmin-developers.gpg; \
    printf '%s\n' \
      'deb [signed-by=/usr/share/keyrings/debian-webmin-developers.gpg] https://download.webmin.com/download/newkey/repository stable contrib' \
      > /etc/apt/sources.list.d/webmin.list; \
    apt-get update; \
    apt-get install -y --install-recommends webmin; \
    apt-get install -y --no-install-recommends bind9 bind9-utils; \
    apt-get purge -y --auto-remove gnupg; \
    rm -f /etc/webmin/miniserv.pem

RUN set -eux; \
    install -d -m 0755 /usr/local/share/docker-webmin /var/lib/docker-webmin; \
    if [ -f /etc/webmin/miniserv.users ]; then \
      users_hash="$(sha256sum /etc/webmin/miniserv.users)"; \
      printf '%s\n' "${users_hash%% *}" > /usr/local/share/docker-webmin/default-miniserv.users.sha256; \
    else \
      printf '%s\n' absent > /usr/local/share/docker-webmin/default-miniserv.users.sha256; \
    fi

COPY --chmod=0755 entrypoint.sh /usr/local/bin/docker-entrypoint.sh

EXPOSE 10000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD ["curl", "-fkIs", "--max-time", "5", "https://127.0.0.1:10000/"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

ARG OCI_CREATED=""
ARG OCI_VERSION="0.1.0" # x-release-please-version
ARG OCI_REVISION="unknown"
ARG OCI_BASE_NAME="docker.io/library/debian:bookworm-slim"
ARG OCI_BASE_DIGEST="sha256:4724b8cc51e33e398f0e2e15e18d5ec2851ff0c2280647e1310bc1642182655d"

LABEL org.opencontainers.image.title="docker-webmin" \
      org.opencontainers.image.description="Container image for running Webmin on Debian Bookworm Slim." \
      org.opencontainers.image.source="https://github.com/RoFz/docker-webmin" \
      org.opencontainers.image.documentation="https://github.com/RoFz/docker-webmin/blob/main/README.md" \
      org.opencontainers.image.url="https://github.com/RoFz/docker-webmin" \
      org.opencontainers.image.licenses="Apache-2.0 AND BSD-3-Clause" \
      org.opencontainers.image.vendor="RoFz" \
      org.opencontainers.image.created="${OCI_CREATED}" \
      org.opencontainers.image.version="${OCI_VERSION}" \
      org.opencontainers.image.revision="${OCI_REVISION}" \
      org.opencontainers.image.base.name="${OCI_BASE_NAME}" \
      org.opencontainers.image.base.digest="${OCI_BASE_DIGEST}"
