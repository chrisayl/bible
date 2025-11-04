#!/usr/bin/env bash
set -euo pipefail

# Default values
REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO="$2"; shift 2;;
    *) echo "Unknown argument: $1"; exit 1;;
  esac
done

if [ -z "$REPO" ]; then
  echo "❌ Repo name required. Usage: launch-devcontainer.sh --repo <name>"
  exit 1
fi

REPO_DIR="/home/ec2-user/$REPO"
echo "🚀 Launching DevContainer for $REPO..."

if [ ! -d "$REPO_DIR" ]; then
  echo "📦 Cloning repository $REPO..."
  if [ -f /home/ec2-user/.devcontainer.env ]; then
    source /home/ec2-user/.devcontainer.env
  fi
  if [ -n "${GITHUB_PAT:-}" ]; then
    git clone "https://${GITHUB_PAT}@github.com/chrisayl/${REPO}.git" "$REPO_DIR"
  else
    git clone "https://github.com/chrisayl/${REPO}.git" "$REPO_DIR"
  fi
else
  echo "🔄 Repo exists, pulling latest..."
  cd "$REPO_DIR"
  git pull
fi

cd "$REPO_DIR"
if [ -d ".devcontainer" ]; then
  echo "🏗️ Building DevContainer..."
  devcontainer up --workspace-folder . || true
else
  echo "⚠️ No .devcontainer directory found in $REPO_DIR."
fi

echo "✅ Done! You can now connect via VS Code Remote SSH."
