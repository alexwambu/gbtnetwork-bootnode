#!/bin/bash
set -e

LOG_FILE=$1
STATIC_FILE=$2
MODE=$3

extract_enr() {
  grep -m 1 "Self" "$LOG_FILE" | awk '{print $NF}'
}

write_static_nodes() {
  ENR=$(extract_enr)
  if [ -n "$ENR" ]; then
    echo "[\"$ENR\"]" > "$STATIC_FILE"
    echo "✅ Updated static-nodes.json with ENR: $ENR"
  fi
}

if [ "$MODE" = "loop" ]; then
  while true; do
    sleep 60
    write_static_nodes
    cp "$STATIC_FILE" /root/.gbtnetwork/static-nodes.json
  done
else
  write_static_nodes
  cp "$STATIC_FILE" /root/.gbtnetwork/static-nodes.json
fi
