function [m,s]=bounds2n(ab,p)
% [m,s]=bounds2n(a,b,p)
% Mean and stdev of normal distribution that has probability 1-p in [a,b]
m = (ab(:,1)+ab(:,2))/2;
h = ab(:,2) - m;
% 1 - p = erf((h/(s*sqrt(2))))
% h/(s*sqrt(2)) = erfcinv(p)
s = h./(erfcinv(p)*sqrt(2));
end