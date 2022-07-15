#!/bin/bash

function activate_all()
{
    declare nm=$1 ret=1
    while read w ; do
        ret=0
        echo "activate '$w'"
        wmctrl -i -a `echo $w | cut -d' ' -f1`
    done <<< $(wmctrl -lx | grep $nm)
    return $ret
}

for app in "$@"; do
  if activate_all $app ; then
    exit 0
  fi
done

echo "None of $@ can be activated"

