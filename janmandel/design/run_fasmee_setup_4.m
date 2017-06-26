diary fasmee_setup_4.log
date
for timestep=1:48,
t=tic
out=fasmee_setup_4([],timestep)
date
toc(t)
outfile = sprintf('out_%02i.mat',timestep)
save(outfile,'out','-v7.3')
shell(['scp -q ',outfile,' jmbackup:cheyenne/LHS4 >& ',outfile,'.scp.log &'])
date
toc(t)
end
exit
