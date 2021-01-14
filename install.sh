#!/usr/bin/env bash
####
# FILE NAME install.sh
#
# Install script for these scripts.
#
####


__INSTALL_DIR=$HOME/bin
__INSTALL_SET=0

# https://stackoverflow.com/a/246128
__CWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#TODO: Add unistall option..
function __usage () {
  echo ""
  echo "install.sh [options]"
  echo ""
  echo "    Install the scripts"
  echo ""
  echo " -h"
  echo " --help                   Display this help message."
  echo ""
  echo ""
  echo " -i"
  echo " --install                Install the scripts. You have to provide this"
  echo "                          if you want to install the scripts."
  echo ""
  echo " --target <directory>     Directory to install the scripts into."
  echo "                          Default: \$HOME/bin"
  echo ""
  exit 0
}

function __parse_args () {
  
  while [[ $# -gt 0 ]]
  do
    case "${1}" in
      -i|--install)
      __INSTALL_SET=1
      shift
      ;;
      -h|--help)
      __usage
      shift
      ;;
      --target)
      __INSTALL_DIR="${2}"
      exit
      shift
      ;;
      *)
      shift
      ;;
      --)
      shift
      break
      ;;
    esac
  done
}

####
# Utility function that prints what what is being executed.
# See: https://stackoverflow.com/a/23342259
####
function __exe () { echo "    $@" ; "$@" ; }

function __main () {
  if [[ $__INSTALL_SET == 1 ]]
  then
    __exe mkdir -p $__INSTALL_DIR
    for __file__ in $__CWD/scripts/*.sh
    do
      __exe cp $__file__ $__INSTALL_DIR/
    done
  else
    echo ""
    echo "YOU MUST PROVIE -i OR --install FOR IT TO INSTALL THE SCRIPTS."
    echo "Please see -h or --help for more information."
    echo ""
    exit 1
  fi
  exit 0
}

__parse_args "${@}"
__main
