#!/bin/bash

source $(dirname `realpath $0`)/_include.sh

function prepare()
{
    # WARNING: params/flags/etc with '-' inside do not work but claimed to (dont: --some-flag, do: --someflag)
    parser_definition() {
        setup   REST help:usage -- "Usage: ${THIS_SELF_EXE} [options]... [arguments]..." ''
        msg -- "Install GUI applications from PPAs with apt (must be run as root)."
        msg -- ""
        msg -- 'Parameters (no whitespaces in values, + mandatory, - optional):'
        param  PKG      -p --pkg     --    "- config file with list of packages to install"
        param  PPA      -P --ppa     --    "- config file with list of PPAs to import"
        flag   KEYS     -K --keys    --    "- acquire missing keys by their hashes"
        flag   NO_COLOR --no-color   --    "- do not colorize output"
        disp   :usage   -h --help    --    "- print help, ignore any other cliargs"
        msg -- 'PPAs config file is of bash syntax and contains several associative arrays'
        msg -- '    which describes which ppas to import and how to do it'
    }
    eval "$($THIS_LIB_PATH/getoptions.sh parser_definition) exit 1"

    [ -z "$REST" ] || :fail 2 "Extra args detected (param with space?)"

    :capar-rp PKG pkg opt ; :capar-rp PPA ppa opt ; :capar-rp KEYS keys opt ;
    for pk in pkg ppa ; do
        local pv="${CliArgs[$pk]}"
        if [[ -n $pv && ! -f $pv ]] ; then
            :fail 4 "File with list of $pk does not exist" "(${CliArgs[$pk]})"
        fi
    done

    :echo_assarr CliArgs IntenseBlack

    :must-be-root
}


prepare $*

codename=$THIS_UBUNTU_CODENAME
if [ -z "${CliArgs[ppa]}" ] ; then
    echo -e "${Purple}No PPAs to import${ResetColor}"
else
    echo -e "${Cyan}Import PPAs...${ResetColor}"
    source ${CliArgs[ppa]}
    source $THIS_LIB_PATH/ppa.sh
    mkdir -p /etc/apt/sources.list.d/
    ppa_import PPA_LAUNCHPAD PPA_LAUNCHPAD lp
    ppa_import PPA_KEYS_AUTO PPA_REPO_DEBS auto
    ppa_import PPA_KEYS_SIGN PPA_REPO_DEBS sign
    ppa_import PPA_KEYS_LP PPA_REPO_DEBS lpker
fi

if [ -n "${CliArgs[keys]}" ] ; then
    ppa_add_missing_keys
fi
