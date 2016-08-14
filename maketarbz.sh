#!/bin/sh

OUTPUT=${OUTPUT:-"../"}

if [[ $1 = '' ]]; then
  echo "Usage: $0 <package directory>"
  exit
fi

find $1 -type f -not -name "*~" -and -not -name ".*" -print0 | \
    tar -cvjf $OUTPUT/$1.tar.bz2 --null -T -
