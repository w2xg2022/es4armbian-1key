# 平台定义表：新增平台时只需在这里加一行对应的设定
# core 档案直接从 libretro buildbot (aarch64 nightly) 下载，避免 apt 套件名称/版本不一致问题
CORE_BUILDBOT_BASE="https://buildbot.libretro.com/nightly/linux/aarch64/latest"

PLATFORM_CODES=(fc sfc md gba ps1)

declare -A PLATFORM_NAME=(
    [fc]="FC / 红白机 (Nintendo)"
    [sfc]="SFC / 超级任天堂 (Super Nintendo)"
    [md]="MD / 世嘉 (Sega Genesis)"
    [gba]="GBA (Game Boy Advance)"
    [ps1]="PS1 (PlayStation)"
)

declare -A PLATFORM_CORE=(
    [fc]="nestopia_libretro.so"
    [sfc]="snes9x_libretro.so"
    [md]="genesis_plus_gx_libretro.so"
    [gba]="mgba_libretro.so"
    [ps1]="pcsx_rearmed_libretro.so"
)

declare -A PLATFORM_EXT=(
    [fc]=".nes .NES .zip .ZIP"
    [sfc]=".smc .sfc .SMC .SFC .zip .ZIP"
    [md]=".md .bin .gen .MD .BIN .GEN .zip .ZIP"
    [gba]=".gba .GBA .zip .ZIP"
    [ps1]=".bin .cue .pbp .chd .BIN .CUE .PBP .CHD"
)

declare -A PLATFORM_ESNAME=(
    [fc]="nes"
    [sfc]="snes"
    [md]="genesis"
    [gba]="gba"
    [ps1]="psx"
)

declare -A PLATFORM_FULLNAME=(
    [fc]="Nintendo Entertainment System"
    [sfc]="Super Nintendo Entertainment System"
    [md]="Sega Genesis / Mega Drive"
    [gba]="Game Boy Advance"
    [ps1]="Sony PlayStation"
)

declare -A PLATFORM_ROMDIR=(
    [fc]="nes"
    [sfc]="snes"
    [md]="genesis"
    [gba]="gba"
    [ps1]="psx"
)

DEFAULT_PLATFORMS="fc sfc"
