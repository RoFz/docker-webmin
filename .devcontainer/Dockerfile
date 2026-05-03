FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# NOTE: DL3008 (pin apt package versions) is suppressed here intentionally.
# The base image version is pinned and updated by Dependabot; apt package versions
# are tied to the Ubuntu release in that image and would break on every base image bump.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl gnupg2 pipx python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN ARCH=$(dpkg --print-architecture) \
    && case "${ARCH}" in \
        amd64) HL_ARCH="x86_64" ;; \
        arm64) HL_ARCH="arm64" ;; \
        *) echo "Unsupported arch: ${ARCH}" && exit 1 ;; \
    esac \
    && curl -sSL "https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-${HL_ARCH}" -o /usr/local/bin/hadolint \
    && chmod +x /usr/local/bin/hadolint

RUN mkdir -p /home/vscode/.claude /home/vscode/.codex /home/vscode/.gnupg /home/vscode/.vscode-server \
    && chown vscode:vscode /home/vscode/.claude /home/vscode/.codex /home/vscode/.gnupg /home/vscode/.vscode-server \
    && chmod 700 /home/vscode/.gnupg \
    && chmod 777 /home/vscode/.vscode-server
