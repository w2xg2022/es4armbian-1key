#!/bin/bash
# 階段 1：環境檢測與共用依賴安裝
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
. ./00-common.sh

require_root

log "系統資訊：$(. /etc/os-release; echo "$PRETTY_NAME ($(uname -m))")"

log "安裝共用依賴（polkitd/pkexec、SDL2 mixer、字型相關工具等）"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
    curl ca-certificates unzip \
    polkitd pkexec \
    libsdl2-mixer-2.0-0 \
    libfreeimage3 libcurl4 libpugixml1v5 \
    fontconfig

ensure_game_user

mkdir -p /tmp/es4armbian-1key

# 顯示環境探測：之後第4階段（ES 部署）依此決定走 KMSDRM 或 X11
if [ -e /dev/dri/card0 ] || [ -e /dev/dri/card1 ]; then
    log "偵測到 /dev/dri，後續優先嘗試 KMSDRM（非 X11）模式"
    echo "kmsdrm" > /tmp/es4armbian-1key/display_mode
else
    warn "未偵測到 /dev/dri，後續將直接使用 X11 模式"
    echo "x11" > /tmp/es4armbian-1key/display_mode
fi

log "階段 1 完成"
