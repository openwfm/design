function var_at_h=interpw2height(p,var,h)
%  wh=interp2height(p,h)

alt_at_w=(p.ph+p.phb)/9.81; % geopotential altitude at w-points
for k=1:size(alt_at_w,3)    % convert into height above the terrain
    hgt_at_w(:,:,k,:)=alt_at_w(:,:,k,:)-alt_at_w(:,:,1,:);
end
if strcmp(var,'w')
    hgt=hgt_at_w(:,:,:,:);
    fprintf('interpolating staggered variable %s to height %im\n',var,h)
else  % assuming given in center
    hgt=0.5*(hgt_at_w(:,:,2:end,:)+hgt_at_w(:,:,1:end-1,:));
    fprintf('interpolating centered variable %s to height %im\n',var,h)
end
[m,n,k,t]=size(p.w);
var_at_h=zeros(m,n,t);
kk=size(hgt,3);
var=p.(var);
for it=1:t
    for in=1:n
        for im=1:m
            %x=squeeze(hgt_at_w(im,in,:,it));
            %y=squeeze(p.w(im,in,:,it));
            for i=2:kk
                x1=hgt(im,in,i,it);
                if h<x1
                else
                    y1=var(im,in,i,it);
                    y0=var(im,in,i-1,it);
                    x0=hgt(im,in,i-1,it);
                    var_at_h(im,in,it)=y1+(y1-y0)*(h-x0)/(x1-x0);
                    break
                end
            end
        end
    end
end
end            
