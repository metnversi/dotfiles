#!/bin/env bash

# This is privilege script
# Use with caution

WORKDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PFILE=$WORKDIR/../packages.yaml
is_installed() { dpkg -l | grep -qw "$1"; }
exist() { command -v "$1" >/dev/null 2>&1; }

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
extract_section(){
    awk -v section="$1" '
    $0 ~ section {flag=1; next}
    flag && /^\s*-/ {sub(/^\s*-\s*/, ""); print; next}
    flag && !/^\s*-/ {flag=0}
  ' $2 | paste -sd ' '
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

    if [[ ! -t 0 ]]; then
        echo "Non-interactive environment detected. Installing optional packages by default."
        include_optional=false
    else
        echo -e "\033[33m\033[1m[WARNING]\033[0m Do you want optional package\n${optional_packages} [y/N]? (auto-selects 'N' in 3s)"
        read -t 3 -p "> " include_optional
        [[ "$include_optional" =~ ^[Yy]$ ]] && include_optional=true || include_optional=false
    fi
    
	required_packages=$(extract_section "required:" "$PFILE")
	gui_packages=$(extract_section "gui:" "$PFILE")
	optional_packages=$(extract_section "optional:" "$PFILE")

    packages="${required_packages}"
	$include_optional && packages+=" ${optional_packages}"
	$graphical && packages+=" ${gui_packages}"

    packages_to_install=""
	for pkg in $packages; do
	    is_installed "$pkg" || packages_to_install+=" $pkg"
	done
	[ -n "${packages_to_install}" ] \
        && apt install -y $packages_to_install \
            || echo "All packages are already installed."
}
#------------------------------------------------------------- end trixie packaging setup


# avatar to use with display manager such as GNOME. Now I don't use it anymore.
avatar () {
    local graphical=$1
    if [[ -n $graphical ]]; then
	    if [[ -e "/var/lib/AccountsService/icons/${USER}.png" ]]; then
	        echo 
	    else
	        cp "${WORKDIR}/../pref/asset/user.png" "/var/lib/AccountsService/icons/${USER}.png"
	        cat >> /var/lib/AccountsService/users/${USER} <<EOF
[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/home/${USER}/Pictures/bg.jpg'

[User]
XSession=i3
Icon=/var/lib/AccountsService/icons/${USER}.png
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
    cat > /etc/sysctl.d/dot.conf <<'EOF'
vm.swappiness                     =  5
vm.drop_caches                    =  3
vm.stat_interval                  =  10

net.core.busy_read                =  50
net.core.busy_poll                =  50
net.ipv4.tcp_fastopen             =  3
net.ipv6.conf.all.disable_ipv6    =  1
net.ipv6.conf.all.disable_policy  =  1
net.ipv4.ip_local_port_range      =  32000    60000

kernel.nmi_watchdog               =  0
kernel.timer_migration            =  0
EOF

    command sysctl --system 1> /dev/null
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
    echo "source /etc/aliasrc" | tee -a $BASH_GLOBAL
}

# compile suckless terminal.
st(){
    command -v curl > /dev/null || (echo "No curl binary. Stop program." && exit 1)
    STFILE=st-0.9.tar.gz
    curl -LO https://dl.suckless.org/st/$STFILE
    tar xvzf $STFILE
    chown $USER:$USER st-0.9 -R
    rm st-0.9/config.h 
    ln -sf $WORKDIR/../pref/config.h st-0.9/config.h
    cd st-0.9 && make clean install
    cd ..
    rm $STFILE
}

graphical=''
#alias_add

if [ -n "$DISPLAY" ]; then
    graphical=true
fi

dependencies $graphical
if [ -d /sys/class/power_supply/BAT0/ ]; then
    laptoplid
    laptopTouchPadX11
fi

avatar $graphical

sysctl
st
# ipv6
