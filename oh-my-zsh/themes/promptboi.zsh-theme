R="%{$reset_color%}"
SYM="$R%{$fg_bold[white]%}"
USR="$R%{$fg_bold[cyan]%}"
DIR="$R%{$fg[cyan]%}"
CRS="%{$R$fg_bold[white]%}─[%{$fg[red]%}X%{$fg_bold[white]%}]"
ERR="%(?:$SYM:$CRS)"

PROMPT="
$SYM┌\$ERR\$SYM─[\$USR%n\$SYM]─[\$DIR%~\$SYM]
$SYM└───▶ $ $R\
"
