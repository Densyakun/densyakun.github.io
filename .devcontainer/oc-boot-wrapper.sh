#!/bin/bash
# devcontainer postStartCommand 用ラッパー（環境と起動状態を記録してから常駐起動を分離する）
set -x
exec >/tmp/oc-boot.log 2>&1
date -Is
id
echo "HOME=$HOME PWD=$PWD"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
echo "SCRIPT_DIR=$SCRIPT_DIR"
ls -la "$SCRIPT_DIR"

# 親プロセスのツリーから完全に切り離す
(
  setsid nohup bash "$SCRIPT_DIR/opencode-serve.sh" >/tmp/opencode-serve.log 2>&1 </dev/null &
)

for i in 1 2 3; do
  sleep 10
  echo "===CHECK-$i $(date -Is)==="
  pgrep -af serve.sh || true
  pgrep -af 'opencode web' || true
  (ss -ltn 2>/dev/null | grep :4096) || echo no-listener
  echo "--- serve.log tail ---"
  tail -15 /tmp/opencode-serve.log 2>&1 || true
  echo "--- opencode.log tail ---"
  tail -5 /tmp/opencode.log 2>&1 || true
done
echo "===WRAPPER END $(date -Is)==="