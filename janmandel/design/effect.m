function [varargout]=effect(X,Y)
% V = effect(X,Y)
% [V,ymean] = effect(X,Y)
% [V,ymean,yvar] = effect(X,Y)
% [V,ymean,yvar,eff] = effect(X,Y)
%
% Evaluating effect of parameters from repeated Latin Hypercube Sampling
%
% Input
%   X   matrix of input values (#parameters, #sampling points, #repetitions) from rLHS
%       X(i,:,r) are random permutations of the same sample points
%   Y   matrix size (#instances,#sampling points, #repetitions) of output values
%       Y(:,j,l) is the output generated from parameter vector X(:,j,l)
%
% Output
%   V           V(:,i) is the variance in Y due to parameter i 
%   ymean       mean of Y over all inputs
%   yvar        variance of Y over all inputs
%               in general this does not equal to sum of V only for linear model
%   eff         eff(:,i) is the sensitivity coefficient of parameter i
%               which equals V scaled by yvar (same as scaled to one
%               in the case of linear input-output relation)
%
% Reference: Andrea Saltelli, Stefano Tarantola, Francesca Campolongo
% and Marco Ratto, Sensitivity Analysis in Practice, John Wiley 2004
% p. 134
% McKay, p. 24

[L,N,r]=size(X); 
[dim,NN,rr]=size(Y);
if NN~=N | rr~=r,
    error('incompatible dimensions of arguments')
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

% disp('matching')
% y(:,i,j,l) = Y(:,ix,l) such that X(i) is in j                                                                                                                                    -th bin in repetition l
y=zeros(dim,L,N,r);
for i=1:L                   % variable
    for j=1:N               % sample point
        for l=1:r           % repetition
            ix=find(X(i,:,l) == D0(i,j));
            if length(ix) ~= 1,
                error('exactly one point should match')
            end
            y(:,i,j,l)=Y(:,ix,l);
        end
    end
end

% cmean(:,i,j) = mean of y over repetitions conditional on X(i) in j-th bin

% disp('conditional mean')
% for l=1:r         % to watch convergence
for l=r;          % to get the results
    cmean = mean(y(:,:,:,1:l),4);
    % disp('checking')
    %for i=1:L
    %    for ix=1:dim,
    %        err(ix,i) = mean(cmean(ix,i,:))-mean(mean((Y(ix,:,:))));
    %    end
    %end
    %err_mean=norm(err(:))

    % disp('mean of its variance')
    V = mean(var(cmean,1,3),3);
    % ymean(i) = mean of Y(i)
    % ymean = mean(cmean,3);
    % variance due to input j
    % V = mean((cmean-ymean*ones(1,N)).^2,2);
    y2 = reshape(Y(:,:,1:l),[dim,N*l]);
    yvar=var(y2,0,2);
    eff=V ./ (yvar * ones(1,L)+realmin); % avoid division by zero    
    fprintf('%3i repeats ',l)
    fprintf('var at points %g max %g avg',max(yvar),mean(yvar))
    for i=1:L
        fprintf(' param %3i: max %g avg %g',i,max(eff(:,i)),mean(eff(:,i)))
    end
    fprintf('\n')
end
ymean=mean(y2,2);
out={V,ymean,yvar,eff};
varargout=out(1:nargout);
end