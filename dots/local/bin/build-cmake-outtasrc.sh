#!/bin/bash

# Script for building cmake-based project with in-source dir schema
# adapted for using in conjunction with VIM.

# Searches for top-level project's dir (where .git subdir resides), then guesses
# directories layout, goes to the place where cmake in-source build dir for
# given compiler-profile pair lives and calls make -j8.

# Initial cmake magic should be made by hand with respect of dir-layouting contract.

#### Project's dir layout
# <cmake-based-project-root>
#   build/
#        <compiler>.<profile>

#### Cli Args
# $1 = full path to any file within project's source tree
# $2 = compiler (gcc, clang)
# $3 = profile  (release, debug, relwithdebinfo)
# example: build-cmake-outtasrc.sh project/module/main.cpp gcc release

#### VIM setup
# :set makeprg=build-cmake-outtasrc.sh\ %:p\ <compiler>\ <profile>
# (filename modifiers for vim: https://vimhelp.org/cmdline.txt.html#filename-modifiers)

for opt in PATH2FILE COMPILER PROFILE; do
    if [ -z $1 ]; then
        echo "Mandatory option $opt is missing (build-cmake-outtasrc.sh <PathToFile> <Compiler> <BuildProfile>)"
        exit 1
    fi
    declare "$opt=$1"
    shift
done

PATH2PDIR=$(dirname $PATH2FILE)
if [ -d $PATH2FILE ]; then
    cd $PATH2FILE
elif [ -d $PATH2PDIR ]; then
    cd $PATH2PDIR
else
    echo "$PATH2FILE: bad filepath ($PATH2PDIR)"
    exit 2
fi

until [ -d .git ] || [ "$PWD" = "$OLDPWD" ]; do cd ..; done
SRCDIR="$PWD"
if [ "$SRCDIR" = "/" ]; then
    echo "$PATH2FILE does not belong to GIT tree"
    exit 3
fi


BLDDIR=$SRCDIR/build/$COMPILER.$PROFILE
if [ ! -d $BLDDIR ]; then
    echo "$BLDDIR: build dir does not exist"
    exit 4
fi

echo "BUILD: compiler=$COMPILER; profile=$PROFILE; dir=$SRCDIR; bld=$BLDDIR"
echo "==============================================="
echo
echo

cd $BLDDIR
make -j8
