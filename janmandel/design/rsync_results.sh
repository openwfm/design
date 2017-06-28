#!/bin/tcsh -f
cd ~/cheyenne_test
foreach i (LHS4*_??$1_*)
set dir = cheyenne/LHS4/$i
ssh jmbackup "mkdir -p $dir"
echo 'rsync -arvzuP $i/wrfout* jmbackup:$dir/'
rsync -arvzucP $i/wrfout* jmbackup:$dir/
end

