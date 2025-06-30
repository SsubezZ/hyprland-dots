export PATH=$HOME/bin:/usr/local/bin:$PATH

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
on_error="\$(if [ \$? -ne 0 ]; then echo \"${etc_color}[${er_color}X${etc_color}]─\"; fi)"
symbol="${reset}${white}$(if [[ ${EUID} == 0 ]]; then echo '#'; else echo '$'; fi)"
PS1="
${etc_color}┌─${on_error}["
PS1+="${username_color}\u"
#PS1+="${at_color}@";
#PS1+="${host_color}\h"
PS1+="${etc_color}]─["
PS1+="${directory_color}\w"
PS1+="${etc_color}]\n└───▶ "
# PS1+="${symbol}${reset} "
PS1+="${reset}"

source /home/subez/.aliases

if [[ ${EUID} != 0 ]]; then source $XDG_CONFIG_HOME/hypr/wallpapers/.wallpapers 2>/dev/null || true; fi

slowfetch() {
  bash -c '
    stty -echo
    trap "stty echo" EXIT

    script -q -c "fastfetch --config \"$HOME/.config/fastfetch/for_shell.jsonc\"" /dev/null |
    while IFS= read -r -d "" -n1 char; do
      printf "%s" "$char"
      sleep 0.0005
    done
  '
}
if [[ ${EUID} != 0 ]]; then slowfetch; fi
