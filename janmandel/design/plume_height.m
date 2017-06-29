function h=plume_height(p)
% input:
% p structure with 3D fields ph, phb,tr17_1
% output:
% h max altitude (m above the sea) where rt17_1>moke_threshold

% parameter
smoke_threshold = 10;

% altitude from geopotential at w-points
alt_at_w=(p.ph+p.phb)/9.81; 
% altitude at mesh centers
hgt=0.5*(alt_at_w(:,:,2:end)+alt_at_w(:,:,1:end-1)); 

tr = p.tr17_1;
[is,js,ks]=size(tr);

h = zeros(is,js);
for j=1:js
    for i=1:is
          for k=ks:-1:1
               if tr(i,j,k) > smoke_threshold
                   h(i,j) = hgt(i,j,k);
                   break
               end
          end
    end
end
end % plume_height