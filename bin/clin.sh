#!/bin/bash

source $(dirname `realpath $0`)/_include.sh


function install_lunarvim()
{
    # WARNING: LunarVim sadly supports customization of it's paths, never try to move cache dir from default location
    #   tested customizations are:
    #   INSTALL_PREFIX - dir/bin where starter script resides (bin is always appended); defaults to ~/.local (+bin)
    #   LUNARVIM_RUNTIME_DIR - where glue code lives; defaults to ~/.local/share
    #   LUNARVIM_CONFIG_DIR - where configs and compiled code is; defaults to ~/.config/lvim

    # WARNING: packer wants default gcc or clang, whatever
    #   sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
    #   sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10
    #   sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 10

    # NOTE: how it works:
    #   release is downloaded and placed to dist dir
    #   lunarvim is installed with runtime and install paths pointed to dist dir
    #   starter script patched and moved to the requested bin dir
    #   cache dir is always neovim's default
    #   config is copied from the repo only if it doesnt exist (so stowed one is not touched)

    # NOTE: consider installation to default paths only

    if ! command -v gcc && ! command -v clang ; then :fail 8 "Cannot find gcc or clang" >&2; exit 1; fi
    if ! command -v nvim ; then :fail 8 "Cannot find neovim" >&2; fi

    declare dirDist="${CliArgs[dist]}"  dirLib="${CliArgs[lib]}" dirCfg="${CliArgs[cfg]}" dirBin="${CliArgs[bin]}"
    cd $dirDist

    # rm -rf ~/.local/share/lunarvim ~/.local/bin/lvim ~/.local/share/applications/lvim.desktop ~/.config/lvim/plugin ~/.cache/nvim ~/.local/share/nvim/

    echo "Installing LunarVim... "
    local LVIMV=latest
    if [ $LVIMV = latest ] ; then
        LVIMV=$(curl -s https://api.github.com/repos/LunarVim/LunarVim/releases/latest | jq -r '.tag_name')
        echo "LVIM release is: $LVIMV"
    fi
    if [ ! -d $dirDist/lvim-$LVIMV/LunarVim-* ] ; then
        mkdir -p $dirDist/lvim-$LVIMV
        wget -qO - https://api.github.com/repos/LunarVim/LunarVim/tarball/$LVIMV | tar -xzC $dirDist/lvim-$LVIMV
    fi

    declare -x INSTALL_PREFIX=$dirDist/_ LUNARVIM_RUNTIME_DIR=$dirDist/_/lib LUNARVIM_CONFIG_DIR=$dirDist/_/cfg LUNARVIM_CACHE_DIR=
    # echo "install=$INSTALL_PREFIX runtime=$LUNARVIM_RUNTIME_DIR config=$LUNARVIM_CONFIG_DIR cache=$LUNARVIM_CACHE_DIR"
    $dirDist/lvim-$LVIMV/LunarVim-*/utils/installer/install.sh --local --no-install-dependencies

    {
        echo "#!/bin/sh"; echo "# auto generated lunarvim launcher"; echo
        echo "export LUNARVIM_RUNTIME_DIR='$dirLib/lvim/lvim'"
        echo "export LUNARVIM_CONFIG_DIR='$dirCfg/lvim'"
        echo "export LUNARVIM_CACHE_DIR='$HOME/.cache/nvim'"
        echo; echo 'exec nvim -u "$LUNARVIM_RUNTIME_DIR/init.lua" "$@"'
    } > $dirBin/lvim

    rm -rf $dirCfg/lvim/plugin $dirLib/lvim
    mkdir -p $dirBin $dirLib/lvim $dirCfg/lvim
    mv -f $LUNARVIM_RUNTIME_DIR/* $dirLib/lvim
    cp -n $THIS_DOTS_PATH/config/lvim/config.lua $dirCfg/lvim/config.lua
    chmod a+x $dirBin/lvim
    rm -rf $INSTALL_PREFIX

    # 1st time old list of plugins is synced (why? no answer)
    $dirBin/lvim +'autocmd User PackerComplete | qall' +PackerSync
    # and then afterwards updated list is taken into accaunt
    $dirBin/lvim +'autocmd User PackerComplete | qall' +PackerSync
}



function prepare()
{
    local na=$#
    local icmds=`declare -F | awk '{print $NF}' | sort | egrep "^install_" | sed "s/install_//g"`

    # WARNING: params/flags/etc with '-' inside do not work but claimed to (dont: --some-flag, do: --someflag)
    parser_definition() {
        setup   REST help:usage -- "Usage: ${THIS_SELF_EXE} [options]... [arguments]..." ''
        msg -- "Clone and install. That's it."
        msg -- ""
        msg -- 'Parameters (no whitespaces in values, + mandatory, - optional):'
        param  DISTDIR  -d --dist    --    "+ folder to install application files"
        param  BINDIR   -b --bin     --    "+ install starter scripts here"
        param  LIBDIR   -l --lib     --    "+ storage for library files"
        param  CFGDIR   -c --cfg     --    "+ place configs there"
        flag   NO_COLOR --no-color   --    "- do not colorize output"
        disp   :usage   -h --help    --    "- print help, ignore any other cliargs"
        msg -- 'If not specified - then not performed'
        msg -- '    BINPATH - installation of symlinks to binaries'
        msg -- 'All args passed at the rest are components to install, one or several of:'
        msg -- "    ${icmds//$'\n'/ }"
    }
    eval "$($THIS_LIB_PATH/getoptions.sh parser_definition) exit 1" # initial $@ is substitud with free args

    for k in dist bin lib cfg ; do # all cliarg dirs are strictly mandatory
        :capar-rp "${k^^}DIR" $k
    done

    :capar-restargs-ontail "$REST" "$na" "$icmds" "$@"
    CliArgs[cmds]=$* # $@ contains all free args while REST is a list of their indicies in the command line

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



