ODD=1
for I in out/*.png; do
    if [ $ODD = 0 ] ; then
	echo `echo $I | sed -e 's/\///' -e 's/\.png//'`":"
	./out/copper_fun_generate $I
	echo "        dc.l	\$fffffffe"
	ODD=1

    else
	ODD=0
    fi

done