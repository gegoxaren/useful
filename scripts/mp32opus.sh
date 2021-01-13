#!/usr/bin/env bash

# Convert Audiobooks (mp3) to Opus with cover-art preserved.

for i in *.mp3; do
  name=`echo "$i" | cut -d'.' -f1`
  echo "$name"
  ffmpeg -i "$i" -f flac - | opusenc - "${name}.opus"
done
