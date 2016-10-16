function D=equaln(m,s,N)
% D=equaln(m,s)
% Input:
%   m   vector: mean of normally distributed random variables X(I)
%   s   vector: standard deviation of X(I)
%   N   number of sampling points; if odd if m is a sampling point 
% Returns:
%   D   for each X(I), column with medians of the N intervals of equal probability

if ~isvector(m) || ~isvector(s) || length(m) ~= length(s),
    error('m and s must be vectors of same length')
end
L=length(m);
D = zeros(N,L);
v = (-(N-1):2:N-1)/N; % v(i) represents interval [v(i)-N/2,v(i)+N/2]
p = erfinv(v)';
for I=1:L,
    D(:,I)=m(I)+s(I)*p;
end
end