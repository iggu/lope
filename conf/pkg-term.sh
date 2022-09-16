#!/bin/bash

declare -A PKGs=(
    [sys]="lm-sensors uuid htop"
    [arc]="atool rar unrar libunrar5 zip unzip p7zip-full p7zip-rar"
    [comp]="automake autoconf pkg-config cmake build-essential libtool python3 python3-pip"
    [media]="chafa exif"
    [shell]="tmux silversearcher-ag fd-find ncdu tree mc bash-completion"
    [get]="youtube-dl wget curl"
    [lua]="lua5.1 luajit luarocks liblua5.1-0 liblua5.1-0-dev libapr1 libapr1-dev libaprutil1 libaprutil1-dev libaprutil1-dbd-sqlite3 libapreq2-3 libapreq2-dev"
    [text]="pandoc poppler-utils"
)
