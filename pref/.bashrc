case $- in
*i*) ;;
*) return ;;
esac

HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000
HISTTIMEFORMAT="%F %T "
shopt -s checkwinsize
#bind 'TAB:menu-complete'
#bind 'set show-all-if-ambiguous on'

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

force_color_prompt=yes
color_prompt=yes

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*) ;;
esac

if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
export LS_COLORS="di=34:fi=37"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

complete -C /usr/bin/terraform terraform
#/home/$USER/welcome.sh
#VDPAU_DRIVER=nvidia

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#source <(kubectl completion bash)

export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

PATH="/home/$USER/.nimble/bin:/home/$USER/bin:/home/$USER/myvenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/snap/bin:/usr/sbin:/home/$USER/.local/bin"
PATH="$PATH:/opt/nvim-linux64/bin:/home/linuxbrew/.linuxbrew/bin:.config/emacs/bin:/home/$USER/.bun/bin:/home/$USER/cmake/bin"
PATH="$PATH:/usr/local/go/bin:/home/$USER/.cargo/bin"
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

source $HOME/.nvm/nvm.sh
alias sl='sudo systemctl enable --now libvirtd'
alias vpn='sudo systemctl enable --now openvpn && protonvpn-app &'
alias sss='sudo systemctl status'
alias eee='sudo systemctl enable --now'
alias rrr='sudo systemctl restart'
alias ddd='sudo systemctl disable --now'
alias sc='sudo systemctl'
alias scat='sudo systemctl cat'
alias sedit='sudo systemctl edit'
alias ll='ls -lrta'
alias la='ls -a'
alias ld='ls -ld'
alias l='ls -CF'
alias clr='clear'
alias clea='clear'
alias gg='google-chrome-stable &'
alias vim='nvim'
alias ff='firefox &'
alias cat='bat -p '
alias cd='z'
alias i33='vim ~/.config/i3/config'
alias bathelp='bat --plain --language=help'
help() {
  "$@" --help 2>&1 | bathelp || "$@" help 2>&1 | bathelp
}

bash /home/$USER/.welcome
export PATH="$HOME/.config/rofi/scripts:$BUN_INSTALL/bin:/opt/nvim-linux-x86_64/bin:$HOME/go/bin:$PATH"

export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'
export KUBECONFIG="./kubeconfig"
export WEZTERM_LOG=error
export GTK_THEME="Adwaita"
export RUST_BACKTRACE=full
export LESS='-R'
export TALOSCONFIG="./talosconfig"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export BUN_INSTALL="$HOME/.bun"
export WEZTERM_LOG=error
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export ZOXIDE_CMD_OVERRIDE="cd"
export NVM_DIR="$HOME/.nvm"
export MANPAGER="sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
export ZOXIDE_CMD_OVERRIDE="cd"
eval "$(fzf --bash)"
#eval "$(starship init bash)"
eval "$(zoxide init bash)"
