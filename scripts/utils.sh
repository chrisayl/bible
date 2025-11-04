#!/usr/bin/env bash
set -euo pipefail

ensure_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "🐳 Installing Docker..."
    sudo apt-get update && sudo apt-get install -y docker.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker ec2-user
  fi
}

ensure_devcontainers_cli() {
  if ! command -v devcontainer >/dev/null 2>&1; then
    echo "📦 Installing @devcontainers/cli..."
    sudo npm install -g @devcontainers/cli
  fi
}

clone_or_create_repo() {
  local user="$1" pat="$2" repo="$3" private="$4"
  local path="/home/ec2-user/${repo}"

  echo "🔍 Checking repo $user/$repo ..."
  local status
  status=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token ${pat}" "https://api.github.com/repos/${user}/${repo}")
  if [[ "$status" == "404" ]]; then
    echo "🚀 Creating new repo '${repo}'..."
    curl -s -H "Authorization: token ${pat}"       -d "{"name": "${repo}", "private": ${private}}"       https://api.github.com/user/repos >/dev/null
  fi

  if [ -d "${path}/.git" ]; then
    echo "📥 Pulling latest changes..."
    cd "${path}" && git pull
  else
    echo "📦 Cloning repository..."
    git clone "https://${user}:${pat}@github.com/${user}/${repo}.git" "${path}"
  fi
}
