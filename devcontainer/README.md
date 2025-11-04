# DevContainer EC2 Toolkit

This directory bootstraps and manages **secure DevContainers on an EC2 host**.

## 🧭 Usage

### 1️⃣ From your local Mac
```bash
bash devcontainer/remote-init.sh
```
This will:
- Connect to your EC2 host
- Clone this repo into `/home/ec2-user/devcontainer`
- Run `setup-host.sh` to install Docker + Node + DevContainers CLI
- Register `launch-devcontainer.sh` globally on the EC2 host

### 2️⃣ From EC2
```bash
launch-devcontainer.sh --repo the-firm
```
This spins up (or updates) the specified repo's DevContainer in `/home/ec2-user/the-firm`.

### 3️⃣ Secrets
Create a `/home/ec2-user/.devcontainer.env` file based on `.devcontainer.env.example`.

Example:
```bash
GITHUB_PAT=ghp_XXXX
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-XXXX
```

All containers automatically load these env vars at build time.

---

✅ Works on **Amazon Linux 2023** or **Ubuntu**
✅ Re-runnable and idempotent
✅ Does not expose secrets locally
