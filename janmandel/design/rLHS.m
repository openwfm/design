function P=rLHS(D,r)
% rD=rLHS(D)
% Repeated Latin Hypercube Sampling
% input:
%       D matrix size (L,N)
%         D(i,j) is a sampling point for input i from interval j 
%         the range of values of input i=1:L is decomposed 
%         in N disjoint intervals such that
%         Pr( input i in interval j) = 1/N
%
%       r the number of repetitions
%
%  returns:
%       P matrix size (L,N,r)
%          each P(:,j,k) is one vector of input parameters to run
%          delivering Y(j,k) which can be analyzed by effect
%
%  example:
%       P = rLHS(equaln(mean_vec,std_vec,N),r)
%
%       2 factors with 0 mean and deviation 1 and 3 respectively
%       5 sample values for each
%       repeated 4 times
%       P = rLHS(equaln([0,0],[1,3],5),4)
%       and matrix with each parameter vector as column
%       reshape(rD,2,[])
%  
%  experiment should deliver output y(j,k) from input parameters rD(
%
% Reference:
% McKay, M. D., 1995: Evaluating prediction uncertainty. 
% Technical Report NUREG/CR-6311 LA-12915-MS, 
% Los Alamos National Laboratory,
% http://www.iaea.org/inis/collection/NCLCollectionStore/_Public/26/051/26051087.pdf
% page 24

[L,N]=size(D);
P=zeros(L,N,r);
for k=1:r
    for j=1:L
        P(j,:,k)=D(j,randperm(N));
    end
end
end
