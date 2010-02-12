#!/bin/sh

dest=~/Desktop
date=`date '+%Y%m%d'`
name=KTween-$date
arc=$dest/$name.tar.gz

[ -e $name ] && exit 1
[ -d ../bin ] || exit 2
[ -d ../src ] || exit 3

ln -s .. $name
tar zcvf $arc `find $name/bin $name/src $name/docs $name/tests -type f | egrep -v '/\.|\.fla$'`
/bin/rm -f $name
ls -l $arc
