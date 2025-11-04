#!/usr/bin/env bash
set -euo pipefail
echo "🚀 Setting up EC2 host for DevContainer..."

sudo apt-get update -y
sudo apt-get install -y docker.io docker-compose nodejs npm jq git curl

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user || true

echo "📦 Installing DevContainer CLI..."
sudo npm install -g @devcontainers/cli

echo "✅ Host setup complete!"
