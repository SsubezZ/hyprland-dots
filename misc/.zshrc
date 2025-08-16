export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="$HOME/.oh-my-zsh"

prompt() {
  PROMPT=$'\n'
  PROMPT+='%F{white}┌─'
  PROMPT+='%(?..%F{white}[%B%F{red}X%f%b%F{white}]─)'
  PROMPT+='[%(!.%B%F{red}.%B%F{cyan})%n%f%b%F{white}]─'
  PROMPT+='[%F{blue}%~%F{white}]'$'\n'
  PROMPT+='%F{white}└───▶%f%b '
}
prompt

# ZSH_THEME="promptboi"

ENABLE_CORRECTION="true"

COMPLETION_WAITING_DOTS="true"
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

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

DISABLE_AUTO_UPDATE="true"
source $ZSH/oh-my-zsh.sh

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

HISTFILE=$HOME/.local/state/zsh/.zsh_history
zshaddhistory() { whence ${${(z)1}[1]} >| /dev/null || return 1 }

source /home/subez/.aliases
eval "$(zoxide init zsh)"

pkg_install() {
  local query="$1"
  pkg_name=$(yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:80% --query="$query")
  if [[ -n "$pkg_name" ]]; then
    yay -Sy $pkg_name
    sudo updatedb
  fi
}

pkg_uninstall() {
  local query="$1"
  pkg_name=$(yay -Qqe | fzf --multi --preview 'yay -Qi {1}' --preview-window=down:80% --query="$query")
  if [[ -n "$pkg_name" ]]; then
    yay -Rns $pkg_name
    sudo updatedb
  fi
}

_pkg_install_completion() {
  local -a packages
  packages=(${(f)"$(yay -Slq)"})
  _describe 'package' packages
}

compdef _pkg_install_completion pkg_install

_pkg_uninstall_completion() {
  local -a packages
  packages=(${(f)"$(yay -Qqe)"})
  _describe 'package' packages
}

compdef _pkg_uninstall_completion pkg_uninstall

slowfetch() {
  bash -c '
    stty -echo
    trap "stty echo" EXIT

    script -q -c "fastfetch --config \"$HOME/.config/fastfetch/for_shell.jsonc\"" /dev/null |
    while IFS= read -r -d "" -n1 char; do
      printf "%s" "$char"
      sleep 0.000025
    done
  '
}
if [[ ${EUID} != 0 ]]; then slowfetch; fi
