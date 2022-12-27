#!/bin/bash

# GitHub Release Installer

source $(dirname `realpath $0`)/_include.sh

declare -A AppsTags # app is user/repo
declare -A Arches=( [x86_64]="(x86_|amd|x)64" [aarch64]="(aarch|arm)64" )

:acquire jq

#####################################################################################
# Utility functions
#####################################################################################

# Constructs the service path in unified format. The containg directory is created if not exists.
# Args are:
#   1: component name
#   2: github user
#   3: github repo
#   4-...: any (even zero) amount of words
# The path is constructed as: <dist-path>/$1/$3++$2++$3++$4
# The last param is treated in a special way. If it starts from dot - it is assumed that this is an
#   extension and appended as is. Otherwise - as other words.
# Examples:
#   % tag user repo => <dist-path>/tag/user++repo
#   % tag user repo word => <dist-path>/tag/user++repo++word
#   % tag user repo w1 w2 => <dist-path>/tag/user++repo++w1++w2
#   % tag user repo w1 w2 .ext => <dist-path>/tag/user++repo++w1++w2.ext
function path_dist_construct()
{
    mkdir -p "${CliArgs[dist]}/${1}"
    echo -n "${CliArgs[dist]}/${1}/${3}++${2}"
    if [ $# -gt 3 ] ; then 
        local maybeExt="${@: -1}"
        for ((i=4; i<$#; i++)) ; do
            echo -n "++${!i}"
        done
        [[ $maybeExt == .* ]] && echo "${maybeExt}" || echo "++${maybeExt}"
    fi
}

#####################################################################################
# GitHub related functions.
#####################################################################################

function gh_get_release_spec()
{
    declare owner=$1 repo=$2
    local hh="Accept: application/vnd.github.v3+json"
    local allReleasesJson=`path_dist_construct meta $owner $repo .json`

    echo -ne " > ${IntenseBlack}"
    # download meta only of it is missing or 'updout' set and outdated (to avoid api limit exceed)
    if [ ! -f "$allReleasesJson" ] || \
       [[ "${CliArgs[updout]}" && "$(find "$allReleasesJson" -mtime "+${CliArgs[updout]}")" ]] ; then
        echo -en "${Cyan}"
        curl -s -H $hh "https://api.github.com/repos/$owner/$repo/releases" > $allReleasesJson
    fi
    echo -e "${allReleasesJson}${ResetColor}"
}

###############################################################################

function gh_release_info()
{
    declare owner=$1 repo=$2 ver=$3
    if [[ "$ver" == "latest" ]] ; then
        jq -r '.[0]'
    elif [[ "$ver" =~ ^-[0-9]+$ ]] ; then # ignore first N versions
        jq -r ".[${ver:1}]"
    else
        jq -r --arg V $ver '.[] | select(.tag_name==$V)'
    fi < $(path_dist_construct meta $owner $repo .json)
}

###############################################################################

function gh_select_url() # 1=info 2=arch
{
    declare relInfo="$1" arch=$2
    declare anyRet nAnyRet=0 osRet
    local archRe=${Arches[$arch]}

    local jqUrlRe='".*(t.z|\\.tar\\..z|zip)$"'
    local jqQuery='.assets[].browser_download_url | select(test('$jqUrlRe'))'
    # local jqEndsWith='endswith(".tar.gz") or endswith(".zip") or endswith(".tar.xz")'
    # local jqQuery=".assets[].browser_download_url | select($jqEndsWith)"
    for url in `jq -r "$jqQuery"`; do
        if [[ $url == *inux* ]]; then
            [[ $url =~ $archRe ]] && echo $url && return # exact match! return immediately
            [[ "$arch" == "x86_64" ]] && osRet=$url # assume linux w/o arch to be x86_64
        else
            anyRet=$url
            let nAnyRet++
        fi
    done < <(echo $relInfo)

    [ -n "$osRet" ] && echo $osRet && return
    [ $nAnyRet -eq 1 ] && echo $anyRet # very likely that package is arch-agnostic
    # no package for the particular arch - print nothing to raise error
}

###############################################################################

function gh_download_url()
{
    declare owner=$1 repo=$2 ver=$3 arch=$4 url=$5
    local ext=`:ext4ar $url`
    local localPkgFn="$(path_dist_construct $arch $owner $repo $ver).$ext"

    if [ -f $localPkgFn ] ; then
        echo -ne " > ${IntenseBlack}"
    else
        echo -ne " > ${Cyan}"
        wget -qc $url -O $localPkgFn
    fi
    echo -e "$localPkgFn${ResetColor}"
}

###############################################################################

function gh_unpack_dist() # 1=version 2=arch
{
    declare owner=$1 repo=$2 ver=$3 arch=$4
    local pkg="$(path_dist_construct $arch $owner $repo $ver)"

    echo -en " > ${IntenseBlack}"
    if [ ! -d "$pkg" ] ; then
        local td=`mktemp -d`
        :extract ${pkg}* $td

        mkdir -p "$pkg"
        if [[ `ls -1 $td | wc -l` == "1" && `ls -1d $td/*/ 2>/dev/null | wc -l` == "1" ]] ; then
            mv $td/**/* "$pkg" # the only single directory - it's content is app's tree
        else
            mv $td/* "$pkg" # archive had no root directory - the tree as is
        fi

        rm -rf $td
        echo -en "${Cyan}"
    fi

    echo -e "$pkg/${ResetColor}"
}

#####################################################################################
# Main flow
#####################################################################################

function prepare()
{
    # WARNING: params/flags/etc with '-' inside do not work but claimed to (dont: --some-flag, do: --someflag)
    parser_definition() {
        setup   REST help:usage -- "Usage: ${THIS_SELF_EXE} [options]... [arguments]..." ''
        msg -- "Install applications from github onto local host."
        msg -- ""
        msg -- 'Parameters (no whitespaces in values, + mandatory, - optional):'
        param  APPLIST  -l --list    --    "+ file with the list of applications"
        param  DISTDIR  -d --dist    --    "+ folder to install application files"
        param  BINPATH  -b --bin     --    "- install application files to this root"
        param  REGEX    -r --regex   --    "- matching filter for the apps from list"
        param  ARCH     -a --arch    --    "- download apps for this machine type"
        param  UPDOUT   -U --updout  --    "- update outdated (older then some days, <0 to force)"
        flag   NO_COLOR --no-color   --    "- do not colorize output"
        flag   NO_FAIL  -I --nofail  --    "- do not fail when app is not suitable, just skip it"
        disp   :usage   -h --help    --    "- print help, ignore any other cliargs"
        msg -- 'APPLIST is a file where each line contains mandatory word of owner/repo'
        msg -- '    and optional word of the required version in terms of the app'
        msg -- '    (or "latest" if omitted) and # for comment (till the end of the line)'
        msg -- 'If not specified - then not performed'
        msg -- '    BINPATH - installation of symlinks to binaries'
        msg -- '    REGEX - filtering of entries in applist (take all)'
        msg -- 'If ARCH is not set - current machine architecture is used.'
        msg -- '  If app from the list is not suitable for the current architecture -'
        msg -- '  installation would fail until "--no-fail" flag is raised.'
    }

    par() {
        [ -n "${3}${!1}" ] || :fail 3 "Mandatory param $1 is not set"
        CliArgs[$2]="${!1}"
        unset ${1}
    }

    eval "$(${THIS_LIB_PATH}/getoptions.sh parser_definition) exit 1"
    [ -z "$REST" ] || :fail 2 "Extra args detected (param with space?)"
    [[ -z $ARCH || -v "Arches[$ARCH]" ]] || :fail 3 "Unsupported machine architecture '$ARCH'" "(expect: ${!Arches[@]})"
    par APPLIST list ; par DISTDIR dist ;
    par BINPATH bin opt ; par REGEX regex opt ;  par ARCH arch opt ;  par NO_FAIL nofail opt ;  par UPDOUT updout opt ;
    [ -f ${CliArgs[list]} ] || :fail 4 "File with list of packages does not exist" "(${CliArgs[list]})"

    :echo_assarr CliArgs IntenseBlack

    local ln=0
    while read -r line; do
        let ln++ # remove comments and extra spaces, subst tabs with spaces, collapse whitespaces
        local cols=$(echo "$line" | sed 's/\t/ /g' | sed "s/ *#.*$//g" | tr -s ' ')
        case `echo $cols | wc -w` in # can be or only user/repo, or u/r with tags
            0) ;; # ignore empty lines
            1) AppsTags[${cols}]="latest" ;; # no ws after usr/repo
            2) AppsTags[$(echo $cols | cut -s -d' ' -f1)]=$(echo $cols | cut -s -d' ' -f2) ;;
            *) :fail 9 "${CliArgs[list]}:$ln - invalid line format '$line'" "(accept only 'ghUser/ghRepo ?tag)";;
        esac
    done < ${CliArgs[list]}

    # :echo_assarr AppsTags IntenseBlack
}

###############################################################################

function delete_dist_dirs()
{
    if [ -n "${CliArgs[updout]}" ] ; then
        declare ghOwner="$1" ghRepo="$2" arch=${CliArgs[arch]:-`arch`}
        local rmPath="$(path_dist_construct $arch $ghOwner $ghRepo)"
        local rmDirs=$(find $(dirname $rmPath) -name "*$(basename $rmPath)*" -type d -printf '%p ')
        if [ -n "$rmDirs" ] ; then
            echo -e " > ${Purple}$(echo $rmDirs | xargs basename) ${IntenseBlack}${ResetColor}"
            rm -rf $rmDirs
        fi
    fi
}

###############################################################################

function download()
{
    local arch=${CliArgs[arch]:-`arch`}
    for ghApp in ${!AppsTags[@]} ; do
        if [[ "$ghApp" =~ "${CliArgs[regex]}" ]] ; then
            declare ghRepo="${ghApp#*/}" ghOwner="${ghApp%/*}" ghTag=${AppsTags[$ghApp]}

            echo -e "**** ${Green}$ghOwner/$ghRepo${ResetColor} : ${Green}$ghTag${ResetColor} ****"
            gh_get_release_spec $ghOwner $ghRepo

            local ghRelInfo=`gh_release_info $ghOwner $ghRepo $ghTag`
            [[ -z $ghRelInfo ]] && :fail 11 "Tag $ghTag not found for app $ghApp"
            ghTag=`echo "$ghRelInfo" | jq -r '.tag_name'`

            local ghUrl=`gh_select_url "$ghRelInfo" $arch`
            if [[ -z $ghUrl ]] ; then
                if [[ -z ${CliArgs[nofail]} ]] ; then
                    :fail 12 "Download URL is not found for app $ghApp '${CliArgs[nofail]}'"
                else
                    echo -e " > ${Yellow}$ghTag ${IntenseYellow}unapplicable${ResetColor}"
                    continue
                fi
            fi

            echo -e " > ${Yellow}$ghTag ${IntenseBlack}$ghUrl${ResetColor}"
            if [[ -n ${CliArgs[bin]} ]] ; then
                gh_download_url $ghOwner $ghRepo $ghTag $arch $ghUrl
                delete_dist_dirs $ghOwner $ghRepo
                gh_unpack_dist $ghOwner $ghRepo $ghTag $arch
            fi
        fi
    done
}

function install()
{
    local arch=${CliArgs[arch]:-`arch`}
    function ?samelink() { [[ -L $1 && "$(realpath -q `readlink $1`)" == "$(realpath -q $2)" ]] && return 0 || return 1 ; }

    # install every binary file except completion scripts and appimages
    if [ -n "${CliArgs[bin]}" ] ; then
        mkdir -p ${CliArgs[bin]}
        echo -e "**** ${Green}Installing executables${ResetColor} => ${Green}${CliArgs[bin]}${ResetColor} ****"
        # TODO: install from tagged dirs only - steal idea from download()
        while read -r exe; do
            local n=`basename $exe`
            local l="${CliArgs[bin]}/$n"
            case "$n" in
                *.sh|*.awk|*.bat) ;; # ignore those files; TODO: search only app's ./ and ./bin folders for exe
                *) ?samelink "$l" "$exe" || ln -sfv "$exe" "$l" ;; # make a link with possible overwrite - maybe it's an update
            esac
        done < <(find ${CliArgs[dist]}/$arch -type f -executable -not -path "*complet*" -not -iname "*.appimage")
    fi

    # install appimages
    find ${CliArgs[bin]} -executable -iname "*.appimage" -exec rm '{}' ';'
    while read -r appimg; do
        local name=$(echo $appimg | rev | cut -d'/' -f2 | rev | cut -d'+' -f1)
        local link="${CliArgs[bin]}/$name"
        if ! ?samelink "$link" "$appimg" ; then
            [[ -x "$appimg" ]] || chmod a+x "$appimg"
            ln -sfv "$appimg" "$link"
        fi
    done < <(find ${CliArgs[dist]}/$arch -type f -iname "*.appimage")
}

###############################################################################

function MAIN() { :; }
    :require-pkgs jq curl
    prepare $*
    download $*
    install $*

###############################################################################
