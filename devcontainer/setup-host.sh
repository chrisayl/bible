#!/usr/bin/env bash
set -euo pipefail

echo "🧩 Setting up EC2 host for DevContainers..."

# Detect package manager
if command -v dnf >/dev/null 2>&1; then
  PKG=dnf
elif command -v yum >/dev/null 2>&1; then
  PKG=yum
else
  PKG=apt-get
fi

sudo $PKG update -y
sudo $PKG install -y git curl jq wget unzip tar ca-certificates

# Install Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker..."
  if [ "$PKG" = "yum" ] || [ "$PKG" = "dnf" ]; then
    sudo $PKG install -y docker
    sudo systemctl enable docker
    sudo systemctl start docker
  else
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
  fi
  sudo usermod -aG docker ec2-user || true
fi

# Install Node + DevContainer CLI
if ! command -v node >/dev/null 2>&1; then
  echo "📦 Installing Node.js + DevContainer CLI..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash - || true
  sudo $PKG install -y nodejs
  sudo npm install -g @devcontainers/cli
fi

# Register launcher globally
sudo cp ~/devcontainer/devcontainer/launch-devcontainer.sh /usr/local/bin/launch-devcontainer.sh
sudo chmod +x /usr/local/bin/launch-devcontainer.sh

echo "✅ Host setup complete!"
