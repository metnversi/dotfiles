#!/usr/bin/env bash
# Intended for high advance usage - Designed to exec startx from TTY login

# Ensure we have PATH env :)
if [ -f $HOME/.bashrc ]; then
    . $HOME/.bashrc
fi

rm -rf $HOME/.xinitrc

create_xinitrc() {
    local session_cmd="$1"
    local session_name="$2"

    cat > "$HOME/.xinitrc" <<EOF
#!/usr/bin/env bash

export SAL_USE_VCLPLUGIN=gtk3
export XDG_CURRENT_DESKTOP="$session_name"
export XDG_SESSION_DESKTOP="$session_name"
export DESKTOP_SESSION="$session_name"
export XDG_SESSION_TYPE="x11"
if [[ "$session_name" == "lxqt" || "$session_name" == "kde" ]]; then
    export QT_QPA_PLATFORMTHEME=qt6ct
else
    export QT_QPA_PLATFORMTHEME=gtk3
fi
export LVM_SUPPRESS_FD_WARNINGS=1

if [ -z "\$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/\$(id -u)/bus"

fi

DBUS_UPDATE=\$(which dbus-update-activation-environment)
if [ -x "\$DBUS_UPDATE" ]; then
    \$DBUS_UPDATE --systemd --all
fi

exec > "\$HOME/.local/share/${session_name}-${TIMESTAMP}.log"
exec $session_cmd
EOF
    chmod +x "$HOME/.xinitrc"
}

if [[ -z "$DISPLAY" && -n "$XDG_VTNR" && -z "$TMUX" ]]; then
    TIMESTAMP=$(date +%H%M%S%s)

    cat << EOF
===================================
  Select session to start:
===================================
1) GNOME
2) i3 (or press Enter)
3) KDE
4) LXQt
5) Do nothing
-----------------------------------
Automatically starting i3 in 2 seconds...
EOF
    read -t 2 -rp "Enter choice: " choice

    case $choice in
        1)
            echo "Starting GNOME..."
            create_xinitrc "gnome-session" "gnome"
            ;;
        2)
            echo "Starting i3..."
            create_xinitrc "i3" "i3"
            ;;
        3)
            echo "Starting KDE Plasma..."
            create_xinitrc "startplasma-x11" "kde"
            ;;
        4)
            echo "Starting LXQt..."
            create_xinitrc "startlxqt" "lxqt"
            ;;
        5)
            echo "Do nothing"
            rm -f "$HOME/.xinitrc"
            return
            ;;
        *)
            echo "No input or invalid choice. Starting i3 by default."
            create_xinitrc "i3" "i3"
            ;;
    esac
    exec startx
fi
