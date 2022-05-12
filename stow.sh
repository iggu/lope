#!/bin/bash

SRC=$(dirname $(realpath $0))/dots
SRCDIRS=`find "$SRC" -mindepth 1 -maxdepth 1 -type d -printf "%f "`
SRCFILES=`find "$SRC" -maxdepth 1 -type f -printf "%f "`

TGT=${1:-~}

C_ERR='\033[0;31m'
C_WRN='\033[0;33m'
C_NOT='\033[0;35m'
C_OK='\033[0;32m'
C_CLR='\033[0m' # No Color

echo target: $TGT
echo modules: $SRCDIRS
echo files: $SRCFILES

stow_dot_mod()
{
    local mod=$1
    local dryrun=$2 # empty for apply and '-n' to test
    local dirs=`find "$SRC/$mod" -mindepth 1 -maxdepth 1 -type d -printf "%f "`
    local conflicts=""

    echo  -e "${C_NOT}**** '$SRC/$mod' =$dryrun=> '$TGT/.$mod' ****${C_CLR}"
    cd "$SRC/$mod"

    for dir in $dirs ; do
        local dst="$TGT/.$mod/$dir"
        mkdir -p "$dst"
        if ! stow $dryrun --no-folding --override=$dir -t "$dst" "$dir" ; then
            conflicts="$dir $conflicts"
        fi
    done

    if [ -n "$conflicts" ] ; then
        echo "================================" >&2
        echo -e "There are conflicts in the ${C_WRN}'$mod'${C_CLR} tree:" >&2
        echo -e "    => ${C_WRN}$conflicts${C_CLR}" >&2
        echo "Resolve and try again" >&2
        return 1
    fi
}

stow_all_dot_mods()
{
    local dryrun=$1
    local ret=0
    for mod in $SRCDIRS ; do
        stow_dot_mod "$mod" "$dryrun" || ret=1
    done
    echo
    return $ret
}

ret=1
stow_all_dot_mods "-n" && stow_all_dot_mods && ret=0 \
    && echo -e "${C_OK}==== Stow succeeded ====" \
    || echo -e "${C_ERR}==== Stow failed - conflicts! ====" >&2
echo -e "$C_CLR"

if [ "$ret" -eq "0" ] ; then
    for f in $SRCFILES ; do
        ln -sf "$SRC/$f" "$TGT/.$f"
    done
fi

exit $ret

