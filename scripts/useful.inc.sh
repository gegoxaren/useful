#!/usr/bin/env bash

####
# FILE NAME useful.inc.sh
#
# Authors:
#    Gustav Hartvigsson 2024
#    Distributed under the Cool Licence 1.1
# 
# PURPOSE
#   This file provides usefule bash libary functions.
####
# Add the following to your script to be able to include it:
#     __SCRIPT_ROOT=$(dirname $(readlink -f $0))
#     source $__SCRIPT_ROOT/useful.inc.sh
####

####
# FUNCTION __silent
#
# PURPOSE
#   Silent a run command.
#
# ARGUMENTS
#   A command and it's arguments.
#
# RETURNS
#   Exit code of command.
#
####
function __silent () {
  $@ >> /dev/null 2>&1
  return $?
}

####
# FUNCTION __find_tool
#
# PURPOSE
#   checks if a tool (progam) exists.
#
# NOTE
#   You need to specify "__SANITY=true" among your globals.
####
function __find_tool () {
  __silent which $1

  if [[ $? > 0 ]]; then
    echo "    Can't find tool \"${1}\"."
    __SANITY=false
  fi
}
