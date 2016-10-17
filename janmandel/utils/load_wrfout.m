function dom=load_wrfout(search,base)
% dom=load_wrfout(search)
% dom=load_wrfout(search,base)
if ~exist('base','var')
    base='.';
end
path=fullfile(base,search);
fprintf('Searching for %s\n',path)
f=dir(path);
nfiles = length(f);
if ~nfiles>0,
    error('No files found')
end
vars={'LFN','FGRNHFX','TIGN_G','FIRE_AREA'};
% get numbers of timesteps
tsteps=zeros(1,nfiles);
for i=1:nfiles
    file{i}=fullfile(base,f(i).name);
    p=ncdump(file{i},'-q');
    for j=1:length(p)
        if strcmp(p(j).varname,vars{1})
             tsteps(i)=p(j).dimlength(3);
        end
    end
    if tsteps(i)==0,
        error(['Variable ',vars{1},' not found.'])
    end
end
fprintf('Times steps: '),disp(tsteps)
fprintf('Cumulative: '),disp(cumsum(tsteps))
tstart=[1,1+cumsum(tsteps)];

dom=load_domain(file{nfiles});
p = nc2struct(file{nfiles},{'FIRE_AREA'},{},tsteps(nfiles));
[isize,jsize]=size(p.fire_area);
[i,j,v]=find(p.fire_area);
istart = max(1,min(i)-5);
iend   = min(isize,max(i)+5);
jstart = max(1,min(j)-5);
jend   = min(jsize,max(j)+5);
fprintf('Interested in indices [ %d : %d ] x [%d: %d]\n',istart,iend,jstart,jend)
for j=1:length(vars),
    lvars{j}=lower(vars{j});
    s.(lvars{j})=zeros(iend-istart+1,jend-jstart+1,tstart(nfiles+1)-1);
end    
for i=1:nfiles
    start=[istart-1,jstart-1,0];
    count=[iend-istart+1,jend-jstart+1,tsteps(i)];
    for j=1:length(vars),
        fprintf('Reading slice of %s from file %d %s\n',vars{j},i,file{i})
        p=ncvar(file{i},vars{j},start,count);
        s.(lvars{j})(:,:,tstart(i):tstart(i+1)-1)=p.var_value;
    end
end
dom.sub=s;
dom.ii=[istart:iend];
dom.jj=[jstart:jend];

    

