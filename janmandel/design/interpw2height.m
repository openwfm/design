function w=interpw2height(p,h)
%  interp2height(p,h)

alt_at_w=(p.ph+p.phb)/9.81; % geopotential altitude at w-points
for k=1:size(alt_at_w,3)    % convert into height above the terrain
    hgt_at_w(:,:,k,:)=alt_at_w(:,:,k,:)-alt_at_w(:,:,1,:);
end
[m,n,k,t]=size(p.w);
for im=m:-1:1
    for in=n:-1:1
        for ik=k:-1:1
            xx(im,in,ik)=im;
            yy(im,in,ik)=in;
        end
    end
end
for it=1:t,
    hh = hgt_at_w(:,:,:,it);
    ww = p.w(:,:,:,it);
    F=griddedInterpolant(xx,yy,hh,ww);
    hh = ones(size(xx));
    for ih=1:length(h),
        fprintf('Interpolating W to %g m',h(ih))
        w(:,:,it)=F(xx,yy,hh*h(ih));
    end
end
