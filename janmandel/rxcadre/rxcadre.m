%k=[kml2struct('../../KML/L2F_Fire1.kml'),kml2struct('../../KML/L2F_Fire2.kml')];save k.mat k
load k.mat

%dom=load_domain('rxcadre-wrfxpy/wrf/wrfout_d04_2012-11-11_15:00:00');save dom.mat dom
load dom.mat

ign=kml2ign(k,dom)

ign=rxcadre_update_ign(ign,dom)

tign_in=make_tign(ign,dom);
%ncreplace('wrfinput_d04','TIGN_G',tign_in)
%save tign.mat tign
fprintf('Minimal ignition time %gs from simulation start\n',min(tign_in(:)))
