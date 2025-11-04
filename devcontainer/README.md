# Unified Persistent DevContainer (EC2 Host Setup)

This setup provides a **single golden development environment** hosted on EC2,
with per-repo isolation and persistent config (Docker-in-Docker).

## 🚀 Quickstart

### 1️⃣ One-time EC2 host setup
```bash
bash devcontainer/setup-host.sh
```

### 2️⃣ Launch a new repo environment
```bash
bash devcontainer/launch-devcontainer.sh --repo the-firm --github-pat ghp_xxx
```

### 3️⃣ Rebuild or update
```bash
bash devcontainer/launch-devcontainer.sh --repo the-firm --rebuild
```

### 4️⃣ Connect via VS Code
```bash
code --remote ssh-remote+ec2-dev
```

---

## 🔐 Secrets
Global tokens in `/home/ec2-user/.devcontainer.env`:

```bash
CLAUDE_CODE_OAUTH_TOKEN=sk-ant-xxxxx
```

---

## 📦 Structure
```
bible/devcontainer/
├── README.md
├── remote-init.sh
├── setup-host.sh
├── launch-devcontainer.sh
├── scripts/
│   └── utils.sh
└── .devcontainer/
    ├── devcontainer.json
    ├── Dockerfile
    ├── init-devcontainer.sh
    ├── code_standards.md
    ├── .env.example
    └── systemd/
        └── devcontainer.service
```
