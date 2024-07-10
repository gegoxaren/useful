#!/usr/bin/env bash

___ARGS=$@

___FILE=""
___FIRST_PAGE=0
___LAST_PAGE=0
___SANITY=1
___SCALE=250
___HAS_OPTIPNG=1

function ___usage () {
  echo "pdf2images.sh --- Convert a range of pdf pages into pngs."
  echo "USAGE:"
  echo "    pdf2images.sh <file>.pdf <first page> <last page>"
  echo ""
}

function ___silent () {
  $@ >> /dev/null 2>&1
  return $?
}

function ___sanity_check () {
  # Check that we have the tools needed.
  ___silent which pdftoppm 

  if [ $? -gt 0 ]; then
    echo "    Can't find tool \"pdftoppm\" (Required)."
    ___SANITY=0
  fi

  ___silent which optipng
  if [ $? -gt 0 ]; then
    echo "    Can't find tool \"optpng\" (Not required)."
    ___HAS_OPTIPNG=0
  fi
  
  if [ $___SANITY -eq 0 ]; then
    echo "Please install the missing tools."
    echo ""
    exit 1
  fi
}

function ___process () {

  pdftoppm -f $___FIRST\
           -l $___LAST\
           -r $___SCALE\
           -gray\
           -png\
           -progress\
           $___FILE\
           ${___FILE%%.*}

  if [ $___HAS_OPTIPNG -eq 1 ]; then
    optipng ${___FILE%%.*}*.png
  fi
}

function ___parse_args () {
  if [ $# -eq 0 ]; then
    ___usage
    exit 1
  fi
  
  ___FILE=$1
  shift
  ___FIRST=$1
  shift
  ___LAST=$1
  shift

  if [ $# -ne 0 ]; then
    echo "Nummber of arguments missmatch."
    echo ""
    ___usage
    exit 1
  fi
}

function ___main () {
  ___sanity_check
  ___parse_args $___ARGS
  ___process
  exit 0
}

___main

