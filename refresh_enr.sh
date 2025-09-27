#!/bin/bash
LOG_FILE=$1
STATIC_FILE=$2

extract_enr() {
  grep -o "enr:[^ ]*" "$LOG_FILE" | head -n 1
}

update_file() {
  local ENR=$1
  if [ -n "$ENR" ]; then
    echo "[\"$ENR\"]" > "$STATIC_FILE"
    echo "✅ static-nodes.json updated: $ENR"
  fi
}

if [ "$3" == "loop" ]; then
  while true; do
    ENR=$(extract_enr)
    update_file "$ENR"
    sleep 60
  done
else
  ENR=$(extract_enr)
  update_file "$ENR"
fi
