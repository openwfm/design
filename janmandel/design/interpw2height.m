function w=interpw2height(p,h)
%  interp2height(p,h)

alt_at_w=(p.ph+p.phb)/9.81; % geopotential altitude at w-points
for k=1:size(alt_at_w,3)    % convert into height above the terrain
    hgt_at_w(:,:,k,:)=alt_at_w(:,:,k,:)-alt_at_w(:,:,1,:);
end
[m,n,k,t]=size(p.w);
for im=m:-1:1
    for in=n:-1:1
        for it=t:-1:1
            h_vec=squeeze(hgt_at_w(im,in,:,it));
            w_vec=squeeze(p.w(im,in,:,it));
            w(im,in,:,it)=interp1(h_vec,w_vec,h);
        end
    end
end
end

function yq=fastinterp1(x,y,xq)
    for i=2:length(x)
        if xq<x(i)
        else
           yq=y(i-1)+(y(i)-y(i-1))*(xq-x(i-1))/(x(i)-x(i-1));
        end
    end
end
            