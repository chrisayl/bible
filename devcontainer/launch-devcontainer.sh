#!/usr/bin/env bash
set -euo pipefail

REPO_NAME=""
GITHUB_PAT=""
REBUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo) REPO_NAME="$2"; shift 2;;
    --github-pat) GITHUB_PAT="$2"; shift 2;;
    --rebuild) REBUILD=true; shift;;
    *) shift;;
  esac
done

if [[ -z "$REPO_NAME" ]]; then
  echo "❌ Usage: $0 --repo <repo_name> [--github-pat <token>] [--rebuild]"
  exit 1
fi

source /home/ec2-user/.devcontainer.env || true

CONTAINER_NAME="devcontainer_${REPO_NAME}"
CONFIG_VOL="devcontainer_config"
WORK_VOL="devcontainer_${REPO_NAME}_workspace"

echo "🚧 Building DevContainer for repo: $REPO_NAME"

if $REBUILD; then
  docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
fi

docker volume create "$CONFIG_VOL" >/dev/null
docker volume create "$WORK_VOL" >/dev/null

docker build -t unified-devcontainer ./.devcontainer

echo "🚀 Starting container $CONTAINER_NAME ..."
docker run -d --name "$CONTAINER_NAME" \
  --privileged \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$CONFIG_VOL":/config \
  -v "$WORK_VOL":/workspace \
  -e CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN" \
  -e GITHUB_PAT="$GITHUB_PAT" \
  unified-devcontainer

echo "✅ Container $CONTAINER_NAME started successfully!"
