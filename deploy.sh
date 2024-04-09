#!/bin/bash

# Check if the script is run as root
if [ "$EUID" -ne 0 ]
    then echo "Please run as root"
    exit
fi

SCRIPT_DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

installPackage() {
    package=$1
    echo "--- Installing $package ---"
    if dpkg -s $package >/dev/null 2>&1; then
        echo "$package is already installed, SKIP"
    else
        apt-get install -y $package
    fi
}

# Install GDB
installPackage gdb

# Install GCC multilib, cross-compilers
installPackage gcc-multilib

# Install vim-nox
installPackage vim-nox

# Install Vundle
echo "--- Installing Vundle ---"
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
else
    echo "Vundle is already installed"
fi

# Install Jellybeans
echo "--- Installing Jellybeans ---"
if [ ! -d ~/.vim/pack/themes/start/jellybeans ]; then
    git clone https://github.com/nanotech/jellybeans.vim.git ~/.vim/pack/themes/start/jellybeans
else
    echo "Jellybeans is already installed"
fi

# Run :PluginInstall
echo "--- Running :PluginInstall ---"
vim +PluginInstall +qall

symlinkFile() {
    filename="$SCRIPT_DIR/$1"
    destination="$HOME/$2/$1"

    mkdir -p $(dirname "$destination")
    
    if [ ! -L "$destination" ]; then
        if [ -e "$destination" ]; then
            echo "[ERROR] $destination exists but it's not a symlink. Please fix that manually" && exit 1
        else
            ln -s "$filename" "$destination"
            echo "[OK] $filename -> $destination"
        fi
    else
        echo "[WARNING] $filename already symlinked"
    fi
}

deployManifest() {
    for row in $(cat $SCRIPT_DIR/$1); do
        filename=$(echo $row | cut -d \| -f 1)
        operation=$(echo $row | cut -d \| -f 2)
        destination=$(echo $row | cut -d \| -f 3)

        case $operation in
            symlink)
                symlinkFile $filename $destination
                ;;

            *)
                echo "[WARNING] Unknown operation $operation. Skipping..."
                ;;
        esac
    done
}

echo "--- Common configs ---"
deployManifest MANIFEST
echo "--- Linux configs ---"
deployManifest MANIFEST.linux