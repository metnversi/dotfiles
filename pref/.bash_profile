#!/usr/bin/env bash
# Intended for high advance usage - Designed to exec startx from TTY login

[[ -f $HOME/.xinitrc ]] && chmod +x $HOME/.xinitrc

if [[ -z $DISPLAY && $XDG_VTNR ]]; then
    TIMESTAMP=$(date +%H%M%S%s)

    echo "==================================="
    echo "  Select session to start: "
    echo "==================================="
    echo "1) GNOME"
    echo "2) i3"
    echo "3) KDE"
    echo "4) Do nothing (or press Enter)"
    echo "-----------------------------------"
    echo "Automatically starting i3 in 2 seconds..."

    read -t 2 -rp "Enter choice: " choice

    create_xinitrc() {
        local session_cmd="$1"
        local session_name="$2"

        cat > "$HOME/.xinitrc" <<EOF
#!/usr/bin/env bash
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
        *)
            echo "No input or invalid choice. Starting i3 by default."
            create_xinitrc "i3" "i3"
            ;;
    esac
    exec startx
fi
