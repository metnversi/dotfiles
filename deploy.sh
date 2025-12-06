#!/bin/env bash

# set -o xtrace

# Avoid to run the script as shell other than bash.
if [[ ${SHELL} != "/bin/bash" ]]; then
  echo -e "Please run inside a bash shell, or \e[32mexport SHELL=/bin/bash\e[0m before running the script, with caution."
  echo -e "You can later use command \e[033mchsh -s /bin/zsh\e[0m to change default shell to zsh for instance."
  exit 1
fi

unset GREP_OPTIONS
USER=${USER:-"$(logname)"}
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${WORKDIR}/function

if [ -d /sys/class/power_supply/BAT0 ]; then
    laptoplid
    laptopTouchPadX11
    sudo apt install -y tlp 
else 
    sudo apt install tuned -y
fi

if [ -n "$DISPLAY" ]; then
    lockScreen
    avatar
    iosevka
    chromeWayland
fi

header
prepare
tsoding_update
# deployManifest ${WORKDIR}/MANIFEST.linux
trixieftp
dependencies
youtube
miscInstall

# brew_install
# github_cli
motd
# gdmMacOS
sysctl
# ipv6
emacsrun
# omzshInstall
alias_add
st
echo "Please source bashrc/zshrc after done install to \
make change applied, \
or just simply logout and login back."
header
