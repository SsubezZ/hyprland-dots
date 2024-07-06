export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="promptboi"

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

plugins=(
  git
  archlinux
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
  zsh-fzf-history-search
)
source $ZSH/oh-my-zsh.sh

# Plugins Customizations
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=#435789
ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd completion)
ZSH_AUTOSUGGEST_USE_ASYNC="true"

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp root line)
ZSH_HIGHLIGHT_MAXLENGTH=512
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=white
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[global-alias]=fg=magenta
ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
ZSH_HIGHLIGHT_STYLES[path]=underline
ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[command-substitution]=none
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta
ZSH_HIGHLIGHT_STYLES[process-substitution]=none
ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=yellow
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta
ZSH_HIGHLIGHT_STYLES[assign]=none
ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
ZSH_HIGHLIGHT_STYLES[named-fd]=none
ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout

zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

# PATH
export VISUAL="nvim"
export EDITOR="nvim"
export PATH="$HOME/.local/bin:$PATH"
export XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
export GIT="$HOME/Gits/"
export PS1

# Aliases
alias hypr="nvim $GIT/hyprland-dots/hypr/hyprland.conf"
alias vim="nvim"
alias cat="bat"
alias startjellyfin="sudo systemctl start jellyfin"
alias stopjellyfin="sudo systemctl stop jellyfin"
# Nitrosense
alias nitro="~/.config/hypr/scripts/nitrosense"
alias auto-nitro="~/.config/hypr/scripts/nitrosense a"
alias quiet-nitro="~/.config/hypr/scripts/nitrosense qa"
alias default-nitro="~/.config/hypr/scripts/nitrosense da"
alias performance-nitro="~/.config/hypr/scripts/nitrosense pa"
alias max-nitro="~/.config/hypr/scripts/nitrosense m"
alias custom-nitro="~/.config/hypr/scripts/nitrosense c"
# ls to eza
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias lt='eza -T --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'
# misc
alias clock="tty-clock -s -c -t -C 6"
alias fetch="fastfetch"
alias matrix="clear && unimatrix -a -b -c cyan -f -s 98 && clear"

fastfetch --config "$HOME/.config/fastfetch/for_shell.jsonc"
