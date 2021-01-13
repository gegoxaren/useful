#!/usr/bin/env bash
###################
# FILE NAME: video2lbry.sh
#
# Encodes videos so they are ready to be uploaded to LBRY.
#
####################
ARGS=()
ARGS="${@}"

__IN_NAME=
__OUT_NAME=

__help () {
  echo "video2lbry.sh -- Make vide ready for upload to LBRY."
  echo " "
  echo "-i <input video file>     Input Video File."
  echo " "
  echo "-o <output video file>    Output Video File"
  echo "                          (_lbry.mp4 will be added to the end)."
  echo " "
}

__enc_mp4 () {
  ffmpeg -y -i "$__IN_NAME"\
          -threads 7\
          -c:v libx264\
          -crf 21\
          -preset slower\
          -pix_fmt yuv420p\
          -maxrate 5000K\
          -bufsize 5000K\
          -vf 'scale=if(gte(iw\,ih)\,min(2560\,iw)\,-2):if(lt(iw\,ih)\,min(2560\,ih)\,-2)'\
          -movflags +faststart\
          -c:a aac\
          -b:a 256k\
          "${__OUT_NAME}_lbry.mp4"
}

__parse_args() {
  if [[ -z "$1" ]]
  then
    echo "Try --help or -h."
    exit 1
  fi
  
  
  while [[ $# -gt 0 ]]
  do
    eval key="${1}"
    
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
      -h|--help)
      __help
      shift
      ;;
      *)
      __help
      exit
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
  if [[ ! -e "$__IN_NAME" ]]
  then
    echo "missing input audio. Please provide."
    exit 1
  fi
  
  if [[ $__OUT_NAME == "" ]]
  then
    echo "missing output file name. Please provide."
    exit 1
  fi
  
  
  if [[ $__IN_NAME == ${__OUT_NAME}_lbry.mp4 ]]
  then
    echo "Filenames can't be the same."
    exit
  fi
  __enc_mp4
}

__parse_args "${@}"
__main
