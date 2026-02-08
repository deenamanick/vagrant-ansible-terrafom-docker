#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="/vagrant/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "[runner] Missing $ENV_FILE" >&2
  echo "[runner] Create it by copying /vagrant/.env.example to /vagrant/.env and filling values." >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

: "${GITHUB_REPO:?GITHUB_REPO must be set in .env (owner/repo)}"

if [[ -z "${RUNNER_TOKEN:-}" && -z "${GITHUB_PAT:-}" ]]; then
  echo "[runner] Either RUNNER_TOKEN or GITHUB_PAT must be set in .env" >&2
  exit 1
fi

RUNNER_NAME=${RUNNER_NAME:-"$(hostname)-gha"}
RUNNER_LABELS=${RUNNER_LABELS:-"self-hosted,runner,vm"}
RUNNER_WORKDIR=${RUNNER_WORKDIR:-"_work"}

echo "[runner] Building runner image from /vagrant/runner-image ..."
cd /vagrant/runner-image
sudo docker build -t gha-runner-local:latest .

echo "[runner] Stopping old runner container (if any) ..."
sudo docker rm -f gha-runner 2>/dev/null || true

echo "[runner] Starting runner container ..."
# Persist runner _work and tool caches on the VM
sudo mkdir -p /opt/gha-runner/_work /opt/gha-toolcache /opt/tfplugin-cache

sudo docker run -d --name gha-runner --restart=always \
  -e GITHUB_REPO="$GITHUB_REPO" \
  -e RUNNER_TOKEN="${RUNNER_TOKEN:-}" \
  -e GITHUB_PAT="${GITHUB_PAT:-}" \
  -e RUNNER_NAME="$RUNNER_NAME" \
  -e RUNNER_LABELS="$RUNNER_LABELS" \
  -e RUNNER_WORKDIR="$RUNNER_WORKDIR" \
  -e RUNNER_ALLOW_RUNASROOT=1 \
  -e TF_PLUGIN_CACHE_DIR="/tfplugin-cache" \
  -e RUNNER_TOOL_CACHE="/runner/_toolcache" \
  -v /opt/gha-runner/_work:/opt/actions-runner/_work \
  -v /opt/gha-toolcache:/runner/_toolcache \
  -v /opt/tfplugin-cache:/tfplugin-cache \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gha-runner-local:latest

echo "[runner] Runner container started. Showing last logs..."
sudo docker logs --tail 50 gha-runner || true
