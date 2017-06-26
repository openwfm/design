#!/bin/tcsh
cd ~/cheyenne_test
foreach i (LHS4*_$1?_*)
echo timing: `date` $i start
(cd ~/Projects/wrfxpy; ./process_output.sh $i)
echo timing: `date` $i end
end
