function v=effectnd(X,p,f)
% v_var=effectnd(X,p,f)
% compute 1st order effect for values in nd array
% in:
%   X  the rLHS sampling points (#parameters, #sampling points, #replicants)
%   p  structure array (#sampling points, #replicants) with field f 
%   f  field of p, nd-array, each entry processed independently
% out:
%   v structture with fields
%      v.var  (like f, #parameters) variance of point value due to parameter
%      v.avg  average of p.f over sampling points and replicants

    [L,N,r]=size(X);
    fprintf('effect on %s\n',f)
    vv=zeros(1,N,r);
    for k=1:r
        for i=1:N
            ff(:,i,k)=p(i,k).(f)(:);
        end
    end
    [v.eff,v.mean,v.var]=effect(X,ff);
    v.eff=reshape(v.eff,[size(p(1,1).(f)),L]);
    v.mean=reshape(v.mean,size(p(1,1).(f)));
    v.var=reshape(v.var,size(p(1,1).(f)));
end    
