#!/usr/bin/env bash
set -euo pipefail

read -p "EC2 host (e.g. ec2-user@1.2.3.4): " HOST
read -p "Path to PEM key (or empty for ssh-agent): " PEM
SSH_OPTS=""
[[ -n "$PEM" ]] && SSH_OPTS="-i $PEM"

scp $SSH_OPTS -r ./bible/devcontainer "$HOST:~/"
ssh $SSH_OPTS "$HOST" "cd ~/bible/devcontainer && bash setup-host.sh"
