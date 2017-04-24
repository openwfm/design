function V=effect(X,Y)
% V = effect(X,Y) 
% Evaluating effect of parameters
% Input
%   X   matrix of input values (#parameters, #sampling points, #repetitions) from rLHS
%       X(i,:,r) are random permutations of the same sample points
%   Y   matrix size (#sampling points, #repetitions) of output values
%       Y(j,l) is the output generated from parameter vector X(:,j,l)
%
% Reference: Andrea Saltelli, Stefano Tarantola, Francesca Campolongo
% and Marco Ratto, Sensitivity Analysis in Practice, John Wiley 2004
% p. 134
% McKay, p. 24

[L,N,r]=size(X); 
[NN,rr]=size(Y);
if NN~=N | rr~=r,
    error('incompatible dimension')
end

% retrieve the sampling points and check for Latin Hypercube
D0 = sort(X(:,:,1),2);        % sorted lists of sample points
for i=1:L
    for l=1:r, 
        D=sort(X(i,:,l));
        if any(D ~= D0(i,:)),
            error(sprintf('X(%i,:,l) must be permutations of the same sample points',i))
        end
    end
end

% y(i,j,l) = Y(ix,l) such that X(i) is in j-th bin in repetition l
y=zeros(L,N,r);
for i=1:L                   % variable
    for j=1:N               % sample point
        for l=1:r           % repetition
            ix=find(X(i,:,l) == D0(i,j));
            if length(ix) ~= 1,
                error('exactly one point should match')
            end
            y(i,j,l)=Y(ix,l);
        end
    end
end

% cmean(i,j) = mean of y conditional on X(i) in j-th bin
cmean = mean(y,3);
% ymean(i) = mean of X(i)
ymean = mean(cmean,2);
% variability due to input j
V = mean((cmean-ymean*ones(1,N)).^2,2);
V
end
