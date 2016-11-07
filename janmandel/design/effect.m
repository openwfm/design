function V=effect(P,Y)
%    effect(P,Y) 
% Evaluating effect of factors
% Input
%   P   matrix size (#parametrs, #sampling points, #repetitions) from rLHS
%       P(i,:,r) are random permutations of the same sample points
%   Y   matrix size (#sampling points, #repetitions) of output values
%       Y(j,k) is the output generated from parameter vector P(:,j,k)
%
% Reference: Andrea Saltelli, Stefano Tarantola, Francesca Campolongo
% and Marco Ratto, Sensitivity Analysis in Practice, John Wiley 2004
% p.134

[L,N,r]=size(P); 

% retrieve the sampling points and check for Latin Hypercube
for l=1:r
    D=sort(P(:,:,l),2);
    if l==1,
        D0=D;
    elseif any(D(:) ~= D0(:)),
        error('P(i,:,r) must be random permutations of the same sample points')
    end
end

% yy(j,i,l) = y(ix,l) such that X(j) is in i-th bin in run ix repetition l
y=zeros(L,N,r);
for l=1:r
    for i=1:N
        for j=1:L
            ix=find(P(j,:,l) == D(j,i));
            y(j,i,l)=Y(ix,l);
        end
    end
end

% cmean(j,i) = mean of y conditional on X(j) in i-th bin
cmean = mean(y,3);
% mean of over i, does not depend on j
yy = mean(cmean,2);
ymean=yy(1);
% variability due to input j
V = mean((cmean-ymean).^2,2);
