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
            
            x=squeeze(hgt_at_w(im,in,:,it));
            y=squeeze(p.w(im,in,:,it));
            %for i=2:k
            %    if h<x(i)
            %    else
            %        yq=y(i-1)+(y(i)-y(i-1))*(h-x(i-1))/(x(i)-x(i-1));
            %        break
            %    end
            %end
            w(im,in,it)=fastinterp1(x,y,h);
        end
    end
end
end

function yq=fastinterp1(x,y,xq)
    for i=2:length(x)
        if xq<x(i)
        else
           yq=y(i-1)+(y(i)-y(i-1))*(xq-x(i-1))/(x(i)-x(i-1));
           break
        end
    end
end
            