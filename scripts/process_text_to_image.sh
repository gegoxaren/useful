#!/usr/bin/env bash
####
# FILE NAME process_text_to_image.sh
#
# Changes
#
# 2018-09-03:
#   * added --no-header for when you want to use your own pandoc header
#
# 2018-09-22
#   * Fixed --no-header...
#     Seemed to have forgotten the "$" infront of the variable.
#
# 2021-01-13
#   * fixed up the if statments.
#
# 2024-07-10
#   * Added sanity check
#   * General logic fixes.
#   * Added --author argument
#   * Fixed help message formating
####

__DPI=300

__IN_FILE=
__OUT_FILE=big_image
__PERSERVE_TMP=false
__INVERT_COLOURS=false
__NO_PANDOC_HEADER=false

__CWD=$PWD

__PANDOC_HEADER="
geometry: margin=0.5cm
papersize: a5
mainfont: DejaVu Serif
fontsize: 12pt
"

__TITLE=""
__AUTHOR=""

__SANITY=true


__SCRIPT_ROOT=$(dirname $(readlink -f $0))
source $__SCRIPT_ROOT/useful.inc.sh

function __usage () {
  
  echo "process_text_to_image.sh - Takes one text file and convernts it to a single"
  echo "image using pandoc, xelatex, imagemagick, pdftoppm, pdfcrop"
  echo ""
  echo "!IMPORTANT! The folder \"./tmp/\" in the current working directory will be"
  echo "            used as a temporary storage, and may be deleted, along with it's"
  echo "            contents!"
  echo ""
  echo "---------------------"
  echo ""
  echo "-h             --help"
  echo "	Print this help message"
  echo ""
  echo "-i <file>      --input <file>"
  echo "	The file to use to convert to an image. "
  echo ""
  echo "-o <file>      --output <file>"
  echo "	The image to output to. (Default=big_image.png)"
  echo ""
  echo "-d <integer>   --dpi <integer>"
  echo "	Set the dpi of the intermediate image relative to an a5 paper."
  echo "	(Default=300)"
  echo ""
  echo "-p             --perserve"
  echo "	Do not delete the TMP folder."
  echo ""
  echo "--invert"
  echo "	Invert the colours of the final image."
  echo ""
  echo "-t \"name\"      --title \"name\""
  echo "	Set the title on the the title page."
  echo ""
  echo "-a \"name\"      --author \"name\""
  echo "        Set an author to the title page."
  echo ""
  echo "--no-header"
  echo "	Do not insert the pandoc header. (Default:"
  echo "$__PANDOC_HEADER"
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


function __sanity_check () {
  # Check that we have the tools needed.
  __find_tool pandoc
  __find_tool xelatex
  __find_tool convert
  __find_tool pdftoppm
  __find_tool pdfcrop

  if [[ $__SANITY == false ]]; then
    echo ""
    echo "Please install the missing tools."
    echo ""
    exit 1
  fi
}

function __main () {
  # FIXME: Split the functionality out of the main function.
  # FIXME: Use mkdtemp instead of the folder we are in.
  __parse_args "${@}"
  __sanity_check
  
  echo "__IN_FILE\: $__IN_FILE"
  echo "__OUT_FILE\: $__OUT_FILE"
  echo "CWD\: $__CWD"
  echo "__DPI: $__DPI"
  
  if [[ ! -e "$__CWD/$__IN_FILE" ]] || [[ -z $__IN_FILE  ]]
  then
    echo "The provided <infile> does not exit."
    echo ""
    exit 1
  fi
  
  # first we create a temp folder.
  mkdir -p "$__CWD/tmp"
  
  #next we want to copy our file into it.
  cp "$__CWD/$__IN_FILE" "$__CWD/tmp/text.txt"
  cd "$__CWD/tmp"
  
  # Now we can start the work for this.
  if [[ $__NO_PANDOC_HEADER == false ]]
  then
    # FIXME: This is cursed.
    # We add a special header to the file to make it pandoc know what to do.
    #
    # The header is built from the bottom up. The input text at the bottom, and
    # the rest of the "elements" added above.
    
    printf '%s\n' "---" "$(cat "$__CWD/tmp/text.txt")" > "$__CWD/tmp/text.txt"
    if [[ ! -z $__TITLE ]]; then
      printf '%s\n' "title: ${__TITLE}" "$(cat "$__CWD/tmp/text.txt")" > "$__CWD/tmp/text.txt"
    fi

    if [[ ! -z $__AUTHOR ]]; then
      printf '%s\n' "author: ${__AUTHOR}" "$(cat "$__CWD/tmp/text.txt")" > "$__CWD/tmp/text.txt"
    fi
    
    printf '%s' "$__PANDOC_HEADER" "$(cat "$__CWD/tmp/text.txt")" > "$__CWD/tmp/text.txt"
    
    printf '%s' "---" "$(cat "$__CWD/tmp/text.txt")" > "$__CWD/tmp/text.txt"
  fi
  
  # Now we use pandoc to do to convert it to a PDF.
  echo "Generating PDF"
  pandoc --pdf-engine=xelatex "$__CWD/tmp/text.txt" -o "$__CWD/tmp/text.pdf"
  echo "Cropping PDF"
  pdfcrop --margins '10 5 10 5' "$__CWD/tmp/text.pdf" "$__CWD/tmp/text-croped.pdf"
  
  # Convert it to images
  echo "Converting to images"
  pdftoppm "$__CWD/tmp/text-croped.pdf" "$__CWD/tmp/page" -png -rx $__DPI -ry $__DPI -gray
  
  # convert make the colour space greyscale and the append to each other
  convert -append -colorspace gray +matte -depth 8 "$__CWD/tmp/page-*.png" "$__CWD/tmp/big-page.png"
  
  FINAL_IMAGE=""
  
  # If we invert the final image this is where we do it.
  if [[ $__INVERT_COLOURS == true ]]
  then
    echo "Inverting colours"
    convert "$__CWD/tmp/big-page.png" -channel RGB -negate "$__CWD/tmp/big-page-inverted.png"
    FINAL_IMAGE="$__CWD/tmp/big-page-inverted.png"
  else
    FINAL_IMAGE="$__CWD/tmp/big-page.png"
  fi
  
  echo "Copying final image to $__CWD/$__OUT_FILE.png"
  cp "$FINAL_IMAGE" "$__CWD/$__OUT_FILE.png"
  
  ####
  # Cleanup of eveything.
  ####
  if [[ $__PERSERVE_TMP == true ]]
  then
    echo "Note: Not cleaning up!"
  else
    rm -r "$__CWD/tmp"
  fi
  echo "Done."
  echo ""
}


function __parse_args () {
  if [[ -z "$1" ]]
  then
    echo "Try --help or -h."
    exit 1
  fi
  
  while [[ $# -gt 0 ]]
  do
    case $1 in
      -i|--input)
        __IN_FILE="$2"
        shift
        shift
      ;;
      -o|--output)
        __OUT_FILE="$2"
        shift
        shift
      ;;
      -t|--title)
        __TITLE="$2"
        shift
        shift
      ;;
      -a|--author)
        __AUTHOR="$2"
        shift
        shift
      ;;
      -d|--dpi)
        __DPI="$2"
        shift
        shift
      ;;
      -p|--perserve)
        __PERSERVE_TMP=true
        shift
      ;;
      --invert)
        __INVERT_COLOURS=true
        shift
      ;;
      --no-header)
        __NO_PANDOC_HEADER=true
        shift
      ;;
      -h|--help)
         __usage
         exit
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

__main "${@}"

