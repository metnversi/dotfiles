#!/bin/env bash

# This is a privilege script
# Use with caution

_is_installed() { dpkg -l | grep -qw "$1"; }
_is_existed() { command -v "$1" >/dev/null 2>&1; }

_logger() {
    local done=0
    if [[ "$1" == "-d" ]]; then
        done=1
        shift
    fi
    local mod="$1"
    shift
    if (( done )); then
        echo -e "\r\e[K\e[32m[$mod]\e[0m $*"
    else
        echo -ne "\r\e[K\e[32m[$mod]\e[0m $*..."
    fi
}

# Ignore sleeping on close the lib
laptoplid (){
	CHECK=$(grep -v ^# /etc/systemd/logind.conf | grep HandleLid)
	if [[ -z ${CHECK} ]]; then
        PATHD=/etc/systemd/logind.conf
        cat >> $PATHD <<'EOF'
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
EOF
    fi
}

# trixie packaging setup
# extract_section(){
#     awk -v section="$1" '
#     /^\s*#/ {next}
#     $0 ~ section {flag=1; next}
#     flag && /^\s*-/ {sub(/^\s*-\s*/, ""); print; next}
#     flag && !/^\s*-/ {flag=0}
#   ' $2 | paste -sd ' '
# }

_extract_section(){
  awk -v section="$1" '
    { sub(/#.*$/, ""); sub(/[ \t]+$/, ""); }
    /^$/ {next}
    $0 ~ section {flag=1; next}
    flag && /^\s*-/ {sub(/^\s*-\s*/, ""); print; next}
    flag && !/^\s*-/ {flag=0}
  ' "$2" | paste -sd ' '
}


trixieftp () {
	CHECK=$(grep -v ^# /etc/apt/sources.list | grep ftp || false)
	CODENAME=$(grep CODENAME /etc/os-release | awk -F'=' '{print $2}')
	if [[ -z ${CHECK} ]]; then
	    echo -e "deb http://ftp.hk.debian.org/debian bookworm main contrib non-free non-free-firmware
	  deb http://ftp.hk.debian.org/debian ${CODENAME} main contrib non-free non-free-firmware
	  deb-src http://deb.debian.org/debian/ ${CODENAME} main non-free-firmware
	  deb http://security.debian.org/debian-security ${CODENAME}-security main non-free-firmware
	  deb-src http://security.debian.org/debian-security ${CODENAME}-security main non-free-firmware

	  deb http://deb.debian.org/debian/ ${CODENAME}-updates main non-free-firmware
	  deb-src http://deb.debian.org/debian/ ${CODENAME}-updates main non-free-firmware" | tee /etc/apt/sources.list
	    dpkg --add-architecture i386
	    apt update
    fi
}

dependencies () {
    local graphical=$1
    trixieftp
    
	local required_packages=$(_extract_section "required:" "$PFILE")
	local gui_packages=$(_extract_section "gui:" "$PFILE")
	local optional_packages=$(_extract_section "optional:" "$PFILE")
    local include_optional=false

    if [[ ! -t 0 ]]; then
        echo "Non-interactive environment detected. Installing optional packages by default."
    else
        echo -e "\033[33m\033[1m[WARNING]\033[0m Do you want optional package\n${optional_packages} [y/N]? (auto-selects 'N' in 3s)"
        read -t 3 -p "> " include_optional
        [[ "$include_optional" =~ ^[Yy]$ ]] && include_optional=true || include_optional=false
    fi
    local packages="${required_packages}"
	$include_optional && packages+=" ${optional_packages}"
	$graphical && packages+=" ${gui_packages}"

    echo -e "\n\e[32m----------------------------\n\e[0mPackage to install:\n$packages\n\e[32m-----------------------------\e[0m\n"
    local packages_to_install=""
	for pkg in $packages; do
	    _is_installed "$pkg" || packages_to_install+=" $pkg"
	done
	[ -n "${packages_to_install}" ] \
        && apt install -y $packages_to_install \
            || echo "All packages are already installed."
}


# avatar to use with display manager such as GNOME/KDE. Support by AccountService.
# Now I don't use it anymore.
avatar () {
    local graphical=$1
    local ACT_USER=${SUDO_USER:-$USER}

    if [[ -n $graphical ]]; then
        if [[ -e "/var/lib/AccountsService/icons/${ACT_USER}.png" ]]; then
            echo "Avatar already _is_existeds for ${ACT_USER}."
        else
            cp "${WORKDIR}/../pref/asset/user.png" "/var/lib/AccountsService/icons/${ACT_USER}.png"
            cat >> "/var/lib/AccountsService/users/${ACT_USER}" <<EOF
[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/home/${ACT_USER}/Pictures/bg.jpg'

[User]
XSession=i3
Icon=/var/lib/AccountsService/icons/${ACT_USER}.png
SystemAccount=false
EOF
        fi
    fi
}

# laptop touch pad allow to click/doubke click on X11.
laptopTouchPadX11 () {
    if [[ -e /etc/X11/xorg.conf.d/90-touchpad.conf ]]; then
        echo
    else
        mkdir -p /etc/X11/xorg.conf.d/
        echo -e 'Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
  EndSection' | tee /etc/X11/xorg.conf.d/90-touchpad.conf
    fi
    cat > ~/.xsession <<'EOF'
exec i3
EOF
    chmod +x ~/.xsession
}


# Some sysctl paramters that I frequently use
sysctl(){
    cat > /etc/sysctl.d/00-dot.conf <<'EOF'
# zram installed to use with 100% swappiness
vm.swappiness                         =  150
vm.watermark_boost_factor             =  0
vm.watermark_scale_factor             =  125
vm.page-cluster                       =  0
vm.stat_interval                      =  10
vm.vfs_cache_pressure                 =  50
vm.dirty_ratio                        =  10
vm.dirty_background_ratio             =  5
kernel.nmi_watchdog                   =  0
kernel.timer_migration                =  0
net.core.busy_read                    =  50
net.core.busy_poll                    =  50
net.ipv4.ip_forward                   =  1
net.ipv4.tcp_fastopen                 =  3
net.ipv6.conf.all.disable_ipv6        =  1
net.ipv6.conf.all.disable_policy      =  1
net.ipv4.ip_local_port_range          =  32000  65001
net.core.optmem_max                   =  40960
net.ipv4.tcp_fin_timeout              =  10
net.ipv4.tcp_synack_retries           =  2
net.ipv4.tcp_syn_retries              =  2
net.ipv4.tcp_max_syn_backlog          =  65535
net.ipv4.tcp_keepalive_time           =  300
net.ipv4.tcp_keepalive_probes         =  5
net.ipv4.tcp_keepalive_intvl          =  15
net.ipv4.tcp_rfc1337                  =  1
net.ipv4.conf.all.log_martians        =  1
net.ipv4.conf.default.log_martians    =  1
net.ipv4.conf.all.rp_filter           =  0
net.ipv4.conf.all.send_redirects      =  0
net.ipv4.conf.default.send_redirects  =  0
net.core.somaxconn                    =  65535
net.core.netdev_max_backlog           =  65535
net.ipv4.tcp_max_syn_backlog          =  65535
net.ipv4.tcp_max_tw_buckets           =  2000000
net.ipv4.tcp_tw_reuse                 =  0
net.ipv4.tcp_tw_recycle               =  0
net.ipv4.tcp_slow_start_after_idle    =  0
net.ipv4.udp_rmem_min                 =  8192
net.ipv4.udp_wmem_min                 =  8192
net.ipv4.conf.all.accept_source_route =  0
net.ipv4.tcp_rmem                     =  4096 87380 16777216
net.ipv4.tcp_wmem                     =  4096 87380 16777216
net.core.rmem_max                     =  16777216
net.core.wmem_max                     =  16777216
net.core.netdev_budget                =  1000
net.core.rmem_default                 =  262144
net.core.wmem_default                 =  262144
EOF

    command sysctl --system 1> /dev/null
    cat > /etc/default/zramswap <<'EOF'
ALGO=zstd
PERCENT=70
SIZE=512
PRIORITY=100
EOF
systemctl restart zramswap
}


# Ban IPv6, an evil past :)
# ipv6(){
#     echo "precedence ::ffff:0:0/96  10" | tee -a /etc/gai.conf
# }

# Another evil past: build Hyprland. I actually did it successful, but
# it cannot compare to i3wm. After all, simplicity is the best!
# Just keep it here in case building on some VM for testing.
# hyprland_dep(){
# apt install libpugixml-dev \
    #  libgbm-dev libdisplay-info-dev \
    #  hwdata libmagic-dev \
    #  libtomlplusplus-dev libudis86-dev \
    #  libxcb-errors-dev libnotify-dev \
    #  qt6-base-dev qt6-declarative-dev \
    #  qt6-wayland-dev qml-module-qtquick-layouts \
    #  qml-module-qtquick-shapes libsdbus-c++-dev \
    #  libgbm-dev libaudit-dev -y
#
# mkdir -p ~/repos/hyprland && cd ~/repos/hyprland
# list=$(cat <<EOF
# https://github.com/hyprwm/aquamarine.git
# https://github.com/end-4/dots-hyprland.git
# https://codeberg.org/dnkl/fuzzel.git
# https://github.com/hyprwm/hyprcursor.git
# https://github.com/hyprwm/hyprgraphics.git
# https://github.com/hyprwm/hypridle.git
# https://github.com/hyprwm/Hyprland.git
# https://github.com/hyprwm/hyprland-plugins.git
# https://github.com/hyprwm/hyprland-protocols.git
# https://github.com/hyprwm/hyprlang.git
# https://github.com/hyprwm/hyprlock.git
# https://github.com/Gustash/Hyprshot.git
# https://github.com/KZDKM/Hyprspace.git
# https://github.com/shezdy/hyprsplit.git
# https://github.com/hyprwm/hyprutils.git
# https://github.com/hyprwm/hyprwayland-scanner.git
# https://github.com/Horus645/swww.git
# https://github.com/marzer/tomlplusplus.git
# https://github.com/SimplyCEO/wofi.git
# EOF
#     )
# echo "$list" | xargs -n 1 git clone
# }


# Add global alias
alias_add(){
    if [[ -f /etc/bash.bashrc ]]; then
        BASH_GLOBAL=/etc/bash.bashrc
    else
        BASH_GLOBAL=/etc/bashrc
    fi
    cp ${WORKDIR}/../pref/aliasrc /etc/aliasrc
    sed -i "/aliasrc/d" $BASH_GLOBAL
    echo "source /etc/aliasrc" >> $BASH_GLOBAL
}

# compile suckless terminal.
st(){
    local MOD="st"
    local STFILE=st-0.9.tar.gz
    local ACT_USER=${SUDO_USER:-$USER}

    _logger "$MOD" "Start installer"
    command -v curl > /dev/null || { _logger -d "$MOD" "No curl. Stop."; return 1; }
    _logger "$MOD" "Downloading source"
    curl -sLO "https://dl.suckless.org/st/$STFILE" || { _logger -d "$MOD" "Download failed"; return 1; }
    _logger "$MOD" "Configuring"
    tar xzf "$STFILE"
    chown -R "$ACT_USER:$ACT_USER" st-0.9
    rm -f st-0.9/config.h
    ln -sf "$WORKDIR/../pref/config.h" st-0.9/config.h
    _logger "$MOD" "Compiling"
    (
        cd st-0.9 || exit 1
        make clean install > /dev/null 2>&1
    ) || { _logger -d "$MOD" "Compilation failed"; return 1; }
    _logger "$MOD" "Cleaning up"
    rm "$STFILE"
    _logger -d "$MOD" "Installed"
}

xorg_no_root(){
    REAL_USER=${SUDO_USER:-$USER}
    xfile=/etc/X11/Xwrapper.config

    sed -i '/needs_root_rights/d' $xfile
    echo "needs_root_rights = no" >> $xfile
    usermod -aG video,render $REAL_USER
}

process_limits() {
    INTERACTIVE_USERS=$(awk -F: '($3 >= 400 && $7 !~ /nologin|false/) {print $1}' /etc/passwd | grep -v "nfsnobody")

    if [[ -z "$INTERACTIVE_USERS" ]]; then
        echo -e "\e[33m[WARNING]\e[0m No interactive users found to process."
        exit 0
    fi

    local TYPE=$1
    local DEFAULT=$2
    local THRESHOLD=$3
    local GLOBAL_MAX=$4
    local total_current_config=0
    local total_needed_new=0
    echo -e "\n--- Processing $TYPE Configuration ---"
    for user in $INTERACTIVE_USERS; do
        local existing=$(grep -v "^#" /etc/security/limits.conf | awk -v u="$user" -v t="$TYPE" '$1==u && $3==t && $2=="-" {print $4}')
        if [[ -n "$existing" ]]; then
            echo -e "\e[32m[OK]\e[0m $user: existing $TYPE is $existing"
            total_current_config=$((total_current_config + existing))
        else
            local current_usage=0
            if [[ "$TYPE" == "nofile" ]]; then
                current_usage=$(lsof -u "$user" 2>/dev/null | wc -l)
            else
                current_usage=$(ps -u "$user" -o nlwp --no-headers | awk '{sum+=$1} END {print sum+0}')
            fi
            local suggested=$DEFAULT
            if [[ $current_usage -gt $THRESHOLD ]]; then
                suggested=$((current_usage * 2))
            fi
            total_needed_new=$((total_needed_new + suggested))
            echo -e "\e[33m[NEW]\e[0m $user: Needs $TYPE ($suggested) | Current: $current_usage"
            echo "$user - $TYPE $suggested" >> /etc/security/limits.conf
            echo -e "\e[32m[APPLIED]\e[0m $user - $TYPE $suggested added to limits.conf"
        fi
    done

    local free=$((GLOBAL_MAX - total_current_config))
    echo "Summary: System Max: $GLOBAL_MAX | Configured: $total_current_config | Available: $free"
}


WORKDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PFILE=$WORKDIR/../packages.yaml
TOTAL_MEM_KB=$(cat /proc/meminfo | grep -i MemTotal | awk '{print $2}')
MAX_FILE_TOTAL=$((TOTAL_MEM_KB * 70 / 1024))
MAX_PROC_TOTAL=4000000

graphical=''
if [ -n "$DISPLAY" ]; then
    graphical=true
fi

main(){
    alias_add
    dependencies $graphical

    if [ -d /sys/class/power_supply/BAT0/ ]; then
        laptoplid
        laptopTouchPadX11
    fi
    xorg_no_root
    sysctl
    #process_limits "nofile" 65535 33000 $MAX_FILE_TOTAL
    process_limits "nproc" 8192 4096 $MAX_PROC_TOTAL
    st
    # ipv6
}

if [[ -n "$1" && "$1" != _* ]] && declare -f "$1" > /dev/null; then
    "$@"
elif [[ -n "$1" ]]; then
    echo -e "\e[31m[ERROR]\e[0m Function '$1' is private or does not exist."
    exit 1
else
    main
fi
