if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
CASE_SENSITIVE="true"
#ENABLE_CORRECTION="true"

zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# zstyle ':omz:update' frequency 13
# zstyle ':omz:update' mode disable
# HYPHEN_INSENSITIVE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# COMPLETION_WAITING_DOTS="true"

# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"
export ZOXIDE_CMD_OVERRIDE="cd"
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git 
  hacker-quotes 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  direnv 
  thefuck 
  pyenv 
  terraform 
  vscode 
  asdf 
  fzf 
  #starship 
  kubectl 
  zsh-interactive-cd 
  zoxide 
  command-not-found 
  tmux
)

export LANG=en_US.UTF-8
if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='vim'
 else
   export EDITOR='nvim'
 fi

# export ARCHFLAGS="-arch $(uname -m)
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh

# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export RUST_BACKTRACE=full
alias ll='ls -lrta'
alias cc='google-chrome-stable &'
alias vim='nvim'
alias ff='firefox &'
alias bb='librewolf &'
alias cf='fortune | cowsay'
alias aa='ansible-playbook' 
# add -p for no line number, and --paging=never to not go less pager.
# bat --list-themes 
alias cat='bat --theme="Catppuccin Macchiato"'

#ssh pair with ct. requires ct (chromaterm, install by pip3)
alias mssh='ct multipass shell'
alias ssh='TERM=xterm-256color ct ssh'

#colorized man page
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

#pnpm
export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

PATH=/home/$USER/.nimble/bin:/home/$USER/bin:/home/$USER/myenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/snap/bin:/usr/sbin:/home/$USER/.local/bin:/usr/local/go/bin
PATH="$PATH:/opt/nvim-linux64/bin:/home/linuxbrew/.linuxbrew/bin:.config/emacs/bin:/home/$USER/cmake/bin"
. "$HOME/.cargo/env"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
source $ZSH/oh-my-zsh.sh

# Move welcome.sh after oh-my-zsh.sh to avoid initialization issues
#/home/$USER/welcome.sh
#fortune | cowsay | hacker-quotes
#bun and fzf
export BUN_INSTALL="$HOME/.bun"
export PATH=$BUN_INSTALL/bin:$PATH
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export LESS='-R'
export LESSOPEN='|~/.lessfilter %s'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
eval "$(zoxide init zsh)"
