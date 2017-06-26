cd ~/cheyenne_test/
bsub -q hpss -n1 -PUCUD0002 -W2:00 htar -cvf LHS4/$1.tar $1/{wrfout*,namelist.input,namelist.fire,wrfinput_d05}

