function M=play_domain(dom,ign,start,endframe)
nframes=size(dom.sub.fgrnhfx,3);
m.fgrnhfx=max(dom.sub.fgrnhfx(:));
long=dom.fxlong(dom.ii,dom.jj);
lat=dom.fxlat(dom.ii,dom.jj);
start_datenum=datenum(dom.times(1,:));
for i=start:min(endframe,nframes)
    frame_datenum=datenum(dom.times(i,:));
    t_sec = (frame_datenum-start_datenum)*24*3600;
    ttimes=dom.times(i,:)
    tt = strrep(ttimes,'_',' ')
    tstring=sprintf('%5d %s',i,tt)
    figure(1)
    val=dom.sub.fgrnhfx(:,:,i);
    val(val==0)==NaN;
    hp=pcolor(long,lat,val);
    set(hp,'EdgeAlpha',0);
    h=colorbar;
    ylabel(h,'Heat flux (W/m^2)');
    title(tstring)
    M(i-start+1)=getframe(gcf);
    figure(2)
    val=dom.sub.fgrnhfx(:,:,i);
    v=log(val);v(val==0)=NaN;
    mesh(long,lat,v);
    title(tstring)
    figure(3)
    hold off
    mesh(long,lat,dom.sub.lfn(:,:,i));
    hold on
    contour(long,lat,dom.sub.lfn(:,:,i),[0 0],'k');
    title([tstring,' Level set function'])
    hold off
    figure(4)
    h=mesh(long,lat,min(dom.sub.tign_g(:,:,i),t_sec+1));
    set(h,'FaceAlpha',0.5);
    title([tstring,' Fire arrival time'])
    hold on
    contour3(long,lat,dom.sub.tign_g(:,:,i),[t_sec t_sec],'k');
    plot3_ign(ign,t_sec,'r.');
    hold off
    drawnow
    pause(0.1)
end
end

