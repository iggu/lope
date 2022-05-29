#!/bin/bash

BASH_SELF_DIR=$(dirname `realpath $0`)
BASH_SELF_EXE=$(basename `realpath $0`)
BASH_LIB_PATH=${BASH_LIB_PATH:-`realpath $BASH_SELF_DIR/../lib`}
source ${BASH_LIB_PATH}/common.sh
[[ $* == *--no-color* || -n "${NO_COLOR}" ]] || source ${BASH_LIB_PATH}/colors.sh


declare -A CliArgs


function install_ems()
{
    declare dirDist="${CliArgs[dist]}" dirBin="${CliArgs[bin]}"
    cd $dirDist

    function create_emsdk_script()
    {
        echo "# execute this script and eval it's output to import EMS tools into the calling shell" > ~/.emsdk_env.eval
        echo "echo source $dirDist/emsdk/emsdk_env.sh" >> ~/.emsdk_env.eval
        chmod a+x ~/.emsdk_env.eval
    }

    if [[ -f  emsdk/emsdk_env.sh ]] ; then
        echo "EMSDK is already installed"
    else
        echo "Installing EMSDK... "
        create_emsdk_script
        git clone https://github.com/emscripten-core/emsdk.git &&
            cd emsdk &&
            ./emsdk install latest &&
            ./emsdk activate latest &&
            create_emsdk_script &&
            echo -e "${IntenseYellow}" &&
            echo -n "======= emscripten is installed ========" &&
            echo -e "${IntenseCyan}" &&
            echo 'Do "eval `~/.emsdk_env.eval`" or call alias "emscripten-tools-import-here" to make EMS available for this shell' &&
            echo -e "${ResetColor}"

    fi
}


function prepare()
{
    :echo_assarr BASH_SELF_EXE IntenseBlack

    # WARNING: params/flags/etc with '-' inside do not work but claimed to (dont: --some-flag, do: --someflag)
    parser_definition() {
        setup   REST help:usage -- "Usage: ${BASH_SELF_EXE} [options]... [arguments]..." ''
        msg -- "Install various stuff to user locations, all-in-one or by name"
        msg -- ""
        msg -- 'Parameters (no whitespaces in values, + mandatory, - optional):'
        param  DISTDIR  -d --dist    --    "+ folder to install application files"
        param  BINPATH  -b --bin     --    "- install application files to this root"
        flag   NO_COLOR --no-color   --    "- do not colorize output"
        disp   :usage   -h --help    --    "- print help, ignore any other cliargs"
        msg -- 'If not specified - then not performed'
        msg -- '    BINPATH - installation of symlinks to binaries'
        msg -- 'All args passed at the rest are components to install, one or several of:'
        msg -- "    ${INST_LIST/$'\n'/ }"
    }
    eval "$($BASH_LIB_PATH/getoptions.sh parser_definition) exit 1" # initial $@ is substitud with free args

    :capar DISTDIR dist ;
    :capar BINPATH bin opt ;

    [[ -z $REST ]] && :fail 2 "No components specified"
    CliArgs[cmds]=$* # $@ contains all free args while REST is a list of their indicies in the command line
    local j=  # discourage command line like '--opt val free-arg --flag another-free-arg last-free-arg'
    for i in ${REST//[!0-9]/ }; do # check that all the free args are listed in the tail
        [[ -n $j ]] && ((j!=i-1)) && :fail 2 "Components must be listed as a tail of cliargs only"
        j=$i
    done

    local icmds=`declare -F | awk '{print $NF}' | sort | egrep "^install_" | sed "s/install_//g"`
    declare -a badcmds
    for cmd in "$@"; do # ensure that every component passed has it's handler within this script
        echo $icmds | grep -qw "${cmd}" || badcmds+=($cmd)
    done
    [[ ${#badcmds[@]} -ne 0 ]] && :fail 2 "Unsupported component(s): ${badcmds[@]}"

    :echo_assarr CliArgs IntenseBlack
}


function main()
{
    mkdir -p ${CliArgs[dist]}
    [[ -n "${CliArgs[bin]}" ]] && mkdir -p ${CliArgs[bin]}

    for cmd in ${CliArgs[cmds]}; do
        echo -e "**** ${Green} $cmd ${ResetColor} ****"
        install_$cmd
    done
}


prepare $*
main $*



