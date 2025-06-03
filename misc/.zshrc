export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="promptboi"

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"

plugins=(
  autoupdate
  git
  archlinux
  sudo
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
  zsh-fzf-history-search
)
source $ZSH/oh-my-zsh.sh
if [[ ${EUID} != 0 ]]; then source $HOME/.config/hypr/wallpapers/.wallpapers 2>/dev/null || true; fi

# Plugins Customizations

ZSH_CUSTOM_AUTOUPDATE_NUM_WORKERS=10

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE=fg=#435789
# ZSH_AUTOSUGGEST_STRATEGY=(completion math_prev_cmd)

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp root line)
ZSH_HIGHLIGHT_MAXLENGTH=512
ZSH_HIGHLIGHT_STYLES[default]=none
ZSH_HIGHLIGHT_STYLES[root]=none
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

source /home/subez/.aliases

if [[ ${EUID} != 0 ]]; then fastfetch --config "$HOME/.config/fastfetch/for_shell.jsonc"; fi
