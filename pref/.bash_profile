#!/usr/bin/env bash

if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

TIMESTAMP=$(date +%H%M%S%s)

launch_x11() {
    local session_cmd="$1"
    local session_name="$2"

    cat > "$HOME/.xinitrc" <<EOF
#!/usr/bin/env bash

export SAL_USE_VCLPLUGIN=gtk3
export XDG_CURRENT_DESKTOP="$session_name"
export XDG_SESSION_DESKTOP="$session_name"
export DESKTOP_SESSION="$session_name"
export XDG_SESSION_TYPE="x11"
export DRI_PRIME=0
export NVA_GDK_ENABLE_NVDEC=1

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

exec > "\$HOME/.local/share/${session_name}-${TIMESTAMP}.log" 2>&1
exec $session_cmd
EOF
    chmod +x "$HOME/.xinitrc"
    exec startx
}

launch_wayland() {
    local session_cmd="$1"
    local session_name="$2"

    rm -f "$HOME/.xinitrc"

    # Base Wayland Environment
    export XDG_CURRENT_DESKTOP="$session_name"
    export XDG_SESSION_DESKTOP="$session_name"
    export DESKTOP_SESSION="$session_name"
    export XDG_SESSION_TYPE="wayland"
    export QT_QPA_PLATFORM="wayland;xcb"
    export GDK_BACKEND="wayland,x11,*"
    export ELECTRON_OZONE_PLATFORM_HINT="auto"
    export DRI_PRIME=0
    export NVA_GDK_ENABLE_NVDEC=1

    if [[ "$session_name" == "lxqt" || "$session_name" == "kde" ]]; then
        export QT_QPA_PLATFORMTHEME=qt6ct
    fi

    if lspci | grep -iE 'vga|3d' | grep -iq nvidia; then
        export LIBVA_DRIVER_NAME=nvidia
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export NVD_BACKEND=direct

        if ! lsmod | grep -q "^nvidia_drm"; then
            echo "Loading nvidia-drm for Wayland session..."
            sudo modprobe nvidia-drm modeset=1 fbdev=1
            udevadm settle --timeout=2
        fi
    fi

    if [ -d /dev/dri ]; then
        local cards
        cards=$(find /dev/dri/ -maxdepth 1 -name 'card*' | sort | paste -sd ":" -)
        if [ -n "$cards" ]; then
            export AQ_DRM_DEVICES="$cards"
            export WLR_DRM_DEVICES="$cards"
        fi
    else
        echo "Error happened. You may load the module nvidia_drm manually"
    fi

    exec > "$HOME/.local/share/${session_name}-wayland-${TIMESTAMP}.log" 2>&1
    $session_cmd
}

if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && -n "$XDG_VTNR" && -z "$TMUX" ]]; then

    cat << EOF
===================================
  Select session to start:
===================================
 1) Hyprland  (Wayland)
 2) i3        (X11 - Default)
 3) GNOME     (Wayland)
 4) GNOME     (X11)
 5) KDE       (Wayland)
 6) KDE       (X11)
 7) LXQt      (X11)
 8) Do nothing
-----------------------------------
Automatically starting i3 in 2 seconds...
EOF
    read -t 2 -rp "Enter choice: " choice

    case $choice in
        1)
            echo "Starting Hyprland (Wayland)..."
            launch_wayland "Hyprland" "Hyprland"
            ;;
        3)
            echo "Starting GNOME (Wayland)..."
            launch_wayland "gnome-session" "GNOME"
            ;;
        4)
            echo "Starting GNOME (X11)..."
            launch_x11 "gnome-session" "gnome"
            ;;
        5)
            echo "Starting KDE Plasma (Wayland)..."
            launch_wayland "startplasma-wayland" "KDE"
            ;;
        6)
            echo "Starting KDE Plasma (X11)..."
            launch_x11 "startplasma-x11" "kde"
            ;;
        7)
            echo "Starting LXQt (X11)..."
            launch_x11 "startlxqt" "lxqt"
            ;;
        8)
            echo "Doing nothing."
            rm -f "$HOME/.xinitrc"
            return
            ;;
        2|*)
            echo "Starting i3 (X11)..."
            launch_x11 "i3" "i3"
            ;;
    esac
fi
