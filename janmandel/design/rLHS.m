function rD=rLHS(D,r)
% rD=rLHS(D)
% Repeated Latin Hypercube Sampling
% input:
%       D matrix size (N,L)
%         the range of values of input I=1:L is decomposed 
%         in N disjoint intervals such that
%         Pr( input I in interval J for input I  ) = 1/N
%         D(J,I) is a sampling point from interval J for input I
%       r the number of repetitions
%
%  returns:
%       rD matrix size (r*N,L)
%          each row of rD is one vector of input parameters to run
%
% Reference:
% McKay, M. D., 1995: Evaluating prediction uncertainty. 
% Technical Report NUREG/CR-6311 LA-12915-MS, 
% Los Alamos National Laboratory,
% http://www.iaea.org/inis/collection/NCLCollectionStore/_Public/26/051/26051087.pdf
% page 24

[N,L]=size(D);
rD=zeros(r*N,L);
for I=1:L
    for K=1:r
        rD(1+(K-1)*N:K*N,I)=D(randperm(N)',I);
    end
end
end
