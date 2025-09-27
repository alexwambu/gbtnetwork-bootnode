#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.bootnode}
KEYFILE=$DATADIR/bootnode.key
STATIC_FILE=/app/static-nodes.json
LOG_FILE=/tmp/bootnode.log

mkdir -p "$DATADIR"

# ✅ Check if bootnode binary exists
if ! command -v bootnode >/dev/null 2>&1; then
  echo "❌ bootnode binary not found!"
  exit 127
fi

# ✅ Generate key if missing
if [ ! -f "$KEYFILE" ]; then
  echo "🔑 Generating new bootnode key at $KEYFILE ..."
  bootnode -genkey "$KEYFILE"
fi

# ✅ Start bootnode
echo "🚀 Starting bootnode..."
bootnode -nodekey "$KEYFILE" -verbosity 3 -addr :30301 > "$LOG_FILE" 2>&1 &

sleep 3

# ✅ First ENR extract
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE"

# ✅ Start background refresher
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE" loop &

# ✅ Serve static-nodes.json
cd /app
echo "🌍 Serving static-nodes.json on port 8080..."
python3 -m http.server 8080
