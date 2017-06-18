#!/bin/tcsh 
module load matlab
echo adding diary to run_fasmee_setup_2.log
echo stdout and stderr are in matlab.log
matlab < run_fasmee_setup_2.m >& matlab.log 
