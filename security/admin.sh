#!/bin/env bash

# This is privilege script
# Use with caution

WORKDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PFILE=$WORKDIR/../packages.yaml
is_installed() { dpkg -l | grep -qw "$1"; }
exist() { command -v "$1" >/dev/null 2>&1; }

extract_section(){
  # exist awk || echo "please install gawk package" && exit 1
  # exist paste || echo "please install coreutils package" && exit 1
  awk -v section="$1" '
    $0 ~ section {flag=1; next}
    flag && /^\s*-/ {sub(/^\s*-\s*/, ""); print; next}
    flag && !/^\s*-/ {flag=0}
  ' $2 | paste -sd ' '
}

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

trixieftp () {
	CHECK=$(grep -v ^# /etc/apt/sources.list | grep ftp)
	CODENAME=$(lsb_release -c | awk '{print $2}')
	if [[ -z ${CHECK} ]]; then
	  echo -e "deb http://ftp.hk.debian.org/debian bookworm main contrib non-free non-free-firmware 
	  deb http://ftp.hk.debian.org/debian ${CODENAME} main contrib non-free non-free-firmware
	  deb-src http://deb.debian.org/debian/ ${CODENAME} main non-free-firmware
	  deb http://security.debian.org/debian-security ${CODENAME}-security main non-free-firmware
	  deb-src http://security.debian.org/debian-security ${CODENAME}-security main non-free-firmware
	
	  deb http://deb.debian.org/debian/ ${CODENAME}-updates main non-free-firmware
	  deb-src http://deb.debian.org/debian/ ${CODENAME}-updates main non-free-firmware" | tee -a /etc/apt/sources.list
	  dpkg --add-architecture i386
	  apt update
fi
}

avatar () {
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
}

dependencies () {
    trixieftp
	echo -e "\033[31m\033[1m[NOTE]\e[0m Make sure you checked packages.yaml for required packages, gui and optional packages!"
	required_packages=$(extract_section "required:" "$PFILE")
	gui_packages=$(extract_section "gui:" "$PFILE")
	optional_packages=$(extract_section "optional:" "$PFILE")
    echo -e "\033[33m\033[1m[WARNING]\033[0m Do you want optional package\n${optional_packages} [y/N]? (auto-selects 'N' in 5s)"
    read -t 5 -p "> " include_optional
    [[ "$include_optional" =~ ^[Yy]$ ]] && include_optional=true || include_optional=false
	#[[ "$include_optional" =~ ^[Nn]$ || -z "$include_optional" ]] && include_optional=false || include_optional=true
	
	is_graphical=$([ "$(systemctl get-default)" = "graphical.target" ] && echo true || echo false)
	packages="${required_packages}"
	$include_optional && packages+=" ${optional_packages}"
	$is_graphical && packages+=" ${gui_packages}"

    packages_to_install=""
	for pkg in $packages; do
	  is_installed "$pkg" || packages_to_install+=" $pkg"
	done
	[ -n "${packages_to_install}" ] \
        && apt install -y $packages_to_install \
            || echo "All packages are already installed."
}


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

lockScreen () {
if ! exist "betterlockscreen"; then
  echo "please build i3lock-color from source first!"
  git clone https://github.com/betterlockscreen/betterlockscreen.git
  apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev \
       libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
       libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev \
       libxkbcommon-x11-dev libjpeg-dev libgif-dev imagemagick bc 
  git clone https://github.com/Raymo111/i3lock-color.git
  cd i3lock-color && bash ./install-i3lock-color.sh
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | bash -s system
  echo -e "betterlockscreen -w dim\nsource ~/.fehbg" > ~/.xinitrc
  chmod +x ~/.xinitrc
  echo -e "[Unit]
Description = Lock screen when going to sleep/suspend
Before=sleep.target
Before=suspend.target

[Service]
User=%I
Type=simple
Environment=DISPLAY=:0
ExecStart=/usr/local/bin/betterlockscreen --lock
TimeoutSec=infinity
ExecStartPost=/usr/bin/sleep 1

[Install]
WantedBy=sleep.target
WantedBy=suspend.target" | tee /etc/systemd/system/betterlockscreen@.service
  systemctl enable "betterlockscreen@${USER}"
  installed "betterlockscreen"
else
  echo
fi
}

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

kernel.nmi_watchdog               =  0
kernel.timer_migration            =  0
EOF

command sysctl --system 1> /dev/null
}


ipv6(){
    echo "precedence ::ffff:0:0/96  10" | tee -a /etc/gai.conf 
}


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

st(){
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

st
alias_add
dependencies
if [ -d /sys/class/power_supply/BAT0/ ]; then
    laptoplid
    laptopTouchPadX11
fi

if [ -n "$DISPLAY" ]; then
    lockScreen
    avatar
fi

sysctl
# ipv6
