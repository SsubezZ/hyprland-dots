R="%{$reset_color%}"
SYM="$R%{$fg[white]%}"
USR="$R%{$fg_bold[cyan]%}"
DIR="$R%{$fg[cyan]%}"
CRS="%{$R$fg[white]%}─[%{$fg[red]%}X$R%{$fg[white]%}]"
ERR="%(?:$SYM:$CRS)"

PROMPT="
$SYM┌\$ERR\$SYM─[\$USR%n\$SYM]─[\$DIR%~\$SYM]
$SYM└───▶ $ $R\
"
