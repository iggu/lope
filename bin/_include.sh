# include this once to the script runner

THIS_SELF_EXE=$(basename `realpath $0`)
THIS_SELF_DIR=$(dirname `realpath $0`)
THIS_CONF_PATH=${THIS_LIB_PATH:-`realpath $THIS_SELF_DIR/../conf`}
THIS_LIB_PATH=${THIS_LIB_PATH:-`realpath $THIS_SELF_DIR/../lib`}
THIS_DOTS_PATH=${THIS_DOTS_PATH:-`realpath $THIS_SELF_DIR/../dots`}

THIS_UBUNTU_CODENAME=$(cat /etc/lsb-release | grep CODENAME | cut -d'=' -f2) ;\
# THIS_UBUNTU_RELEASE=$(cat /etc/lsb-release | grep RELEASE | cut -d'=' -f2) ;\

source ${THIS_LIB_PATH}/common.sh

## Enable our easy to read Colour Flags as long as --no-colors hasn't been passed
## or the NO_COLOR Env Variable (https://no-color.org/) is set. 
## (condition is here since I failed to understand how to implement it with getoption.sh)
[[ $* == *--no-color* || -n "${NO_COLOR}" ]] || source ${THIS_LIB_PATH}/colors.sh

# use logging as color output facility which verbosity level can be easily configured
# B_LOG_DEFAULT_TEMPLATE="@5@"
# source ${THIS_LIB_PATH}/b-log.sh

# common variable for every script
# used with getoption.sh lib
#     eval "$(${THIS_LIB_PATH}/getoptions.sh parser_definition) exit 1"
declare -A CliArgs

function :acquire()
{
    declare cmd="$1" pkg="${2:-$1}" path=
    while [ -z "$path" ]; do
        path=$(command -v $cmd)
        if [ -z "$path" ] ; then
            echo -e "${C_ERR}Cannot find '$cmd' command (from package '$pkg') to proceed." >&2
            echo -e "${C_WRN}Do you want to install it?${C_CLR} (y/n) "
            read -r -s -n 1
            if [[ "${REPLY,,}" == "y" ]] ; then
                sudo apt-get install $pkg
            else
                echo -e "${C_WRN}Ok then, bye${C_CLR}" ; exit 1
            fi
        fi
    done
    echo -e "Using '${C_OK}${path}${C_CLR}' command for operations"
}