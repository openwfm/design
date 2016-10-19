function ign=kml2ign(k,dom)
% tign=kml2tign(k,dom)
% build list of igniton points
%
% input: 
%    k   KML structure array as produced by kml2struct. Fields used:
%           Geometry   if not 'Point', ignored
%           Name       the ignition points will be sorted by this
%           Lon        longitude
%           Lat        latiude
%           
%    dom domain structure 
%           as read by load_dom
%
% returns:
%     ign structure array of ignition points and times
%         contains entries from array k with added fields:
%           t          igntion time
%           ros        rate of spread
%           radius     radius of initial ignition 
%
%    
% usage:
%
% k=kml2struct(kml);
% dom=load_dom(wrfout);
% ign = kml2ign(k,dom);
% tign=make_tign(ign,dom);
% ncreplace(wrfinput,tign);

% extract ignition points from the KML
ign=[];
for i=1:length(k),
    if strcmp(k(i).Geometry,'Point'),
        ign=[ign,k(i)];
    end
end
% sort by Name
for i=1:length(ign)
    n(i)=str2num(ign(i).Name);
end
[nn,ii]=sort(n);

% add ROS and ignition radius
ign=ign(ii);
for i=1:length(ign)
    ign(i).ros=0.5;
    ign(i).radius=50;
end

% starting igntion time
ign(1).t=500;
speed=10;
for i=2:length(ign)
    d=point_dist(ign(i-1),ign(i),dom);
    ign(i).t=ign(i-1).t+d/speed;
end
end

