# ============================================================
# Pi Coding Agent + pi-web Web UI
# Base: Debian stable, user: root
#
# pi-web runs via the published npm package (bin: pi-web)
# pi agent installed via official install script
# ============================================================
FROM debian:stable

# --- Build args (injected by CI; default to latest) ---
ARG PI_WEB_VERSION=latest
ARG PI_AGENT_VERSION=latest

# --- User / working dir ---
USER root
WORKDIR /root

# --- System packages ---
# curl: for pi install script
# git, build-essential, python3, python3-pip, python3-venv: dev tooling
# ca-certificates, gnupg, wget: for nodejs setup
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        wget \
        git \
        build-essential \
        python3 \
        python3-pip \
        python3-venv \
        procps \
        nano \
        vim \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js (LTS, >= 22.19.0 required by pi-web) ---
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# --- Bun ---
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

# --- Pi coding agent (official install script) ---
RUN curl -fsSL https://pi.dev/install.sh | sh

# --- pi-web (global install via npm) ---
RUN npm install -g @agegr/pi-web@${PI_WEB_VERSION}

# --- Runtime ---
ENV NODE_ENV=production \
    PI_WEB_HOSTNAME=0.0.0.0 \
    PI_WEB_NO_OPEN=1
EXPOSE 30141

# pi-web binds to 0.0.0.0:30141 (reachable from host)
CMD ["pi-web", "--hostname", "0.0.0.0", "--no-open"]
