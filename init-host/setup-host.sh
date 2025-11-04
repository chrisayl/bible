#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# 🧩 setup-host.sh
# Initializes a fresh Amazon Linux 2023 EC2 instance for DevContainers
# Installs Docker, Node.js, @devcontainers/cli, and the launcher
# ------------------------------------------------------------------------------

REPO="chrisayl/bible"
BASE_URL="https://raw.githubusercontent.com/${REPO}/main/init-hosts"

echo "🚀 Setting up DevContainer host environment..."

# --- Detect package manager ---
if command -v dnf >/dev/null 2>&1; then
  PKG="dnf"
else
  PKG="yum"
fi

# --- Update base system ---
echo "📦 Updating system packages..."
sudo $PKG update -y

# --- Install prerequisites ---
echo "🔧 Installing base dependencies..."
sudo $PKG install -y curl wget git jq unzip tar ca-certificates

# --- Install Docker ---
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker..."
  sudo $PKG install -y docker
  sudo systemctl enable --now docker
  sudo usermod -aG docker ec2-user
else
  echo "✅ Docker already installed."
fi

# --- Install Node.js + npm ---
if ! command -v node >/dev/null 2>&1; then
  echo "🧩 Installing Node.js (LTS)..."
  curl -fsSL https://rpm.nodesource.com/setup_lts.x | sudo bash -
  sudo $PKG install -y nodejs
else
  echo "✅ Node.js already installed."
fi

# --- Install DevContainer CLI ---
if ! command -v devcontainer >/dev/null 2>&1; then
  echo "📦 Installing @devcontainers/cli..."
  sudo npm install -g @devcontainers/cli
else
  echo "✅ DevContainer CLI already installed."
fi

# --- Install the reusable launcher ---
echo "⬇️ Installing DevContainer launcher..."
sudo curl -fsSL "${BASE_URL}/launch-devcontainer.sh" -o /usr/local/bin/launch-devcontainer.sh
sudo chmod +x /usr/local/bin/launch-devcontainer.sh

echo ""
echo "✅ Host setup complete!"
echo "Next steps:"
echo "  1. Reconnect SSH so Docker group takes effect:"
echo "       exit && ssh ec2-user@<host>"
echo "  2. Launch a container:"
echo "       launch-devcontainer.sh --repo my-app --github-pat <token>"
echo ""
echo "💡 Source: ${BASE_URL}"
