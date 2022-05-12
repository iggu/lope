#!/bin/bash

# say user wants to securely connect to the server over ssh
# assume that this script is installed somewhere in the $PATH on the server side

# first, start x11vnc remotely with a tunnel to it's port via ssh: ('' are important!)
#	$ ssh -C -L 5900:localhost:5900 <user>@<server> '~/bin/x11vnc.sh'
# second, on the client run any VNC viewer and connect to localport 5900
#	- this would bring up remote desktop :0 w/o any auth as is 

# when connection is closed - the remote server would stop, so to re-connect user
#	must first re-run the 'ssh...' command and then connect with a client again

# 'remmina' and 'VNC Viewer' are good clients for VNC

# vnc port and x display can be configured via setting vars PORT and DISP before program start
#	PORT=5901 DISP=:1 x11vnc.sh
#
# when `-ncache 10` option is set - some clients show very long height which can be
# scrolled down when pointing with mouse to lower edge of the desktop - so dont use this option
# https://askubuntu.com/questions/125123/vertical-resolution-over-vnc-multiplied-by-12

PORT=${PORT:-5900}
DISP=${DISP:-:0}

echo '****************************************************************************'
echo "*** Starting one-shot local VNC server for x-display $DISP on port $PORT ***"
echo '****************************************************************************'

x11vnc -localhost -shared -remap less-comma,parenleft-9,parenright-0 \
       -nomodtweak -noxfixes -noxrecord -noxdamage -ncache_cr \
       -repeat -sloppy_keys -noxkb  -skip_dups \
       -display $DISP \
       -rfbport $PORT
       # -debug_keyboard \

