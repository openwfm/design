function ign_out=rxcadre_update_ignition(ign,dom)
start_times=char(dom.times(1,:));
start_datenum=datenum(start_times);
rxcadre_datenum=datenum(2012,11,11);
fprintf('Simulation start %s\n',datestr(start_datenum));
fprintf('Ignition date    %s\n',datestr(rxcadre_datenum));
ign_out=ign;
for i=1:length(ign)
    h=str2num(ign(i).Name(1:2));
    m=str2num(ign(i).Name(3:4));
    s=str2num(ign(i).Name(5:6));
    % time in s since sim start
    ign_out(i).datenum= rxcadre_datenum + (h*3600+m*60+s)/(24*3600);
    ign_out(i).t=(rxcadre_datenum-start_datenum)*24*3600+h*3600+m*60+s;
    fprintf('Ignition point %5d %s %s from start%6ds Lat%10.5f Lon%10.5f\n',...
         i,ign_out(i).Name, datestr(ign_out(i).datenum),ign_out(i).t,ign_out(i).Lat,ign_out(i).Lon)
end

