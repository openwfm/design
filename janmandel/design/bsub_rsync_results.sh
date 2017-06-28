#!/bin/tcsh -f
foreach i (1 2 3 4 5 6 7 8 9 0)
bsub -q caldera -n1 -PUCUD0002 -W24:00 "./rsync_results.sh $i >& rsync_results_$i.log"
end

