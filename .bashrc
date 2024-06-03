#-----------------------------------------------------------------------------------------------------
# bash customization
# Define some basic colors using tput (8-bit color: 256 colors)
white="\[$(tput setaf 15)\]"
red="\[$(tput setaf 196)\]"
blue="\[$(tput setaf 12)\]"
cyan="\[$(tput setaf 14)\]"
bold="\[$(tput bold)\]"
reset="\[$(tput sgr0)\]"

# Define basic colors to be used in prompt
## The color for username (cyan, for root user: red)
username_color="${reset}${bold}${cyan}\$([[ \${EUID} == 0 ]] && echo \"${red}\")"
## Color of @ symbol (white)
at_color=$reset$bold$white
## Color of ✗ symbol (red)
er_color=$reset$bold$red
## Color of host/pc-name (blue)
host_color=${reset}${bold}${cyan}
## Color of current working directory (cyan)
directory_color=$reset$blue
## Color for other characters (like the arrow)
etc_color=$reset$white$bold
# If last operation did not succeded, add [✗]- to the prompt
on_error="\$([[ \$? != 0 ]] && echo \"${etc_color}[${er_color}✗${etc_color}]─\")"
# The last symbol in prompt ($, for root user: #)
symbol="${reset}${bold}${white}$(if [[ ${EUID} == 0 ]]; then echo '#'; else echo '$'; fi)"

# Setup the prompt/prefix for linux terminal
PS1="${etc_color}┌─${on_error}["
PS1+="${username_color}\u" # \u=Username
#PS1+="${at_color}@";
#PS1+="${host_color}\h" #\h=Host
PS1+="${etc_color}]─["
PS1+="${directory_color}\w" # \w=Working directory
PS1+="${etc_color}]\n└──╼ " # \n=New Line
PS1+="${symbol}${reset} "

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] &&
	. /usr/share/bash-completion/bash_completion

# Aliases
#alias pacman="sudo pacman"
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

# PATH
export VISUAL="nvim"
export EDITOR="nvim"
export PATH="$HOME/.local/bin:$PATH"
export XDG_SCREENSHOTS_DIR="$HOME/Pictures/Screenshots"
export GIT="$HOME/Gits/"
export PS1

fastfetch --config "$HOME/.config/fastfetch/for_shell.jsonc"
#-----------------------------------------------------------------------------------------------------
