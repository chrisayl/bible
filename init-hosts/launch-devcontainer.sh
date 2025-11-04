#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 --repo <repo_name> --github-pat <token> [--user <github_user>] [--private true|false]"
  exit 1
}

GITHUB_USER="chrisayl"
PRIVATE_FLAG="false"
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) REPO_NAME="$2"; shift 2 ;;
    --github-pat) GITHUB_PAT="$2"; shift 2 ;;
    --user) GITHUB_USER="$2"; shift 2 ;;
    --private) PRIVATE_FLAG="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "❌ Unknown argument: $1"; usage ;;
  esac
done

if [ -z "${REPO_NAME:-}" ] || [ -z "${GITHUB_PAT:-}" ]; then
  usage
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/scripts/utils.sh"

if [ -f "/home/ec2-user/.devcontainer.env" ]; then
  export $(grep -v '^#' /home/ec2-user/.devcontainer.env | xargs)
  echo "🔐 Loaded environment from ~/.devcontainer.env"
fi

ensure_docker
ensure_devcontainers_cli
clone_or_create_repo "$GITHUB_USER" "$GITHUB_PAT" "$REPO_NAME" "$PRIVATE_FLAG"

cd "/home/ec2-user/${REPO_NAME}"
export GITHUB_TOKEN="$GITHUB_PAT"

echo "🚀 Launching DevContainer for $REPO_NAME..."
devcontainer up --workspace-folder . || true

echo ""
echo "✅ DevContainer '$REPO_NAME' running!"
echo "💡 Connect with: code --remote ssh-remote+ec2-${REPO_NAME}"
