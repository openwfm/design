function dom=load_domain(wrfout)
dom=nc2struct(wrfout,{'FXLONG','FXLAT','UNIT_FXLONG','UNIT_FXLAT'},{},1);