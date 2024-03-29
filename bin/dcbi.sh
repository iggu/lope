#!/bin/bash
# Download, Configure, Build & Install

source $(dirname `realpath $0`)/_include.sh

###############################################################################

#### Check prerequisites, clone code from github, configure, make and install it
# $1=required:packages,comma,separated
# $2=ghuser/ghrepo[?/ghbranch]
# $3="configure options" in addition to --prefix
# $4="make options" -- optional
# $5="post-install command in the repo dir" -- optional
function _ghclone_make_install()
{
    local rqpkg=`echo $1 | tr ',' ' '`
    [ -z "$rqpkg" ] || :require-pkgs $rqpkg

    local gh=($(echo $2 | tr '/' "\n"))
    declare user=${gh[0]} repo=${gh[1]} branch=${gh[2]}

    local dir=`mktemp -u -d -p "${CliArgs[tmpdir]}" --suffix=.git -t $user+$repo.XXXX`

    git clone --recursive ${branch:+-b $branch} --single-branch --depth=1 "https://github.com/$user/$repo" "$dir"
    cd $dir # never return to the path we came from
    [ -f .gitmodules ] && git submodule update --init
    [ -x ./autogen.sh ] && ./autogen.sh
    [[ -f ./configure.ac && ! -x ./configure ]] && (aclocal && autoheader && automake --add-missing && autoconf || autoreconf -fi)
    [ -x ./configure ] && ./configure --prefix=${CliArgs[prefix]} $3
    PREFIX=${CliArgs[prefix]} make $4
    PREFIX=${CliArgs[prefix]} make install
    [[ -n "$5" ]] && $5

    if [ -n "${CliArgs[clean]}" ] ; then rm -rf $dir ; fi
}

###############################################################################

function _ghclone_cmake_install()
{
    local rqpkg=`echo $1 | tr ',' ' '`
    [ -z "$rqpkg" ] || :require-pkgs $rqpkg make cmake g++

    local gh=($(echo $2 | tr '/' "\n"))
    declare user=${gh[0]} repo=${gh[1]} branch=${gh[2]}

    local dir=`mktemp -u -d -p "${CliArgs[tmpdir]}" --suffix=.git -t $user+$repo.XXXX`

    git clone --recursive ${branch:+-b $branch} --single-branch --depth=1 "https://github.com/$user/$repo" "$dir"
    mkdir "$dir/build"
    cd "$dir/build" # never return to the path we came from
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${CliArgs[prefix]} ..
    make install

    if [ -n "${CliArgs[clean]}" ] ; then rm -rf $dir ; fi
}

###############################################################################

function _appimage_install()
{
    declare url="$2" app="$1"
    dpkg -l libfuse2 >/dev/null || sudo apt install libfuse2
    dpkg -l libfuse2 >/dev/null
    case "$url" in
        *.zip)
            local fn="$(basename $url)"
            local dir="$(mktemp -d /tmp/${fn}.XXXXXXXXXX)"
            local arch="/tmp/$fn"
            wget -c $url -O $arch
            unzip "$arch" -d "$dir"
            mv -f $dir/*.AppImage $app
            rm -rf $dir
            ;;
        *)
            wget -c $url -O $app
            ;;
    esac
    chmod a+x $app
}

###############################################################################

function install_encryptpad()
{
    _appimage_install "$HOME/.local/bin/encryptpad" \
        "https://github.com/evpo/EncryptPad/releases/download/v0.5.0.2/encryptpad0_5_0_2.AppImage"
}

###############################################################################

function install_fff()
{
    _ghclone_make_install make,cc,gcc dylanaraps/fff${1:+/$1}
}

###############################################################################

function install_vnote()
{
    _appimage_install "$HOME/.local/bin/vnote" \
        "https://github.com/vnotex/vnote/releases/download/v3.16.0/vnote-linux-x64_v3.16.0.zip"
}

###############################################################################


function install_passh()
{
    _ghclone_make_install make,cc,gcc clarkwang/passh${1:+/$1} "" "" "cp -bv passh ${CliArgs[prefix]}/bin"
}

###############################################################################

function install_tldr()
{
    :require-pkgs /usr/include/zip.h:libzip-dev /usr/include/x86_64-linux-gnu/curl/curl.h:libcurl4-gnutls-dev
    _ghclone_make_install make,cc,gcc tldr-pages/tldr-c-client${1:+/$1} "" "" "cp -bv tldr ${CliArgs[prefix]}/bin"
}

###############################################################################

function install_rdrview()
{
    :require-pkgs /usr/include/seccomp.h:libseccomp-dev /usr/include/x86_64-linux-gnu/curl/curl.h:libcurl4-gnutls-dev
    _ghclone_make_install make,cc,gcc eafer/rdrview${1:+/$1} "" "" "cp -bv rdrview ${CliArgs[prefix]}/bin"
}

###############################################################################

function install_kabmat()
{
    _ghclone_make_install make,cc,gcc PlankCipher/kabmat${1:+/$1} "" "" "cp -bv kabmat ${CliArgs[prefix]}/bin"
}

###############################################################################

function install_fzy()
{
    _ghclone_make_install make,cc,gcc jhawthorn/fzy${1:+/$1}
}

###############################################################################

function install_jq()
{
    _ghclone_make_install make,cc,gcc stedolan/jq${1:+/$1} \
        "--disable-maintainer-mode --with-oniguruma=builtin"
}

###############################################################################

function install_encpipe()
{
    _ghclone_make_install make,cc,gcc jedisct1/encpipe${1:+/$1}
}

###############################################################################

function install_doneyet()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,g++ \
                      gtaubman/doneyet${1:+/$1} "" "" "cp -bv doneyet ${CliArgs[prefix]}/bin"
}

###############################################################################

function install_xstow()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,g++ \
                      majorkingleo/xstow${1:+/$1}
}

###############################################################################

function install_ugrep()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,g++ \
                      Genivia/ugrep${1:+/$1}
}

###############################################################################

function install_xkbswitch()
{
    _ghclone_cmake_install /usr/include/X11/extensions/XKBfile.h:libxkbfile-dev \
                            grwlf/xkb-switch${1:+/$1}

    local pLib=$(find ${CliArgs[prefix]}/lib/ -maxdepth 1 -name "libxkbswitch.so.*.*.*")
    echo
    if [ -z $pLib ]; then
        echo "Cannot find library"
    else
        echo "XKB-SWITCH and friends (ivanesmantovich/xkbswitch.nvim) use shared libraries"
        echo "LD possibly would not find libxkbswitch in ${CliArgs[prefix]}/lib"
        echo "to force apps search there - as root make symlink to system-wide library path"
        echo "  > sudo ln -s ${CliArgs[prefix]}/lib/libxkbswitch* /usr/local/lib"
        echo "  > sudo ldconfig # rebuild libs list"
        echo "or export LD_PRELOAD pointing to this particular lib"
        echo "  > export LD_PRELOAD=$pLib"

        echo
        read -r -s -n 1 -p "Want me to export 'libxkbswitch' system-wide? (y/...): "
        if [[ "${REPLY,,}" == "y" ]] ; then
            echo
            sudo ln -s ${CliArgs[prefix]}/lib/libxkbswitch* /usr/local/lib
            sudo ldconfig
            echo done
        fi
        echo
    fi
}

###############################################################################

function install_neovim()
{
    _ghclone_make_install pkg-config,libtool:libtool-bin,gettextize:gettext,make,cmake,g++ \
                      neovim/neovim${1:+/$1} "" \
                      "CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX=${CliArgs[prefix]}"
}

###############################################################################

function install_ctags()
{
    _ghclone_make_install pkg-config,autoconf,automake,make,gcc \
                      universal-ctags/ctags${1:+/$1}
}

###############################################################################

function install_frogmouth()
{
    # Markdown viewer / browser for terminal
    :require-pkgs python3 pip
    sudo pip install python3-xdg frogmouth
}

###############################################################################

function install_pwgen()
{
    :require-pkgs python3 pip
    sudo pip install pwgen-passphrase
}

###############################################################################

function install_speedtest()
{
    local exe="$HOME/.local/bin/speedtest"
    mkdir -p ~/.local/bin
    wget https://raw.githubusercontent.com/tankibaj/speedtest/master/speedtest -O $exe
    chmod a+x $exe
    echo "Done speedtest"
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
        # BitstreamVeraSansMono
        # CodeNewRoman
        # DroidSansMono
        # FiraCode
        # FiraMono
        # Go-Mono
        # Hack
        # Hermit
        JetBrainsMono
        # Meslo
        # Noto
        # Overpass
        # ProggyClean
        # RobotoMono
        # SourceCodePro
        # SpaceMono
        # Ubuntu
        UbuntuMono
    )
    :require-pkgs fc-cache:fontconfig

    local version=${1:-2.2.2}
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

function install_qmmpskins()
{
    local zip=`mktemp --dry-run --suffix=.zip`
    wget -qO $zip http://imbicile.pp.ru/wp-content/uploads/2015/12/skins.zip &&
        unzip -n $zip -d ~/.qmmp/ &&
        rm $zip
}

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
        pushd `pwd` &>/dev/null
        install_$name $tag
        popd &>/dev/null
    done
}

###############################################################################

prepare $*
main

###############################################################################
