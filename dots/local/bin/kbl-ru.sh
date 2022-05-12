
if setxkbmap -layout us,ru -model pc104 -option "grp:caps_toggle"; then
    echo "Russian keyboard layout added, CAPS LOCK toggles"
else
    echo "Failed to setup Russian keyboard layout"
fi

