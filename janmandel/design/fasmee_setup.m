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
    
end

save rep P X D N

load rep
for i = 1:N,

    case_id=num2str(P(:,i))'
    job_id = ['Fishlake_',case_id]
    
    nml = fileread('namelist.input.template');
    nml = strrep(nml,'_fire_ext_grnd_',num2str(D(2,i)));
    nml = strrep(nml,'_fire_atm_feedback_',num2str(D(3,i)));
    nml_f =['namelist.input_',case_id];
    filewrite(nml_f,nml)
    
    lsf = fileread('runwrf1.lsf.template');
    lsf = strrep(lsf,'_job_id_',job_id);
    filewrite('runwrf1.lsf',lsf)
    
    job = fileread('job.json.template');
    job = strrep(lsf,'_job_id_',job_id);
    filewrite('job.json',job)
    
    
    wrf_f = ['wrfinput_d05_',case_id];
    system(['/bin/cp -f wrfinput_d05.template ',wrf_f]);
    fmc_gc=ncread(wrf_f,'FMC_GC');
    fmc_gc(:,:,1)=D(1,i)-0.01;
    fmc_gc(:,:,2)=D(1,i);
    fmc_gc(:,:,3)=D(1,i)+0.01;
    fmc_gc(:,:,4)=0.05;
    fmc_gc(:,:,5)=0.78;
    ncreplace(wrf_f,'FMC_GC',fmc_gc);
    
end
