#!/bin/bash

proto=$(echo $1 | cut -d: -f1)
param=$(echo $1 | cut -d: -f2)
echo -n "proto=$proto, param=$param; "
case "$proto" in
    "@file")
        echo "FILE" ;;
    *)
        echo "????" ;;
esac
read -p "Press any key to continue..."
