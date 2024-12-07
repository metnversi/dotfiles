#!/bin/bash
rm $HOME/.bashrc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlinkFile() {
  filename="$SCRIPT_DIR/$1"
  destination="$HOME/$2"

  mkdir -p "$(dirname "$destination")"

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    rm -rf "$destination"
    echo -e "\033[33m[INFO]\033[0m $destination existed. Overwritten."
  fi

  ln -s "$filename" "$destination"
  echo -e "\033[32m[OK]\033[0m $filename -> $destination "
}

deployManifest() {
  while IFS='|' read -r filename operation destination; do
    case $operation in
    symlink | override)
      symlinkFile "$filename" "$destination"
      ;;
    *)
      echo -e "\031[33m[SKIP]\033[0m $operation."
      ;;
    esac
  done <"$SCRIPT_DIR/$1"
}

deployManifest MANIFEST.linux
echo "************************************************************"
echo -e "\e[32m[HELLO WORLD]\e[0m Begin install package...."
"$(dirname $0)/install.sh"
