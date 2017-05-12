function var_at_h=interpw2height(p,var,h,d)
%  wh=interp2height(p,var,h)
%  input:
%   p   structure with fields ph, phb, and the variable, from WRF
%   var string, the name of the variable (4D, the last is timestep)
%   h   height (m or hPa) to interpolate to
%   d   string: 'h' or 'height terrain' height is in m above the terrain
%               'a' or 'altitude sea' height is in m over sea level

alt_at_w=(p.ph+p.phb)/9.81; % geopotential altitude at w-points
switch d
    case {'h','height', 'height terrain','terrain'}
        above='terrain';
        for k=1:size(alt_at_w,3)    % convert into height above the terrain
            hgt_at_w(:,:,k,:)=alt_at_w(:,:,k,:)-alt_at_w(:,:,1,:);
        end
    case {'s','a','altitude','sea','sea level'}
        above='sea level';
        hgt_at_w = alt_at_w;
    otherwise
        d
        error('interpw2height: invalid arg 4')
end
if strcmp(var,'w')
    hgt=hgt_at_w;
    fprintf('Interpolating staggered variable %s to height %im above the %s\n',var,h,above)
else  % assuming given in center
    hgt=0.5*(hgt_at_w(:,:,2:end,:)+hgt_at_w(:,:,1:end-1,:));
    fprintf('interpolating centered variable %s to height %im above the %s\n',var,h,above)
end
[m,n,k,t]=size(p.w);
var_at_h=zeros(m,n,t);
kk=size(hgt,3);
var=p.(var);
for it=1:t
    for in=1:n
        for im=1:m
            if h>hgt(im,in,1,it)
                for k=2:kk
                    x1=hgt(im,in,k,it);
                    if h>x1
                    else
                        y1=var(im,in,k,it);
                        y0=var(im,in,k-1,it);
                        x0=hgt(im,in,k-1,it);
                        var_at_h(im,in,it)=(y0*(x1-h)+y1*(h-x0))/(x1-x0);
                        break
                    end
                end
            else
                var_at_h(im,in,it)=0; % under ground
            end
        end
    end
end
end            
