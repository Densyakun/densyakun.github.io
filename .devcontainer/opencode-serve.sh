#!/bin/sh
# Kozmik Cloud Deck 用 opencode 常駐起動スクリプト
# postStartCommand から setsid で呼び出される（プロセスグループの回収を回避）
set -u

# リポジトリのルートへ移動（自身の位置から推測）
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$SCRIPT_DIR/.." || exit 1

export PATH="$HOME/.opencode/bin:$PATH"

# xdg-open（ブラウザ自動起動）を抑制。サーバー起動のみ行う
export BROWSER=true

# 認証情報（devcontainer.env が効かない環境向けにここで保証。ポート公開時は必ず変更すること）
export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
export OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-c2691c2fefc33ee30e117c27}"

# 初回のみインストール
if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
  (curl -fsSL https://opencode.ai/install | bash >/tmp/opencode-install.log 2>&1 || true)
fi
if [ ! -x "$HOME/.opencode/bin/opencode" ]; then
  echo "opencode binary not found after install" >>/tmp/opencode-serve.log
  exit 1
fi

# ポート4096で待受中でなければ起動する（Basic認証設定時は401も稼働扱い）
while true; do
  code=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:4096/ || echo 000)
  if [ -z "$code" ] || [ "$code" = "000" ]; then
    echo "$(date -Is) starting opencode web" >>/tmp/opencode-serve.log
    nohup "$HOME/.opencode/bin/opencode" web --hostname 0.0.0.0 --port 4096 >>/tmp/opencode.log 2>&1 &
    disown
  fi
  sleep 15
done