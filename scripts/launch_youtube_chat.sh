#!/usr/bin/env bash
####
# Launch a web browser with the chat pop-out for a YouTube live stream.
####
ARGS=()
ARGS="${@}"


__DEFAULT_BROWSER=xdg-open
__YOUTUBE_URL=""

function __usage () {
  echo ""
  echo "launch_youtube_chat.sh <YouTube-URL> [optional options]"
  echo ""
  echo "    Takes the provided URL for a YouTube Live Stream and starts a"
  echo "    web browser pointing to the address of the chat for that stream."
  echo ""
  echo " -h"
  echo " --help                       Display this help message."
  echo ""
  echo " -b <browser>" 
  echo " --browser <browser>          Use <browser> as the web browser instead"
  echo "                              of default as provided by xdg-open."
  echo ""
  exit 0
}

function __parse_youtube_url {
  __YOUTUBE_URL=$(echo $1 | sed -r 's/^.*[&?]v=(.{11})([&#].*)?$/\1/')
}

function __parse_args () {
  if [[ -z "$1" ]]
  then
    echo "Try --help or -h."
    exit 1
  fi
  
  
  
  while [[ $# -gt 0 ]]
  do
    
    case "${1}" in
      -b|--browser)
      __DEFAULT_BROWSER="$2"
      shift
      shift
      ;;
      -h|--help)
      __usage
      shift
      ;;
      *)
        if [[ "$__YOUTUBE_URL" == "" ]]
        then
          __parse_youtube_url $1
        else
          echo "Did you try to set the URL twice?"
          echo "Please run with --help for usage."
          exit 1
        fi
      shift
      ;;
      --)
      shift
      break
      ;;
    esac
  done
  
  if [[ "$__YOUTUBE_URL" == "" ]]
  then
    echo "URL not set"
    echo "Please run with --help for usage."
    exit 1
  fi
  
}

function __main () {
  #echo "Browser: " $__DEFAULT_BROWSER
  #echo "YouTube video-id: " $__YOUTUBE_URL
  
  local __final_url
  __final_url="https://www.youtube.com/live_chat?is_popout=true&v=""${__YOUTUBE_URL}"
  
  #echo $__final_url
  
  $__DEFAULT_BROWSER $__final_url
}

__parse_args "${@}"
__main
