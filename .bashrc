white="\033[37m"
red="\033[31m"
blue="\033[34m"
cyan="\033[36m"
bold="\[$(tput bold)\]"
reset="\[$(tput sgr0)\]"

username_color="${reset}${bold}${cyan}\$([[ \${EUID} == 0 ]] && echo \"${red}\")"
at_color=$reset$bold$white
er_color=$reset$bold$red
host_color=${reset}${bold}${cyan}
directory_color=$reset$blue
etc_color=$reset$white
on_error="\$([[ \$? != 0 ]] && echo \"${etc_color}[${er_color}X${etc_color}]─\")"
symbol="${reset}${white}$(if [[ ${EUID} == 0 ]]; then echo '#'; else echo '$'; fi)"
PS1="
${etc_color}┌─${on_error}["
PS1+="${username_color}\u"
#PS1+="${at_color}@";
#PS1+="${host_color}\h"
PS1+="${etc_color}]─["
PS1+="${directory_color}\w"
PS1+="${etc_color}]\n└───▶ "
PS1+="${symbol}${reset} "

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
  . /usr/share/bash-completion/bash_completion

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
alias clock="tty-clock -s -c -t -C 6"
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
alias fetch="fastfetch"
alias matrix="clear && unimatrix -a -b -c cyan -f -s 98 && clear"

fastfetch --config "$HOME/.config/fastfetch/for_shell.jsonc"
