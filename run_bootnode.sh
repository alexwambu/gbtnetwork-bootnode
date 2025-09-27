#!/bin/bash
set -e

DATADIR=${DATADIR:-/root/.bootnode}
KEYFILE=$DATADIR/bootnode.key
FALLBACK_KEY=/app/bootnode.key
STATIC_FILE=/app/static-nodes.json
LOG_FILE=/tmp/bootnode.log

mkdir -p "$DATADIR"

# ✅ If no key, use fallback or generate
if [ ! -f "$KEYFILE" ]; then
  if [ -f "$FALLBACK_KEY" ]; then
    cp "$FALLBACK_KEY" "$KEYFILE"
  else
    bootnode -genkey "$KEYFILE"
  fi
fi

# ✅ Start bootnode
bootnode -nodekey "$KEYFILE" -verbosity 3 -addr :30301 > "$LOG_FILE" 2>&1 &

sleep 3

# ✅ Initialize static-nodes.json if missing
if [ ! -f "$STATIC_FILE" ]; then
  echo "[]" > "$STATIC_FILE"
fi

# ✅ Refresh static nodes once + loop + http
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE" once
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE" loop &
/app/refresh_enr.sh "$LOG_FILE" "$STATIC_FILE" http 8080 &

wait
