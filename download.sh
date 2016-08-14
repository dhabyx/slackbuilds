#!/bin/sh

# Download script for ffmpeg and its dependencies

# Copyright 2016 Dhaby Xiloj <slack.dhabyx@gmail.com>
# All rights reserved.
#
# Redistribution and use of this script, with or without modification, is
# permitted provided that the following conditions are met:
#
# 1. Redistributions of this script must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
#  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
#  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO
#  EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
#  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
#  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
#  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
#  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
#  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

CWD=$(pwd)
DOWNLOAD_PATH="$CWD/downloads"

set -e

INFO_FILES=$(find . -name '*.info' -not -path "./templates*")

# test if a file exists and if md5sum it's ok
# how to use downloadSources:
#   testSource URL MD5SUM
#     return 'ok' if the sources exists and this pass md5sum check.
#     return 'md5sum' otherwise or 'false' if file doesn't exists
function testSource()
{
  FILE=$(basename $1)
  if [ -f $FILE ]; then
    FILE_MD5SUM=$(md5sum $FILE | cut -d ' ' -f 1)
    if [ $FILE_MD5SUM = $2 ]; then
      echo 'ok'
    else
      echo $FILE_MD5SUM
    fi
  else
    echo 'File not exists'
  fi
}

# downloadSource url and test with md5sum
# how to use:
# downloadSource URL MD5SUM
function downloadSource()
{
  wget $1 || exit 1
  FILE=$(basename $1)
  echo "Check md5sum to $FILE"
  TEST=$(testSource $1 $2)
  if [ $TEST != 'ok' ]; then
    echo "Fail when downloading from $1" 1>&2
    echo "md5sum not match"
    echo " Found: $TEST" 1>&2
    echo " Expected: $2" 1>&2
    exit 1
  else
    echo "md5sum OK"
  fi
}

# make a symbolic link of an FILE in download path
# of an INFOFILE path.
# how to use:
#   makeSymbolicLink INFOFILE FILE
function makeSymbolicLink()
{
  DESTDIR=$(dirname "$CWD/$1")
  find $DESTDIR -type l -exec rm {} \;
  ln -sf $DOWNLOAD_PATH/$2 $DESTDIR/$2
}

if [ ! -d $DOWNLOAD_PATH ]; then
  mkdir $DOWNLOAD_PATH
fi

cd $DOWNLOAD_PATH
for INFO in $INFO_FILES; do
  echo $INFO
  . $CWD/$INFO
  IFS=' ' read -r -a MD5SUM_ARRAY <<< $MD5SUM
  IFS=' ' read -r -a URL_ARRAY <<< $DOWNLOAD
  if [ $URL_ARRAY = "UNSUPPORTED" -a $ARCH = "x86_64" ]; then
    IFS=' ' read -r -a MD5SUM_ARRAY <<< $MD5SUM_x86_64
    IFS=' ' read -r -a URL_ARRAY <<< $DOWNLOAD_x86_64
  fi
  if [ $URL_ARRAY != "DOWNLOAD_LNK_TKN" -a $URL_ARRAY != "UNSUPPORTED" ]; then
    for index in ${!URL_ARRAY[@]}; do
      TEST=$(testSource ${URL_ARRAY[index]} ${MD5SUM_ARRAY[index]})
      FILE=$(basename ${URL_ARRAY[index]})
      if [ "$TEST" != 'ok' ]; then
        echo "Downloading ${URL_ARRAY[index]}"
        downloadSource ${URL_ARRAY[index]} ${MD5SUM_ARRAY[index]}
      else
        echo "md5sum $FILE OK"
      fi
      makeSymbolicLink $INFO $FILE
    done
  fi
done
