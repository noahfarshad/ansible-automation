#!/bin/bash

declare -A disps usrs
usrs=()
disps=()

EXPIRE=$1
POTENCY=$2
TITLE="$3"
MESSAGE="$4"
ICON=$5

if [ -z ${ICON} ]; then
  ICON_ARGS="";
else
  ICON_ARGS="-i $ICON";
fi

for i in $(users);do
    [[ $i = root ]] && continue # skip root
    usrs[$i]=1
done # unique names

for u in "${!usrs[@]}"; do
    for i in $(sudo ps e -u "$u" | sed -rn 's/.* DISPLAY=(:[0-9]*).*/\1/p');do
        disps[$i]=$u
    done
done

for d in "${!disps[@]}";do
    echo "User: ${disps[$d]}, Display: $d"
    echo "ICON ARGS: $ICON_ARGS"
    sudo -u "${disps[$d]}" DISPLAY="$d" notify-send -t $EXPIRE -u $POTENCY "$TITLE" "$MESSAGE" $ICON_ARGS
done
