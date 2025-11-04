#!/usr/bin/env bash
set -euo pipefail
usage(){ echo "Usage: $0 [--repo <repo_name>] [--github-pat <token>] [--user <github_user>] [--private true|false] [--rebuild true|false]"; exit 1; }
GITHUB_USER="${GITHUB_USER:-chrisayl}"; PRIVATE_FLAG="false"; REBUILD="false"; REPO_NAME="${REPO_NAME:-}"
while [[ $# -gt 0 ]]; do case $1 in
  --repo) REPO_NAME="$2"; shift 2 ;;
  --github-pat) GITHUB_PAT="$2"; shift 2 ;;
  --user) GITHUB_USER="$2"; shift 2 ;;
  --private) PRIVATE_FLAG="$2"; shift 2 ;;
  --rebuild) REBUILD="$2"; shift 2 ;;
  -h|--help) usage ;;
  *) echo "❌ Unknown arg: $1"; usage ;;
esac; done
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "${SCRIPT_DIR}/scripts/utils.sh"
load_env || true
ensure_docker; ensure_devcontainers_cli
if [[ -z "${REPO_NAME}" ]]; then
  if [ -d .git ]; then REPO_NAME="$(basename "$(pwd)")"; else echo "❌ --repo required when not inside a git repo."; usage; fi
fi
TARGET="/home/ec2-user/${REPO_NAME}"
if [[ "$(pwd)" != "${TARGET}" ]]; then clone_or_create_repo "${GITHUB_USER}" "${GITHUB_PAT:-${GITHUB_TOKEN:-}}" "${REPO_NAME}" "${PRIVATE_FLAG}"; cd "${TARGET}"; fi
export GITHUB_TOKEN="${GITHUB_PAT:-${GITHUB_TOKEN:-}}"
if [[ "${REBUILD}" == "true" ]]; then devcontainer up --workspace-folder . --build-no-cache || true; else devcontainer up --workspace-folder . || true; fi
echo "✅ DevContainer '${REPO_NAME}' ready. Open /home/ec2-user/${REPO_NAME} in VS Code Remote."
