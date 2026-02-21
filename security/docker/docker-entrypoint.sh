#!/bin/bash

set -e
useradd -m -u "$DUID" -d /home/"$DUSER" -s /bin/bash "$DUSER" 2>/dev/null || true
if [ ! -d "/home/$DUSER/repos/dotfiles" ]; then
    mkdir -p /home/$DUSER/repos
    cp -r /usr/local/share/dotfiles /home/$DUSER/repos/dotfiles
    chown -R "$DUSER:$DUSER" "/home/$DUSER"
fi
exec sudo -E HOME=/home/$DUSER -u $DUSER bash -x /home/$DUSER/repos/dotfiles/deploy.sh
