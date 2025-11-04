#!/usr/bin/env bash
set -euo pipefail
if command -v dnf >/dev/null 2>&1; then PKG="dnf"; elif command -v yum >/dev/null 2>&1; then PKG="yum"; else PKG="apt-get"; fi
sudo ${PKG} update -y || true
sudo ${PKG} install -y curl wget git jq unzip tar ca-certificates sudo || true
if ! command -v docker >/dev/null 2>&1; then
  if [[ "$PKG" == "apt-get" ]]; then sudo apt-get install -y docker.io; else sudo ${PKG} install -y docker; fi
  sudo systemctl enable --now docker
  sudo usermod -aG docker ec2-user || true
fi
if ! command -v node >/dev/null 2>&1; then
  if [[ "$PKG" == "apt-get" ]]; then curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs; else curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash - || true; sudo ${PKG} install -y nodejs; fi
fi
if ! command -v devcontainer >/dev/null 2>&1; then sudo npm install -g @devcontainers/cli; fi
sudo install -m 0755 ./launch-devcontainer.sh /usr/local/bin/launch-devcontainer.sh
echo "✅ Host ready."
