root_dir='/glade/u/home/jmandel/scratch/WRF341F_jm2_devel/wrffire/wrfv2_fire/test'
template_dir=[root,'/Fishlake_template']
wksp_dir = '/glade/u/home/jmandel/Projects/wrfxpy/wksp'

generate=0
if generate 
    N = 5;
    [D,logm,logs]=equal_logn(...
              [0.04 0.14         % 10 h moisture
               6,     50         % heat ext depth         fire_ext_grnd
               0.5     2],...     % heat flux multiplier  fire_atm_feedback
               0.1,...           % probability value outside given interval
               N)                % sample points
    [X,P]=rLHS(D,1)

save rep P X D N
    
end


load rep
for i = 1:N,

    case_id=num2str(P(:,i))';
    job_id = ['Fishlake_',case_id]
    
    job_dir = [wksp_dir,'/',job_id]
    wrf_dir = [root_dir,'/',job_id]  % where wrf will run

    shell(['mkdir ',job_dir])
    shell(['cp -a ',template_dir,' ',wrf_dir])
    shell(['ln -s ',job_dir,'/wrf ',wrf_dir])

    nml = fileread([wrf_dir,'/namelist.input.template']);
    nml = strrep(nml,'_fire_ext_grnd_',num2str(D(2,i)));
    nml = strrep(nml,'_fire_atm_feedback_',num2str(D(3,i)));
    filewrite([wrf_dir,'/namelist.input'],nml)
    
    lsf = fileread([wrf_dir,'/runwrf1.lsf.template']);
    lsf = strrep(lsf,'_job_id_',job_id);
    filewrite([wrf_dir,'/runwrf1.lsf'],lsf)
    
    job = fileread([wrf_dir,'/job.json.template']);
    job = strrep(job,'_job_id_',job_id);
    filewrite([job_dir,'/job.json'],job)
    
    
    wrf_f = [wrf_dir,'/wrfinput_d05'];
    fmc_gc=ncread(wrf_f,'FMC_GC');
    fmc_gc(:,:,1)=D(1,i)-0.01;
    fmc_gc(:,:,2)=D(1,i);
    fmc_gc(:,:,3)=D(1,i)+0.01;
    fmc_gc(:,:,4)=0.05;
    fmc_gc(:,:,5)=0.78;
    ncreplace(wrf_f,'FMC_GC',fmc_gc);
    
end
