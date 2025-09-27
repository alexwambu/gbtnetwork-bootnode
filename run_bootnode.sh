#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.bootnode}
KEYFILE=$DATADIR/bootnode.key
STATIC_FILE=/app/static-nodes.json
LOG_FILE=/tmp/bootnode.log

mkdir -p "$DATADIR"

# Generate key if missing
if [ ! -f "$KEYFILE" ]; then
  echo "🔑 Generating new bootnode key..."
  bootnode -genkey "$KEYFILE"
fi

# Start bootnode in background
echo "🚀 Starting bootnode..."
bootnode -nodekey "$KEYFILE" -verbosity 3 -addr :30301 > "$LOG_FILE" 2>&1 &

sleep 2

# Run first ENR extraction
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE"

# Start background refresher
echo "🔄 Launching auto-refresh process..."
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE" loop &

# Serve static file
echo "🌍 Serving static-nodes.json on port 8080..."
cd /app
python3 -m http.server 8080
