function run_fasmee_extract(timestep)
out=fasmee_extract([],timestep)
outfile = sprintf('out_%02i.mat',timestep)
fprintf('writing %s\n',outfile')
save(outfile,'out','-v7.3')
shell(['./bsub_rsync.sh ',outfile])
end
