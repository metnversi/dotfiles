
PATH="$HOME/.nimble/bin:$HOME/bin:$HOME/myvenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/snap/bin:/usr/sbin:/$HOME/.local/bin"
PATH="$PATH:/opt/nvim-linux64/bin:/home/linuxbrew/.linuxbrew/bin:$HOME/.config/emacs/bin:$HOME/.bun/bin:$HOME/cmake/bin:$HOME/.linkerd2/bin"
PATH="$PATH:/usr/local/go/bin:/home/$USER/.cargo/bin"
export PATH="$HOME/.config/rofi/scripts:$BUN_INSTALL/bin:/opt/nvim-linux-x86_64/bin:$HOME/go/bin:$PATH"

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

unset color_prompt force_color_prompt

# PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#case "$TERM" in
#    xterm* | rxvt*)
#        PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#        ;;
#    *) 
#        PS1= "$ " 
#        ;;
#esac

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

complete -C /usr/bin/terraform terraform

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source <(/usr/bin/kubectl completion bash)

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

help() {
  "$@" --help 2>&1 | bathelp || "$@" help 2>&1 | bathelp
}

abbrev() { a='[0-9a-fA-F]' b=$a$a c=$b$b; sed "s/$b-$c-$c-$c-$c$c$c//g"; }

eval "$(fzf --bash)"
# eval "$(starship init bash)"
eval "$(zoxide init bash)"
source <(talosctl completion bash)
source "$HOME/.cargo/env"

if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
  export PS1="[ssh]$PS1"
fi
# source ~/.dev/bin/activate 

alias offscr='xset dpms force off'
alias cd='z'
alias e='$HOME/.local/bin/emacsscript.sh'
alias emacs='$HOME/.local/bin/emacsscript.sh'
alias cat='bat -p'

source ~/.exportrc
source ~/.secret
pokemon-colorscripts \
    --no-title -sr | \
    fastfetch \
        -c $HOME/.config/fastfetch/config-pokemon.jsonc \
        --logo-type file-raw \
        --logo-height 10 \
        --logo-width 5 \
        --logo -
complete -C /usr/bin/mc mc
TEXT=$(sed 's/||/\\e\[32m||\\e\[0m/g' $HOME/.text) && echo -e "$TEXT"
cd
