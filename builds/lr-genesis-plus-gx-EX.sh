#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
# https://github.com/RapidEdwin08/RetroPie-Setup
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/RapidEdwin08/RetroPie-Setup/master/ext/RetroPie-Extra/LICENSE
#
# [lr-genesis-plus-gx-EX + Expanded Rom Size Support] https://github.com/BillyTimeGames/Genesis-Plus-GX-Expanded-Rom-Size.git +P4PR1UM Compatibility (202507)
#
# If no user is specified (for RetroPie below v4.8.9)
if [[ -z "$__user" ]]; then __user="$SUDO_USER"; [[ -z "$__user" ]] && __user="$(id -un)"; fi

rp_module_id="lr-genesis-plus-gx-EX"
rp_module_desc="Fork of lr-genesis-plus-gx + Expanded Rom Size Support"
rp_module_help="Place Genesis roms in:\n$romdir/megadrive\n\nSegaChannelRevival requires Expanded Rom Size Support\n\nUse [lr-genesis-plus-gx-EX] for SegaChannelRevival ROMs\n\nP4PR1UM requires +/-2.5GB Memory to run in its entirety\n\nUse [lr-genesis-plus-gx-EX-SWAP] for LOW RAM Hardware"
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/Genesis-Plus-GX/master/LICENSE.txt"
rp_module_repo="git https://github.com/RapidEdwin08/Genesis-Plus-GX-Expanded-Rom-Size.git master"
rp_module_section="exp"

function sources_lr-genesis-plus-gx-EX() {
    gitPullOrClone "$md_build" https://github.com/RapidEdwin08/Genesis-Plus-GX-Expanded-Rom-Size.git
}

function build_lr-genesis-plus-gx-EX() {
    make -f Makefile.libretro clean
    make -f Makefile.libretro
    md_ret_require="$md_build/genesis_plus_gx_libretro.so"
}

function install_lr-genesis-plus-gx-EX() {
    md_ret_files=(
        'genesis_plus_gx_libretro.so'
        'HISTORY.txt'
        'LICENSE.txt'
        'README.md'
    )
}

function configure_lr-genesis-plus-gx-EX() {
    local system
    local def
    for system in gamegear mastersystem megadrive sg-1000 segacd; do
        def=0
        [[ "$system" == "gamegear" || "$system" == "sg-1000" ]] && def=1
        # always default emulator for non armv6
        ! isPlatform "armv6" && def=1
        mkRomDir "$system"
        addEmulator "$def" "$md_id" "$system" "$md_inst/genesis_plus_gx_libretro.so"
        [[ "$system" == 'megadrive' ]] && addEmulator 0 "$md_id-SWAP" "$system" "$md_inst/ex-swap.sh %ROM%"
        addSystem "$system"
    done

    [[ "$md_mode" == "remove" ]] && return

    local paprium_sys=lr-genesis-plus-gx-EX-SWAP
    echo Configure [emulators.cfg] to run [paprium] [Paprium] [PAPRIUM] with [$paprium_sys] to meet 2.5GB Memory Requirements
    if [ "$(cat /opt/retropie/configs/all/emulators.cfg | grep -e megadrive_paprium -e megadrive_Paprium -e megadrive_PAPRIUM)" == '' ]; then
        echo "megadrive_paprium = \"$paprium_sys\"" >> /opt/retropie/configs/all/emulators.cfg
        echo "megadrive_Paprium = \"$paprium_sys\"" >> /opt/retropie/configs/all/emulators.cfg
        echo "megadrive_PAPRIUM = \"$paprium_sys\"" >> /opt/retropie/configs/all/emulators.cfg
    fi

    cat >"$md_inst/ex-swap.sh" << _EOF_
#!/bin/bash

# This file contains functions from The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# https://retropie.org.uk/forum/topic/37137/has-anyone-got-paprium-working-on-retropie/42
swap_mb=2500

## ~/RetroPie/RetroPie-Setup/scriptmodules/inifuncs.sh
function conf_memory_vars() {
    __memory_total_kb=\$(awk '/^MemTotal:/{print \$2}' /proc/meminfo)
    __memory_total=\$(( __memory_total_kb / 1024 ))
    if grep -q "^MemAvailable:" /proc/meminfo; then
        __memory_avail_kb=\$(awk '/^MemAvailable:/{print \$2}' /proc/meminfo)
    else
        local mem_free=\$(awk '/^MemFree:/{print \$2}' /proc/meminfo)
        local mem_cached=\$(awk '/^Cached:/{print \$2}' /proc/meminfo)
        local mem_buffers=\$(awk '/^Buffers:/{print \$2}' /proc/meminfo)
        __memory_avail_kb=\$((mem_free + mem_cached + mem_buffers))
    fi
    __memory_avail=\$(( __memory_avail_kb / 1024 ))
}

## ~/RetroPie/RetroPie-Setup/scriptmodules/helpers.sh
function rpSwap() {
    local command=\$1
    local __swapdir=/opt/retropie/libretrocores/lr-genesis-plus-gx-EX/ex-swap
    local swapfile="\$__swapdir/swap"
    case \$command in
        on)
            local needed=\$2
            local size=\$((needed - __memory_avail))
            echo Memory Required: [\$needed] Memory Avalable: [\$__memory_avail]
            if [[ \$size -ge 0 ]]; then
                rpSwap off force
                echo "Adding [\$size] MB of additional swap"
                sudo mkdir -p "\$__swapdir/"
                sudo fallocate -l \${size}M "\$swapfile"
                sudo chmod 600 "\$swapfile"
                sudo mkswap "\$swapfile"
                sudo swapon "\$swapfile"
            else
                echo SWAPFILE NOT NEEDED
            fi
            ;;
        off)
            if [[ -f "\$swapfile" ]] || [[ "\$2" == "force" ]]; then
                echo "Removing additional swap"
                sudo swapoff "\$swapfile" 2>/dev/null
                sudo rm -f "\$swapfile" 2>/dev/null
            fi
            ;;
    esac
}

# Calculate current [__memory_avail], compare to required [swap_mb], Only Create [swapfile] IF needed
conf_memory_vars
rpSwap on \$swap_mb

# Command to run [genesis_plus_gx_libretro.so]
## /opt/retropie/emulators/retroarch/bin/retroarch -L /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/genesis_plus_gx_libretro.so --config /opt/retropie/configs/megadrive/retroarch.cfg /home/pi/RetroPie/roms/megadrive/Paprium.7z --appendconfig /dev/shm/retroarch.cfg
/opt/retropie/emulators/retroarch/bin/retroarch -L $md_inst/genesis_plus_gx_libretro.so --config /opt/retropie/configs/megadrive/retroarch.cfg "\$@"

# Turn Off and Remove [swapfile] IF needed
rpSwap off
_EOF_
    chmod 755 "$md_inst/ex-swap.sh"
}
