function ign_out=process_ignition_points(dom,ign,randomize_xy,randomize_t,clamp)
% ign=process_ignition_points(dom,ign,randomize,clamp)
% arguments:
%    domain - structure with fields
%       coord_x, coord_y x and y coordinates of nodes
%       unit_x, unit_y   unit in x and y coordinates (m)
%
%    ign    - structure with fields
%       x,y    coordinates of ignition point
%       t      time of the ignition point
%       r      radius where ignition will be enforced
%
%    params - structure with fields
%       randomize_xy  stdev of randomization in plane (m)
%       randomize_t   stdev of randomization in time (t) 
%       clamp2mesh    if to return nearest mesh points
%
%    returned:
%    ign_out      - same structure as ign

for k=length(ign.x):-1:1
    ign_out.t(k) = ign.t(k) + randn*params.randomize_t;
    x=ign.x(k);
    y=ign.y(k);
    x=x+randn*params.randomize_xy/dom.unit_x;
    y=x+randn*params.randomize_xy/dom.unit_x;
    if params.clamp2mesh,
         % find the nearest point (lon(i,j),lat(i,j)) to (x,y)
        d = norm([dom.unit_x*(dom.coord_x-x), dom.unit_y*(dom.coord_y-y)]);
        [p,q,minvalue]=find(d==min(d(:)));
        % pick randomly the nearest if more than one
        i=round(0.5+rand*length(p));
        x=coord_x(p(i),q(i));
        y=coord_y(p(i),q(i));
    end
    ign_out.x(i)=x(i);
    ign_out.y(i)=y(i);
end
    
        
    

