function tign=make_tign(ign,dom,tign_max)
% tign=make_tign(domain,ign,tign_max)
%
% update ignition points and create ignition time array
% arguments:
%    dom - structure with fields
%       fxlong, fxlat               x and y coordinates of nodes
%       unit_fxlong, unit_fxlong    unit in x and y coordinates (m)
%
%    ign    - structure array ßwith fields
%       ros    ignition rate of spread
%       x,y    coordinates of ignition point
%       t      time of the ignition point
%       r      radius where ignition will be enforced
%
% usage:
% navigate in matlab to fasmee/janmandel and
% startup
% to set up the path. Then
% dom=load_domain(wrfout);
% then
%   % k=kml2struct(kml);ign = kml2ign(k,dom);
% or
%   ign = xls2ign(xls)
% tign=make_tign(ign,dom);
% ncreplace(wrfinput,'TIGN_G',tign);
% when running WRF-SFIRE set number of ignitions to zero and 
% fire_tign_in_time = number in seconds between max ignition time and max ignition time+duration 

duration = 1000;

for k=1:length(ign)
    lon(k)=ign(k).Lon;
    lat(k)=ign(k).Lat;
    t(k)=ign(k).t;
end

fprintf('ignition lon %g : %g\n',min(lon),max(lon));
fprintf('ignition lat %g : %g\n',min(lat),max(lat));
fprintf('domain   lon %g : %g\n',min(dom.fxlong(:)),max(dom.fxlong(:)));
fprintf('domain   lat %g : %g\n',min(dom.fxlat(:)),max(dom.fxlat(:)));
fprintf('time         %g : %g\n',min(t),max(t));

% max pessimistic ignition time
% 
[nx,ny]=size(dom.fxlong);
if ~exist('tign_max'),
    tign_max=max(nx*dom.unit_fxlong,ny*dom.unit_fxlat)/min(cell2mat(({ign.ros})));
end
tign = tign_max*ones(size(dom.fxlong));
for k=1:length(ign)
    % distances from ignition point i
    d=sqrt(((dom.fxlong-ign(k).Lon)*dom.unit_fxlong).^2 + ...
        ((dom.fxlat-ign(k).Lat)*dom.unit_fxlat).^2);
    % ign time be set at distance up to r
    s=(d<=ign(k).radius);
    % fire arrival time from ignition assuming given ros 
    tign(s)=min(tign(s),ign(k).t+d(s)/ign(k).ros);
end 
b=duration+max(t);
[i,j,v]=find(tign<b);
mesh(min(b,tign(min(i):max(i),min(j):max(j))))
end
    
 


