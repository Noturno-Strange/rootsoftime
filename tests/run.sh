#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export XDG_DATA_HOME="$tmp/data"
godot --headless --editor --import
godot --headless --script res://tests/rules.gd -- --test
for total in 2 4; do
  godot --headless --max-fps 60 --single-threaded-scene --script res://tests/network.gd -- --test host "$total" >"$tmp/host" 2>&1 &
  host=$!
  sleep 1
  clients=()
  for ((i=1; i<total; i++)); do
    godot --headless --max-fps 60 --single-threaded-scene --script res://tests/network.gd -- --test client "$total" >"$tmp/client$i" 2>&1 &
    clients+=("$!")
  done
  result=0
  for pid in "${clients[@]}" "$host"; do wait "$pid" || result=1; done
  cat "$tmp/host" "$tmp"/client*
  [[ "$result" == 0 ]]
done
godot --headless --max-fps 60 --script res://tests/reconnect.gd -- --test host >"$tmp/rehost" 2>&1 &
host=$!
sleep 1
result=0
godot --headless --max-fps 60 --script res://tests/reconnect.gd -- --test client || result=1
wait "$host" || result=1
cat "$tmp/rehost"
exit "$result"
