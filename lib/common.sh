#!/bin/bash

# Print the whole associative array
function :echo_assarr() # 1=ArrayName 2=EchoColor
{
    declare -n ARR=$1
    echo -ne "${!2}"
    paste -d= <(printf "$1[%s]\n" "${!ARR[@]}") <(printf "%s\n" "${ARR[@]}")
    echo -ne "${ResetColor}"
}

# Print error message and exit
function :fail() # 1=errorCode, 2=erroMessage, 3..=printfParams
{
    local errCode=${1:-9}
    local args=("$@")
    printf "${Red}Error#%d: ${BoldRed}%s " "$1" "$2" >&2
    echo -e "${Red}${args[@]:2}${ResetColor}" >&2
    exit $errCode
}

# Places cliarg stored in the variable with name $1 into already declared assarr CliArgs
# under the key $2; if $3 is empty - then the param is mandatory and must be set or the
# script fail with exitcode 3
:capar()
{
    [ -n "${3}${!1}" ] || :fail 3 "Mandatory param $1 is not set"
    CliArgs[$2]="${!1}"
    unset ${1}
}
# Same as :capar but value is casted to real path
:capar-rp()
{
    [ -n "${3}${!1}" ] || :fail 3 "Mandatory param $1 is not set"
    CliArgs[$2]=`realpath -q "${!1}"`
    unset ${1}
}

# Get all free args and ensure that they all are in the tail of the command line
# Mandatory:
#   $1 = list of indicies of cliargs ($REST after parse_definitions)
#   $2 = the index of last cliarg in the original command line
# Optional:
#   $3 = the list of allowed freeargs (optional; if not set - when all the rest just ignored)
#   $4 = the list of all freeargs ($*) (optional; if not set - when all the rest just ignored)
#   $5 = manda/opt separator (optional; if set then $4 is treated as 'manda:opt' pairs, and only 'manda' is checked while 'opt' is ignored)
# Test that freeargs do monotonically increase and end up with the last cliarg
# To acquire the values one must use $* right after parse_definitions
:capar-restargs-ontail()
{
    [[ -z $1 ]] && :fail 2 "No rest-args specified"
    local j=  # discourage command line like '--opt val rest-arg --flag another-rest-arg last-rest-arg'
    for i in ${1//[!0-9]/ }; do # check that all the free args are listed in the tail
        [[ -n $j ]] && ((j!=i-1)) && :fail 2 "Rest-args must be listed as a tail of cliargs only"
        j=$i
    done
    [[ $j -ne $2 ]] && :fail 2 "Rest-args must be listed as a tail of cliargs only"

    if [[ -n $3 && -n $4 ]]; then
        declare -a bad
        for fa in $4; do # ensure that every component passed has it's handler within this script
            fa=${fa%%$5*} # get rid of optional part if any, consider only manda
            echo $3 | grep -qw "${fa}" || bad+=($fa)
        done
        [[ ${#bad[@]} -ne 0 ]] && :fail 2 "Unsupported rest-arg(s): ${bad[@]}"
    fi

}

# ensure that we are root
:must-be-root()
{
    [ "${UID}" != "0" ] && :fail ${1:-1} "Must be root" "(you are: `whoami`)"
}

# List commands:packages which are stictly required
# If command and package are the same - then no : is required, a single word is enough
# Example: gettext libtool:libtool-bin
:require-pkgs()
{
    declare -a absent
    for meta in $@ ; do
        local exe=`echo $meta | cut -d':' -f1`
        command -v $exe >/dev/null || absent+=($meta)
    done

    if [ -n "$absent" ] ; then
        declare -a pkgs cmds
        for a in ${absent[@]}; do
            cmds+=(`echo $a | cut -d':' -f1`)
            pkgs+=(`echo $a | cut -d':' -f2`)
        done
        :fail 2 "Require packages" "[" ${pkgs[@]} "] for commands [" ${cmds[@]} "]"
    fi
}

# need python3 of minor version at least of $1
:require-py3()
{
    :require-pkgs python3
    declare minPyV=$1 pyV=$(python3 -V | cut -d. -f2)
    [ "$pyV" -ge $minPyV ] || :fail 2 "Require Python >= 3.$minPyV" "but deal with $pyV"
    (pip -V | grep -q "3.$pyV") || :fail 2 "Require pip for Python 3.$pyV" "but deal with" `pip -V`
}

# Tests 1st param if it ends with any of supported archive extensions and returns it
:ext4ar()
{
    case $1 in
        *.tar.bz2) echo tar.bz2 ;;
        *.tar.gz)  echo tar.gz  ;;
        *.tar.xz)  echo tar.xz  ;;
        *.bz2)     echo bz2     ;;
        *.rar)     echo rar     ;;
        *.gz)      echo gz      ;;
        *.tar)     echo tar     ;;
        *.tbz)     echo tbz     ;;
        *.tbz2)    echo tbz2    ;;
        *.tgz)     echo tgz     ;;
        *.txz)     echo txz     ;;
        *.zip)     echo zip     ;;
        *.Z)       echo Z       ;;
    esac
}

# Extracts (silently) given in $1 archive file path to directory $2 (or cwd)
:extract()
{
    if [ -f $1 ] ; then
        local origPwd=`pwd`
        [ -d "$2" ] && cd "$2"
        case $1 in
            *.deb)      dpkg-deb -x $1 ./ ;;
            *.tar.bz2)  tar xjf $1      ;;
            *.tar.gz)   tar xzf $1      ;;
            *.tar.xz)   tar xf $1       ;;
            *.bz2)      bunzip2 $1      ;;
            *.rar)      rar x $1        ;;
            *.gz)       gunzip $1       ;;
            *.tar)      tar xf $1       ;;
            *.tbz)      tar xjf $1      ;;
            *.tbz2)     tar xjf $1      ;;
            *.tgz)      tar xzf $1      ;;
            *.txz)      tar xf $1       ;;
            *.zip)      unzip -qqq $1        ;;
            *.Z)        uncompress $1   ;;
            *)          :fail 100 "'$1' cannot be extracted via extract()" ;;
        esac
        cd "$origPwd"
    else
        echo "'$1' is not a valid file"
    fi
}

# takes files for the given '<component>' in 'files/<action>' directory and applies '<action>' on it
# for the given target path preserving all the related paths under 'files/<action>/<component>'
# actions are: overwrite (tbd: patch, remove)
function :files_actions_apply() # $1=fromComponentName $2=toPath
{
    local dirBin=$(dirname `realpath $0`) # assume that caller is located in bin/ and it's path is stored in $0
    local dirInFiles=`realpath $dirBin/../files`
    local dirInOvwr="$dirInFiles/overwrite/$1"
    local dirOutRoot="$2"

    # perform 'overwrite' action for files
    while read -r inFile ; do # inFile is path relative to the patchset root
        local outDir="$dirOutRoot/$(dirname $inFile)"
        mkdir -p "$outDir"
        cp -fv "$dirInOvwr/$inFile" "$outDir/$(basename $inFile)"
    done < <(cd $dirInOvwr && find -type f -printf '%P\n')

    # TODO: place other actions like 'link', 'patch' or 'delete' below
}
