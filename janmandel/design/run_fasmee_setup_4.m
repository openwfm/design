date
for timestep=48:-1:41,
t=tic
out=fasmee_setup_4([],timestep)
date
toc(t)
outfile = sprintf('out_%02i.mat',timestep)

fprintf('writing %s\n',outfile')
save(outfile,'out','-v7.3')
date
toc(t)

%shell(['scp ',outfile,' jmbackup:cheyenne/LHS4])
%date
%toc(t)
end
exit
