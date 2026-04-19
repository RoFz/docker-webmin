FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# NOTE: DL3008 (pin apt package versions) is suppressed here intentionally.
# The base image version is pinned and updated by Dependabot; apt package versions
# are tied to the Ubuntu release in that image and would break on every base image bump.
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends pipx python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/vscode/.claude /home/vscode/.codex /home/vscode/.vscode-server \
    && chown vscode:vscode /home/vscode/.claude /home/vscode/.codex /home/vscode/.vscode-server \
    && chmod 777 /home/vscode/.vscode-server
