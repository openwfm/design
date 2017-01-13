 function h = covEllip(s,r,m,n)
%
% h = covEllip(s,r,m,n)
%
% Return handle h to line of ellipse [x-m(1), y-m(2)]*inv(c)*[x-m(1); y-m(2)]
% == 1 centered at m (default [0;0]) in the x-y plane, where c =
% [s(1)^2, s(1)*s(2)*r; s(1)*s(2)*r, s(2)^2] = v*d*v' is a 2D covariance
% matrix with correlation r (default 0), 2 real orthogonal eigenvectors
% v(:,1:2) and 2 positive eigenvalues d(1,1), d(2,2). Use 1 < n (default
% 32) points for the line.
%
% Author: Aime' Fournier
%
 if nargin < 4
    n = 32;
 end
 if nargin < 3
    m = [0;0];
 end
 if nargin < 2
    r = 0;
 end
 if any(s < 0)
    error('any(s < 0) not allowed')
 elseif abs(r) > 1
    error('|Correlation| > 1 not allowed')
 elseif n < 5
    error('Need n >= 5 line points')
 end
 x = sqrt(4*r^2*s(1)^2*s(2)^2 + (s(1)^2 - s(2)^2)^2);
 d(1,1) = (s(1)^2 + s(2)^2 + x)/(2*(1 - r^2)*s(1)^2*s(2)^2);
 d(2,2) = (s(1)^2 + s(2)^2 - x)/(2*(1 - r^2)*s(1)^2*s(2)^2);
 v = [s(1)^2 - s(2)^2 - x, s(1)^2 - s(2)^2 + x
            2*r*s(1)*s(2),       2*r*s(1)*s(2)];
 v = v*diag(1./sqrt(diag(v'*v)));
%  fprintf('%s eigensystem relative error %9.3g\n', mfilename, norm(inv([s(1)^2 s(1)*s(2)*r; s(1)*s(2)*r s(2)^2])-v*d*v', 1)/norm(v*d*v', 1))
%  f = @(i,w)v(i,:)*([cos(w); sin(w)]./sqrt(diag(d)));
%  [~, x] = fminbnd(@(w) f(1,w), -pi, pi);
%  fprintf('%s extrema relative errors %9.3g ', mfilename, x/(-s(1)) - 1)
%  [~, x] = fminbnd(@(w)-f(1,w), -pi, pi);
%  fprintf('%9.3g ',  -x/s(1)    - 1)
%  [~, x] = fminbnd(@(w) f(2,w), -pi, pi);
%  fprintf('%9.3g ',   x/(-s(2)) - 1)
%  [~, x] = fminbnd(@(w)-f(2,w), -pi, pi);
%  fprintf('%9.3g\n', -x/s(2)    - 1)
 u = (2*(0 : n - 1)/(n - 1) - 1)*pi;
 x = repmat(m(:), 1, n) + v*diag(1./sqrt(diag(d)))*[cos(u)
                                                    sin(u)];
% line(u, x')
 h = line(x(1,:), x(2,:));