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
            %x=squeeze(hgt_at_w(im,in,:,it));
            %y=squeeze(p.w(im,in,:,it));
            for i=2:k
                x1=hgt_at_w(im,in,i,it);
                if h<x1
                else
                    y1=p.w(im,in,i,it);
                    y0=p.w(im,in,i-1,it);
                    x0=hgt_at_w(im,in,i-1,it);
                    w(im,in,it)=y1+(y1-y0)*(h-x0)/(x1-x0);
                    break
                end
            end
        end
    end
end
end            