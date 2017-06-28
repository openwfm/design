date
for timestep=12,
out=fasmee_setup_4([],timestep)
outfile = sprintf('out_%02i.mat',timestep)
fprintf('writing %s\n',outfile')
save(outfile,'out','-v7.3')
shell(['rsync -arvuP ',outfile,' jmbackup:cheyenne/LHS4'])
end
exit
