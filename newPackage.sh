#!/bin/bash

# Script helper for make slackbuild directory structure

# Copyright 2015 Dhaby Xiloj <slack.dhabyx@gmail.com>
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

# path to templates dir
CWD=$(pwd)
TMPL_PATH="$CWD/templates"
AUTHOR="Dhaby Xiloj"
YEAR=$(date +%Y)
EMAIL="slack.dhabyx@gmail.com"
COUNTRY=""
ALIAS="DhabyX"

function displayHelp {
cat << EOF 
Usage:
    $0 package_name [template]

    Available templates:
        autotools (default)
        cmake
        python
        perl
        rubygem
EOF
exit
}

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    displayHelp
fi

TMPL_NAME=""

if [ $# -eq 1 ]; then
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        displayHelp
    fi
    TMPL_NAME="autotools"
else
    TMPL_NAME=$2
fi
PKG_NAME=$1

TMPL_FILE="$TMPL_PATH/$TMPL_NAME-template.SlackBuild"

if [ ! -f $TMPL_FILE ]; then
    echo "ERROR: template not found."
    echo
    displayHelp
fi

if [ -d "$CWD/$PKG_NAME" ]; then
    echo "ERROR: $PKG_NAME package directory structure already exists."
    exit
fi

mkdir $CWD/$PKG_NAME

# copy standard files
cp $TMPL_PATH/{doinst.sh,README} \
    $CWD/$PKG_NAME

# edit variables in SlackBuild file
sed "s/\(<appname>\|appname\)/$PKG_NAME/g; \
    s/<year>/$YEAR/; s/<you>/$AUTHOR/; \
    s/<where you live>/<$EMAIL>/" \
    $TMPL_FILE > $CWD/$PKG_NAME/$PKG_NAME.SlackBuild

# edit and clean slack-desc file
head -"$[$(awk '/appname/{ print NR; exit }' $TMPL_PATH/slack-desc)+1]" \
    $TMPL_PATH/slack-desc | sed "s/appname/$PKG_NAME/g" > $CWD/$PKG_NAME/slack-desc
for i in {1..9}; do
    tail -1 $CWD/$PKG_NAME/slack-desc >> $CWD/$PKG_NAME/slack-desc
done

cat $TMPL_PATH/template.info | \
    sed 's/".*"/""/' | \
    sed 's/MAINTAINER=""/MAINTEINER="'$ALIAS'"/' | \
    sed 's/EMAIL=""/EMAIL="'$EMAIL'"/' | \
    sed 's/PRGNAM=""/PRGNAM="'$PKG_NAME'"/' > $CWD/$PKG_NAME/$PKG_NAME.info
