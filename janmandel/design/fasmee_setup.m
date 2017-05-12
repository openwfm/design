function out=fasmee_setup(out)
root_dir='/glade/u/home/jmandel/scratch/WRF341F_jm2_devel/wrffire/wrfv2_fire/test'
template_dir=[root_dir,'/Fishlake_template']
wksp_dir = '/glade/u/home/jmandel/Projects/wrfxpy/wksp'

generate=0
clone=1
extract=0
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

for k=1:r
    
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


if extract
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
                p.job_id=job.id;
                if k==1 & i==1,
                    out=nc2struct(f,{'XLONG','XLAT','FXLONG','FXLAT','HGT'},{},1)
                end
                out.p(i,k)=p;
            end
        end
        out.X=X;
        out.P=P;
        out.D=D;
    % end
    save -v7.3 out out
else
    if ~exist('out','var')
        disp('variable out not given, loading from file')
        load out
    end
end % extract

if analysis,
        for k=1:r
            for i=1:N
                fprintf('vertical interpolation replicant %i run %i\n',k,i)
                out.p(i,k).w10=interpw2height(out.p(i,k),'w',10,'terrain');
                out.p(i,k).w20=interpw2height(out.p(i,k),'w',20,'terrain');
                out.p(i,k).smoke10=interpw2height(out.p(i,k),'tr17_1',10,'terrain');
                out.p(i,k).smoke20=interpw2height(out.p(i,k),'tr17_1',20,'terrain');
                out.p(i,k).smoke2500a=interpw2height(out.p(i,k),'tr17_1',2500,'sea');
                out.p(i,k).smoke3000a=interpw2height(out.p(i,k),'tr17_1',3000,'sea');
                out.p(i,k).smoke4000a=interpw2height(out.p(i,k),'tr17_1',4000,'sea');
                out.p(i,k).smoke5000a=interpw2height(out.p(i,k),'tr17_1',5000,'sea');
            end
        end
        out.fgrnhfx=effectnd(X,out.p,'fgrnhfx');
        out.w10=effectnd(X,out.p,'w10');
        out.w20=effectnd(X,out.p,'w20');
        out.smoke10=effectnd(X,out.p,'smoke10');
        out.smoke20=effectnd(X,out.p,'smoke20');
        out.smoke2500a=effectnd(X,out.p,'smoke2500a');
        out.smoke3000a=effectnd(X,out.p,'smoke3000a');
        out.smoke4000a=effectnd(X,out.p,'smoke4000a');
        out.smoke5000a=effectnd(X,out.p,'smoke5000a');
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
