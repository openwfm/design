function out=fasmee_setup(out)
format compact
root_dir='/glade2/scratch2/jmandel/wrf-fire_cheyenne/wrfv2_fire/test'
case_dir='/glade2/scratch2/jmandel/wrf-fire_cheyenne/wrfv2_fire/test'
template_dir = '/glade/p/work/jmandel/fasmee.git/janmandel/design/templates'
wksp_dir = '/glade/u/home/jmandel/Projects/wrfxpy/wksp'
template='_Fishlake_5d';

generate=0
clone=2
extract=0
analysis=0

r=1
rmax=100
N=5
case_names={
'Fishlake_5d_09032014',
'Fishlake_5d_09112016',
'Fishlake_5d_09222012',
'Fishlake_5d_09262015',
'Fishlake_5d_09272015',
}

if generate,

[D,logm,logs]=equal_logn(...
              [0.04 0.14         % 10 h moisture
               6,     50         % heat ext depth         fire_ext_grnd
               0.5    2          % heat flux multiplier  fire_atm_feedback
               0.5    2          % adjr0
               0.5    2          % ajdw
               0.5    2          % adjs
               ],0.1,...         % probabreility value outside given interval
               N) ;              % sample points

D = [D; 1:N]  % add line for the choice of days - case

    for k=1:rmax
        P(:,:,k)=rLHS(D,1);
    end
    save rep2_2 P D N
else
    load rep2_2
end

if clone


P=P(:,:,1:r)

[L,N,r]=size(P);

X = get_params_vec(P,D);

for k=1:r
    
    for i = 1:N,

    job_id = get_job_id(P,i,k);
    
    fmc_gc_10h = X(1,i,k);
    fire_ext_grnd = X(2,i,k);
    fire_atm_feedback=X(3,i,k);
    adjr0 = X(4,i,k)
    adjrw = X(5,i,k)
    adjrs = X(6,i,k)
    case_num = X(7,i,k)
    case_name = case_names{case_num}
    if case_num ~= P(7,i,k), error('bad case_num'),end
    description = job_id;
    disp(description)

    if clone > 1
    job_dir = [wksp_dir,'/',job_id]
    wrf_dir = [root_dir,'/',job_id]  % where wrf will run

    shell(['/bin/rm -rf ',job_dir])
    shell(['mkdir ',job_dir])
    shell(['/bin/rm -rf ',wrf_dir])
    from_dir=[case_dir,'/',case_name]
    shell(['cp -a ',from_dir,' ',wrf_dir])
    shell(['ln -s ',wrf_dir,' ',job_dir,'/wrf '])

    nml = fileread([template_dir,'/namelist.input_',case_name]);
    nml = strrep(nml,'__fire_ext_grnd__',num2str(fire_ext_grnd));
    nml = strrep(nml,'__fire_atm_feedback__',num2str(fire_atm_feedback));
    filewrite([wrf_dir,'/namelist.input'],nml)
    
    nml = fileread([template_dir,'/namelist.fire',template]);
    nml = strrep(nml,'__adjr0__',num2str(adjr0));
    nml = strrep(nml,'__adjrw__',num2str(adjrw));
    nml = strrep(nml,'__adjrs__',num2str(adjrs));
    filewrite([wrf_dir,'/namelist.fire'],nml)
    
    lsf = fileread([template_dir,'/runwrf_cheyenne.pbs',template]);
    lsf = strrep(lsf,'__job_id__',job_id);
    filewrite([wrf_dir,'/runwrf_cheyenne.pbs'],lsf)
    
    job = fileread([template_dir,'/job.json',template]);
    job = strrep(job,'__description__',description);
    job = strrep(job,'__job_id__',job_id);
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
end % extract

if analysis,
    if ~exist('out','var')
        disp('variable out not given, loading from file')
        load out
    end
        out.fgrnhfx=effectnd(X,out.p,'fgrnhfx');
        for h=[5,10,20,30]  % height above the terrain
            w=['w',num2str(h)];
            s=['smoke',num2str(h)];
            for k=1:r
                for i=1:N
                    out.p(i,k).(w)=interpw2height(out.p(i,k),'w',h,'terrain');
                    out.p(i,k).(s)=interpw2height(out.p(i,k),'tr17_1',h,'terrain');
                end
            end
            out.(w)=effectnd(X,out.p,w);
            out.(s)=effectnd(X,out.p,s);
        end
        for h=[2000:500:5000];   % altitude above the sea level
            w=['w',num2str(h),'a'];
            s=['smoke',num2str(h),'a'];
            for k=1:r
                for i=1:N
                    out.p(i,k).(w)=interpw2height(out.p(i,k),'w',h,'sea');
                    out.p(i,k).(s)=interpw2height(out.p(i,k),'tr17_1',h,'sea');
                end
            end
            out.(w)=effectnd(X,out.p,w);
            out.(s)=effectnd(X,out.p,s);
        end
end % analysis


function job_id = get_job_id(P,i,k)
    case_id=sprintf('%03i_%s',k,num2str(P(:,i,k))');
    job_id = sprintf('LHS4_%s_%s',case_names{P(7,i,k)},case_id);
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
end  % function fasmee_setup
