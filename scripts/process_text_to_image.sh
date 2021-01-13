#!/usr/bin/env bash

# ------
# Changes
#
# 2018-09-03:
# added --no-header for when you want to use your own pandoc header
#
# 2018-09-22
# Fixed --no-header... Seemed to have forgotten the "$" infront of the variable.
#
# ------

ARGS=()
ARGS="${@}"

DPI=300

IN_FILE=
OUT_FILE=big_image
PERSERVE_TMP=false
INVERT_COLOURS=false
_NO_PANDOC_HEADER=false

CWD=$PWD

_PANDOC_HEADER="
geometry: margin=0.5cm
papersize: a5
mainfont: DejaVu Serif
fontsize: 12pt
"

TITLE=""

echo "-----"
echo "---"
echo "--"
echo "-"

print_help() {
  
  echo "process_text_to_image.sh - Takes one text file and convernts it to a single"
  echo "image using pandoc, xelatex, imagemagick, pdftoppm, pdfcrop"
  echo ""
  echo "!IMPORTANT! The folder \"./tmp/\" in the current working directory will be"
  echo "            used as a temporary storage, and may be deleted, along with it's"
  echo "            contents!"
  echo ""
  echo "---------------------"
  echo ""
  echo "-h	--help"
  echo "	Print this help message"
  echo ""
  echo "-i <file>	--input <file>"
  echo "	The file to use to convert to an image. "
  echo ""
  echo "-o <file>	--output <file>"
  echo "	The image to output to. (Default=big_image.png)"
  echo ""
  echo "-d <integer>	--dpi <integer>"
  echo "	Set the dpi of the intermediate image relative to an a5 paper."
  echo "	(Default=300)"
  echo ""
  echo "-p		--perserve"
  echo "	Do not delete the TMP folder."
  echo ""
  echo "-invert"
  echo "	Invert the colours of the final image."
  echo ""
  echo "-t \"name\"	--title \"name\""
  echo "	Set the title on the the title page."
  echo ""
  echo "--no-header"
  echo "	Do not insert the pandoc header. (Default:"
  echo "$_PANDOC_HEADER"
  echo ")"
  echo ""
  echo "---------------------"
  echo ""
  echo "If you are getting an error from convert that the height or width exeeds"
  echo "some value, you may want to check the ImageMagick policy.xml file."
  echo ""
  echo "The path to ImageMagick policy file is:"
  convert -list policy | grep .xml 
  echo ""
  echo "---------------------"
}





main() {
  #ESCAPED_CWD=$(echo ${CWD} | sed 's/ /\\ /g' | sed "s/'/\\\'/g" )
  
  echo "IN_FILE\: $IN_FILE"
  echo "OUT_FILE\: $OUT_FILE"
  echo "CWD\: $CWD"
  echo "DPI: $DPI"
  #echo "ESCAPED_CWD\: $ESCAPED_CWD"
  
  if [ ! -e "$CWD/$IN_FILE" ]
  then
    echo "!!!in file does not exist!!!"
    echo ""
    #print_help
    exit 1
  fi
  
  # first we create a temp folder.
  mkdir -p "$CWD/tmp"
  
  #next we want to copy our file into it.
  cp "$CWD/$IN_FILE" "$CWD/tmp/text.txt"
  cd "$CWD/tmp"
  
  # Now we can start the work for this.
  if [ $_NO_PANDOC_HEADER = false ]
  then
    # We add a special header to the file to make it pandoc know what to do.
    
    printf '%s\n' "---" "$(cat "$CWD/tmp/text.txt")" > "$CWD/tmp/text.txt"
    if [ -n TITLE="" ]
    then
      printf '%s\n' "title: ${TITLE}" "$(cat "$CWD/tmp/text.txt")" > "$CWD/tmp/text.txt"
    fi
    
    printf '%s' "$_PANDOC_HEADER" "$(cat "$CWD/tmp/text.txt")" > "$CWD/tmp/text.txt"
    
    printf '%s' "---" "$(cat "$CWD/tmp/text.txt")" > "$CWD/tmp/text.txt"
  fi
  
  # Now we use pandoc to do to convert it to a PDF.
  pandoc --pdf-engine=xelatex "$CWD/tmp/text.txt" -o "$CWD/tmp/text.pdf"
  
  pdfcrop --margins '10 5 10 5' "$CWD/tmp/text.pdf" "$CWD/tmp/text-croped.pdf"
  
  # Convert it to images
  pdftoppm "$CWD/tmp/text-croped.pdf" "$CWD/tmp/page" -png -rx $DPI -ry $DPI -gray
  
  # convert make the colour space greyscale and the append to each other
  convert -append -colorspace gray +matte -depth 8 "$CWD/tmp/page-*.png" "$CWD/tmp/big-page.png"
  
  FINAL_IMAGE=""
  
  # If we invert the final image this is where we do it.
  if [ $INVERT_COLOURS = true ]
  then
    convert "$CWD/tmp/big-page.png" -channel RGB -negate "$CWD/tmp/big-page-inverted.png"
    FINAL_IMAGE="$CWD/tmp/big-page-inverted.png"
  else
    FINAL_IMAGE="$CWD/tmp/big-page.png"
  fi
  
  cp "$FINAL_IMAGE" "$CWD/$OUT_FILE.png"
}


parse_args() {
  if [ -z "$1" ]
  then
    echo "Try --help or -h."
    exit 1
  fi
  
  
  while [[ $# -gt 0 ]]
  do
    eval key="${1}"
    
    case "${1}" in
      -i|--input)
      IN_FILE="$2"
      shift
      shift
      ;;
      -o|--output)
      OUT_FILE="$2"
      shift
      shift
      ;;
      -t|--title)
      TITLE="$2"
      shift
      shift
      ;;
      -d|--dpi)
      DPI="$2"
      shift
      shift
      ;;
      -p|--perserve)
      PERSERVE_TMP=true
      shift
      ;;
      --invert)
      INVERT_COLOURS=true
      shift
      ;;
      --no-header)
      _NO_PANDOC_HEADER=true
      shift
      ;;
      -h|--help)
      print_help
      exit
      shift
      ;;
      *)
      #print_help
      #exit 1
      shift
      ;;
      --)
      shift
      break
      ;;
    esac
  done
}

parse_args "${@}"
main

if [ $PERSERVE_TMP = true ]
then
  echo "Not cleaning up!"
else
  rm -r "$CWD/tmp"
fi

echo "-"
echo "--"
echo "---"
echo "----"



