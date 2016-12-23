
% Author: Aime' Fournier

 figure(2*sum(cell2mat({sta.nWin})) + 1)
 clf
 n = 0;
 clear j
 for i = lSta				% station loop:
    yr = datevec(min(sta(i).t)) : datevec(max(sta(i).t));
    nYr = length(yr);
    cm = colormap(jet(nYr));		% color for each year
    for l = 1 : sta(i).nWin
       n = n + 1;
       subplot(sum(cell2mat({sta.nWin})), 1, n)
       if any(sta(i).mom(l).n <= 1)
	  text(.1, .5, sprintf('%s-%d has <%d burn days.', sta(i).name, l, max(sta(i).mom(l).n) + 1), 'FontSize', 20)
	  axis off
       else
	  %
	  % Assign the strictly upper triangular correlation matrix:
	  %
	  p = zeros(nDat);
	  m = 0;
	  for k = 1 : nDat - 1		% row loop:
	     for j = k + 1 : nDat	% column loop (upper triangle):
		m = m + 1;
		p(k,j) = ...		% corr(d(k),d(j))
		   sta(i).mom(l).r(m);
	     end
	  end, clear j k m
	  q = diag(sta(i).mom(l).s);	% std(d)
	  %
	  % Add the id and lower triangle, and multiply in the std:
	  %
	  p = q*(p + p' + eye(nDat))*q;	% cov(d)
% 	  disp(norm(p - p', 1)/norm(p, 1))
          [r j] = eig(p, 'vector');
	  %
	  % Change to sqrt of precision matrix:
	  %
	  if min(j) <= eps		% suspect spurious correlations
	     fprintf('%5s-%d %9.1e <=  eigenvalues <= %9.1e rectified.\n', sta(i).name, l, min(j), max(j))
	     [r j] = deal(r(:,j > 0), j(j > 0));
	     p = r*diag(1./sqrt(j));	% p*p' is the precision matrix orthogonal to the singular directions
	  else
	     p = chol(inv(p), 'lower');	% p*p' is the precision matrix
	  end
	  %
	  % Time series of Mahalanobis distances from the mean:
	  %
	  r = sqrt(sum(((sta(i).d - repmat(sta(i).mom(l).m, sta(i).nt, 1))*p).^2, 2));
	  [~, j] = sort(r);
	  j = j(1 : 32);
	  %
	  % Write some largest values:
	  %
	  writetable(table(r(j), datestr(sta(i).t(j), datef), 'VariableNames', {'M_dev' 'time'}), ...
	     sprintf('txt/M_%s-%d.txt',sta(i).name,l))
          j = find(isfinite(r));	% LGST can be -Inf
	  %
	  % Extrema of Mahalanobis distance:
	  %
	  [sta(i).Md(1,l) sta(i).Mt(1,l)] = min(r(j));
	  [sta(i).Md(2,l) sta(i).Mt(2,l)] = max(r(j));
	  sta(i).Mt(:,l) = sta(i).t(j(sta(i).Mt(:,l)));
	  for k = 1 : 2			% min-max loop:
	     sta(i).Mm(k,l) = (sta(i).Mt(k,l) - ...
		datenum(sprintf('%4d-01-01T00:00:00Z', datevec(sta(i).Mt(k,l))), datef))*12/365;
	  end
	  for j = 1 : nYr			% year loop at station i:
	     Jan1 = datenum(sprintf('%4d-01-01T00:00:00Z', yr(j)), datef);
	     t = (sta(i).t - Jan1)*12/365;	% months since January 1 00:00
	     f = isfinite(r) & 0 <= t & t < 12;
	     line(t(f), r(f), 'Color', cm(j,:), 'DisplayName', ...
		sprintf('{\\ity}=%d', yr(j)), 'LineStyle', 'none', 'Marker', '.')
	  end,clear f j Jan1 t
	  line(sta(i).Mm(1,l), sta(i).Md(1,l), 'DisplayName', 'min', 'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', 2^3)
	  line(sta(i).Mm(2,l), sta(i).Md(2,l), 'DisplayName', 'max', 'LineStyle', 'none', 'Marker', '^', 'MarkerSize', 2^3)
	  set(gca, 'YScale', 'log', 'YTick', 2.^(floor(log2(sta(i).Md(1,l))) : 2 : ceil(log2(sta(i).Md(2,l)))))
	  axis tight
	  set(legend('Location', 'eastoutside'), 'FontSize', 5)
	  [u{1:4}] = datevec(sta(i).Mt(1,l));
	  [v{1:4}] = datevec(sta(i).Mt(2,l));
	  title(sprintf( ...
	     '{\\it\\delta}[%d,%d,%d,%d] = %5.2f \\leq (%5s-%d %d:%d M-dev. {\\it\\delta}[{\\ity},{\\itm},{\\itd},{\\ith}]) \\leq {\\it\\delta}[%d,%d,%d,%d] = %5.2f', ...
	     u{:}, sta(i).Md(1,l), sta(i).name, l, yr([1 end]), v{:}, sta(i).Md(2,l)))
	  if i == lSta(end) & l == sta(i).nWin
	     xlabel('months since January 1 00:00')
	  end
       end
    end
 end, clear i j k l m p q r t u v
 orient tall