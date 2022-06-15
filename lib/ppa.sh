#!/bin/bash

# test if ppa is already added
function ppa_is_in()
{
    local ppa=$1
    local sources=`find /etc/apt/sources.list.d/ -type f 2>/dev/null`
    grep -q "^deb .*$ppa" '/etc/apt/sources.list' $sources
    return $?
}

# standard ubuntu ppa on launchpad with with standard keys location
function ppa_source_lp()
{
    declare ppa=$1 key=$3
    local ppaformat="$(echo ${ppa} | tr "/" "-")"
    echo "deb http://ppa.launchpad.net/${ppa}/ubuntu ${THIS_UBUNTU_CODENAME} main # $ppa" \
            >> /etc/apt/sources.list.d/${ppaformat}-${THIS_UBUNTU_CODENAME}.list
    echo -n "++ PPA/lp { $ppa } : "
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv ${key} > /dev/null 2>&1 \
        && echo OK || echo FAIL
}

# add ppa for external repo with key stored in launcpad
function ppa_source_lpker()
{
    declare name=$1 debstr="$2" key=$3
    echo "deb $debstr # $name" \
            >> /etc/apt/sources.list.d/${name}-${THIS_UBUNTU_CODENAME}.list
    echo -n "++ PPA/lpker { $name } : "
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv ${key} > /dev/null 2>&1 \
        && echo OK || echo FAIL
}

# add ppa by url with key which can be imported by url too
function ppa_source_auto()
{
    declare name=$1 debstr="$2" keyurl="$3"
    echo -n "++ PPA/auto { $name } : "
    wget -qO- "$keyurl" | sudo apt-key add -
    echo "deb $debstr # $name" >> /etc/apt/sources.list.d/$name.list
}

# add ppa by url which is signed by the particular key, available by url
function ppa_source_sign()
{
    declare name=$1 debstr="$2" keyurl="$3"
    local gpg=/usr/share/keyrings/$name-archive-keyring.gpg
    echo "++ PPA/sign { $name } : OK"
    curl -fsSLo $gpg $keyurl
    echo "deb [signed-by=$gpg] $debstr # $name" >> /etc/apt/sources.list.d/$name.list
}

# add all missing keys for ppas
function ppa_add_missing_keys()
{
    echo "Quering for missing gpg keys ..."
    local tf=`mktemp --suffix=_apt_add_key.txt`
    apt-get update >> /dev/null 2> $tf

    local keys=`grep NO_PUBKEY $tf | rev | cut -d' ' -f1 | rev`
    for key in $keys ; do
        echo -n "$key: "
        apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv ${key} > /dev/null 2>&1 \
            && echo OK || echo FAIL
    done

    rm -rf $tf
}

# Imports the ppa into sources list
# Accepts assarr with keys, assarr with deb strings and the suffix of the concrete ppa adder
# All assarrs are keyed by ppa name
function ppa_import()
{
    declare -n keys=$1 debs=$2
    local sfx=$3
    for ppa in ${!keys[@]}; do
        if ! ppa_is_in $ppa; then
            ppa_source_$sfx $ppa "${debs[$ppa]}" "${keys[$ppa]}"
        fi
    done
}

