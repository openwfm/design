function plot3_ign(ign,t_sec,mark)
    Lon=[ign.Lon];
    Lat=[ign.Lat];
    t=[ign.t];
    ix=find(t<=t_sec);
    fprintf('plot3_ign: %d ignited points\n',length(ix))
    plot3(Lon(ix),Lat(ix),t(ix),mark)
end
