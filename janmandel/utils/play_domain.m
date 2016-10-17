function play_domain(dom)
nframes=size(dom.sub.fgrnhfx,3);
m.fgrnhfx=max(dom.sub.fgrnhfx(:));
for i=200:nframes
    long=dom.fxlong(dom.ii,dom.jj);
    lat=dom.fxlat(dom.ii,dom.jj);
    figure(1)
    val=dom.sub.fgrnhfx(:,:,i);
    pcolor(long,lat,val);
    figure(1)
    pcolor(long,lat,val);
    h=colorbar;
    ylabel(h,'Heat flux (W/m^2)');
    title(num2str(i))
    figure(2)
    v=log(val);v(val==0)=NaN;
    mesh(long,lat,v);
    figure(3)
    mesh(long,lat,min(dom.sub.lfn(:,:,i),500));
    title('Level set function')
    drawnow
    pause(0.1)
end
end

