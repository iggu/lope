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

# ensure that we are root
:must-be-root()
{
    [ "${UID}" != "0" ] && :fail ${1:-1} "Must be root" "(you are: `whoami`)"
}
