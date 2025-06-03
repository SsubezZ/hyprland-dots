R="%{$reset_color%}"
SYM="$R%{$fg[white]%}"
USR="$R%{$fg_bold[cyan]%}$([[ ${EUID} == 0 ]] && echo $R%{$fg_bold[red]%})%n"
DIR="$R%{$fg[blue]%}%~"
CRS="%{$R$fg[white]%}─[%{$fg_bold[red]%}X$R%{$fg[white]%}]"
ERR="%(?:$SYM:$CRS)"
SIG="$R%{$fg[white]%}$(if [[ ${EUID} == 0 ]]; then echo '#'; else echo '$'; fi)"

PROMPT="
$SYM┌\$ERR\$SYM─[\$USR\$SYM]─[\$DIR\$SYM]
$SYM└───▶ $SIG $R\
"
