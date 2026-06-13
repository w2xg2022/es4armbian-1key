#!/bin/bash
# 階段 3：部署 RetroArch + 使用者偏好設定 + 中文選單字體修正
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
. ./00-common.sh

require_root
ensure_game_user

GAME_HOME="$(getent passwd "$GAME_USER" | cut -d: -f6)"
RA_CFG_DIR="$GAME_HOME/.config/retroarch"

log "安裝 RetroArch 與常用 core（先測 NES/SNES）"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
    retroarch \
    libretro-nestopia \
    libretro-snes9x

log "套用使用者偏好設定 (retroarch.cfg：簡體中文介面、SELECT+START 退出遊戲等)"
fetch_asset "retroarch/retroarch.cfg"
mkdir -p "$RA_CFG_DIR"
backup_once "$RA_CFG_DIR/retroarch.cfg"
install -o "$GAME_USER" -g "$GAME_USER" -m 0644 \
    "$ASSETS_DIR/retroarch/retroarch.cfg" "$RA_CFG_DIR/retroarch.cfg"

log "套用中文選單字體修正（取代 ozone 主題預設字型，修正選單亂碼）"
fetch_asset "fonts/regular.ttf"
fetch_asset "fonts/bold.ttf"
FONT_DIR="$RA_CFG_DIR/assets/ozone/fonts"
mkdir -p "$FONT_DIR"
for f in regular.ttf bold.ttf; do
    backup_once "$FONT_DIR/$f"
    install -o "$GAME_USER" -g "$GAME_USER" -m 0644 "$ASSETS_DIR/fonts/$f" "$FONT_DIR/$f"
done
chown -R "$GAME_USER:$GAME_USER" "$RA_CFG_DIR"

log "建立 core 連結到 ~/.config/retroarch/cores（與 es_systems.cfg 路徑對應）"
mkdir -p "$RA_CFG_DIR/cores"
for core in snes9x nestopia; do
    src="/usr/lib/$(uname -m)-linux-gnu/libretro/${core}_libretro.so"
    if [ -f "$src" ]; then
        ln -sf "$src" "$RA_CFG_DIR/cores/${core}_libretro.so"
    else
        warn "找不到 $src，請確認 libretro-$core 套件的安裝路徑"
    fi
done
chown -R "$GAME_USER:$GAME_USER" "$RA_CFG_DIR/cores"

log "階段 3 完成"
log "備註：字體修正路徑為 $FONT_DIR，若 MD1000 測試後發現 RetroArch 仍顯示亂碼，"
log "      表示實際選單字型路徑不同，需要在這支腳本中調整 FONT_DIR。"
