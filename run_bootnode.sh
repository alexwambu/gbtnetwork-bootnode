#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.bootnode}
KEYFILE=$DATADIR/bootnode.key
FALLBACK_KEY=/app/bootnode.key
STATIC_FILE=/app/static-nodes.json
LOG_FILE=/tmp/bootnode.log

mkdir -p "$DATADIR"

# ✅ Ensure bootnode binary is available
if ! command -v bootnode >/dev/null 2>&1; then
  echo "❌ bootnode binary missing!"
  exit 127
fi

# ✅ If no key exists, copy fallback
if [ ! -f "$KEYFILE" ]; then
  if [ -f "$FALLBACK_KEY" ]; then
    echo "🗝️ Using fallback bootnode.key..."
    cp "$FALLBACK_KEY" "$KEYFILE"
  else
    echo "🔑 Generating new bootnode key..."
    bootnode -genkey "$KEYFILE"
  fi
fi

# ✅ Start bootnode
echo "🚀 Starting bootnode..."
bootnode -nodekey "$KEYFILE" -verbosity 3 -addr :30301 > "$LOG_FILE" 2>&1 &

sleep 3

# ✅ Extract first ENR + create static-nodes.json
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE"

# ✅ Start background refresher loop
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE" loop &

# ✅ Serve static-nodes.json over HTTP
cd /app
echo "🌍 Serving static-nodes.json at /static-nodes.json on port 8080"
python3 -m http.server 8080
