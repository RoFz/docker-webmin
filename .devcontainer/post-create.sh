#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

echo "[devcontainer] Installing tooling..."

# Claude Code
npm install -g @anthropic-ai/claude-code

# Codex CLI
npm install -g @openai/codex

# Ensure Claude Code skips onboarding - ~/.claude.json is outside the bind-mounted
# ~/.claude dir, so it is not persisted automatically and must be seeded on each build.
test -f ~/.claude.json || echo '{"hasCompletedOnboarding":true,"installMethod":"native"}' > ~/.claude.json

# pre-commit (for local hook runs and gitlint)
pipx install pre-commit

echo "[devcontainer] Tool versions:"
node --version
npm --version
pre-commit --version
echo "[devcontainer] post-create complete."
