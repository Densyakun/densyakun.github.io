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

# ポート4096で待受中（HTTP 200/401 応答）でなければ起動する
# 注意: curl -w %{http_code} は接続失敗時も 000 を出力しつつ終了コード非ゼロになるため、
#       '|| echo' を足すと 000000 に化けて判定が壊れる。--noproxy でプロキシ経由のハングも回避
while true; do
  code=$(curl -s --noproxy '*' -o /dev/null -w '%{http_code}' --max-time 5 http://127.0.0.1:4096/ 2>/dev/null)
  if [ "$code" != "200" ] && [ "$code" != "401" ]; then
    echo "$(date -Is) starting opencode web (code=${code:-none})" >>/tmp/opencode-serve.log
    nohup "$HOME/.opencode/bin/opencode" web --hostname 0.0.0.0 --port 4096 >>/tmp/opencode.log 2>&1 &
    disown
  fi
  sleep 15
done