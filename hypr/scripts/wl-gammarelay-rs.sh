#!/usr/bin/env bash

queryBright() {
  local BRIGHT
  BRIGHT=$(busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Brightness | cut -d ' ' -f2 | xargs)
  swayosd-client --custom-icon "daytime-sunset-symbolic" --custom-progress "$BRIGHT"
}

queryTemp() {
  local TEMP_R TEMP_N
  TEMP_R=$(busctl --user get-property rs.wl-gammarelay / rs.wl.gammarelay Temperature | cut -d ' ' -f2 | xargs)
  TEMP_N=$(awk -v v="$TEMP_R" 'BEGIN {printf "%.2f", (v-1000)/9000}')

  swayosd-client --custom-icon "night-light-symbolic" --custom-progress "$TEMP_N"
}

if [[ ${1} == "brightness" ]]; then
  if [[ ${2} == "up" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d "+0.01"
  elif [[ ${2} == "down" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateBrightness d "-0.01"
  elif [[ "${2}" =~ ^[0-9]*\.?[0-9]+$ ]] && (($(awk -v v="${2}" 'BEGIN{print (v>=0 && v<=1)?1:0}'))); then
    busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Brightness d "${2}"
  else
    echo "up|down|<value>"
    exit 1
  fi
  queryBright
elif [[ ${1} == "temperature" ]]; then

  if [[ ${2} == "up" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n "+100"
  elif [[ ${2} == "down" ]]; then
    busctl --user -- call rs.wl-gammarelay / rs.wl.gammarelay UpdateTemperature n "-100"
  elif [[ "${2}" =~ ^[0-9]+$ ]] && ((${2} >= 1000 && ${2} <= 10000)); then
    busctl --user set-property rs.wl-gammarelay / rs.wl.gammarelay Temperature q "${2}"
  else
    echo "up|down|<value>"
    exit 1
  fi
  queryTemp

else
  echo "ERR: brightness|temperature up|down|<value>"
  exit 1
fi

exit 0
