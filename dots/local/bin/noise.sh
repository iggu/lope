#!/bin/bash

###############################################################################
#              Interactively select a noise to listen to.                     #
###############################################################################

function fzf_command_select()
{
    if [ -n "$(command -v fzf)" ] ; then
        echo "fzf --cycle"
    elif [ -n "$(command -v fzy)" ] ; then
        echo "fzy"
    else
        echo "No suitable FuzzyFinder command found" >&2
    fi
}

declare gcFzf=$(fzf_command_select)
[ -z "$gcFzf" ] && exit 1

declare gpNoiseDir="/usr/share/anoise/sounds"
if [ ! -d "$gpNoiseDir" ] ; then
    echo "ANOISE package is not installed" 2>&1
    exit 1
fi

declare gpAllNoises=$(ls -1 $gpNoiseDir/*.ogg | rev | cut -d'/' -f1 | rev | cut -d'.' -f1)
declare gpSelectedNoise=$(for n in $gpAllNoises; do echo $n; done | $gcFzf --prompt "Select noise: ")
if [ -z "$gpSelectedNoise" ] ; then
    echo "No noise selected, cancel"
    exit 0
fi

echo "Looping noise: $gpSelectedNoise"
while true; do
    # ogg doesnt exit on ctrl-c, it restarts;
    # to exit - we pipe output, ctrl-c kills endpoint and then - all processes in the pipe
    # (with 'ogg -r' even this approach sometimes doesnt work, dont use '-r')
    ogg123 "/usr/share/anoise/sounds/$gpSelectedNoise.ogg" 2>&1 | tail
    if [ "$?" -ne "0" ] ; then
        echo -e "\nBreak!"
        exit 0
    fi
done
