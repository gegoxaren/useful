#!/usr/bin/env bash

####
# FILE NAME pdf2images.sh
# 
# Changes:
#
#  2024-07-10
#    * Initial version
#    *
####

__FILE=""
__FIRST_PAGE=0
__LAST_PAGE=0
__SCALE=250
__SANITY=true
__HAS_OPTIPNG=false

function __usage () {
  echo "pdf2images.sh --- Convert a range of pdf pages into pngs."
  echo "USAGE:"
  echo "    pdf2images.sh <file>.pdf <first page> <last page>"
  echo ""
}

function __silent () {
  $@ >> /dev/null 2>&1
  return $?
}

function __sanity_check () {
  # Check that we have the tools needed.
  __silent which pdftoppm 

  if [ $? -gt 0 ]; then
    echo "    Can't find tool \"pdftoppm\" (Required)."
    __SANITY=false
  fi

  __silent which optipng
  if [ $? -gt 0 ]; then
    echo "    Can't find tool \"optpng\" (Not required)."
    __HAS_OPTIPNG=false
  fi
  
  if [[ $__SANITY == false ]]; then
    echo "Please install the missing tools."
    echo ""
    exit 1
  fi
}

function __process () {

  pdftoppm -f $__FIRST\
           -l $__LAST\
           -r $__SCALE\
           -gray\
           -png\
           -progress\
           $__FILE\
           ${__FILE%%.*}

  if [[ $__HAS_OPTIPNG == true ]]; then
    optipng ${__FILE%%.*}*.png
  fi
}

function __parse_args () {
  if [ $# -eq 0 ]; then
    __usage
    exit 1
  fi
  
  __FILE=$1
  shift
  __FIRST=$1
  shift
  __LAST=$1
  shift

  if [ $# -ne 0 ]; then
    echo "Nummber of arguments missmatch."
    echo ""
    __usage
    exit 1
  fi
}

function __main () {
  __sanity_check
  __parse_args "${@}"
  __process
  exit 0
}

__main "${@}"

