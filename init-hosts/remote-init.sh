#!/usr/bin/env bash
set -euo pipefail
prompt(){ read -rp "$1" "$2"; } ; prompt_secret(){ read -rsp "$1" "$2"; echo ""; }
echo "🌐 === Remote EC2 DevContainer Bootstrap ==="
prompt "EC2 host (e.g. ec2-user@11.22.33.44): " EC2_HOST
prompt "Path to PEM key (blank if in ssh config): " PEM_PATH
prompt "Your GitHub username: " GITHUB_USER
prompt_secret "GitHub PAT (hidden): " GITHUB_PAT
prompt "Repository name (e.g. the-firm): " REPO_NAME
prompt "Private repo? (y/n): " PRIVATE_ANS
prompt "Add SSH config entry 'ec2-dev'? (y/n): " ADD_SSH
PRIVATE_JSON="false"; [[ "$PRIVATE_ANS" =~ ^[Yy]$ ]] && PRIVATE_JSON="true"
SSH_OPTS=""; [[ -n "${PEM_PATH}" ]] && SSH_OPTS="-i ${PEM_PATH}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token ${GITHUB_PAT}" "https://api.github.com/repos/${GITHUB_USER}/${REPO_NAME}")
if [[ "$HTTP_CODE" == "404" ]]; then
  CREATE_RESP=$(curl -s -H "Authorization: token ${GITHUB_PAT}" -d "{"name":"${REPO_NAME}","private":${PRIVATE_JSON}}" https://api.github.com/user/repos)
  echo "$CREATE_RESP" | grep -q '"full_name"' || { echo "❌ Failed to create repository"; echo "$CREATE_RESP"; exit 1; }
fi
ssh ${SSH_OPTS} "${EC2_HOST}" "bash -lc '
  set -e
  if ! command -v git >/dev/null 2>&1; then
    if command -v dnf >/dev/null 2>&1; then sudo dnf install -y git; elif command -v yum >/dev/null 2>&1; then sudo yum install -y git; else sudo apt-get update && sudo apt-get install -y git; fi
  fi
  if [ ! -d ~/init-hosts ]; then
    git clone https://github.com/chrisayl/init-hosts.git ~/init-hosts
  else
    cd ~/init-hosts && git pull
  fi
  cd ~/init-hosts
  bash setup-host.sh
'"
ssh ${SSH_OPTS} "${EC2_HOST}" "bash -lc 'export GITHUB_PAT="${GITHUB_PAT}"; /usr/local/bin/launch-devcontainer.sh --repo "${REPO_NAME}" --github-pat "${GITHUB_PAT}" --user "${GITHUB_USER}"'"
if [[ "$ADD_SSH" =~ ^[Yy]$ ]]; then
  { echo ""; echo "Host ec2-dev"; echo "  HostName ${EC2_HOST#*@}"; echo "  User ${EC2_HOST%@*}"; [[ -n "$PEM_PATH" ]] && echo "  IdentityFile ${PEM_PATH}"; } >> "${HOME}/.ssh/config"
fi
echo "🎉 Done."
