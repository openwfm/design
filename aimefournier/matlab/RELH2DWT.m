 function p = RELH2DWT( r, t, f )
%
% p = RELH2DWT( r, t [,  1])
% r = RELH2DWT( p, t  , -1 )
%
% At temperature t (Celsius), convert
% relative humidity r (0:100 %) to dew point temperature p (Celsius), or p back to r.
% See https://en.wikipedia.org/wiki/Dew_point.
%

% Author:               Aime' Fournier
% Project Title:        Modeling support for FASMEE experimental design using WRF-SFIRE-CHEM
% JFSP project number:  16-4-05-3

 if nargin < 3
    f = 1;
 end
 b = 17.368*(0 <= t) + 17.966*(0 > t);
 c = 238.88*(0 <= t) + 247.15*(0 > t);
 d = 234.5;
 p = zeros(size(r));
 if f == 1
    z = r == 0;
    p(z) = -c(z);
    z = r ~= 0;
    g = log(r(z)/100) + (b(z) - t(z)/d).*t(z)./(t(z) + c(z));
    p(z) = c(z).*g./(b(z) - g);
 elseif f == -1
    z = r == -c;			% r is p if f == -1
    p(z) = 0;
    z = r ~= -c;
    g = b(z).*r(z)./(c(z) + r(z));
    p(z) = 100*exp(g - (b(z) - t(z)/d).*t(z)./(t(z) + c(z)));
 else
    error('|%d| ~= 1',f)
 end
