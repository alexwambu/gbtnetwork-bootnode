#!/bin/bash
set -e

LOG_FILE=$1
STATIC_FILE=$2
MODE=${3:-once}   # "once" or "loop"
HTTP_PORT=${4:-8080}

update_static_nodes() {
  if [ ! -f "$LOG_FILE" ]; then
    echo "⚠️ Log file $LOG_FILE not found!"
    return 1
  fi

  # Prefer ENR over enode
  ENR=$(grep -Eo "enr:[a-zA-Z0-9_-]+" "$LOG_FILE" | tail -n1)
  ENODE=$(grep -Eo "enode://[0-9a-fA-F@.:]+" "$LOG_FILE" | tail -n1)

  if [ -n "$ENR" ]; then
    echo "🔑 Found ENR: $ENR"
    echo "[\"$ENR\"]" > "$STATIC_FILE"
  elif [ -n "$ENODE" ]; then
    echo "🔑 Found enode: $ENODE"
    echo "[\"$ENODE\"]" > "$STATIC_FILE"
  else
    echo "⚠️ No ENR/enode found in $LOG_FILE yet."
    return 1
  fi

  # ✅ Sync to GBTNetwork data dir
  mkdir -p /root/.gbtnetwork
  cp "$STATIC_FILE" /root/.gbtnetwork/static-nodes.json
  echo "✅ Updated static-nodes.json"
}

start_http_server() {
  echo "🌐 Serving $STATIC_FILE at http://0.0.0.0:$HTTP_PORT/static-nodes.json"
  while true; do
    # Minimal HTTP server in bash (no python dependency)
    { 
      read line
      echo -e "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n"
      cat "$STATIC_FILE"
    } | nc -l -p "$HTTP_PORT" -q 1
  done
}

if [ "$MODE" = "loop" ]; then
  echo "🔄 Running in loop mode: refreshing every 60s"
  while true; do
    update_static_nodes
    sleep 60
  done
elif [ "$MODE" = "http" ]; then
  update_static_nodes
  start_http_server
else
  update_static_nodes
fi
