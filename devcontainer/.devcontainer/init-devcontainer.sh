#!/usr/bin/env bash
set -e

mkdir -p /config/claude /workspace

if [[ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]]; then
  echo "$CLAUDE_CODE_OAUTH_TOKEN" > /config/claude/token
fi

echo "✅ Initialized Claude config and workspace."
