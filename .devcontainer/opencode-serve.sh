#!/bin/bash
# Kozmik Cloud Deck 用 opencode 常駐起動スクリプト (v4: インストール失敗に耐える堅牢版)
LOG=/tmp/opencode-serve.log
OPENCODE_VERSION=${OPENCODE_VERSION:-1.18.27}

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
INSTALL_DIR="$HOME/.opencode/bin"
mkdir -p "$INSTALL_DIR"
echo "resolved HOME=$HOME INSTALL_DIR=$INSTALL_DIR" >>"$LOG" 2>&1

# "$HOME/kozmik-cloud-dashboard" はコンテナ再作成(rebuild)で消えるため、
# opencode のフォルダ履歴が参照するパスとしてリポジトリを指す symlink を自動作成する。
# 既存の実体（ディレクトリ/有効 symlink）がある場合は尊重し、壊れた symlink のみ張り直す。
if [ -d /workspaces/densyakun.github.io ] && { [ ! -e "$HOME/kozmik-cloud-dashboard" ] || [ -L "$HOME/kozmik-cloud-dashboard" ]; }; then
  ln -sfn /workspaces/densyakun.github.io "$HOME/kozmik-cloud-dashboard"
  echo "$(date -Is) symlink ensured: $HOME/kozmik-cloud-dashboard -> /workspaces/densyakun.github.io" >>"$LOG" 2>&1
fi

# ブラウザ自動起動 (xdg-open) を抑制し、サーバー起動のみ行う
export BROWSER=true

# 認証情報（ポートを公開しているため必ず設定する。環境変数が効かない環境向けの既定値）
export OPENCODE_SERVER_USERNAME="${OPENCODE_SERVER_USERNAME:-opencode}"
export OPENCODE_SERVER_PASSWORD="${OPENCODE_SERVER_PASSWORD:-c2691c2fefc33ee30e117c27}"

PORT=4096

# バイナリを用意する (決して exit しない)
# 戦略A: 公式インストーラをバージョン固定で実行（GitHub API の最新版取得を回避）
# 戦略B: リリース tarball を直接ダウンロードして展開（戦略AがAPIレート制限等で死んだ場合）
ensure_binary() {
  if [ -x "$INSTALL_DIR/opencode" ]; then
    return 0
  fi
  echo "$(date -Is) strategy A: install opencode $OPENCODE_VERSION" >>"$LOG" 2>&1
  (curl -s --noproxy '*' -fsSL https://opencode.ai/install | bash -s -- --version "$OPENCODE_VERSION" --no-modify-path) >>/tmp/opencode-install.log 2>&1
  if [ -x "$INSTALL_DIR/opencode" ]; then
    echo "$(date -Is) strategy A ok: $("$INSTALL_DIR/opencode" --version 2>&1 | head -1)" >>"$LOG" 2>&1
    return 0
  fi

  case "$(uname -s)" in
    Linux*) OS=linux ;;
    Darwin*) OS=darwin ;;
    *) OS=linux ;;
  esac
  case "$(uname -m)" in
    x86_64) ARCH=x64 ;;
    aarch64|arm64) ARCH=arm64 ;;
    *) ARCH=x64 ;;
  esac
  combo="$OS-$ARCH"
  url="https://github.com/anomalyco/opencode/releases/download/v${OPENCODE_VERSION}/opencode-${combo}.tar.gz"
  echo "$(date -Is) strategy B: direct download $combo" >>"$LOG" 2>&1
  tmpd=$(mktemp -d /tmp/ocx.XXXXXX)
  if curl -s --noproxy '*' -fSL -o "$tmpd/oc.tar.gz" "$url" && tar -xzf "$tmpd/oc.tar.gz" -C "$tmpd" && [ -f "$tmpd/opencode" ]; then
    install -m 755 "$tmpd/opencode" "$INSTALL_DIR/opencode"
    rm -rf "$tmpd"
    if [ -x "$INSTALL_DIR/opencode" ]; then
      echo "$(date -Is) strategy B ok: $("$INSTALL_DIR/opencode" --version 2>&1 | head -1)" >>"$LOG" 2>&1
      return 0
    fi
  fi
  rm -rf "$tmpd"
  echo "$(date -Is) both strategies failed; will retry" >>"$LOG" 2>&1
  return 1
}

# バイナリが手に入るまでリトライ（起動直後のネットワーク/API不調に耐える）
while ! ensure_binary; do
  sleep 15
done

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
  nohup "$INSTALL_DIR/opencode" web --hostname 0.0.0.0 --port "$PORT" >>/tmp/opencode.log 2>&1 &
  echo "$(date -Is) opencode pid=$! shellpid=$$" >>"$LOG" 2>&1
  sleep 20
done