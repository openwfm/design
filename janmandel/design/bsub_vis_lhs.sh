#!/bin/tcsh
#foreach i (00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20)
foreach i (00)
bsub -q geyser -n1 -PUCUD0002 -W24:00 "./vis_lhs.sh $i >& $i.vis.log"
end

