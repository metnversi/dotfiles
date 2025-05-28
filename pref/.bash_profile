chmod +x ~/.xsession
if [[ -z $DISPLAY && $XDG_VTNR ]]; then
  echo "Select session to start:"
  echo "1) GNOME"
  echo "2) i3"
  echo "3) Hyprland"
  echo "Automatically starting i3 in 3 seconds..."

  read -t 3 -rp "Enter choice [1-3]: " choice

  case $choice in
    1)
        #echo "exec gnome-session > ~/.local/share/gnome-$(date +%H%S%M%s).log 2>&1" > ~/.xsession
        echo "" > ~/.xsession
        exec debus-run-session gnome-session
      ;;
    2)
      echo "exec i3 > ~/.local/share/i3-$(date +%H%S%M%s).log 2>&1" > ~/.xsession
      startx
      ;;
    3)
        exec hyprland
      ;;
    *)
      echo "No input or invalid choice. Starting i3 by default."
      echo "exec i3" > ~/.xsession
      startx
      ;;
  esac
fi
