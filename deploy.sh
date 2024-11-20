#!/bin/bash
rm $HOME/.bashrc

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

symlinkFile() {
  filename="$SCRIPT_DIR/$1"
  destination="$HOME/$2"

  mkdir -p "$(dirname "$destination")"

  if [ -e "$destination" ] || [ -L "$destination" ]; then
    rm -rf "$destination"
    echo -e "\033[31m [INFO]\033[0m $destination existed. Overwritten."
  fi

  ln -s "$filename" "$destination"
  echo -e "\033[32m [OK]\033[0m $filename -> $destination "
}

deployManifest() {
  while IFS='|' read -r filename operation destination; do
    case $operation in
    symlink | override)
      symlinkFile "$filename" "$destination"
      ;;
    *)
      echo -e "\033[33m [WARNING]\033[0m $operation. Skipping..."
      ;;
    esac
  done <"$SCRIPT_DIR/$1"
}

deployManifest MANIFEST.linux
echo "************************************************************"
echo "************************************************************"
echo -e "\033[33m[HELLO WORLD]\0m Begin install package....\033"
"$(dirname $0)/install.sh"
