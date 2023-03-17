#!/bin/bash

proto=$(echo $1 | cut -d: -f1)
param=$(echo $1 | cut -d: -f2)
echo "cwd=$(pwd), args=$@"
echo -n "proto=$proto, param=$param; "
case "$proto" in
    "@file")
        echo -n "FILE ($param) "
        [ -f "$param" ] && echo "exists" || echo "doesnt exist"
        bat "$param" ;;
    *)
        echo "????" ;;
esac
read -p "Press any key to continue..."
