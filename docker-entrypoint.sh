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

# Start tailscaled if binary exists on the persistent volume.
# Auth state is persisted in the statedir so it reconnects automatically.
TS_BIN="/data/workspace/.local/bin/tailscaled"
TS_STATE="/data/workspace/.local/tailscale"
if [ -x "$TS_BIN" ]; then
  rm -f "$TS_STATE/tailscaled.sock"
  "$TS_BIN" \
    --tun=userspace-networking \
    --statedir="$TS_STATE" \
    --socket="$TS_STATE/tailscaled.sock" \
    >>"$TS_STATE/tailscaled.log" 2>&1 &
  echo "[entrypoint] tailscaled started (pid $!)"
fi

exec "$@"
