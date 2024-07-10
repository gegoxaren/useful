#!/usr/bin/env bash
####
# FILE NAME: enc2firefox.sh
#
# Encodes (mp4/x264) videos so they can be played in firefox.
#
# Updates:
# 2020-09-05:
#   * Removed an eval that made no sense.
#   * Added FJ mode for those spicy memes.
#
# 2021-01-13:
#   * Fixed up if statments
#
# 2024-07-10
#  * Simplefied if-else-statement.
#
####

__IN_NAME=""
__OUT_NAME=""
__USE_WEBM=false
__USE_FJ=false

__usage () {
  echo "enc2firefox.sh -- Make Videos Playable in Firefox"
  echo " "
  echo "-i <input video file>     Input Video File."
  echo " "
  echo "-o <output video file>    Output Video File"
  echo "                          (.mp4 will be added to the end)."
  echo " "
  echo "-m                        output webm instead"
  echo "                          (Will change ending to .webm)."
  echo " "
  echo "-f                        Use FJ settings. Low bandwith, small size."
  echo "                          (Will append .mp4 to the end)."
  echo " "
  exit
}

__enc_mp4 () {
  ffmpeg -i "$__IN_NAME"\
            -c:v libx264\
            -preset slower\
            -crf 22\
            -pix_fmt yuv420p\
            -c:a aac\
            -b:a 128k\
            "$__OUT_NAME".mp4
}

__enc_fj () {
  ffmpeg -i "$__IN_NAME"\
            -c:v libx264\
            -preset slower\
            -pix_fmt yuv420p\
            -b:v 1024k\
            -s hd720\
            -r 30\
            -c:a aac\
            -b:a 128k\
            "$__OUT_NAME".mp4
}

__enc_webm () {
  ffmpeg -i "$__IN_NAME"\
            -c:v libvpx-vp9\
            -b:v 0\
            -crf 20\
            -c:a libopus\
            "$__OUT_NAME".webm
}

__parse_args() {
  if [[ -z "$1" ]]
  then
    echo "Try --help or -h."
    exit 1
  fi
  
  
  while [[ $# -gt 0 ]]
  do
    
    case "${1}" in
      -i)
      __IN_NAME="$2"
      shift
      shift
      ;;
      -o)
      __OUT_NAME="$2"
      shift
      shift
      ;;
      -m)
      __USE_WEBM=true
      shift
      ;;
      -f)
      __USE_FJ=true
      shift
      ;;
      -h|--help)
      __usage
      shift
      ;;
      *)
      __usage
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

__main () {
  if [[ ! -e "$__IN_NAME" ]]; then
    echo "missing input audio. Please provide."
    exit 1
  fi
  
  if [[ $__OUT_NAME == "" ]]; then
    echo "missing output file name. Please provide."
    exit 1
  fi
 
  if [[ $__USE_WEBM == true ]]; then
    if [[ $__IN_NAME == $__OUT_NAME.webm ]]; then
      echo "Filenames can't be the same."
      exit
    fi
    __enc_webm
  elif [[ $__IN_NAME == $__OUT_NAME.mp4 ]]; then
    if [[ $__USE_FJ == true ]]; then
      __enc_fj
    else
      __enc_mp4
    fi
  else
    echo " Input and output files can't be the same."
    exit
  fi
}

__parse_args "${@}"
__main
