#!/bin/bash
ODD=1
COUNTER=1
for I in out/*.png; do
    if [ $ODD = 0 ] ; then
	if [ $COUNTER -lt 16 ] ; then
	    ((COUNTER++))
	    echo `echo $I | sed -e 's/\///' -e 's/\.png//'`":"
	    ./out/copper_fun_generate $I
	#mv -f resized.png $I.resized.png
	    echo "        dc.l	\$fffffffe"
	    ODD=1
	fi

    else
	ODD=0
    fi

done