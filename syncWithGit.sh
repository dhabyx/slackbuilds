#!/bin/sh

GITREPO=${GITREPO:-"../github-slackbuilds"}

if [ "$1" = "" -o "$2" = "" ]; then
  echo "Usage: $0 SOURCE DEST_CATEGORY"
  echo "       this makes a cp DEST_CATEGORY/SOURCE SOURCE"
  echo " "
  echo "  USE: $0 --diff SOURCE DEST_CATEGORY"
  echo "       this makes a diff between SOURCE and DEST_CATEGORY/SOURCE"
  echo "  USE: $0 --reverse SOURCE DEST_CATEGORY"
  echo "       this makes a cp from DEST_CATEGORY/SOURCE to SOURCE"
  echo ""
  exit
fi

if [ $1 = "--diff" ]; then
  if [ "$3" = "" ]; then
    echo "USE: $0 --diff SOURCE DEST_CATEGORY"
    exit
  fi
  GITREPO=$GITREPO/$3/$(basename $2)
  if [ -d $GITREPO ]; then
    git diff $(basename $2) $GITREPO
  else
    echo "$GITREPO does not exist"
  fi
  exit
elif [[ "$1" = "--reverse" ]]; then
  GITREPO=$GITREPO/$3/$(basename $2)
  SOURCE=$(basename $2)
  if [ -d $GITREPO ]; then
    for FILE in $GITREPO/* ; do
      BASENAME=$(basename $FILE)
      if [ -e $SOURCE/$BASENAME ]; then
       cp -v $GITREPO/$BASENAME $SOURCE/$BASENAME
      else
        echo "$BASENAME not found in GITREPO"
      fi
    done
    exit
  else
    echo "$GITREPO does not exist"
    exit
  fi
elif [[ "$1" = "-"* ]]; then
  echo "USE: $0 --diff SOURCE DEST_CATEGORY"
  exit
fi


SOURCE=$(basename $1)

GITREPOPATH=$GITREPO/$2/$SOURCE

if [ ! -d $GITREPOPATH ]; then
  echo "$GITREPOPATH directory does not exist"
  exit
fi

(
  cd $GITREPO
  git checkout master
  git branch
  git checkout -B $SOURCE || exit
)

for FILE in $GITREPOPATH/* ; do
  BASENAME=$(basename $FILE)
  if [ -e $SOURCE/$BASENAME ]; then
    echo  "cp $GITREPOPATH/$BASENAME $SOURCE/$BASENAME"
    cp $GITREPOPATH/$BASENAME $SOURCE/$BASENAME 
  else
    echo "$BASENAME not found in SOURCE"
  fi
done

for FILE in $SOURCE/* ; do
  BASENAME=$(basename $FILE)
  if [ -h $FILE ]; then
    echo "SKIP $BASENAME"
  else
    if [ ! -e $GITREPOPATH/$BASENAME ] ; then
      echo  "WARNING: $BASENAME not found in GITREPOPATH"
    fi
  fi
done
