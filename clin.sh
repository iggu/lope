#!/bin/bash


SELF=$(realpath $0)
$(dirname $SELF)/bin/clin.sh  -d $HOME/.local/share -b $HOME/.local/bin -l $HOME/.local/lib -c $HOME/.config/ "$@"

