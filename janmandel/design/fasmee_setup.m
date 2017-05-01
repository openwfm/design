N = 5;
[D,logm,logs]=equal_logn(...
              [0.04 0.14         % 10 h moisture
               6,     50         % heat ext depth         fire_ext_grnd
               0.5     2],...     % heat flux multiplier  fire_atm_feedback
               0.1,...           % probability value outside given interval
               N)                % sample points
[X,P]=rLHS(D,1)
for i = 1:N,
    nml = fileread('namelist.input.template');
    nml = strrep(nml,'_fire_ext_grnd_',num2str(D(2,i)));
    nml = strrep(nml,'_fire_atm_feedback_',num2str(D(3,i)));
    nml_f =['namelist.input_',num2str(P(:,i))'];
    filewrite(nml_f,nml)
    case_id=num2str(P(:,i))'
    wrf_f = ['wrfinput_d05_',case_id];
    system(['/bin/cp -f wrfinput_d05.template ',wrf_f]);
    fmc_gc=ncread(wrf_f,'FMC_GC');
    fmc_gc(:,:,1)=D(1,i)-0.01;
    fmc_gc(:,:,2)=D(1,i);
    fmc_gc(:,:,3)=D(1,i)+0.01;
    fmc_gc(:,:,4)=0.05;
    fmc_gc(:,:,5)=0.78;
    ncreplace(wrf_f,'FMC_GC',fmc_gc);
    job = fileread('runwrf1.lsf.template');
    job = strrep(job,'_case_',case_id);
    job_f =['runwrf1.lsf_',case_id];
    filewrite(job_f,job)
end
