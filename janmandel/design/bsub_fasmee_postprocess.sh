#!/bin/tcsh -f
set i=$1
./bsub_matlab_line.sh "run_fasmee_extract($i), run_fasmee_setup_4($i)" fasmee$i
