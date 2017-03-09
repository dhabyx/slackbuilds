#!/bin/sh

CWD=$(pwd)
OUTPUT=${OUTPUT:-"$CWD/.."}

CATEGORIES="SBoCategory"

if [[ $1 = '' ]]; then
  echo "Usage: $0 <package directory>"
  exit
fi

PKGDIR=$(basename $1)

if [[ -d $PKGDIR ]]; then
  OUTPUT_TAR="$OUTPUT/$PKGDIR.tar.bz2"
  rm -f $OUTPUT_TAR
  find $PKGDIR -type f -not -name "*~" -and -not -name ".*" -print0 | \
      tar -cvjf $OUTPUT_TAR --null -T -
  echo "Tarball saved on: $OUTPUT_TAR"
  MD5SUM=$(md5sum $OUTPUT_TAR | cut -f 1 -d ' ')
  echo "MD5SUM: $MD5SUM"
  CATEGORY=$(grep --color=auto $PKGDIR $CATEGORIES)
  echo "SBo category: $CATEGORY"
else
  echo "$PKGDIR directory not found"
fi
