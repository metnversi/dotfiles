#!/bin/env bash

#set -o xtrace
#unset GREP_OPTIONS

rm $HOME/.bashrc
[ -d "tsoding/.git" ] &&
  git -C tsoding pull --recurse-submodules &&
  git -C tsoding submodule update --init --recursive ||
  git clone --recurse-submodules https://github.com/rexim/dotfiles.git tsoding 2>/dev/null
sed -i "/gitconfig/d" tsoding/MANIFEST
sed -i "s/20/9/" tsoding/.emacs
sed -i "s/Iosevka-/Iosevka Nerd Font-/" tsoding/.emacs
bash tsoding/deploy.sh MANIFEST
echo -e "\e[32m[Emacs]\e[0m Done\n\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '-')\e[0m"
find . -type f -exec sed -i 's/lisa/'"$(whoami)"'/g' {} +
if [[ -z "./pref/asset/$(whoami)".png ]]; then mv ./pref/asset/lisa.png ./pref/asset/"$(whoami)".png; fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlinkFile() {
  filename="$SCRIPT_DIR/$1"
  destination="$HOME/$2"
  mkdir -p "$(dirname "$destination")"
  ln -sf "$filename" "$destination"
  echo -e "\033[32m[OK]\033[0m $filename -> $destination"
}

deployManifest() {
  while IFS='|' read -r filename operation destination; do
    [[ -z "$filename" ]] && continue
    if [[ $filename =~ ^# ]]; then
      echo -e "\033[33m[DELETE]\033[0m $destination"
      rm -f "$HOME/$destination"
      continue
    fi

    case $operation in
    symlink | override)
      symlinkFile "$filename" "$destination"
      ;;
    *)
      echo -e "\033[31m[ERROR]\033[0m You fucked up with $filename"
      ;;
    esac
  done <"$SCRIPT_DIR/$1"
}

deployManifest MANIFEST.linux
echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '-')\e[0m"
"$(dirname $0)/install.sh"
