#!/bin/bash
set -e

DATADIR=/root/.gbtnetwork
KEYFILE=/app/bootnode.key
STATIC_FILE=/app/static-nodes.json
GENESIS_FILE=/app/genesis.json
LOG_FILE=/tmp/bootnode.log

mkdir -p "$DATADIR"

echo "[*] Starting bootnode..."
bootnode -nodekey "$KEYFILE" -verbosity 3 -addr :30301 > "$LOG_FILE" 2>&1 &
BOOT_PID=$!

sleep 3

echo "[*] Ensuring static-nodes.json exists..."
cp "$STATIC_FILE" "$DATADIR/static-nodes.json"

if [ ! -d "$DATADIR/geth/chaindata" ]; then
    echo "[*] Initializing GBTNetwork with genesis.json..."
    geth --datadir "$DATADIR" init "$GENESIS_FILE"
fi

echo "[*] Launching GBTNetwork node..."
exec geth \
    --networkid 999 \
    --datadir "$DATADIR" \
    --http --http.addr 0.0.0.0 --http.port 9636 --http.api eth,net,web3,txpool \
    --port 30303 \
    --bootnodes "enode://$(bootnode -nodekey "$KEYFILE" -writeaddress)@127.0.0.1:30301" \
    --ipcdisable \
    --allow-insecure-unlock \
    --verbosity 3
