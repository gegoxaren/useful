#!/usr/bin/env bash

####
# FILE NAME do-offline-updates.sh
#
# Authors:
#    Gustav Hartvigsson 2024
#    Distributed under the Cool Licence 1.1
#
####

__UPDATES_AVAILABLE=false
__DO_REBOOT=true
__DO_DOWNLOAD=true
__REBOOT_COMMAND="systemctl reboot"

__SANITY=true

__SCRIPT_ROOT=$(dirname $(readlink -f $0))
source $__SCRIPT_ROOT/useful.inc.sh

function __usage () {
  echo "    do-offline-updates.sh"
  echo "Perform offline updates, if available."
  echo ""
  echo "--help           -h"
  echo "    Show this help message."
  echo ""
  echo "--no-reboot"
  echo "    Do not perform an reboot."
  echo ""
  echo "--no-download    --check-updates"
  echo "    Do not download updates."
  echo "    Will show if updates are available."
  echo "    Implies --no-reboot."
  echo ""
}

function __sanity_check () {
  # Check that we have the tools needed.
  __find_tool systemctl
  __find_tool pkcon

  if [[ $__SANITY == false ]]; then
    echo ""
    echo "Please install the missing tools."
    echo ""
    exit 1
  fi
} 

function __check_for_updates () {
  __silent pkcon get-updates
  if [[ $? == 0 ]]; then
    echo "Updates are available!"
    echo ""
    __UPDATES_AVAILABLE=true
  else
    echo "No updates available."
    __UPDATES_AVAILABLE=false
  fi
}

function __download_updates () {
  pkcon update --only-download
  if [[ $? == 0 ]];then
    __UPDATES_AVAILABLE=true
  else
    ## huh?
    __UPDATES_AVAILABLE=false
  fi

}

function __reboot () {
  pkcon offline-trigger
  echo "reboot"
  eval $__REBOOT_COMMAND
}

function __parse_args () {

  while [[ $# -gt 0 ]]
  do
    case $1 in
      -h|--help)
         __usage
         exit
         shift
      ;;
      --no-reboot)
        __DO_REBOOT=false
        shift
        ;;
      --no-download|--check-updates)
        __DO_REBOOT=false
        __DO_DOWNLOAD=false
        shift
        ;;
      *)
        echo "Unkown argument \"${1}\"."
        exit 1
        shift
      ;;
      --)
        shift
        break
      ;;
    esac
  done
}

function __main () {
  __sanity_check
  __parse_args $@
  __check_for_updates

  if [[ ( "$__DO_DOWNLOAD" == true ) && ( "$__UPDATES_AVAILABLE" == true ) ]]; then
    __download_updates
  fi

  if [[ ( "$__DO_REBOOT" == true ) && ( "$__UPDATES_AVAILABLE" == true ) ]]; then
    __reboot
  fi
}


__main $@
