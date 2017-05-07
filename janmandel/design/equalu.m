function D=equalu(l,u,N)
% D=equalu(l,u,N)
% Input:
%   l,u   vector: bounds of uniformly distribution random variables X(i)
%   N   number of sampling points; (l+u)/2 is a sampling point if N is odd  
% Returns:
%   D   for each X(i), row with medians of the N intervals of equal probability

if ~isvector(l) || ~isvector(u) || length(l) ~= length(u),
    error('l and u must be vectors of same length')
end
L=length(l);
D = zeros(L,N);
v = [(-(N-1):2:N-1)/N]; % v(i) represents interval [v(i)-N/2,v(i)+N/2]
for i=1:L,
    D(i,:)=v*(u(i)-l(i))/2+(l(i)+u(i))/2;
end
end