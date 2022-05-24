#!/bin/bash


declare -A Self=( 
    [dir]=$(dirname `realpath $0`)
    [lib]=$(dirname `realpath $0`)/lib
    [bin]=$(dirname `realpath $0`)/bin
    [conf]=$(dirname `realpath $0`)/conf
    [exe]=$(basename `realpath $0`)
)

declare -A Ghai=(
    [exe]="${Self[bin]}/ghai.sh"
    [conf]="${Self[conf]}/pkgs.lst"
    [dist]="$HOME/.local/lib/ghai"
    [inst]="$HOME/.local/bin"
)

echo "Installing apps from github...."
echo " >> ${Ghai[exe]} -l ${Ghai[conf]} -d ${Ghai[dist]} -b ${Ghai[inst]} -I"
${Ghai[exe]} -l ${Ghai[conf]} -d ${Ghai[dist]} -b ${Ghai[inst]} -I

