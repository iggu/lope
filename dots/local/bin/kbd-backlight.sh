#!/bin/bash

# For keyboards with backlights - turn lights on and off
# HowTos:
# - https://wiki.archlinux.org/title/Keyboard_backlight
# - https://forum.kde.org/viewtopic.php%3Ff=22&t=143111.html

STATUS=$(xset q | grep Scroll | sed 's/.*Scroll Lock: //' | xargs echo -n)

case "${1,,}" in
    on) CMD=led ;;
    off) CMD=-led ;;
    toggle) if [ "$STATUS" = "on" ] ; then CMD=-led ; else CMD=led ; fi ;;
    *) echo "Need 1st cliarg to be one of 'on', 'off' or 'toggle' (while got '$1')" ; exit 1 ;;
esac

echo -n "Change Scroll Lock status from <${STATUS^^}> to <O"
[ "$CMD" = "led" ] && echo "N>" || echo "FF>"

xset $CMD named "Scroll Lock"
