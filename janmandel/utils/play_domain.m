function movies=play_domain(dom,ign,varargin)
% movies=play_domain(dom,ign[,startframe,endframe,box])

nframes=size(dom.sub.fgrnhfx,3);
m.fgrnhfx=max(dom.sub.fgrnhfx(:));
long=dom.fxlong(dom.ii,dom.jj);
lat=dom.fxlat(dom.ii,dom.jj);

opt=length(varargin);
if opt>=1,
    startframe=varargin{1};
else
    startframe=1;
end
if opt>=2,
    endframe=varargin{2};
else
    endframe=nframes;
end
if opt>=3,
    box=varargin{3};
else
    box=[min(long(:)),max(long(:)),min(lat(:)),max(lat(:))];
end
ispan=find(long(:,1)>= box(1) & long(:,1)<=box(2));    
jspan=find(lat(1,:)>= box(3) & lat(1,:)<=box(4));    

start_datenum=datenum(dom.times(1,:));
for i=startframe:min(endframe,nframes)

    hold off    
    frame_datenum=datenum(dom.times(i,:));
    t_sec = (frame_datenum-start_datenum)*24*3600;
    ttimes=dom.times(i,:)
    tt = strrep(ttimes,'_',' ')
    tstring=sprintf('%5d %s',i,tt)
    
    figure(1)
    val=dom.sub.fgrnhfx(:,:,i);
    val(val==0)==NaN;
    hp=pcolor(long(ispan,jspan),lat(ispan,jspan),val(ispan,jspan));
    set(hp,'EdgeAlpha',0);
    h=colorbar;
    ylabel(h,'Heat flux (W/m^2)');
    title(tstring)
    M1(i-startframe+1)=getframe(gcf);
    
    figure(2)
    val=dom.sub.fgrnhfx(:,:,i);
    v=log(val);v(val==0)=NaN;
    mesh(long(ispan,jspan),lat(ispan,jspan),v(ispan,jspan));
    title([tstring, 'Fire heat flux'])
    M2(i-startframe+1)=getframe(gcf);
    
    figure(3)
    val=dom.sub.lfn(:,:,i);
    mesh(long(ispan,jspan),lat(ispan,jspan),val(ispan,jspan));
    hold on
    contour(long(ispan,jspan),lat(ispan,jspan),val(ispan,jspan),[0 0],'k');
    title([tstring,' Level set function'])
    hold off
    M3(i-startframe+1)=getframe(gcf);
    
    figure(4)
    val=min(dom.sub.tign_g(:,:,i),t_sec+1);
    h=mesh(long(ispan,jspan),lat(ispan,jspan),val(ispan,jspan));
    set(h,'FaceAlpha',0.5);
    title([tstring,' Fire arrival time'])
    hold on
    contour3(long(ispan,jspan),lat(ispan,jspan),val(ispan,jspan),[t_sec t_sec],'k');
    plot3_ign(ign,t_sec,'r.');
    hold off
    M4(i-startframe+1)=getframe(gcf);

    drawnow
    pause(0.1)
end

movies={M1,M2,M3,M4};
end

