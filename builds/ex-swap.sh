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
    __memory_total_kb=$(awk '/^MemTotal:/{print $2}' /proc/meminfo)
    __memory_total=$(( __memory_total_kb / 1024 ))
    if grep -q "^MemAvailable:" /proc/meminfo; then
        __memory_avail_kb=$(awk '/^MemAvailable:/{print $2}' /proc/meminfo)
    else
        local mem_free=$(awk '/^MemFree:/{print $2}' /proc/meminfo)
        local mem_cached=$(awk '/^Cached:/{print $2}' /proc/meminfo)
        local mem_buffers=$(awk '/^Buffers:/{print $2}' /proc/meminfo)
        __memory_avail_kb=$((mem_free + mem_cached + mem_buffers))
    fi
    __memory_avail=$(( __memory_avail_kb / 1024 ))
}

## ~/RetroPie/RetroPie-Setup/scriptmodules/helpers.sh
function rpSwap() {
    local command=$1
    local __swapdir=/opt/retropie/libretrocores/lr-genesis-plus-gx-EX/ex-swap
    local swapfile="$__swapdir/swap"
    case $command in
        on)
            local needed=$2
            local size=$((needed - __memory_avail))
            echo Memory Required: [$needed] Memory Avalable: [$__memory_avail]
            if [[ $size -ge 0 ]]; then
                rpSwap off force
                echo "Adding [$size] MB of additional swap"
                sudo mkdir -p "$__swapdir/"
                sudo fallocate -l ${size}M "$swapfile"
                sudo chmod 600 "$swapfile"
                sudo mkswap "$swapfile"
                sudo swapon "$swapfile"
            else
                echo SWAPFILE NOT NEEDED
            fi
            ;;
        off)
            if [[ -f "$swapfile" ]] || [[ "$2" == "force" ]]; then
                echo "Removing additional swap"
                sudo swapoff "$swapfile" 2>/dev/null
                sudo rm -f "$swapfile" 2>/dev/null
            fi
            ;;
    esac
}

# Calculate current [__memory_avail], compare to required [swap_mb], Only Create [swapfile] IF needed
conf_memory_vars
rpSwap on $swap_mb

# Command to run [genesis_plus_gx_libretro.so]
## /opt/retropie/emulators/retroarch/bin/retroarch -L /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/genesis_plus_gx_libretro.so --config /opt/retropie/configs/megadrive/retroarch.cfg /home/pi/RetroPie/roms/megadrive/Paprium.7z --appendconfig /dev/shm/retroarch.cfg
/opt/retropie/emulators/retroarch/bin/retroarch -L /opt/retropie/libretrocores/lr-genesis-plus-gx-EX/genesis_plus_gx_libretro.so --config /opt/retropie/configs/megadrive/retroarch.cfg "$@"

# Turn Off and Remove [swapfile] IF needed
rpSwap off
