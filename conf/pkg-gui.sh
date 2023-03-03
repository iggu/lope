#!/bin/bash

declare -A PKGs=(
    [remote]="remmina remmina-plugin-rdp remmina-plugin-vnc x11vnc"
    [desktop]="wmctrl xdotool xsecurelock"
    [code]="gitk kdiff3 codium sublime-text"
    [files]="doublecmd-qt doublecmd-plugins"
    [media]="w3m-img sxiv imagemagick-6.q16hdri mplayer smplayer smplayer-themes smtube qmmp ffmpegthumbnailer ffmpeg mpv"
    [dev]="libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev"
    [term]="xterm fonts-firacode"
    [noise]="anoise-gui anoise-community-extension2 anoise-community-extension3" # all=basic, 1=boring, 2=places, 3=noises, 4=lakes&rivers, 5=birds
    [browse]="firefox-esr vivaldi-stable brave-browser librewolf chromium-codecs-ffmpeg-extra telegram"
    [youtube]="youtube-to-mp3 youtube-downloader lyrics-finder "
    [office]="goldendict vym"
)
