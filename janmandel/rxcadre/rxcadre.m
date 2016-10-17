k=[kml2struct('../../KML/L2F_Fire1.kml'),kml2struct('../../KML/L2F_Fire2.kml')];save k.mat k
load k.mat

%dom=load_domain('wrfout_d04_2016-10-17_00:00:00');save dom.mat dom
load dom.mat

ign=kml2ign(k,dom)

start_times=char(dom.times')
start_datenum=datenum(start_times);
rxcadre_datenum=datenum(2012,11,11);
for i=1:length(ign)
    h=str2num(ign(i).Name(1:2));
    m=str2num(ign(i).Name(3:4));
    s=str2num(ign(i).Name(5:5));
    % time in s since sim start
    ign(i).t=(rxcadre_datenum-start_datenum)*12*3600+h*3600+m*60+s;
end
tign=make_tign(ign,dom);
ncreplace('wrfinput_d04','TIGN_G',tign)