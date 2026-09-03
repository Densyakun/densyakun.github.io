#!/bin/bash
# Kozmik Cloud Deck 用 opencode 常駐起動スクリプト (v3: 原因追跡用に全行程をログ出力)
LOG=/tmp/opencode-serve.log

{
  echo "==== $(date -Is) serve.sh start ===="
  echo "argv0=$0 uid=$(id -u) user=$(id -un) HOME=$HOME PWD=$PWD"
} >>"$LOG" 2>&1

# gh 経由の ssh 等で起動すると HOME が Windows の C:... に化けることがあるため、
# uid の passwd エントリから確実な HOME を再導出する。
real_home=$(getent passwd "$(id -u)" | cut -d: -f6)
if [ -z "$real_home" ]; then
  real_home=/home/codespace
fi
export HOME="$real_home"
export PATH="$HOME/.opencode/bin:$PATH"
echo "resolved HOME=$HOME stdPATH=$PATH" >>"$LOG" 2>&1

# ブラウザ自動起動 (xdg-open) を抑制し、サーバー起動のみ行う
export BROWSER=true

# 認証情報（ポートを公開しているため必ず設定する。環境変数が効かない環境向けの既定値）
export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
export OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-c2691c2fefc33ee30e117c27}"

PORT=4096

# 初回のみインストール
if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
  echo "$(date -Is) installing opencode..." >>"$LOG" 2>&1
  (curl -fsSL https://opencode.ai/install | bash) >>/tmp/opencode-install.log 2>&1
  install_rc=$?
  echo "$(date -Is) install rc=$install_rc bin=$(ls -la "$HOME/.opencode/bin/opencode" 2>&1)" >>"$LOG" 2>&1
fi
if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
  echo "$(date -Is) FATAL: opencode binary missing after install" >>"$LOG" 2>&1
  exit 1
fi
echo "$(date -Is) binary ok: $($HOME/.opencode/bin/opencode --version 2>&1 | head -1)" >>"$LOG" 2>&1

# ポート4096で待受中（HTTP 200/401 応答）でなければ起動する。
# 注意: curl -w %{http_code} は接続失敗時も 000 を出力しつつ終了コード非ゼロになるため、
#       '|| echo' を足すと 000000 に化けて判定が壊れる。--noproxy でプロキシ経由のハングも回避。
while true; do
  code=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' --max-time 5 "http://127.0.0.1:$PORT/" 2>/dev/null || true)
  echo "$(date -Is) probe=$code" >>"$LOG" 2>&1
  if [ "$code" = "200" ] || [ "$code" = "401" ]; then
    sleep 30
    continue
  fi
  echo "$(date -Is) starting opencode web" >>"$LOG" 2>&1
  nohup "$HOME/.opencode/bin/opencode" web --hostname 0.0.0.0 --port "$PORT" >>/tmp/opencode.log 2>&1 &
  echo "$(date -Is) opencode pid=$! shellpid=$$" >>"$LOG" 2>&1
  sleep 20
done