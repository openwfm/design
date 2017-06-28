#!/bin/tcsh -f 
echo usage: $0 'command' 'job name'
set j=$2
echo '#\!/bin/tcsh'  > $j.sh
echo module load matlab >> $j.sh
echo "$1" > $j.m
echo "matlab < $j.m >& $j.log" >> $j.sh
chmod +x $j.sh
ls -l $j.sh 
cat $j.sh
ls -l $j.m 
cat $j.m
bsub -q geyser -n1 -PUCUD0002 -W24:00 -J $j ./$j.sh

