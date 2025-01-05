#!/bin/env bash
rm $HOME/.bashrc
git clone --recurse-submodules https://github.com/rexim/dotfiles.git tsoding
sed -i "/gitconfig/d" tsoding/MANIFEST
sed -i "s/20/9/" tsoding/.emacs
bash tsoding/deploy.sh MANIFEST
echo -e "\e[32m Emacs \e[0m: Done"
echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '=')\e[0m"
find . -type f -exec sed -i 's/anna/'"$(whoami)"'/g' {} +
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
    case $operation in
    symlink | override)
      symlinkFile "$filename" "$destination"
      ;;
    *)
      echo -e "\033[31m[SKIP]\033[0m $operation."
      ;;
    esac
  done <"$SCRIPT_DIR/$1"
}

deployManifest MANIFEST.linux
echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '=')\e[0m"

#echo -e "\e[32m*****Begin install package*****\e[0m"
"$(dirname $0)/install.sh"
