function D=equaln(m,s,N)
% D=equaln(m,s,N)
% Input:
%   m   vector: mean of normally distributed random variables X(i)
%   s   vector: standard deviation of X(i)
%   N   number of sampling points; m is a sampling point if N is odd  
% Returns:
%   D   for each X(i), row with medians of the N intervals of equal probability

if ~isvector(m) || ~isvector(s) || length(m) ~= length(s),
    error('m and s must be vectors of same length')
end
L=length(m);
D = zeros(L,N);
v = (-(N-1):2:N-1)/N; % v(i) represents interval [v(i)-N/2,v(i)+N/2]
p = erfinv(v);
for i=1:L,
    D(i,:)=m(i)+s(i)*p;
end
end