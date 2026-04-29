# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Path to your oh-my-zsh installation.
export ZSH='$HOME/.oh-my-zsh'
export SHELL=/bin/zsh
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
# Reevaluate the prompt string each time it's displaying a prompt
setopt prompt_subst
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
autoload bashcompinit && bashcompinit
autoload -Uz compinit
compinit
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi
if [[ -x /usr/local/bin/aws_completer ]]; then
  complete -C '/usr/local/bin/aws_completer' aws
fi

#eval "$(brew shellenv)"

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey '^p' up-line-or-history
bindkey '^n' down-line-or-history

export FUNCNEST=700
# export TERM=screen-256color
# export TERM=xterm-256color


# Starship or Powerlevel10k

# eval "$(starship init zsh)"
# export STARSHIP_CONFIG=~/.config/starship/starship.toml

if command -v brew >/dev/null 2>&1 && [[ -f "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme ]]; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ ! -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] || source ${ZDOTDIR:-$HOME}/.p10k.zsh


# TODO: AWK
# list of interesting commands
# kill port --https://github.com/jkfran/killport --command killport
# create QR with amzqr --https://github.com/x-hw/amazing-qr --command amzqr

# You may need to manually set your language environment
export LANG=en_US.UTF-8

export EDITOR=/opt/homebrew/bin/nvim

alias ping=gping
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
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# nnn
alias n="nnn"
function nnn () {
  command nnn "$@"

  if [ -f "$NNN_TMPFILE" ]; then
          . "$NNN_TMPFILE"
  fi
}
export NNN_PLUG='f:finder;o:fzopen;p:mocq;d:diffs;t:nmount;v:imgview'

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
# alias v="/opt/homebrew/bin/nvim"
# 1. Определяем переменную с командой (без типов, просто строка)
editable_files='fd -L --exclude "*.{code,data,webm,mp4,mp3,png,avif,webp,jpg,jpeg}"'
# 2. Функция-обёртка, аналогичная alias из Nushell
v() {
  local file
  # Передаём значение переменной как команду-источник
  file=$(tv files --source-command "$editable_files")
  [[ -n "$file" ]] && nvim "$file"
}

# Nmap
alias nm="nmap -sC -sV -oN nmap"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/kamradsmeshnyavy/.vimpkg/bin:${GOPATH}/bin:/Users/kamradsmeshnyavy/.cargo/bin:$PATH"



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
export EZA_CONFIG_DIR=/Users/kamradsmeshnyavy/.config/eza
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
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
#


if [ -f ~/.fzf.zsh ]; then

  # After installing fzf with brew, you have to run the install script
  # echo -e "y\ny\nn" | /opt/homebrew/opt/fzf/install

  source ~/.fzf.zsh

  # Preview file content using bat
  export FZF_CTRL_T_OPTS="
    --preview 'bat -n --color=always {}'
    --bind 'ctrl-/:change-preview-window(down|hidden|)'"

  # Use :: as the trigger sequence instead of the default **
  export FZF_COMPLETION_TRIGGER='::'
  export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
  --color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
  --color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
  --color=selected-bg:#45475A \
  --color=border:#6C7086,label:#CDD6F4"

  # Eldritch Colorscheme / theme
  # https://github.com/eldritch-theme/fzf
  # export FZF_DEFAULT_OPTS='--color=fg:#ebfafa,bg:#09090d,hl:#37f499 --color=fg+:#ebfafa,bg+:#0D1116,hl+:#37f499 --color=info:#04d1f9,prompt:#04d1f9,pointer:#7081d0 --color=marker:#7081d0,spinner:#f7c67f,header:#323449'
fi




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

# ===== Nushell aliases migrated to zsh =====
# conflicts (existing zsh alias kept unchanged):
# la -> zsh: tree
# la -> nushell: eza --all --icons
# n -> zsh: nnn
# n -> nushell: exec nu
# k -> zsh: kubectl
# k -> nushell: zellij delete-all-sessions -y; zellij kill-all-sessions -y
# v -> zsh: /opt/homebrew/bin/nvim
# v -> nushell: nvim (tv files --source-command $editable_files)
# ga -> zsh: git add -p
# ga -> nushell: git add
# gc -> zsh: git commit -m
# gc -> nushell: git commit --verbose
# gca -> zsh: git commit -a -m
# gca -> nushell: git commit --verbose --all
# gp -> zsh: git push origin HEAD
# gp -> nushell: git push
# gpu -> zsh: git pull origin
# gpu -> nushell: git push upstream
# gst -> zsh: git status
# gst -> nushell: custom status def + aliases (gss/gsb)
# gr -> zsh: ~/go/src/github.com/tomnomnom/gf/gf
# gr -> nushell: git remote
# cl -> zsh: clear
# cl -> nushell: clear

# replace.nu
alias cd='z'
alias curl='curlie'
alias du='dust'
alias dig='doggo'
alias grep='rg'
alias top='btop'
alias vim='nvim'

# brew.nu
alias bi='brew install'
alias bui='brew uninstall'
alias bou='brew outdated'
alias bu='brew upgrade'
alias bua='brew update && brew upgrade && brew cleanup'
alias rm_brewlock='rm -rf "$(brew --prefix)/var/homebrew/locks"'

# eza.nu + lla.nu
alias ll='eza --long --icons'
alias lst='eza --all --icons --tree'
alias llt='eza --long --icons --tree'
alias lls='lla --sizemap'
alias lltl='lla --timeline'
alias llg='lla --git'

# mac.nu
alias nu-kill='kill'
alias kill='command kill'
alias python='python3'
alias pip='pip3'

# alias.nu (safe direct aliases)
alias a='gh copilot suggest'
alias b='bun run'
alias d='dust'
alias e='exit 0'
alias ff='fastfetch'
alias g='lazygit --use-config-dir ~/.config/lazygit'
alias h='bun run hexo s'
alias i='gemini'
alias m='start_mpd'
alias o='open'
alias p='tmux popup -w 80% -h 80%'
alias q='exit 0'
alias r='rmpc'
alias s='somo'
alias t='tokei'
alias u='uv'
alias w='wsl'
alias x='~/.local/bin/extract'
alias y='yazi'
alias ze='zellij attach --create gnix'
alias c2p='code2prompt'
alias ci='code'
alias gg='gitui'
alias lc='nvim leetcode.nvim'
alias hexo='bun run hexo'
# renamed from `pyenv` to avoid shadowing real pyenv binary in zsh startup
alias pyenvnu='overlay use .venv/bin/activate.nu'
alias scene='adb shell sh /storage/emulated/0/Android/data/com.omarea.vtools/up.sh'
alias shizuku='adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh'
alias zo='zoxide'

# folder aliases (as in nushell)
alias music='yazi ~/OneDrive/Music'
alias vluv='cd ~/vluv'
alias wiki='cd ~/astro-docs'
alias draft='nvim ~/.cahce/temp.md'

# git.nu (non-conflicting aliases)
git_current_branch() { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
git_main_branch() { git remote show origin 2>/dev/null | sed -n 's/.*HEAD branch: //p'; }

alias gaa='git add --all'
alias gapa='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gap='git apply'
alias gapt='git apply --3way'
alias gbd='git branch --delete'
alias gbD='git branch --delete --force'
alias gbl='git blame -b -w'
alias gbm='git branch --move'
alias gbmc='git branch --move "$(git_current_branch)"'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsn='git bisect new'
alias gbso='git bisect old'
alias gbsr='git bisect reset'
alias gbss='git bisect start'
alias gcn='git commit --verbose --no-edit'
alias gcam='git commit --all --message'
alias gcsm='git commit --signoff --message'
alias gcas='git commit --all --signoff'
alias gcasm='git commit --all --signoff --message'
alias gcb='git checkout -b'
alias gcd='git checkout develop'
alias gcf='git config --list'
alias gcl='git clone --recurse-submodules'
alias gscl='git clone --depth=1'
alias gclean='git clean --interactive -d'
alias gcm='git checkout "$(git_main_branch)"'
alias gcmsg='git commit --message'
alias gcor='git checkout --recurse-submodules'
alias gcount='git shortlog --summary --numbered'
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'
alias gcs='git commit --gpg-sign'
alias gcss='git commit --gpg-sign --signoff'
alias gcssm='git commit --gpg-sign --signoff --message'
alias gd='git diff'
alias gdca='git diff --cached'
alias gdcw='git diff --cached --word-diff'
alias gdct='git describe --tags "$(git rev-list --tags --max-count=1)"'
alias gds='git diff --staged'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdup='git diff @{upstream}'
alias gdw='git diff --word-diff'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gignore='git update-index --assume-unchanged'
alias gl='git log'
alias glg='git log --stat'
alias glgp='git log --stat --patch'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glo='git log --oneline --decorate'
alias gm='git merge'
alias gmtl='git mergetool --no-prompt'
alias gmtlvim='git mergetool --no-prompt --tool=vimdiff'
alias gma='git merge --abort'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gpod='git push origin --delete'
alias gpodc='git push origin --delete "$(git_current_branch)"'
alias gpr='git pull --rebase'
alias gpv='git push --verbose'
alias gpra='git pull --rebase --autostash'
alias gprav='git pull --rebase --autostash --verbose'
alias gprv='git pull --rebase --verbose'
alias gpsup='git push --set-upstream origin "$(git_current_branch)"'
alias gra='git remote add'
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase develop'
alias grbi='git rebase --interactive'
alias grbm='git rebase "$(git_main_branch)"'
alias grbo='git rebase --onto'
alias grbs='git rebase --skip'
alias grev='git revert'
alias grh='git reset'
alias grhh='git reset --hard'
alias groh='git reset "origin/$(git_current_branch)" --hard'
alias grm='git rm'
alias grmc='git rm --cached'
alias grs='git restore'
alias grss='git restore --source'
alias grst='git restore --staged'
alias grt='cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"'
alias gru='git reset --'
alias grup='git remote update'
alias grv='git remote --verbose'
alias gsb='git status --short --branch'
alias gsd='git svn dcommit'
alias gsh='git show'
alias gshs='git show -s'
alias gsi='git submodule init'
alias gsps='git show --pretty=short --show-signature'
alias gsr='git svn rebase'
alias gss='git status --short'
alias gsta='git stash push'
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstu='gsta --include-untracked'
alias gstall='git stash --all'
alias gsu='git submodule update'
alias gsw='git switch'
alias gswc='git switch --create'
alias gts='git tag --sign'
alias glum='git pull upstream "$(git_main_branch)"'
alias gunignore='git update-index --no-assume-unchanged'
alias gup='git pull --rebase'
alias gupv='git pull --rebase --verbose'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash --verbose'
alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
alias gwt='git worktree'
alias gwta='git worktree add'
alias gwtls='git worktree list'
alias gwtmv='git worktree move'
alias gwtrm='git worktree remove'
alias gam='git am'
alias gamc='git am --continue'
alias gams='git am --skip'
alias gama='git am --abort'
alias gamscp='git am --show-current-patch'

start_mpd() {
  if ! pgrep mpd >/dev/null 2>&1; then
    echo "[INFO] Starting MPD..."
    mpd ~/.config/mpd/mpd.conf
  else
    echo "[INFO] MPD is already running."
  fi

  local retries=5
  while (( retries > 0 )); do
    if mpc status >/dev/null 2>&1; then
      break
    fi
    sleep 0.5
    ((retries--))
  done

  if (( retries == 0 )); then
    echo "[ERROR] MPD did not respond after waiting."
    return 1
  fi

  echo "[INFO] MPD started. Initializing queue..."
  if mpc listall | mpc add >/dev/null 2>&1; then
    echo "[INFO] Queue initialized."
  else
    echo "[ERROR] Error adding songs."
  fi

  if [[ "$OSTYPE" == darwin* ]] && command -v mpd-now-playable >/dev/null 2>&1; then
    if ! pgrep -f mpd-now-playable >/dev/null 2>&1; then
      echo "[INFO] Starting mpd-now-playable for Now Playing widget integration..."
      nohup mpd-now-playable >/dev/null 2>&1 &
    else
      echo "[INFO] mpd-now-playable is already running."
    fi
  fi
}

 export XDG_CONFIG_HOME="/Users/kamradsmeshnyavy/.config"

eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(command pyenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(command pyenv init -)"
export PATH=$PATH:~/.spoofdpi/bin

# Created by `pipx` on 2025-09-13 12:59:56
export PATH="$PATH:/Users/kamradsmeshnyavy/.local/bin"
export PATH="$PATH:/Users/kamradsmeshnyavy/Library/Python/3.9/bin"


# FPATH for alacritty(design kamrad)
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi

# # Tmux
# if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#    tmux attach -t work-flow || tmux new -s work-flow
# fi

# Автозапуск Zellij
#if command -v zellij >/dev/null 2>&1; then
  # Проверяем, не запущен ли Zellij уже (через переменную окружения ZELLIJ)
 # if [[ -z "$ZELLIJ" ]]; then
    # Если сессия не существует — создаём новую, иначе подключаемся
  #  zellij --layout ~/session-layout.kdl a main-session
  #fi
#fi

# # tokyonight
# # zsh-syntax-highlighting
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# ZSH_HIGHLIGHT_STYLES[command]='fg=#82aaff'                 # blue
# ZSH_HIGHLIGHT_STYLES[alias]='fg=#ffcc00'                   # yellow
# ZSH_HIGHLIGHT_STYLES[builtin]='fg=#/Users/kamradsmeshnyavy/Library/Python/3.9/binc3e88d'                 # green
# ZSH_HIGHLIGHT_STYLES[function]='fg=#ffffcc'                # light yellow
# ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff757f,bold'      # red
# ZSH_HIGHLIGHT_STYLES[separator]='fg=#828bb8'               # fg_dark
# ZSH_HIGHLIGHT_STYLES[argument]='fg=#c8d3f5'                # fg
# ZSH_HIGHLIGHT_STYLES[globbing]='fg=#ff966c'                # orange
# ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#fca7ea'  # purple
# ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#86e1fc'  # cyan
# ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#65bcff' # blue1
# ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#4fd6be'    # teal/green1


source /opt/homebrew/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

#update fzf
source <(fzf --zsh)

export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"



export PATH=$PATH:/Users/kamradsmeshnyavy/.spicetify
export PATH="$PATH:/opt/homebrew/opt/postgresql@15/bin"

eval "$(tv init zsh)"

alias qutebrowser='~/clone/qutebrowser/.venv/bin/python3 -m qutebrowser'

# Nix
 if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
	 . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
 fi
 # End Nix

export PATH=/Users/kamradsmeshnyavy/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/opt/homebrew/bin:/Users/kamradsmeshnyavy/.npm-global/bin:/Users/kamradsmeshnyavy/.pyenv/shims:/Users/kamradsmeshnyavy/.nix-profile/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/kamradsmeshnyavy/.vimpkg/bin:/Users/kamradsmeshnyavy/go/bin:/Users/kamradsmeshnyavy/.cargo/bin:/opt/homebrew/opt/fzf/bin:/Users/kamradsmeshnyavy/.spoofdpi/bin:/Users/kamradsmeshnyavy/.local/bin:/Users/kamradsmeshnyavy/Library/Python/3.9/bin:/Users/kamradsmeshnyavy/.spicetify:/opt/homebrew/opt/postgresql@15/bin:/Applications/Ghostty.app/Contents/MacOS
