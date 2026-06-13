#!/bin/bash
# 階段 2：隱藏開機跑碼 + 套用自訂 Plymouth 開機畫面
#
# 原理：
#   - /boot/armbianEnv.txt 的 verbosity 控制 kernel log 是否灌到畫面上，
#     bootlogo=true 則讓 Plymouth 全螢幕覆蓋開機過程。
#   - Plymouth "armbian" 主題的 watermark.png 是開機動畫置中顯示的圖，
#     替換成 1920x1080 自訂圖即可蓋掉整個開機畫面。
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
. ./00-common.sh

require_root

ENV_FILE="/boot/armbianEnv.txt"
THEME_DIR="/usr/share/plymouth/themes/armbian"
WATERMARK="$THEME_DIR/watermark.png"

if [ ! -f "$ENV_FILE" ]; then
    err "找不到 $ENV_FILE，此腳本僅支援 Armbian (u-boot + armbianEnv.txt)"
    exit 1
fi

backup_once "$ENV_FILE"

log "設定 $ENV_FILE：verbosity=0, bootlogo=true"
if grep -q '^verbosity=' "$ENV_FILE"; then
    sed -i 's/^verbosity=.*/verbosity=0/' "$ENV_FILE"
else
    echo 'verbosity=0' >> "$ENV_FILE"
fi
if grep -q '^bootlogo=' "$ENV_FILE"; then
    sed -i 's/^bootlogo=.*/bootlogo=true/' "$ENV_FILE"
else
    echo 'bootlogo=true' >> "$ENV_FILE"
fi

if [ -d "$THEME_DIR" ]; then
    fetch_asset "watermark.png"
    backup_once "$WATERMARK"
    log "套用自訂開機畫面到 $WATERMARK"
    install -m 0644 "$ASSETS_DIR/watermark.png" "$WATERMARK"
    plymouth-set-default-theme -R armbian || true
else
    warn "找不到 Plymouth armbian 主題目錄 ($THEME_DIR)，跳過開機畫面替換"
fi

log "階段 2 完成（需重啟才會生效；可用 '$ENV_FILE.orig' 還原）"
