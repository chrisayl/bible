#!/usr/bin/env bash
set -euo pipefail

echo "🌐 === EC2 Remote DevContainer Initialization ==="

read -p "EC2 host (e.g. ec2-user@11.22.33.44): " EC2_HOST
read -p "Path to PEM key (or leave blank for SSH config): " PEM_PATH

SSH_OPTS=""
if [ -n "$PEM_PATH" ]; then
  SSH_OPTS="-i $PEM_PATH"
fi

echo "📦 Cloning devcontainer repo onto remote host..."
ssh $SSH_OPTS "$EC2_HOST" "rm -rf ~/devcontainer && git clone https://github.com/chrisayl/bible.git ~/devcontainer && cd ~/devcontainer/devcontainer && bash setup-host.sh"

echo "✅ EC2 host ready! You can now SSH and run:"
echo "   launch-devcontainer.sh --repo the-firm"
