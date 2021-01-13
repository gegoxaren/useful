#!/usr/bin/env bash
#####
# FILE NAME: mp32opus.sh
#
# Convert Audiobooks (mp3) to Opus with cover-art preserved.
#
# FIXME:
# This probobly needs a bit of an overhaul... Now it is just a dumb script
# without any commandline arguments.
#
#####



for i in *.mp3; do
  name=`echo "$i" | cut -d'.' -f1`
  echo "$name"
  ffmpeg -i "$i" -f flac - | opusenc - "${name}.opus"
done
