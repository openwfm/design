function wh=interpw2height(p,h)
%  wh=interp2height(p,h)

alt_at_w=(p.ph+p.phb)/9.81; % geopotential altitude at w-points
for k=1:size(alt_at_w,3)    % convert into height above the terrain
    hgt_at_w(:,:,k,:)=alt_at_w(:,:,k,:)-alt_at_w(:,:,1,:);
end
[m,n,k,t]=size(p.w);
wh=zeros(m,n,t);
for it=1:t
    for in=1:n
        for im=1:m
            %x=squeeze(hgt_at_w(im,in,:,it));
            %y=squeeze(p.w(im,in,:,it));
            for i=2:k
                x1=hgt_at_w(im,in,i,it);
                if h<x1
                else
                    y1=p.w(im,in,i,it);
                    y0=p.w(im,in,i-1,it);
                    x0=hgt_at_w(im,in,i-1,it);
                    wh(im,in,it)=y1+(y1-y0)*(h-x0)/(x1-x0);
                    break
                end
            end
        end
    end
end
end            