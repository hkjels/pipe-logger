#!/bin/bash

SIZE=$(( 10 * 1024 * 1024 ))
FILES=10
TIME_PREFIX=0

usage() {
  echo "$BASH_SOURCE [-s SIZE[k|m|g]] [-n #FILES] [-t] FILENAME"
}

while getopts "s:n:th" opt; do
  case $opt in
    s )
      SIZE=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
      if [ ${SIZE%k} != $SIZE ]; then
        SIZE=$(( ${SIZE%k} * 1024 ))
      elif [ ${SIZE%m} != $SIZE ]; then
        SIZE=$(( ${SIZE%m} * 1024 * 1024 ))
      elif [ ${SIZE%g} != $SIZE ]; then
        SIZE=$(( ${SIZE%g} * 1024 * 1024 * 1024 ))
      fi
    ;;
    n )
      FILES=$OPTARG
    ;;
    t )
      TIME_PREFIX=1
    ;;
    h )
      usage
      exit 0
  esac
done
shift $(($OPTIND -1))

if [ $# -ne 1 ]; then
  usage
  exit 1
fi
FILE=$1

if [ -f "$FILE" ]; then
  if [ `uname` = 'Darwin' ]; then
    bytes=`stat -f%z "$FILE"`
  else
    bytes=`stat -c%s "$FILE"`
  fi
else
  bytes=0
fi

while read line; do
  # Log formatting
  if [ $TIME_PREFIX -eq 1 ]; then
    line="$(date '+[%Y/%m/%d %H:%M:%S]') $line"
  fi
  line="$line\n"

  # Rotate if required
  bytes=$((bytes + ${#line}))
  if [ $bytes -gt $SIZE ]; then
    for i in `seq $((FILES - 1)) -1 1`; do
      [ -f "$FILE.$i" ] && mv -f "$FILE.$i" "$FILE.$((i + 1))"
    done
    mv -f "$FILE" "$FILE.1"
    bytes=0
  fi

  # Log
  echo -en $line >> "$FILE"
done

