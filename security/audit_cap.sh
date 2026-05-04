#!/bin/env bash

[[ $EUID -eq 0 ]] && { echo "[-] Error: This script must NOT be run as root/sudo."; exit 1; }
command -v capsh &>/dev/null || { echo "Error: capsh is required (libcap)."; exit 1; }
{
    echo "PID USER COMMAND EFFECTIVE_CAPS AMBIENT_CAPS"
    for p_path in /proc/[0-9]*; do
        [[ -d "$p_path" ]] || continue
        pid="${p_path##*/}"
        capeff="" capamb="" euid=""
        while read -r prefix v1 v2 rest; do
            case "$prefix" in
                CapEff:) capeff="$v1" ;;
                CapAmb:) capamb="$v1" ;;
                Uid:)    euid="$v2" ;; 
            esac
            [[ -n "$capeff" && -n "$capamb" && -n "$euid" ]] && break
        done < "$p_path/status"
        [[ "$capeff" == "0000000000000000" ]] && continue
        user=$(id -nu "$euid" 2>/dev/null || echo "$euid")
        if [[ -n "$1" ]]; then
            [[ "$user" != "$1" ]] && continue
        else
            [[ "$user" == "root" ]] && continue
        fi
        comm=$(cat "$p_path/comm" 2>/dev/null)
        eff_dec=$(capsh --decode="0x$capeff" 2>/dev/null | cut -d'=' -f2 | tr ' ' ',')
        if [[ "$capamb" == "0000000000000000" ]]; then
            amb_dec="none"
        else
            amb_dec=$(capsh --decode="0x$capamb" 2>/dev/null | cut -d'=' -f2 | tr ' ' ',')
        fi
        echo "$pid $user $comm $eff_dec $amb_dec"
    done
} | column -t
