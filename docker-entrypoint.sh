#!/bin/sh
set -e

# Fix volume permissions for Railway (volume mounts as root, container runs as node)
if [ -d /data ] && [ ! -w /data ]; then
  echo "[entrypoint] Fixing /data permissions for node user..."
  # This requires the container to start with enough capability, or the volume
  # to be pre-configured. If this fails, we'll try to continue anyway.
  sudo chown -R node:node /data 2>/dev/null || true
fi

# Ensure state directories exist
mkdir -p "${OPENCLAW_STATE_DIR:-/data/.openclaw}" "${OPENCLAW_WORKSPACE_DIR:-/data/workspace}" 2>/dev/null || true

exec "$@"
