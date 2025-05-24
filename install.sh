#!/bin/env bash

#####################################################################################################################
### This script can be run independently if the ./deploy.sh script is interrupted, or you cancel it by mistake. #####
#####################################################################################################################
#rename 's/^(\d)\./0$1-/; y/A-Z/a-z/' *.md

#set -o xtrace
unset GREP_OPTIONS

USER=${USER:-"$(logname)"}
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "${HOME}/.local/bin" "${HOME}/repos"

if [[ ${SHELL} != "/bin/bash" ]]; then
  echo -e "Please run inside a bash shell, or \e[32mexport SHELL=/bin/bash\e[0m before running the script, with caution."
  echo -e "You can later use command \e[033mchsh -s /bin/zsh\e[0m to change default shell to zsh for instance."
  exit 1
fi

installed() { echo -e "\e[32m[OK]\e[0m $1"; }
skip() { echo -e "\e[31m[SKIP]\e[0m $1"; }
is_installed() { dpkg -l | grep -qw "$1"; }
exist() { command -v "$1" >/dev/null 2>&1; }

extract_section() {
  #exist awk || echo "please install gawk package" && exit 1
  #exist paste || echo "please install coreutils package" && exit 1
  awk -v section="$1" '
    $0 ~ section {flag=1; next}
    flag && /^\s*-/ {sub(/^\s*-\s*/, ""); print; next}
    flag && !/^\s*-/ {flag=0}
  ' packages.yaml | paste -sd ' '
}

laptoplid () {
	CHECK=$(grep -v ^# /etc/systemd/logind.conf | grep HandleLid)
	if [[ -z ${CHECK} ]]; then
	  echo -e "HandleLidSwitch=ignore
	HandleLidSwitchExternalPower=ignore
	HandleLidSwitchDocked=ignore" | sudo tee -a /etc/systemd/logind.conf
	  installed 'Lid'
	else
	  skip 'Lid'
	fi
}

youtube () {
	exist dyt \
        && skip "dyt (yt mp3)" || \
            {
                echo -e '#!/bin/env bash\nyt-dlp -f bestaudio --extract-audio --audio-format mp3 "$1"' | \
                    sudo tee /usr/bin/dyt >/dev/null && sudo chmod 755 /usr/bin/dyt \
                    && installed "dyt (YouTube MP3 script)";
            }
	exist cyt \
        && skip "cyt (yt mp4)" || \
            {
                echo -e '#!/bin/env bash\nyt-dlp -f bestvideo+bestaudio --merge-output-format mp4 "$1"' | \
                    sudo tee /usr/bin/cyt >/dev/null && sudo chmod 755 /usr/bin/cyt \
                    && installed "cyt (YouTube MP4 script)";
            }
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
	  deb-src http://deb.debian.org/debian/ ${CODENAME}-updates main non-free-firmware" | sudo tee -a /etc/apt/sources.list
	  sudo dpkg --add-architecture i386
	  sudo apt update
	  installed "ftp mirror site"
	else
	  skip "ftp mirror size"
	fi
}

avatar () {
	if [[ -e "/var/lib/AccountsService/icons/${USER}.png" ]]; then
	  skip "avatar ${USER}"
	else
	  sudo -E cp "${WORKDIR}/pref/asset/rose.png" "/var/lib/AccountsService/icons/${USER}.png"
	  echo -e "[org.freedesktop.DisplayManager.AccountsService]\nBackgroundFile='/home/${USER}/Pictures/bg.jpg'
	[User]
	Session=lightdm-xsession
	XSession=i3
	Icon=/var/lib/AccountsService/icons/${USER}.png
	SystemAccount=false" | sudo tee /var/lib/AccountsService/users/rose
	  installed "avatar ${USER}"
	fi
}

dependencies () {
	echo -e "\033[31m\033[1m[NOTE]\e[0m Make sure you checked packages.yaml for required packages, gui and optional packages!"
	required_packages=$(extract_section "required:")
	gui_packages=$(extract_section "gui:")
	optional_packages=$(extract_section "optional:")
    echo -e "\033[31m\033[1m[WARNING]\033[0m Do you want optional package\n${optional_packages} [y/N]? (auto-selects 'N' in 5s)"
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
        && sudo apt install -y $packages_to_install \
            || echo "All packages are already installed."
}

iosevka () {
	if fc-list | grep -i "Iosevka" >/dev/null; then
	  skip "Iosevka"
	else
	  read -p "Install Iosevka Nerd font? (Y/n) " install
	  case ${install:0:1} in
	  n | N)
	    skip "Iosevka"
	    ;;
	  *)
	    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Iosevka.zip -P "/home/${USER}/Downloads"
	    unzip "/home/${USER}/Downloads/*Iosevka*.zip" -d "/home/${USER}/Downloads/Iosevka"
	    sudo mv "/home/${USER}/Downloads/Iosevka/*.ttf" /usr/share/fonts/
	    sudo fc-cache
	    installed "Isoveka"
	    ;;
	  esac
	fi
}

miscInstall () {
    installations=(
        '! exist tpm && [ ! -d "${HOME}/.tmux/plugins/tpm" ] && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && installed tpm || skip tpm'
        '! exist nvim && curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz && rm nvim-linux-x86_64.tar.gz && installed nvim || skip nvim'
        '! exist cargo && curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && installed cargo || skip cargo'
        '! exist yazi && cargo install --locked yazi-cli && installed yazi || skip yazi'
        '! exist starship && curl -sS https://starship.rs/install.sh | sh -s -- -y && curl -Lo ~/.config/starship-schema.json https://starship.rs/config-schema.json && installed starship || skip starship'
        '! exist bun && curl -fsSL https://bun.sh/install | bash && installed bun || skip bun'
        '! exist ct && pipx install chromaterm && installed chromaterm || skip chromaterm'
        '! exist greenclip && wget https://github.com/erebe/greenclip/releases/download/v4.2/greenclip && sudo install -m 0755 greenclip /usr/bin && installed greenclip || skip greenclip'
        '[ ! -d "${HOME}/.vim/bundle/Vundle.vim" ] && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && vim +PluginInstall +qall && installed Vundle || skip Vundle'
        '[ ! -f "${HOME}/.vim/colors/molokai.vim" ] && mkdir -p ~/.vim/colors && curl -s https://raw.githubusercontent.com/tomasr/molokai/master/colors/molokai.vim -o ~/.vim/colors/molokai.vim && installed molokai || skip molokai'
        '[ ! -d "${HOME}/.vim/pack/css-color/start/css-color" ] && git clone https://github.com/ap/vim-css-color.git ~/.vim/pack/css-color/start/css-color && installed css-color || skip css-color'
    )

    for cmd in "${installations[@]}"; do
        eval "$cmd"
    done
}

brew_package() {
  case "$1" in
  brew)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ;;
  *)
    brew install "$1"
    ;;
  esac
}

brew_install () {
	for pkg in brew thefuck zoxide fzf yazi batcat; do
	  if ! exist "$pkg"; then
	    install_brew_package "$pkg"
	    installed "$pkg"
	  else
	    skip "$pkg"
	  fi
	done
}

laptopTouchPadX11 () {
if [[ -e /etc/X11/xorg.conf.d/90-touchpad.conf ]]; then
  sudo mkdir -p /etc/X11/xorg.conf.d
  skip "touchpad"
else
  echo -e 'Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
  EndSection' | sudo tee /etc/X11/xorg.conf.d/90-touchpad.conf
  installed "touchpad"
fi
}

github_cli () {
if ! exist "gh"; then
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) && \
    sudo mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null && \
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null && \
    sudo apt update && \ 
    sudo apt install gh -y \
    installed "github cli"
else
  skip "github cli"
fi
}

lockScreen () {
if ! exist "betterlockscreen"; then
  echo "please build i3lock-color from source first!"
  git clone https://github.com/betterlockscreen/betterlockscreen.git
  sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev \
       libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev \
       libxcb-image0-dev libxcb-util0-dev libxcb-xrm-dev libxkbcommon-dev \
       libxkbcommon-x11-dev libjpeg-dev libgif-dev imagemagick bc 
  git clone https://github.com/Raymo111/i3lock-color.git
  cd i3lock-color && bash ./install-i3lock-color.sh
  #bash i3lock-color/install-i3lock-color.sh
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system
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
WantedBy=suspend.target" | sudo tee /etc/systemd/system/betterlockscreen@.service
  systemctl enable "betterlockscreen@${USER}"
  installed "betterlockscreen"
else
  skip "betterlockscreen"
fi
}


motd () {
echo -e '#!/bin/bash
urls=(
    "https://lwn.net"
    "https://www.phoronix.com/"
    "https://sadservers.com/scenarios"
    "https://discuss.kubernetes.io/"
    "https://cloud.redhat.com/learn"
    "https://developers.redhat.com/blog"
    "https://kubernetes.io/blog/"
)
for url in "${urls[@]}"; do
    /bin/google-chrome-stable "$url" &
done' > ~/.run-web.sh
echo -e "echo -e 'Hello World!
Visit now:
\e[034mhttps://lwn.net
https://www.phoronix.com/
https://sadservers.com/scenarios
https://discuss.kubernetes.io/
https://cloud.redhat.com/learn
https://developers.redhat.com/blog
https://kubernetes.io/blog/\e[0m
If you would like to open all of them in fifefox, press (i3)\e[32m Cmd+A\e[0m
If you would like to open just one, press (alacritty)\e[32m Ctrl+Shift+o\e[0m, then the text appeared'" >~/.welcome
}

omzshInstall () {
if [ -d "${HOME}/.oh-my-zsh" ]; then
  skip "omz"
else
  mkdir -p "${HOME}/.oh-my-zsh/custom"
  git clone https://github.com/ohmyzsh/ohmyzsh.git "${HOME}/.oh-my-zsh" \
      && git clone https://github.com/oldratlee/hacker-quotes.git "${HOME}/.oh-my-zsh/custom/plugins/hacker-quotes" \
      && git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" \
      && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" \
      && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
      && installed "omz"
fi
}

sysctl(){
    sudo tee /etc/sysctl.d/dot.conf > /dev/null <<EOF
vm.swappiness=5
vm.drop_caches=3
net.core.busy_read=50
net.core.busy_poll=50
net.ipv4.tcp_fastopen=3
kernel.nmi_watchdog = 0
vm.stat_interval = 10
kernel.timer_migration = 0
EOF
sudo sysctl --system
}

emacsrun () {
    cat > ~/.local/bin/emacsscript.sh <<'EOF'
#!/bin/env bash

if ! emacsclient -e "(emacs-pid)" >/dev/null 2>&1; then
    emacs --daemon
fi

exec emacsclient -t "$@"

EOF
    
chmod +x ~/.local/bin/emacsscript.sh
}

main () {
    if [ -d /sys/class/power_supply/BAT0 ]; then
        laptoplid
        laptopTouchPadX11
        sudo apt install -y tlp 
    else sudo apt install tuned -y; fi
    if [ -n "$DISPLAY" ]; then
        lockScreen
        avatar
        iosevka
    fi
    
    echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '=')\e[0m"

    trixieftp
    dependencies
    youtube
    miscInstall

    brew_install
    github_cli
    motd
    #gdmMacOS
    sysctl
    emacsrun
    omzshInstall
    echo "Please source bashrc/zshrc after done install to make change applied, or just simply logout and login back."
}

main
