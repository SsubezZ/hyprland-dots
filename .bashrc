white="\[$(tput setaf 15)\]"
red="\[$(tput setaf 196)\]"
blue="\[$(tput setaf 12)\]"
cyan="\[$(tput setaf 14)\]"
bold="\[$(tput bold)\]"
reset="\[$(tput sgr0)\]"

username_color="${reset}${bold}${cyan}\$([[ \${EUID} == 0 ]] && echo \"${red}\")"
at_color=$reset$bold$white
er_color=$reset$bold$red
host_color=${reset}${bold}${cyan}
directory_color=$reset$blue
etc_color=$reset$white$bold
on_error="\$([[ \$? != 0 ]] && echo \"${etc_color}[${er_color}✗${etc_color}]─\")"
symbol="${reset}${bold}${white}$(if [[ ${EUID} == 0 ]]; then echo '#'; else echo '$'; fi)"

PS1="${etc_color}┌─${on_error}["
PS1+="${username_color}\u"
#PS1+="${at_color}@";
#PS1+="${host_color}\h"
PS1+="${etc_color}]─["
PS1+="${directory_color}\w"
PS1+="${etc_color}]\n└──╼ "
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
alias jellyfinstart="sudo systemctl start jellyfin"
alias jellyfinstop="sudo systemctl stop jellyfin"
#Nitrosense
alias nitro="~/.config/hypr/scripts/nitrosense"
alias nitro-auto="~/.config/hypr/scripts/nitrosense a"
alias nitro-quiet="~/.config/hypr/scripts/nitrosense qa"
alias nitro-default="~/.config/hypr/scripts/nitrosense da"
alias nitro-performance="~/.config/hypr/scripts/nitrosense pa"
alias nitro-max="~/.config/hypr/scripts/nitrosense m"
alias nitro-custom="~/.config/hypr/scripts/nitrosense c"
# ls to eza
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -alF --icons --color=always --group-directories-first'
alias la='eza -a --icons --color=always --group-directories-first'
alias lt='eza -T --icons --color=always --group-directories-first'
alias l='eza -F --icons --color=always --group-directories-first'
alias l.='eza -a | egrep "^\."'
# misc
alias matrix="clear && unimatrix -a -b -c cyan -f -s 98 && clear"

fastfetch --config "$HOME/.config/fastfetch/for_shell.jsonc"
