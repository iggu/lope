#!/bin/bash
# Download, Configure, Build & Install

source $(dirname `realpath $0`)/_include.sh

###############################################################################

#### Check prerequisites, clone code from github, configure, make and install it
# $1=required:packages,comma,separated
# $2=ghuser/ghrepo[?/ghbranch]
# $3="make options" -- optional
# $4="post-install command in the repo dir" -- optional
function _ghclone_make_install()
{
    local rqpkg=`echo $1 | tr ',' ' '`
    [ -z "$rqpkg" ] || :require-pkgs $rqpkg

    local gh=($(echo $2 | tr '/' "\n"))
    declare user=${gh[0]} repo=${gh[1]} branch=${gh[2]}

    local dir=`mktemp -u -d -p "${CliArgs[tmpdir]}" --suffix=.git -t $user+$repo.XXXX`

    git clone ${branch:+-b $branch} --single-branch --depth=1 https://github.com/$user/$repo $dir
    cd $dir # never return to the path we came from
    [ -x ./autogen.sh ] && ./autogen.sh
    [[ -f ./configure.ac && ! -x ./configure ]] && aclocal && autoheader && automake --add-missing && autoconf
    [ -x ./configure ] && ./configure --prefix=${CliArgs[prefix]}
    PREFIX=${CliArgs[prefix]} make $3
    PREFIX=${CliArgs[prefix]} make install
    [[ -n "$4" ]] && $4

    if [ -n "${CliArgs[clean]}" ] ; then rm -rf $dir ; fi
}

###############################################################################

function install_encpipe()
{
    _ghclone_make_install make,gcc jedisct1/encpipe ${1:+/$1}
}


###############################################################################

function install_doneyet()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,g++ \
                      gtaubman/doneyet${1:+/$1} "" "cp -bv doneyet ${CliArgs[prefix]}/bin"
}


###############################################################################

function install_xstow()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,g++ \
                      majorkingleo/xstow${1:+/$1}
}

###############################################################################

function install_neovim()
{
    _ghclone_make_install pkg-config,libtool:libtool-bin,gettextize:gettext,make,cmake,g++ \
                      neovim/neovim${1:+/$1} \
                      "CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${CliArgs[prefix]}"
}

###############################################################################

function install_ctags()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,gcc \
                      universal-ctags/ctags${1:+/$1}
}

###############################################################################

function install_emsdk()
{
    :require-pkgs python3 xz:xz-utils

    declare dirDist="${CliArgs[prefix]}/lib" dirBin="${CliArgs[prefix]}/bin" version=${1:-latest}
    mkdir -p $dirBin $dirDist
    cd $dirDist

    function create_emsdk_script()
    {
        echo "# execute this script and eval it's output to import EMS tools into the calling shell" > $dirBin/emsdk_env.eval
        echo "echo source $dirDist/emsdk/emsdk_env.sh" >> $dirBin/emsdk_env.eval
        chmod a+x $dirBin/emsdk_env.eval
    }

    if [[ -f  emsdk/emsdk_env.sh ]] ; then
        echo "EMSDK is already installed"
    else
        echo "Installing EMSDK... "
        # create_emsdk_script
        git clone https://github.com/emscripten-core/emsdk.git &&
            cd emsdk &&
            ./emsdk install $version &&
            ./emsdk activate $version &&
            create_emsdk_script &&
            echo -e "${IntenseYellow}" &&
            echo -n "======= emscripten is installed ========" &&
            echo -e "${IntenseCyan}" &&
            echo 'Do "eval `emsdk_env.eval`" or call alias "emscripten-tools-import-here" to make EMS available for this shell' &&
            echo -e "${ResetColor}"

    fi
}

###############################################################################

function install_nerdfonts()
{
    # https://gist.github.com/matthewjberger/7dd7e079f282f8138a9dc3b045ebefa0?permalink_comment_id=4005789#gistcomment-4005789
    declare -a fonts=(
        BitstreamVeraSansMono
        CodeNewRoman
        DroidSansMono
        FiraCode
        FiraMono
        Go-Mono
        Hack
        Hermit
        JetBrainsMono
        Meslo
        Noto
        Overpass
        ProggyClean
        RobotoMono
        SourceCodePro
        SpaceMono
        Ubuntu
        UbuntuMono
    )
    :require-pkgs fc-cache:fontconfig

    local version=${1:-2.1.0}
    local download_dir=`mktemp -d -p "${CliArgs[tmpdir]}" --suffix=.zips -t nerdfonts.XXXX`
    local fonts_dir="${CliArgs[prefix]}/share/fonts"

    mkdir -p "$fonts_dir"

    for font in "${fonts[@]}"; do
        zip_file="${font}.zip"
        download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
        echo "Downloading $download_url"
        wget "$download_url" -O $download_dir/$zip_file
        unzip -n "$download_dir/$zip_file" -d "$fonts_dir"
    done

    find "$fonts_dir" -name '*Windows Compatible*' -delete
    fc-cache -fv "$fonts_dir"

    if [ -n "${CliArgs[clean]}" ] ; then rm -rf $download_dir ; fi
}

###############################################################################

function prepare()
{
    local na=$#
    local icmds=`declare -F | awk '{print $NF}' | sort | egrep "^install_" | sed "s/install_//g"`

    # WARNING: params/flags/etc with '-' inside do not work but claimed to (dont: --some-flag, do: --someflag)
    parser_definition() {
        setup   REST help:usage -- "Usage: ${THIS_SELF_EXE} [options]... [arguments]..." ''
        msg -- "Build and install. From sources."
        msg -- ""
        msg -- 'Parameters (no whitespaces in values, + mandatory, - optional):'
        param  TMPDIR   -t --tmp     --    "+ folder for temp files (sources, builds, etc)"
        param  PREFIX   -p --prefix  --    "+ install prefix"
        flag   CLEAN    -C --clean   --    "- clean (remove) dist files"
        flag   NO_COLOR --no-color   --    "- do not colorize output"
        disp   :usage   -h --help    --    "- print help, ignore any other cliargs"
        msg -- ""
        msg -- "Available commands are:"
        msg -- "    ${icmds//$'\n'/ }"
        msg -- "Commands may have tail-arg appended with ':', like 'name:tag';"
        msg -- "  in general - this is tag or branch (neovim:v0.7.2)"
        msg -- ""
        msg -- "May require root's priviliges and/or some dev packages."
    }
    eval "$($THIS_LIB_PATH/getoptions.sh parser_definition) exit 1" # initial $@ is substitud with free args

    for k in tmpdir prefix ; do # all cliarg dirs are strictly mandatory
        :capar-rp "${k^^}" $k
    done
    :capar CLEAN clean opt

    :capar-restargs-ontail "$REST" "$na" "$icmds" "$*" :
    CliArgs[cmds]=$* # $@ contains all free args while REST is a list of their indicies in the command line

    :echo_assarr CliArgs IntenseBlack

}

###############################################################################

function main()
{
    mkdir -p "${CliArgs[tmpdir]}"  "${CliArgs[prefix]}"
    for cmd in ${CliArgs[cmds]}; do
        declare name=${cmd%%:*} tag=${cmd#*:}
        [[ $name = $tag ]] && tag=
        echo -e "**** ${Green} $name${tag:+ : $tag} ${ResetColor} ****"
        pushd `pwd`
        install_$name $tag
        popd
    done
}

###############################################################################

prepare $*
main

###############################################################################

