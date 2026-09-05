# pi-web Docker Image

Auto-built Docker image for [Pi coding agent](https://pi.dev) + [pi-web](https://github.com/agegr/pi-web) Web UI.

## Image

**Registry:** `ghcr.io/hcdbp24c3/pi-web`

**Tags:**
- `latest` — newest build
- `<pi-web-version>` — e.g. `0.8.11`

**Architectures:** `linux/amd64`, `linux/arm64`

## Features

- Base: `debian:stable`, runs as `root`
- Installs:
  - Pi coding agent (via official `https://pi.dev/install.sh`)
  - pi-web Web UI (via `npm install -g @agegr/pi-web`)
  - Node.js 22 LTS, Bun, Python 3, git, build tools
- pi-web binds to `0.0.0.0:30141`

## Usage

```bash
docker pull ghcr.io/hcdbp24c3/pi-web:latest

docker run -d \
  --name pi-web \
  -p 30141:30141 \
  -v pi-data:/root/.pi \
  ghcr.io/hcdbp24c3/pi-web:latest
```

Then open <http://localhost:30141>.

### Optional: HTTP Basic Auth

The `pi-web` bin supports `PI_WEB_PASSWORD` (username is always `pi`):

```bash
docker run -d \
  --name pi-web \
  -p 30141:30141 \
  -e PI_WEB_PASSWORD='your-password' \
  ghcr.io/hcdbp24c3/pi-web:latest
```

## How auto-build works

A GitHub Actions workflow (`.github/workflows/build.yml`) runs:

- **Every 6 hours** (cron) and on **manual dispatch**
- Queries the npm registry for the latest versions of:
  - `@agegr/pi-web`
  - `@earendil-works/pi-coding-agent`
- Compares them against the last-built versions committed in `VERSIONS`
- If a new version is found (or `force: true` on manual dispatch):
  - Builds a multi-arch image (`linux/amd64`, `linux/arm64`)
  - Pushes to GHCR with tags `<pi-web-version>` and `latest`
  - Commits the new versions back to `VERSIONS`

### Manual trigger

```bash
gh workflow run build.yml --repo hcdbp24c3/pi-web
# or force a rebuild even if versions are unchanged:
gh workflow run build.yml --repo hcdbp24c3/pi-web -f force=true
```

## Local build

```bash
docker build -t pi-web .
docker run -p 30141:30141 pi-web
```