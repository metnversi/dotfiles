#!/usr/bin/env bash
# Intended for high advance usage - Designed to exec startx from TTY login

if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

[[ -f $HOME/.xinitrc ]] && chmod +x $HOME/.xinitrc

if [[ -z $DISPLAY && $XDG_VTNR ]]; then
    TIMESTAMP=$(date +%H%M%S%s)

    echo "==================================="
    echo "  Select session to start: "
    echo "==================================="
    echo "1) GNOME"
    echo "2) i3 (or press Enter)"
    echo "3) KDE"
    echo "4) Do nothing"
    echo "-----------------------------------"
    echo "Automatically starting i3 in 2 seconds..."

    read -t 2 -rp "Enter choice: " choice

    create_xinitrc() {
        local session_cmd="$1"
        local session_name="$2"

        cat > "$HOME/.xinitrc" <<EOF
#!/usr/bin/env bash

export XDG_CURRENT_DESKTOP="$session_name"
export XDG_SESSION_DESKTOP="$session_name"
export DESKTOP_SESSION="$session_name"
export XDG_SESSION_TYPE="x11"
export QT_QPA_PLATFORMTHEME=gtk3

if [ -z "\$DBUS_SESSION_BUS_ADDRESS" ]; then
    #eval \$(dbus-launch --sh-syntax --exit-with-session)
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/\$(id -u)/bus"

fi

DBUS_UPDATE=\$(which dbus-update-activation-environment)
if [ -x "\$DBUS_UPDATE" ]; then
    \$DBUS_UPDATE --systemd --all
fi

exec $session_cmd > "\$HOME/.local/share/${session_name}-${TIMESTAMP}.log" 2>&1
EOF
        chmod +x "$HOME/.xinitrc"
    }
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

