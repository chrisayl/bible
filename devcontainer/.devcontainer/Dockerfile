# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    python3.12 python3.12-venv python3-pip \
    nodejs npm git curl jq docker.io \
    black isort ruff && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN npm install -g eslint prettier

RUN useradd -ms /bin/bash node && usermod -aG docker node
USER node
WORKDIR /workspace

ENV PATH="/home/node/.local/bin:$PATH"

COPY init-devcontainer.sh /usr/local/bin/init-devcontainer.sh
RUN chmod +x /usr/local/bin/init-devcontainer.sh

CMD ["bash"]
