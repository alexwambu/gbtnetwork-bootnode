#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.gbtnetwork}
GENESIS_FILE=/app/genesis.json
STATIC_NODES=$DATADIR/static-nodes.json

echo "🚀 Initializing GBTNetwork with genesis..."
if [ ! -d "$DATADIR/geth" ]; then
  geth --datadir "$DATADIR" init "$GENESIS_FILE"
fi

echo "📂 Ensuring static-nodes.json exists in $DATADIR"
if [ ! -f "$STATIC_NODES" ]; then
  cp /app/static-nodes.json "$STATIC_NODES"
fi

echo "🌍 Starting GBTNetwork node on RPC port 9636..."
exec geth \
  --datadir "$DATADIR" \
  --networkid 999 \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 9636 \
  --http.api eth,net,web3,personal,miner \
  --ipcdisable \
  --port 30303 \
  --nodiscover \
  --verbosity 3
