#!/bin/sh

dest=~/Desktop
date=`date '+%Y%m%d%H'`
name=KTween-$date
arc=$dest/$name.tar.gz

[ -e $name ] && exit 1

ln -s .. $name
tar zcvf $arc `find $name/bin $name/src $name/docs $name/tests -type f | egrep -v '/\.|\.fla$'`
/bin/rm -f $name
ls -l $arc
