function run_fasmee_setup_4(timestep)
infile = sprintf('out_%02i.mat',timestep)
load(infile)
out=fasmee_setup_4(out,timestep)
outfile = sprintf('out_nop_%02i.mat',timestep)
out.p=[]
save(outfile,'out','-v7.3')
shell(['rsync -arvuP ',outfile,' jmbackup:cheyenne/LHS4'])
end
