# Path to your oh-my-zsh installation.
export ZSH='$HOME/.oh-my-zsh'
export SHELL=/bin/zsh
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
source <(kubectl completion zsh)
complete -C '/usr/local/bin/aws_completer' aws

#eval "$(brew shellenv)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search

export export FUNCNEST=700
export TERM=xterm-256color


# Starship or Powerlevel10k

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

#echo source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# TODO: AWK
# list of interesting commands
# kill port --https://github.com/jkfran/killport --command killport
# create QR with amzqr --https://github.com/x-hw/amazing-qr --command amzqr

# You may need to manually set your language environment
export LANG=en_US.UTF-8

export EDITOR=/run/current-system/sw/bin/nvim


alias la=tree
alias cat=bat
# fast update brew
alias buu='brew update && brew upgrade'

#7zz
# Распаковать любой архив
alias unzipall='7zz x'
# Показать что в архиве
alias peek='7zz l'
# Создать быстрый архив
alias quickzip='7zz a archive.7z'
# Распаковать в папку с именем архива
function extract() {
  7zz x "$1" -o"${1%.*}"
}

# rmt -- rm with trash

alias rm=rmt
alias rmi='rmt --ti' #info
alias rmf='rmt --tf' #flash
alias rmd='rmt --td' #GUI

# ssh
alias sshx='export DISPLAY=:0.0 && open /Applications/Utilities/XQuartz.app && ssh -X'

# yazi
export YAZI_CONFIG_HOME='/Users/kamradsmeshnyavy/.config/yazi'
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'
alias lzg='lazygit'

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"
alias lzd='lazydocker'
# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# GO
export GOPATH='/Users/kamradsmeshnyavy/go'

# VIM
alias v="/run/current-system/sw/bin/nvim"

# Nmap
alias nm="nmap -sC -sV -oN nmap"

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/kamradsmeshnyavy/.vimpkg/bin:${GOPATH}/bin:/Users/kamradsmeshnyavy/.cargo/bin



alias cl='clear'

# K8S
export KUBECONFIG=~/.kube/config
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kl="kubectl logs"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kc="kubectx"
alias kns="kubens"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kcns='kubectl config set-context --current --namespace'
alias podname=''

# HTTP requests with xh!
alias http="xh"

# VI Mode!!!
bindkey jj vi-cmd-mode

# eza
export EZA_CONFIG_DIR=~/.config/eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"
alias ls=l


# SEC STUFF
alias gobust='gobuster dir --wordlist ~/security/wordlists/diccnoext.txt --wildcard --url'
alias dirsearch='python dirsearch.py -w db/dicc.txt -b -u'
alias massdns='~/hacking/tools/massdns/bin/massdns -r ~/hacking/tools/massdns/lists/resolvers.txt -t A -o S bf-targets.txt -w livehosts.txt -s 4000'
alias server='python -m http.server 4445'
alias tunnel='ngrok http 4445'
alias fuzz='ffuf -w ~/hacking/SecLists/content_discovery_all.txt -mc all -u'
alias gr='~/go/src/github.com/tomnomnom/gf/gf'

### FZF ###
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh



export PATH=/opt/homebrew/bin:$PATH

alias mat='osascript -e "tell application \"System Events\" to key code 126 using {command down}" && tmux neww "cmatrix"'

# Nix!
export NIX_CONF_DIR=$HOME/.config/nix
export PATH=/run/current-system/sw/bin:$PATH
export PATH=$HOME/.nix-profile/bin:$PATH

alias nixuu='cd /Users/kamradsmeshnyavy/dotfiles/nix-darwin && nix flake update && sudo darwin-rebuild switch --flake .# && cd -'

function ranger {
	local IFS=$'\t\n'
	local tempfile="$(mktemp -t tmp.XXXXXX)"
	local ranger_cmd=(
		command
		ranger
		--cmd="map Q chain shell echo %d > "$tempfile"; quitall"
	)

	${ranger_cmd[@]} "$@"
	if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
		cd -- "$(cat "$tempfile")" || return
	fi
	command rm -f -- "$tempfile" 2>/dev/null
}
alias rr='ranger'

# navigation
cx() { cd "$@" && l; }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l; }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

 # Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	 . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

export XDG_CONFIG_HOME="/Users/kamradsmeshnyavy/.config"

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
export PATH=$PATH:~/.spoofdpi/bin

# Created by `pipx` on 2025-09-13 12:59:56
export PATH="$PATH:/Users/kamradsmeshnyavy/.local/bin"

# FPATH for alacritty(design kamrad)
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# Tmux
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
   tmux attach -t work-flow || tmux new -s work-flow
fi

# Автозапуск Zellij
#if command -v zellij >/dev/null 2>&1; then
  # Проверяем, не запущен ли Zellij уже (через переменную окружения ZELLIJ)
 # if [[ -z "$ZELLIJ" ]]; then
    # Если сессия не существует — создаём новую, иначе подключаемся
  #  zellij --layout ~/session-layout.kdl a main-session
  #fi
#fi

# zsh-syntax-highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[command]='fg=#82aaff'                 # blue
ZSH_HIGHLIGHT_STYLES[alias]='fg=#ffcc00'                   # yellow
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#c3e88d'                 # green
ZSH_HIGHLIGHT_STYLES[function]='fg=#ffffcc'                # light yellow
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff757f,bold'      # red
ZSH_HIGHLIGHT_STYLES[separator]='fg=#828bb8'               # fg_dark
ZSH_HIGHLIGHT_STYLES[argument]='fg=#c8d3f5'                # fg
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ff966c'                # orange
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#fca7ea'  # purple
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#86e1fc'  # cyan
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#65bcff' # blue1
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#4fd6be'    # teal/green1


#update fzf
source <(fzf --zsh)
export EZA_CONFIG_DIR="~/.config/eza"
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"