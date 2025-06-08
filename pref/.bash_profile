#!/bin/env bash
# intended for high advance usage

[[ -f $HOME/.xsession ]] && chmod +x $HOME/.xsession
[[ -f $HOME/.xinitrc ]] && chmod +x $HOME/.xinitrc 
if [[ -z $DISPLAY && $XDG_VTNR ]]; then
  echo "Select session to start:"
  echo "1) GNOME"
  echo "2) i3"
  echo "3) Hyprland"
  #echo "4) KDE"
  echo "4) Do nothing"
  echo "Automatically starting i3 in 3 seconds..."

  read -t 3 -rp "Enter choice: " choice

  case $choice in
    1)
        echo "exec gnome-session > ~/.local/share/gnome-$(date +%H%S%M%s).log 2>&1" > ~/.xsession
        cat > ~/.xinitrc <<EOF
#!/bin/env bash
exec gnome-session
EOF
        startx
        ;;
    2)
        echo "exec i3 > ~/.local/share/i3-$(date +%H%S%M%s).log 2>&1" > ~/.xsession
                cat > ~/.xinitrc <<EOF
#!/bin/env bash
exec i3
EOF
        startx
        ;;
    3)
        rm ~/.xsession 
        exec hyprland
        ;;
    #4)
    #    echo "exec startplasma-x11 > ~/.local/share/kde-$timestamp.log 2>&1" > ~/.xsession
    #    startx
    #    ;;
    *)
      echo "No input or invalid choice. Starting i3 by default."
      echo "exec i3" > ~/.xsession
              cat > ~/.xinitrc <<EOF
#!/bin/env bash
exec i3
EOF
      startx
      ;;
  esac
fi
