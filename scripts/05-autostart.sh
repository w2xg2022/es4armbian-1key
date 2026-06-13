#!/bin/bash
# 階段 5：開機自動啟動 EmulationStation（仿 MD1000 pegasus-session 架構）
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"
. ./00-common.sh

require_root
ensure_game_user

GAME_HOME="$(getent passwd "$GAME_USER" | cut -d: -f6)"
DISPLAY_MODE="$(cat /tmp/es4armbian-1key/display_mode 2>/dev/null || echo x11)"

if [ "$DISPLAY_MODE" = "kmsdrm" ]; then
    log "設定 systemd 服務：直接以 KMSDRM 模式啟動 EmulationStation（無 X11）"
    cat > /etc/systemd/system/es4armbian.service <<EOF
[Unit]
Description=es4armbian EmulationStation (KMSDRM)
After=systemd-user-sessions.service

[Service]
User=$GAME_USER
PAMName=login
TTYPath=/dev/tty1
Environment=SDL_VIDEODRIVER=kmsdrm
ExecStart=/opt/emulationstation/emulationstation
Restart=always
RestartSec=2

[Install]
WantedBy=graphical.target
EOF
else
    log "設定 X11 環境：openbox autostart + xinitrc + systemd 服務"
    mkdir -p "$GAME_HOME/.config/openbox"

    cat > "$GAME_HOME/.xinitrc" <<'EOF'
exec openbox-session
EOF

    cat > "$GAME_HOME/.config/openbox/autostart" <<'EOF'
xset s off -dpms
xset s noblank
unclutter -idle 0 -root &
(while true; do /opt/emulationstation/emulationstation; sleep 2; done) &
EOF

    chown -R "$GAME_USER:$GAME_USER" "$GAME_HOME/.xinitrc" "$GAME_HOME/.config/openbox"

    cat > /etc/systemd/system/es4armbian.service <<EOF
[Unit]
Description=es4armbian EmulationStation (X11)
After=systemd-user-sessions.service

[Service]
User=$GAME_USER
PAMName=login
TTYPath=/dev/tty1
ExecStart=/usr/bin/startx $GAME_HOME/.xinitrc -- :0 vt1
Restart=always
RestartSec=2

[Install]
WantedBy=graphical.target
EOF
fi

log "啟用 es4armbian.service（開機自動進入 EmulationStation）"
systemctl daemon-reload
systemctl enable es4armbian.service

log "階段 5 完成"
log "提示：請重啟測試（reboot）。若要先在桌面測試，可手動執行："
log "      systemctl start es4armbian.service"
