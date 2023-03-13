#!/bin/bash

###############################################################################
#              Interactively select a radio station to listen to.             #
###############################################################################

declare -x IFS=$'\n'

# search here: https://www.aimp.ru/forum/index.php?topic=22023.0
declare -A stations=(
  [Rock: Ультра / Ultra]=http://nashe1.hostingradio.ru:80/ultra-192.mp3
  [Rock: Aurum Inutile]=http://a5.radioheart.ru:8014/auruminutile
  [Rock: Фреш Рок / Fresh Rock]=http://stream.freshrock.net/320.mp3
  [Rock: Русский Рок / Russian Rock]=http://stream.skymedia.ee/live/rrock
  [Rock: Наше Радио / Nashe]=http://online2.gkvr.ru:8000/nashe_kaz_64.aac
  [Rock: Maximum]=http://radio.tp.tver.ru:8000/maximum_mp3
  [Pop: Мировая Попса / World Pop]=http://nashe1.hostingradio.ru/best-256
  [Pop: Future Fnk]=http://node-16.zeno.fm:80/etbbu6a3dnruv
  [Pop: Gensokyo Radio]=https://stream.gensokyoradio.net/1
  [Pop: Chinamerica]=https://laradiofm.ru/download/2480-ru-m3u
  [Instr: Shonan Beach FM]=http://shonanbeachfm.out.airtime.pro:8000/shonanbeachfm_c
  [Instr: CEU Medieval Radio]=http://stream3.virtualisan.net:7020
  [Instr: Nightwave Plaza]=https://radio.plaza.one/mp3
  [Instr: Radio Monacensis]=https://monacensis.stream.laut.fm/monacensis
  [Instr: Chinese Traditional]=https://laradiofm.ru/download/605-ru-m3u
  [Electro: Kohina]=http://kohina.duckdns.org:8000/stream.ogg
  [Electro: Nightride FM]=https://stream.nightride.fm/nightride.ogg
  [Chill: Japanese Lofi]=https://www.youtube.com/watch?v=-9gEgshJUuY
  [Chill: Code Radio]=https://coderadio-admin.freecodecamp.org/radio/8010/radio.mp3
  [Chill: Calm Focus Mix]=https://www.youtube.com/watch?v=BYl7v0YsX9g
  [Relax: Hang Drum]=https://www.youtube.com/watch?v=szyyoAzDWHM
  [Relax: Mantra]=http://c22.radioboss.fm/playlist/291/stream.m3u
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
