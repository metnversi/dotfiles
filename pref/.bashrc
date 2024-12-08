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

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
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
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  #alias grep='grep --color=auto'
  #alias fgrep='fgrep --color=auto'
  #alias egrep='egrep --color=auto'
fi

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

alias ll='ls -lrta'
alias la='ls -a'
alias ld='ls -ld'
alias l='ls -CF'
alias clr='clear'
alias clea='clear'
alias gg='google-chrome-stable &'
alias vim='nvim'
alias ff='firefox &'
alias cat='bat --theme="Catppuccin Latte" -p '

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

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

export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

#/home/$USER/welcome.sh
VDPAU_DRIVER=nvidia
EDITOR=/opt/nvim-linux64/bin/

PATH=/home/$USER/.nimble/bin:/opt/nvim-linux64/bin:/home/$USER/bin:/usr/local/bin:/bin:/usr/local/games:/usr/games:/usr/bin:/snap/bin:/usr/sbin:/home/$USER/.local/bin:/usr/local/go/bin
PATH="$PATH:/opt/nvim-linux64/bin:/home/linuxbrew/.linuxbrew/bin"
. "$HOME/.cargo/env"
eval "$(starship init bash)"
eval "$(fzf --bash)"
eval "$(zoxide init bash)"
#eval $(thefuck --alias)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#source <(kubectl completion bash)

# pnpm
export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac

#ssh() { TERM=xterm-256color /usr/bin/ssh "$@" | ct; }
alias mssh='ct multipass shell'
alias ssh='TERM=xterm-256color ct ssh'
# bun
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

export WEZTERM_LOG=error
alias sl='sudo systemctl enable --now libvirtd'
alias vpn='sudo systemctl enable --now openvpn && protonvpn-app &'
alias sss='sudo systemctl status'
alias eee='sudo systemctl enable --now'
alias rrr='sudo systemctl restart'
alias ddd='sudo systemctl disable --now'
alias sc='sudo systemctl'
alias scat='sudo systemctl cat'
alias sedit='sudo systemctl edit'

# bun
export BUN_INSTALL="$HOME/.bun"
PATH="$PATH:/home/$USER/.config/rofi/scripts:/home/$USER/myvenv/bin"
