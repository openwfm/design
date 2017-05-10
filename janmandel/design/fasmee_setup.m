function out=fasmee_setup
root_dir='/glade/u/home/jmandel/scratch/WRF341F_jm2_devel/wrffire/wrfv2_fire/test'
template_dir=[root_dir,'/Fishlake_template']
wksp_dir = '/glade/u/home/jmandel/Projects/wrfxpy/wksp'

generate=0
clone=1
analysis=1


if generate == 1
    N = 5;
    P=rLHS(D,1)

save rep1 P D N

else

load rep1
    
end

if generate==2,
    for k=2:r
        P(:,:,k)=rLHS(D,1);
    end
    save rep2 P D N
else
    load rep2
end


if clone

[D,logm,logs]=equal_logn(...
              [0.05 0.14         % 10 h moisture
               6,     50         % heat ext depth         fire_ext_grnd
               0.5    2],...  % heat flux multiplier  fire_atm_feedback
               0.1,...           % probability value outside given interval
               N)                % sample points

%0P =[1;1;5]

r=5
P=P(:,:,1:r)

[L,N,r]=size(P);

X = get_params_vec(P,D);

for k=2:r
    
    for i = 1:N,

    job_id = get_job_id(P,i,k);
    
    fmc_gc_10h = X(1,i,k);
    fire_ext_grnd = X(2,i,k);
    fire_atm_feedback=X(3,i,k);
    description = sprintf('%s fmc_gc_10h=%g fire_ext_grnd=%g fire_atm_feedback=%g',...
        job_id,fmc_gc_10h,fire_ext_grnd,fire_atm_feedback);
    disp(description)

    if clone > 1
    job_dir = [wksp_dir,'/',job_id]
    wrf_dir = [root_dir,'/',job_id]  % where wrf will run

    shell(['/bin/rm -rf ',job_dir])
    shell(['mkdir ',job_dir])
    shell(['/bin/rm -rf ',wrf_dir])
    shell(['cp -a ',template_dir,' ',wrf_dir])
    shell(['ln -s ',wrf_dir,' ',job_dir,'/wrf '])

    nml = fileread([wrf_dir,'/namelist.input.template']);
    nml = strrep(nml,'_fire_ext_grnd_',num2str(fire_ext_grnd));
    nml = strrep(nml,'_fire_atm_feedback_',num2str(fire_atm_feedback));
    filewrite([wrf_dir,'/namelist.input'],nml)
    
    lsf = fileread([wrf_dir,'/runwrf1.lsf.template']);
    lsf = strrep(lsf,'_job_id_',job_id);
    filewrite([wrf_dir,'/runwrf1.lsf'],lsf)
    
    job = fileread([wrf_dir,'/job.json.template']);
    job = strrep(job,'_description_',description);
    job = strrep(job,'_job_id_',job_id);
    filewrite([job_dir,'/job.json'],job)
    
    wrf_f = [wrf_dir,'/wrfinput_d05'];
    fmc_gc=ncread(wrf_f,'FMC_GC');
    fmc_gc(:,:,1)=fmc_gc_10h-0.01;
    fmc_gc(:,:,2)=fmc_gc_10h;
    fmc_gc(:,:,3)=fmc_gc_10h+0.01;
    fmc_gc(:,:,4)=0.05;
    fmc_gc(:,:,5)=0.78;
    ncreplace(wrf_f,'FMC_GC',fmc_gc);
    end
    
end  % for i
end  % for k
end  % clone


if analysis == 1
    wrfout = 'wrfout_d05_2014-09-03_16:30:01'
    X=get_params_vec(P,D);
    % for ts=1
        for k=1:r
            for i=1:N
                job_id = get_job_id(P,i,k);
                fprintf('replicant %03i vector %i job_id %s\n',k,i,job_id)
                job_id = get_job_id(P,i,k)
                f = [wksp_dir,'/',job_id,'/wrf/',wrfout];  % where wrf will run
                p=nc2struct(f,{'FGRNHFX','W','PH','PHB','tr17_1'},{})
                fgrnhfx(:,i,k)=p.fgrnhfx(:);
                p.w10=interpw2height(p,'w',10);
                w10(:,i,k)=p.w10(:);
                p.w20=interpw2height(p,'w',20);
                w20(:,i,k)=p.w20(:);
                p.smoke10=interpw2height(p,'tr17_1',10);
                smoke10(:,i,k)=p.smoke10(:);
                p.smoke20=interpw2height(p,'tr17_1',20);
                smoke20(:,i,k)=p.smoke20(:);
                if k==1 & i==1,
                    out=nc2struct(f,{'XLONG','XLAT','FXLONG','FXLAT','HGT'},{},1)
                end
            end
        end
        out.p(i,k)=p;
        fgrnhfx_var=effect(X,fgrnhfx);
        out.fgrnhfx_var=reshape(fgrnhfx_var,[size(p.fgrnhfx),L]);     
        w10_var=effect(X,w10);
        out.w10_var=reshape(w10_var,[size(p.w10),L]);     
        w20_var=effect(X,w20);
        out.w20_var=reshape(w20_var,[size(p.w20),L]);
        smoke10_var=effect(X,smoke10);
        out.smoke10_var=reshape(smoke10_var,[size(p.smoke10),L]);
        smoke20_var=effect(X,smoke20);
        out.smoke20_var=reshape(smoke20_var,[size(p.smoke20),L]);
        out.X=X;
        out.P=P;
        out.D=D;
    % end
    
end % analysis

end  % function fasmee_setup

function job_id = get_job_id(P,i,k)
    case_id=sprintf('%03i_%s',k,num2str(P(:,i,k))');
    job_id = ['LHS3_Fishlake_',case_id];
end

function X = get_params_vec(P,D)
[L,N,r]=size(P)
    for k=1:r
        for j=1:L
            pp=P(j,:,k);
            X(j,:,k)=D(j,pp);
        end
    end
end 
