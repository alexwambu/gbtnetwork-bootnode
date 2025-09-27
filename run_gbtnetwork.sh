#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.gbtnetwork}

# ✅ Init genesis if not already initialized
if [ ! -d "$DATADIR/geth" ]; then
  echo "🔄 Initializing GBTNetwork with genesis.json..."
  geth --datadir "$DATADIR" init /app/genesis.json
fi

# ✅ Start bootnode in background
echo "🚀 Starting bootnode..."
/app/run_bootnode.sh &

# ✅ Delay before linking static-nodes.json
(
  sleep 10
  echo "🔗 Creating symlink for static-nodes.json..."
  mkdir -p "$DATADIR"
  ln -sf /app/static-nodes.json "$DATADIR/static-nodes.json"
) &

# ✅ Start GBTNetwork full node
echo "🌍 Starting GBTNetwork node..."
exec geth \
  --datadir "$DATADIR" \
  --networkid 999 \
  --port 30303 \
  --http --http.addr 0.0.0.0 --http.port 9636 \
  --http.api "eth,net,web3,personal,miner,admin" \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --syncmode "full" \
  --verbosity 3
