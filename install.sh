#!/bin/bash

ORIGINAL_USER=$(logname)
WORKDIR=$(pwd)
check=$(grep -v ^# /etc/apt/sources.list | grep ftp)
if [[ -z $check ]]; then
  echo "deb http://ftp.hk.debian.org/debian bookworm main non-free" | sudo tee -a /etc/apt/sources.list
else
  echo "we got this"
fi
sudo apt update
echo -e "\033[31m\033[1m Make sure you checked packages.yaml for required packages, gui and optional packages! \033[0m"
extract_section() {
  local section=$1
  awk -v section="$section" '
    $0 ~ section {flag=1; next}
    $0 ~ /^ *-/ && flag {print $2; next}
    $0 !~ /^ *-/ && flag {flag=0}
    ' packages.yaml
}

required_packages=$(extract_section "required:" | paste -sd ' ' -)
gui_packages=$(extract_section "gui:" | paste -sd ' ' -)
optional_packages=$(extract_section "optional:" | paste -sd ' ' -)
read -p $'\033[31m\033[1m[WARNING]\033[0m Do you want optional [Y/n]?' include_optional

if [[ "$include_optional" =~ ^[Yy]$ || -z "$include_optional" ]]; then
  if [ "$(systemctl get-default)" = "graphical.target" ]; then
    output="$required_packages $gui_packages $optional_packages"
  else
    output="$required_packages $optional_packages"
  fi
else
  if [ "$(systemctl get-default)" = "graphical.target" ]; then
    output="$required_packages $gui_packages"
  else
    output="$required_packages"
  fi
fi

sudo apt install -y --ignore-missing $output
sudo apt autoremove
ln -s /usr/bin/batcat ~/.local/bin/bat
echo -e "\033[33m[WARNING]\033[0m Some packages maybe missing due to different naming. Please check the log in /var/log/apt/!"

echo -e "\033[31m\033[1m --- Installing Iosevka Nerd font --- \033[0m"
if fc-list | grep -i "Iosevka" >/dev/null; then
  echo "Iosevka font is already installed, SKIP"
else
  read -p "Install Iosevka Nerd font? (Y/n) " install
  case ${install:0:1} in
  n | N)
    echo "Skipping installation of Iosevka Nerd font. Please install a nerd font for yourself manually!"
    ;;
  *)
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Iosevka.zip -P /home/$ORIGINAL_USER/Downloads
    unzip /home/$ORIGINAL_USER/Downloads/*Iosevka*.zip -d /home/$ORIGINAL_USER/Downloads/Iosevka
    sudo mv /home/$ORIGINAL_USER/Downloads/Iosevka/*.ttf /usr/share/fonts/
    sudo fc-cache
    echo -e "\033[31m\033[1m Installed font Iosevka \033[0m"
    ;;
  esac
fi

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
#install nvim

echo -e "\033[32m\033[1m --- neovim! --- \033[0m"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux64.tar.gz
rm nvim-linux64.tar.gz

echo -e "\033[31m\033[1m ---In Rust we trust!--- \033[0m"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo install --locked yazi-fm yazi-cli

echo -e "\033[31m\033[1m --- nodejs come there! \033[0m"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
nvm install 20

echo -e "\033[31m\033[1m --- starship! ----\033[0m"
curl -sS https://starship.rs/install.sh | sh -s -- -y

echo -e "\033[31m\033[1m ---Bun for JS and TS!--- \033[0m"
curl -fsSL https://bun.sh/install | bash
#echo -e "\033[31m\033[1m ---Bat theme!--- \033[0m"
#mkdir -p "$(bat --config-dir)/themes"
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
#wget -P "$(bat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
#bat cache --build
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install thefuck
brew install zoxide
brew install fzf
brew install yazi
pip3 install chromaterm

echo -e "\033[31m\033[1m ---Github CLI--- \033[0m"
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) &&
  sudo mkdir -p -m 755 /etc/apt/keyrings &&
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null &&
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg &&
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
  sudo apt update &&
  sudo apt install gh -y

echo -e "\033[31m\033[1m --- Install oh-my-zsh, powerlevel10k ---\033[0m"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
git clone https://github.com/oldratlee/hacker-quotes.git ~/.oh-my-zsh/custom/plugins/hacker-quotes
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
zsh

#Soltuions found there: https://cravencode.com/post/essentials/enable-tap-to-click-in-i3wm/
sudo mkdir -p /etc/X11/xorg.conf.d
echo -e 'Section "InputClass"
        Identifier "touchpad"
        MatchIsTouchpad "on"
        Driver "libinput"
        Option "Tapping" "on"
EndSection' | sudo tee /etc/X11/xorg.conf.d/90-touchpad.conf
