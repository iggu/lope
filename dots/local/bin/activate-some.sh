#!/bin/bash

for app in "$@"; do
  if wmctrl -x -a $app; then
    echo "Activated $app"
    exit 0
  fi
done

for app in "$@"; do
  if [ -x "$(command -v $app)" ]; then
    nohup $app 2>&1 & >/dev/null
    echo "Executed $app"
    exit 0
  fi
done

echo "None of $@ can be activated nor started"

