# Containerized GitHub Actions Runner
# Builds an image with the runner binaries baked in for offline/slow networks.

FROM ubuntu:22.04 as base

# Re-declare build args in this stage so they are visible to ENV/RUN
ARG RUNNER_VERSION=2.328.0
ARG RUNNER_ARCH

ENV DEBIAN_FRONTEND=noninteractive \
    RUNNER_VERSION=${RUNNER_VERSION} \
    RUNNER_ARCH=${RUNNER_ARCH}

RUN apt-get update -y && apt-get install -y \
    curl ca-certificates jq tar git gnupg unzip \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
  mkdir -p /etc/apt/keyrings; \
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg; \
  chmod a+r /etc/apt/keyrings/docker.gpg; \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list; \
  apt-get update -y; \
  apt-get install -y docker-ce-cli; \
  rm -rf /var/lib/apt/lists/*; \
  docker --version

# Install Node.js 20 (for GitHub JavaScript actions like checkout/setup-terraform)
RUN set -eux; \
  export DEBIAN_FRONTEND=noninteractive; \
  apt-get update -y; \
  mkdir -p /etc/apt/keyrings; \
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key -o /tmp/nodesource.gpg.key; \
  gpg --yes --batch --dearmor -o /etc/apt/keyrings/nodesource.gpg /tmp/nodesource.gpg.key; \
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list; \
  apt-get update -y; \
  apt-get install -y nodejs; \
  node -v; npm -v

WORKDIR /opt/actions-runner

# Download runner during build so runtime is offline (auto-detect arch or use override)
RUN set -eux; \
  arch="$RUNNER_ARCH"; \
  if [ -z "$arch" ]; then \
    dpkg_arch="$(dpkg --print-architecture)"; \
    case "$dpkg_arch" in \
      amd64) arch="x64" ;; \
      arm64) arch="arm64" ;; \
      armhf) arch="arm" ;; \
      *) echo "Unsupported architecture: $dpkg_arch" >&2; exit 1 ;; \
    esac; \
  fi; \
  url="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz"; \
  echo "Downloading $url"; \
  curl -fsSL -o actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz "$url"; \
  tar xzf actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz; \
  rm -f actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz; \
  ./bin/installdependencies.sh || true

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Optional labels can be passed via env at runtime
ENV RUNNER_ALLOW_RUNASROOT=1 \
    RUNNER_LABELS="self-hosted,lab" \
    RUNNER_NAME="" \
    RUNNER_WORKDIR="_work"

# Default command
CMD ["/entrypoint.sh"]
