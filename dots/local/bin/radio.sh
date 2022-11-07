#!/bin/bash

###############################################################################
#              Interactively select a radio station to listen to.             #
###############################################################################

declare -x IFS=$'\n'

# search here: https://www.aimp.ru/forum/index.php?topic=22023.0
declare -A stations=(
  [Ультра / Ultra]=http://nashe1.hostingradio.ru:80/ultra-192.mp3
  [Aurum Inutile]=http://a5.radioheart.ru:8014/auruminutile
  [Фреш Рок / Fresh Rock]=http://stream.freshrock.net/320.mp3
  [Русский Рок / Russian Rock]=http://stream.skymedia.ee/live/rrock
  [Мировая Попса / World Pop]=http://nashe1.hostingradio.ru/best-256
  [Maximum]=http://radio.tp.tver.ru:8000/maximum_mp3
  [Наше Радио / Nashe]=http://online2.gkvr.ru:8000/nashe_kaz_64.aac
  [CEU Medieval Radio]=http://stream3.virtualisan.net:7020
  [Chilled Cow]=https://youtu.be/5qap5aO4i9A
  [Code Radio]=https://coderadio-admin.freecodecamp.org/radio/8010/radio.mp3
  [Hang Drum Live]=https://www.youtube.com/watch?v=szyyoAzDWHM
  [FUTURE FNK]=http://node-16.zeno.fm:80/etbbu6a3dnruv
  [Gensokyo Radio]=https://stream.gensokyoradio.net/1
  [Kohina]=http://kohina.duckdns.org:8000/stream.ogg
  [Nightride FM]=https://stream.nightride.fm/nightride.ogg
  [Nightwave Plaza]=https://radio.plaza.one/mp3
  [No-Life Radio]=http://listen.nolife-radio.com:8000
  [Radio Monacensis]=https://monacensis.stream.laut.fm/monacensis
  [Chinamerica]=https://laradiofm.ru/download/2480-ru-m3u
  [Chinese Traditional]=https://laradiofm.ru/download/605-ru-m3u
  [Shonan Beach FM]=http://shonanbeachfm.out.airtime.pro:8000/shonanbeachfm_c
)

if command -v fzf &>/dev/null; then
    station=$(fzf --cycle --prompt "Radio: " <<< $(printf "%s\n" "${!stations[@]}"))
else
    select station in $(sort <<< "${!stations[@]}"); do
        break
    done
fi

if [[ -n "$station" ]]; then
    url="${stations[$station]}"
    echo -e "\x1b[0;33m=================================================="
    echo -e "\x1b[0;32m$station"
    echo -e "\x1b[0;36m$url"
    echo -e "\x1b[0;33m==================================================\x1b[0m"
    if command -v mpv &>/dev/null ; then
        exec mpv --no-video "$url" 2>&1 | grep -Ei '(Failed|ERROR|icy-title)' #| sed 's/^.*: //'
    elif command -v mpg321 &>/dev/null ; then
        exec mpg321 "$url"
    elif command -v mpg123 &>/dev/null ; then
        exec mpg123 "$url"
    else
        echo "Cannot find any of supported players for URL $url"
    fi
fi
