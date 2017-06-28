#!/bin/tcsh -f
cd ~/cheyenne_test
foreach i (LHS4*_??$1_*)
set dir = cheyenne/LHS4/$i
echo copying $dir
ssh jmbackup "mkdir -p $dir"
echo 'rsync -arvzcP $i/wrfout* jmbackup:$dir/'
rsync -arvzcP $i/wrfout* jmbackup:$dir/
end

