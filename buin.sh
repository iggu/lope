#!/bin/bash


SELF=$(realpath $0)
$(dirname $SELF)/bin/buin.sh  -p $HOME/.local -t /tmp "$@"

