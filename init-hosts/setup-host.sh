#!/usr/bin/env bash
set -euo pipefail

REPO="chrisayl/bible"
BASE_URL="https://raw.githubusercontent.com/${REPO}/main/init-hosts"

echo "🚀 Setting up DevContainer host environment..."

if command -v dnf >/dev/null 2>&1; then
  PKG="dnf"
elif command -v yum >/dev/null 2>&1; then
  PKG="yum"
else
  PKG="apt-get"
fi

echo "📦 Updating system packages..."
sudo $PKG update -y || true
sudo $PKG install -y curl wget git jq unzip tar ca-certificates sudo || true

if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker..."
  if [[ "$PKG" == "apt-get" ]]; then
    sudo apt-get install -y docker.io
  else
    sudo $PKG install -y docker
  fi
  sudo systemctl enable --now docker
  sudo usermod -aG docker ec2-user || true
else
  echo "✅ Docker already installed."
fi

if ! command -v node >/dev/null 2>&1; then
  echo "🧩 Installing Node.js (LTS)..."
  curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash - 2>/dev/null || true
  sudo $PKG install -y nodejs
fi

if ! command -v devcontainer >/dev/null 2>&1; then
  echo "📦 Installing @devcontainers/cli..."
  sudo npm install -g @devcontainers/cli
fi

echo "⬇️ Installing DevContainer launcher..."
sudo mkdir -p /usr/local/bin
sudo curl -fsSL "${BASE_URL}/launch-devcontainer.sh" -o /usr/local/bin/launch-devcontainer.sh
sudo chmod +x /usr/local/bin/launch-devcontainer.sh

echo ""
echo "✅ Host setup complete!"
echo "💡 Run:"
echo "  launch-devcontainer.sh --repo my-project --github-pat ghp_xxx"
