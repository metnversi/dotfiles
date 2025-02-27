#!/bin/env bash
rm $HOME/.bashrc
git clone --recurse-submodules https://github.com/rexim/dotfiles.git tsoding
sed -i "/gitconfig/d" tsoding/MANIFEST
sed -i "s/20/9/" tsoding/.emacs
sed -i "s/Iosevka-/Iosevka Nerd Font-/" tsoding/.emacs
bash tsoding/deploy.sh MANIFEST
echo -e "\e[32m[Emacs]\e[0m Done"
echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '=')\e[0m"
find . -type f -exec sed -i 's/lisa/'"$(whoami)"'/g' {} +
if [[ -z "./pref/asset/$(whoami)".png ]]; then mv ./pref/asset/lisa.png ./pref/asset/"$(whoami)".png; fi
echo -e '#!/bin/bash
urls=(
    "https://lwn.net"
    "https://www.phoronix.com/"
    "https://sadservers.com/scenarios"
    "https://discuss.kubernetes.io/"
    "https://cloud.redhat.com/learn"
    "https://developers.redhat.com/blog"
)
for url in "${urls[@]}"; do
    firefox "$url" &
done' >~/.run-web.sh
echo -e "echo -e 'Hello World!
Visit now:
\e[034mhttps://lwn.net
https://www.phoronix.com/
https://sadservers.com/scenarios
https://discuss.kubernetes.io/
https://cloud.redhat.com/learn
https://developers.redhat.com/blog\e[0m
If you would like to open all of them in fifefox, press \e[32mCmd+A\e[0m'" >~/.welcome

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
    if [[ $filename =~ ^# ]]; then
      echo -e "\033[31m[DELETE]\033[0m $destination"
      rm -f "$HOME/$destination"
      continue
    fi

    case $operation in
    symlink | override)
      symlinkFile "$filename" "$destination"
      ;;
    *)
      echo -e "\033[31m[SKIP]\033[0m $filename"
      ;;
    esac
  done <"$SCRIPT_DIR/$1"
}

#deployManifest() {
#  while IFS='|' read -r filename operation destination; do
#    case $operation in
#    symlink | override)
#      symlinkFile "$filename" "$destination"
#      ;;
#    *)
#      echo -e "\033[31m[SKIP]\033[0m $filename"
#      ;;
#    esac
#  done <"$SCRIPT_DIR/$1"
#}

deployManifest MANIFEST.linux
echo -e "\e[32m$(printf '%*s' "$(tput cols)" '' | tr ' ' '=')\e[0m"

#echo -e "\e[32m*****Begin install package*****\e[0m"
"$(dirname $0)/install.sh"
