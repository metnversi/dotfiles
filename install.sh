#!/bin/env bash

ORIGINAL_USER=$(logname)
WORKDIR=$(pwd)
installed() {
  echo -e "\e[32m[OK]\e[0m $1"
}
skip() {
  echo -e "\e[31m[SKIP]\e[0m $1"
}

exist() {
  command -v "$1" >/dev/null 2>&1
}

check=$(grep -v ^# /etc/apt/sources.list | grep ftp)
if [[ -z $check ]]; then
  echo "deb http://ftp.hk.debian.org/debian bookworm main non-free" | sudo tee -a /etc/apt/sources.list
  sudo apt update
  installed "ftp mirror site"
else
  skip "ftp mirror size"
fi
if [[ -e /var/lib/AccountsService/icons/anna.png ]]; then
  skip "avatar anna"
else
  sudo -E cp "$WORKDIR/resource/anna.png" /var/lib/AccountsService/icons/
  echo -e "[org.freedesktop.DisplayManager.AccountsService]
BackgroundFile='/home/anna/Pictures/bg.jpg'
   
[User]
Session=lightdm-xsession
XSession=i3
Icon=/var/lib/AccountsService/icons/anna.png
SystemAccount=false" | sudo tee /var/lib/AccountsService/users/anna
  installed "avatar anna"
fi

echo -e "\033[31m\033[1m[NOTE]\e[0m Make sure you checked packages.yaml for required packages, gui and optional packages!"
#extract_section() {
#  local section=$1
#  awk -v section="$section" '
#    $0 ~ section {flag=1; next}
#    $0 ~ /^ *-/ && flag {print $2; next}
#    $0 !~ /^ *-/ && flag {flag=0}
#    ' packages.yaml
#}
#
#required_packages=$(extract_section "required:" | paste -sd ' ' -)
#gui_packages=$(extract_section "gui:" | paste -sd ' ' -)
#optional_packages=$(extract_section "optional:" | paste -sd ' ' -)
#read -p $'\033[31m\033[1m[WARNING]\033[0m Do you want optional [Y/n]?' include_optional
#
#if [[ "$include_optional" =~ ^[Yy]$ || -z "$include_optional" ]]; then
#  if [ "$(systemctl get-default)" = "graphical.target" ]; then
#    output="$required_packages $gui_packages $optional_packages"
#  else
#    output="$required_packages $optional_packages"
#  fi
#else
#  if [ "$(systemctl get-default)" = "graphical.target" ]; then
#    output="$required_packages $gui_packages"
#  else
#    output="$required_packages"
#  fi
#fi
#
#sudo apt install -y --ignore-missing $output
#sudo apt autoremove
#
extract_section() {
  local section=$1
  awk -v section="$section" '
    $0 ~ section {flag=1; next}
    $0 ~ /^ *-/ && flag {print $2; next}
    $0 !~ /^ *-/ && flag {flag=0}
    ' packages.yaml
}

is_installed() {
  dpkg -l | grep -qw "$1"
}

required_packages=$(extract_section "required:" | paste -sd ' ' -)
gui_packages=$(extract_section "gui:" | paste -sd ' ' -)
optional_packages=$(extract_section "optional:" | paste -sd ' ' -)
read -p $'\033[31m\033[1m[WARNING]\033[0m Do you want optional [Y/n]?' include_optional

if [[ "$include_optional" =~ ^[Yy]$ || -z "$include_optional" ]]; then
  if [ "$(systemctl get-default)" = "graphical.target" ]; then
    packages="$required_packages $gui_packages $optional_packages"
  else
    packages="$required_packages $optional_packages"
  fi
else
  if [ "$(systemctl get-default)" = "graphical.target" ]; then
    packages="$required_packages $gui_packages"
  else
    packages="$required_packages"
  fi
fi

packages_to_install=""
for pkg in $packages; do
  if ! is_installed "$pkg"; then
    packages_to_install="$packages_to_install $pkg"
  fi
done

if [ -n "$packages_to_install" ]; then
  sudo apt install -y --ignore-missing $packages_to_install
else
  echo "All packages are already installed."
fi

sudo apt autoremove
if exist "batcat"; then
  skip "batcat"
else
  ln -s /usr/bin/batcat ~/.local/bin/bat
  installed "batcat"
fi
#echo -e "\033[33m[WARNING]\033[0m Some packages maybe missing due to different naming."

if fc-list | grep -i "Iosevka" >/dev/null; then
  skip "Iosevka"
else
  read -p "Install Iosevka Nerd font? (Y/n) " install
  case ${install:0:1} in
  n | N)
    skip "Iosevka"
    ;;
  *)
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Iosevka.zip -P /home/$ORIGINAL_USER/Downloads
    unzip /home/$ORIGINAL_USER/Downloads/*Iosevka*.zip -d /home/$ORIGINAL_USER/Downloads/Iosevka
    sudo mv /home/$ORIGINAL_USER/Downloads/Iosevka/*.ttf /usr/share/fonts/
    sudo fc-cache
    installed "Isoveka"
    ;;
  esac
fi

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  installed "tpm"
else
  skip "tpm"
fi

if ! exist "/opt/nvim-linux64/bin/nvim"; then
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
  sudo rm -rf /opt/nvim
  sudo tar -C /opt -xzf nvim-linux64.tar.gz
  rm nvim-linux64.tar.gz
  installed "nvim"
else
  skip "nvim"
fi

if ! exist "cargo"; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  skip "cargo"
fi

#cargo install --locked yazi-fm yazi-cli
#if cargo install --list | grep -q "yazi-fm"; then
#  echo "yazi-fm is already installed."
#else
#  echo "Installing yazi-fm..."
#  cargo install --locked yazi-fm
#fi
if exist "yazi"; then
  skip "yazi"
else
  cargo install --locked yazi-cli
  installed "yazi"
fi

if exist "node"; then
  skip "nodejs"
else
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install 20
  installed "nodejs"
fi

#curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
#nvm install 20

#curl -sS https://starship.rs/install.sh | sh -s -- -y
if exist "starship"; then
  skip "starship"
else
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  installed "starship"
fi

if ! exist "bun"; then
  curl -fsSL https://bun.sh/install | bash
  installed "bun"
else
  skip "bun"
fi
#echo -e "\033[31m\033[1m ---Bat theme!--- \033[0m"
#mkdir -p "$(bat --config-dir)/themes"
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
#bat cache --build
install_package() {
  case "$1" in
  brew)
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ;;
  *)
    brew install "$1"
    ;;
  esac
}

for pkg in brew thefuck zoxide fzf yazi; do
  if ! exist "$pkg"; then
    install_package "$pkg"
    installed "$pkg"
  else
    skip "$pkg"
  fi
done
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#brew install thefuck
#brew install zoxide
#brew install fzf
#brew install yazi
if ! exist "ct"; then
  pip3 install chromaterm
  installed "chromaterm"
else
  skip "chromaterm"
fi

#Soltuions found there: https://cravencode.com/post/essentials/enable-tap-to-click-in-i3wm/
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

if ! exist "gh"; then
  (type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
    sudo mkdir -p -m 755 /etc/apt/keyrings &&
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
    sudo apt update &&
    sudo apt install gh -y
  installed "github cli"
else
  skip "github cli"
fi

if ! exist "betterlockscreen"; then
  git clone https://github.com/betterlockscreen/betterlockscreen.git
  bash i3lock-color/install-i3lock-color.sh
  wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system
  echo -e "betterlockscreen -w dim
           source ~/.fehbg" >>~/.xinitrc
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
  systemctl enable betterlockscreen@$USER
  installed "betterlockscreen"
else
  skip "betterlockscreen"
fi
echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '=')\e[0m"
if [ -d "$HOME/.oh-my-zsh" ]; then
  skip "omz"
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
  git clone https://github.com/oldratlee/hacker-quotes.git ~/.oh-my-zsh/custom/plugins/hacker-quotes
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  installed "omz"
fi
