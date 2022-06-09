#!/bin/bash

source $(dirname `realpath $0`)/_include.sh

:must-be-root

codename=$(cat /etc/lsb-release | grep CODENAME | cut -d'=' -f2) ;\

######################################################################################################
declare -a PPA_STD=('costales/anoise' 'libreoffice/ppa')
declare -A PPA_NONDSTD_DEBS=(
    [opera-stable]="http://deb.opera.com/opera-stable/ stable non-free"
    [vivaldi-stable]="https://repo.vivaldi.com/archive/deb/ stable main"
    [librewolf]="http://deb.librewolf.net $codename main"
    [codium]="https://download.vscodium.com/debs vscodium main"
    [brave-browser]="https://brave-browser-apt-release.s3.brave.com/ stable main"
)
declare -A PPA_NONDSTD_KEYS=(
    [opera-stable]="https://deb.opera.com/archive.key"
    [vivaldi-stable]="https://repo.vivaldi.com/archive/linux_signing_key.pub"
    [librewolf]="https://deb.librewolf.net/keyring.gpg"
    [codium]="https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg"
)
declare -A PPA_NONDSTD_GPG=(
    [brave-browser]="https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg"
)
######################################################################################################

# input: 'user/repo'
function ppa_is_in()
{
    local ppa=$1
    local sources=`find /etc/apt/sources.list.d/ -type f 2>/dev/null`
    grep -q "^deb .*$ppa" '/etc/apt/sources.list' $sources
    return $?
}

# add ppa to apt-sources
function ppa_source_std()
{
    local ppa=$1
    local ppaformat="$(echo ${ppa} | tr "/" "-")"
    echo "deb http://ppa.launchpad.net/${ppa}/ubuntu ${codename} main" >> /etc/apt/sources.list.d/${ppaformat}-${codename}.list
}

function ppa_source_pub()
{
    declare name=$1 debstr="$2" keyurl="$3"
    echo -n "$name: "
    wget -qO- "$keyurl" | sudo apt-key add -
    echo "deb $debstr # $name" >> /etc/apt/sources.list.d/$name.list
}

function ppa_source_sgn()
{
    declare name=$1 debstr="$2" keyurl="$3"
    local gpg=/usr/share/keyrings/$name-archive-keyring.gpg
    echo "$name (sgn)"
    curl -fsSLo $gpg $keyurl
    echo "deb [sgn-by=$gpg] $debstr # $name" >> /etc/apt/sources.list.d/$name.list
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

# do everything to include ppa into apt sources
function ppa_import_std()
{
    mkdir -p /etc/apt/sources.list.d/
    local sources=`find /etc/apt/sources.list.d/ -type f 2>/dev/null`
    declare -a ppalist

    for ppa in "${PPA_STD[@]}"; do
        if ! ppa_is_in $ppa; then
            ppalist+=($ppa)
            ppa_source_std $ppa
        fi
    done

    if [[ -n "${ppalist[@]}" ]] ; then
        echo "Imported PPAs: ${ppalist[@]}"
        ppa_add_missing_keys
    fi
}

# do everything to include non-standard ppa (url+key)
function ppa_import_pub()
{
    for deb in ${!PPA_NONDSTD_DEBS[@]} ; do
        if ! ppa_is_in $deb ; then 
            if [ ${PPA_NONDSTD_GPG[$deb]+_} ] ; then
                ppa_source_sgn $deb "${PPA_NONDSTD_DEBS[$deb]}" "${PPA_NONDSTD_GPG[$deb]}"
            else
                ppa_source_pub $deb "${PPA_NONDSTD_DEBS[$deb]}" "${PPA_NONDSTD_KEYS[$deb]}"
            fi
        fi
    done
}

ppa_import_pub
ppa_import_std 
