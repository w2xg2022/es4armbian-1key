#!/bin/bash
# 階段 4：部署 EmulationStation（從 es4armbian Release 下載），
# 並依顯示環境設定 es_systems.cfg / es_settings.cfg。
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
. ./00-common.sh

require_root
ensure_game_user

ES_RELEASE_URL="https://github.com/w2xg2022/es4armbian/releases/download/latest/emulationstation-armbian-aarch64.zip"
GAME_HOME="$(getent passwd "$GAME_USER" | cut -d: -f6)"
ES_HOME_CFG="$GAME_HOME/.emulationstation"

log "下載 EmulationStation (es4armbian latest release)"
TMPZIP="/tmp/es4armbian-1key/emulationstation.zip"
mkdir -p /tmp/es4armbian-1key
curl -fsSL "$ES_RELEASE_URL" -o "$TMPZIP"

log "部署到 /opt/emulationstation"
rm -rf /tmp/es4armbian-1key/es-extract
mkdir -p /tmp/es4armbian-1key/es-extract
unzip -oq "$TMPZIP" -d /tmp/es4armbian-1key/es-extract

mkdir -p /opt/emulationstation
cp -a /tmp/es4armbian-1key/es-extract/. /opt/emulationstation/
chmod +x /opt/emulationstation/emulationstation

log "套用 es_systems.cfg / es_settings.cfg（簡體中文、SNES+NES 對應 RetroArch core）"
fetch_asset "emulationstation/es_systems.cfg"
fetch_asset "emulationstation/es_settings.cfg"
mkdir -p "$ES_HOME_CFG"
for f in es_systems.cfg es_settings.cfg; do
    backup_once "$ES_HOME_CFG/$f"
    install -o "$GAME_USER" -g "$GAME_USER" -m 0644 \
        "$ASSETS_DIR/emulationstation/$f" "$ES_HOME_CFG/$f"
done

mkdir -p "$GAME_HOME/ROMs/snes" "$GAME_HOME/ROMs/nes"
chown -R "$GAME_USER:$GAME_USER" "$GAME_HOME/ROMs" "$ES_HOME_CFG"

DISPLAY_MODE="$(cat /tmp/es4armbian-1key/display_mode 2>/dev/null || echo x11)"
log "顯示模式：$DISPLAY_MODE（由階段 1 偵測）"

if [ "$DISPLAY_MODE" = "kmsdrm" ]; then
    log "嘗試 KMSDRM（非 X11）模式快速自檢：3 秒後自動結束"
    if su - "$GAME_USER" -c \
        "SDL_VIDEODRIVER=kmsdrm timeout 3 /opt/emulationstation/emulationstation --version" \
        >/tmp/es4armbian-1key/kmsdrm_test.log 2>&1; then
        log "KMSDRM 自檢通過，標記為 kmsdrm 模式"
    else
        warn "KMSDRM 自檢失敗（log: /tmp/es4armbian-1key/kmsdrm_test.log），改用 X11 模式"
        echo "x11" > /tmp/es4armbian-1key/display_mode
        DISPLAY_MODE="x11"
    fi
fi

if [ "$DISPLAY_MODE" = "x11" ]; then
    log "安裝 X11 最小環境（xserver-xorg, xinit, openbox, unclutter）"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y --no-install-recommends \
        xserver-xorg xinit openbox unclutter
fi

log "階段 4 完成"
