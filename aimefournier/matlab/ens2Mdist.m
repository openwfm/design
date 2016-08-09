 function [d v] = ens2Mdist( x, u, v )
%
%	d = ens2Mdist( x, u, v );
%	[d j m] = ens2Mdist( x );
%
% In the 1st pattern, given a length-n ensemble (array x(1:n) of
% structures), return the Mahalanobis distance d between stuctures u and v
% (structured like x(1)). Any x fields with ~isnumeric are ignored.
% In the 2nd pattern, instead return j such that x(j) is closest to the
% ensemble mean, m.
%

% Author: Aimé Fournier

 if ~isstruct(x)
    error('1st argument must be an array of structures')
 end
 n = length(x);
 if n<2
    error('n==%d is too few members', n)
 end
 if nargin < 2
    [j d] = fminsearch(...
               @(k)dotStruct(...
	              diffStruct(m,x(k)),...
	              fminsearchStruct(...
                         @(y)normStruct(...
			    diffStruct(diffStruct(m,x(k)),multiplyByCovariance( x, y )))^2,...
		         diffStruct(m,x(k))),...
	       randi(n));
 else
 d = (u - v)'*...
     @(w)norm(multiplyByCovariance( x, w ) - u + v)^2,u - v)
 end
 end
 
    function cw = multiplyByCovariance( x, w )
    end
