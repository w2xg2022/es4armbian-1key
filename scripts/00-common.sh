#!/bin/bash
# Shared helpers sourced by all stage scripts.
set -euo pipefail

REPO_RAW_BASE="${REPO_RAW_BASE:-https://raw.githubusercontent.com/w2xg2022/es4armbian-1key/main}"
ASSETS_DIR="${ASSETS_DIR:-/tmp/es4armbian-1key/assets}"
GAME_USER="${GAME_USER:-game}"

log()  { printf '\033[1;32m[1key]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[1key][警告]\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31m[1key][錯誤]\033[0m %s\n' "$*" >&2; }

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        err "請用 root 執行（sudo bash $0）"
        exit 1
    fi
}

ensure_game_user() {
    if ! id "$GAME_USER" >/dev/null 2>&1; then
        log "建立使用者 $GAME_USER"
        useradd -m -G audio,video,input,render "$GAME_USER"
    fi
}

# 下載素材到本地快取（assets/ 目錄），優先用倉庫內已存在的檔案，
# 否則從 GitHub raw 抓取，方便單獨重跑各階段腳本。
fetch_asset() {
    local rel_path="$1"
    local dest="$ASSETS_DIR/$rel_path"
    mkdir -p "$(dirname "$dest")"
    if [ -f "$dest" ]; then
        return 0
    fi
    log "下載素材 $rel_path"
    curl -fsSL "$REPO_RAW_BASE/assets/$rel_path" -o "$dest"
}

backup_once() {
    local f="$1"
    if [ -e "$f" ] && [ ! -e "$f.orig" ]; then
        cp -a "$f" "$f.orig"
    fi
}
