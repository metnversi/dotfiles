#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi
#if use powerlevel10k, comment out plugin starship at plugin folder
#ZSH_THEME="powerlevel10k/powerlevel10k"

export ZSH="$HOME/.oh-my-zsh"
CASE_SENSITIVE="true"
#ENABLE_CORRECTION="true"

zstyle ':omz:update' mode auto    
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# zstyle ':omz:update' frequency 13
# zstyle ':omz:update' mode auto
# HYPHEN_INSENSITIVE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# COMPLETION_WAITING_DOTS="true"

# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd.mm.yyyy"
export LANG=en_US.UTF-8
#if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

#if command -v tmux >/dev/null 2>&1; then
#    [ -z "$TMUX" ] && exec tmux
#fi
[ -s "/home/rose/.bun/_bun" ] && source "/home/rose/.bun/_bun"

export BUN_INSTALL="$HOME/.bun"
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


PATH=/home/$USER/.nimble/bin:/home/$USER/bin:/home/$USER/myvenv/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/snap/bin:/usr/sbin:/home/$USER/.local/bin
PATH=$PATH:/opt/nvim-linux64/bin:/home/linuxbrew/.linuxbrew/bin:.config/emacs/bin:/home/$USER/cmake/bin
PATH=$PATH:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.linkerd2/bin
export PATH="$HOME/.config/rofi/scripts:$BUN_INSTALL/bin:/opt/nvim-linux-x86_64/bin:$HOME/go/bin:$PATH"

plugins=(
  git 
  hacker-quotes 
  zsh-autosuggestions 
  #zsh-syntax-highlighting 
  direnv 
  thefuck 
  pyenv 
  terraform 
  vscode 
  asdf 
  fzf 
  starship 
  kubectl 
  zsh-interactive-cd 
  zoxide 
  command-not-found 
  tmux
)
export ZOXIDE_CMD_OVERRIDE="cd"
eval "$(zoxide init zsh)"

# export ARCHFLAGS="-arch $(uname -m)
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh

# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
function ctalos() {
  for i in {1..3}; do
    MEM=$((3 * 1024))
    name="k8s-control-$i"
    sudo virt-install --name "$name" \
      --memory "$MEM" --os-variant linux2024 \
      --cdrom /home/rose/iso/metal-amd64.iso \
      --disk "path=/var/lib/libvirt/images/${name}-$(date +%d%S),bus=virtio,size=40" \
      --graphics vnc --vcpus 2 \
      --network bridge=virbr0 --noautoconsole \
      --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no --machine q35
  done

  for i in {1..2}; do
    MEM=$((27 * 1024 / 10))
    name="k8s-worker-$i"
    sudo virt-install --name "$name" \
      --memory "$MEM" --os-variant linux2024 \
      --cdrom /home/rose/iso/metal-amd64.iso \
      --disk "path=/var/lib/libvirt/images/${name}-$(date +%d%S),bus=virtio,size=40" \
      --graphics vnc --vcpus 2 \
      --network bridge=virbr0 --noautoconsole \
      --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no --machine q35
  done
}
function dtalos  (){
  for i in $(sudo virsh list --all --name);do 
    if [[ $i =~ '^k8s.*' ]]; then 
      sudo virsh destroy $i 
      sudo virsh undefine --nvram --remove-all-storage $i
    fi
  done

}
#VDPAU_DRIVER=nvidia
. "$HOME/.cargo/env"
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet
source $ZSH/oh-my-zsh.sh
[[ -f ~/.secret ]] && source ~/.secret
#fortune | cowsay | hacker-quotes
#export LESSOPEN='|~/.lessfilter %s'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/terraform terraform
alias ll='ls -l'
alias la='ls -lrta'
alias ls='ls --color=auto'
alias cc='google-chrome-stable &'
#alias vim='nvim'
alias emacs='emacs -nw'
alias e='emacs -nw'
alias ff='firefox &'
#alias bb='librewolf &'
alias cf='fortune | cowsay'
alias aa='ansible-playbook' 
# bat: add -p for no line number, and --paging=never to not go less pager.
alias cat='bat -p'
alias sl='sudo systemctl enable --now libvirtd'
alias ssh='TERM=xterm-256color ssh'
#alias vpn='sudo systemctl enable --now openvpn && protonvpn-app &'
alias cvpn='sudo systemctl enable --now vpnagentd && /opt/cisco/anyconnect/bin/vpn'
alias sss='sudo systemctl status'
alias eee='sudo systemctl enable --now'
alias rrr='sudo systemctl restart'
alias ddd='sudo systemctl disable --now'
alias vid='ffplay -x 80 -y 24'
alias sc='sudo systemctl'
alias scat='sudo systemctl cat'
alias sedit='sudo systemctl edit'
alias i33='emacs -nw ~/.config/i3/config'
alias enf='sudo vim /etc/nftables.conf'
alias vis='sudo virsh list --all'
alias svis='sudo virsh start'
alias dvis='sudo virsh destroy'
alias uvis='sudo virsh undefine --nvram --remove-all-storage'
alias bathelp='bat --plain --language=help'
alias docker='sudo docker'
alias exi='sudo docker exec -it'
alias dps='docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"'
alias gg='google-chrome'
alias dpip="docker ps -q | xargs -n 1 docker inspect --format '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'"
function help() {
    "$@" --help 2>&1 | bathelp
}
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
#alias reboot='sudo efibootmgr -n 0004 && reboot'

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
