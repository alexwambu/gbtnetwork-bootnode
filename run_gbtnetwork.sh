#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.gbtnetwork}
GENESIS=/app/genesis.json

mkdir -p "$DATADIR"

# ✅ Initialize with genesis if not done
if [ ! -f "$DATADIR/geth/chaindata/CURRENT" ]; then
  geth init --datadir "$DATADIR" "$GENESIS"
fi

# ✅ Ensure static nodes present
if [ ! -f "$DATADIR/static-nodes.json" ]; then
  cp /app/static-nodes.json "$DATADIR/static-nodes.json"
fi

# ✅ Launch GBTNetwork node
exec geth --datadir "$DATADIR" \
  --networkid 999 \
  --http --http.addr 0.0.0.0 --http.port 9636 \
  --http.api eth,net,web3,personal \
  --port 30303 \
  --ipcdisable --nodiscover
