export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="promptboi"

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

plugins=(
  git
  archlinux
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

# Plugins Customizations
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=06,bold,underline"
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# PATH
export VISUAL="nvim"
export EDITOR="nvim"
export PATH="$HOME/.local/bin:$PATH"
export HYPRSHOT_DIR="$HOME/Pictures/Screenshots"
export GIT="$HOME/Gits/"
export PS1

# Aliases
#alias pacman="sudo pacman"
alias hypr="nvim $GIT/hyprland-dots/hypr/hyprland.conf"
alias vim="nvim"
alias jellyfinstart="sudo systemctl start jellyfin"
alias jellyfinstop="sudo systemctl stop jellyfin"
# Nitrosense
alias nitro="~/.config/hypr/scripts/nitrosense"
alias nitro-auto="~/.config/hypr/scripts/nitrosense a"
alias nitro-quiet="~/.config/hypr/scripts/nitrosense qa"
alias nitro-default="~/.config/hypr/scripts/nitrosense da"
alias nitro-performance="~/.config/hypr/scripts/nitrosense pa"
alias nitro-max="~/.config/hypr/scripts/nitrosense m"
alias nitro-custom="~/.config/hypr/scripts/nitrosense c"
#"ls" to "exa"
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'

neofetch
