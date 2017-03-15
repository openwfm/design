function ign=xls2ign(xls)
% ign=xls2ign(xls)
% convert xls file to ignition structure
% in: 
%   xls  file name of xls file with 3 columns:Lot,Lat,time(s)
% out:
%   ign  ignition structure to be used in make_tign

x=xlsread(xls);
n=size(x,1);
for i=1:n
    k.Lon=x(i,1);
    k.Lat=x(i,2);
    k.t = x(i,3);
    k.ros=0.5;
    k.radius=50;
    ign(i)=k;
end