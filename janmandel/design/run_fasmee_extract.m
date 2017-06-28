for timestep=[72,60,84]
out=fasmee_extract([],timestep)
outfile = sprintf('out_%02i.mat',timestep)
fprintf('writing %s\n',outfile')
save(outfile,'out','-v7.3')
shell(['./bsub_rsync.sh ',outfile])
end
exit
