#!/bin/bash

# PaCKages installer

source $(dirname `realpath $0`)/_include.sh

###############################################################################

function prepare()
{
    # WARNING: params/flags/etc with '-' inside do not work but claimed to (dont: --some-flag, do: --someflag)
    parser_definition() {
        setup   REST help:usage -- "Usage: ${THIS_SELF_EXE} [options]... [arguments]..." ''
        msg -- "Install packages with apt (must be run as root)."
        msg -- ""
        msg -- 'Parameters (no whitespaces in values, + mandatory, - optional):'
        param  PKG      -p --pkg     --    "- config file with list of packages available to install"
        param  PCATS    -c --pcats   --    "- comma-separated list of categories of packages to install"
        flag   PCALL    -C --pcatall --    "- install all categories of packages from list of available"
        param  PPA      -P --ppa     --    "- config file with list of PPAs to import"
        flag   KEYS     -K --keys    --    "- acquire missing keys by their hashes"
        flag   NO_COLOR --no-color   --    "- do not colorize output"
        disp   :usage   -h --help    --    "- print help, ignore any other cliargs"
        msg -- 'PPAs config file is of bash syntax and contains several associative arrays'
        msg -- '    which describes which ppas to import and how to do it'
        msg -- 'PKGs config file is of bash syntax and contains single assoc array'
        msg -- '    which contains packages by categories recommended for installation'
    }
    eval "$($THIS_LIB_PATH/getoptions.sh parser_definition) exit 1"

    [ -z "$REST" ] || :fail 2 "Extra args detected (param with space?)"

    :capar-rp PKG pkg opt ; :capar PCATS pcats opt; :capar PCALL pcall opt;
    :capar-rp PPA ppa opt ; :capar-rp KEYS keys opt ;
    for pk in pkg ppa ; do
        local pv="${CliArgs[$pk]}"
        if [[ -n $pv && ! -f $pv ]] ; then
            :fail 4 "File with list of $pk does not exist" "(${CliArgs[$pk]})"
        fi
    done

    :echo_assarr CliArgs IntenseBlack

    :must-be-root
}

###############################################################################

function ppa_import_all()
{
    if [ -z "${CliArgs[ppa]}" ] ; then
        echo -e "${Purple}No PPAs to import${ResetColor}"

    else
        echo -e "${Cyan}Import PPAs...${ResetColor}"
        codename=$THIS_UBUNTU_CODENAME
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
}

###############################################################################

function pkg_install_all()
{
    if [ -z "${CliArgs[pkg]}" ] ; then
        echo -e "${Purple}No PKGs to install/recommend (is list of packages provided?)${ResetColor}"
        return
    fi

    source ${CliArgs[pkg]}
    local ag="apt-get install --no-install-recommends"

    if [ -n "${CliArgs[pcall]}" ] ; then
        echo -e "${Cyan}Installing all recommended packages: ${Yellow}${PKGs[@]}${ResetColor}"
        $ag ${PKGs[@]}

    elif [ -n "${CliArgs[pcats]}" ] ; then
        declare install= missing=
        local cats=`echo ${CliArgs[pcats]} | tr ',' ' '`
        for cat in $cats ; do
            if [ -z "${PKGs[$cat]}" ] ; then
                missing+="$cat "
            else
                install+="${PKGs[$cat]} "
            fi
        done

        if [ -n "$missing" ] ; then
            :fail 10 "Unknown package categories:" "$missing"
        else
            echo -e "${Cyan}Installing following categories of recommended packages: ${IntenseYellow}${cats}${ResetColor}"
            echo -e "    > ${Yellow}$install${ResetColor}"
            $ag $install
        fi

    else
        echo -e "${Purple}List of packages recommended to be installed by categories.${ResetColor}"
        echo "Install what you like by selecting any combination of them with 'sudo apt-get install'"
        echo "or via this script's command line options"
        :echo_assarr "PKGs" "IntenseBlack"
    fi
}

###############################################################################

prepare $*
ppa_import_all
pkg_install_all

###############################################################################
