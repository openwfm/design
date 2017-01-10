
% Author: Aime' Fournier

 cm = gray(max(arrayfun(@(x)x.nWin, sta)) + 2);
 cm(end,:) = [];			% don't use white color
 ib = @(a,x) a(1) <= x & x <= a(2);	% in-between condition
 figure(2*lSta(end) + 1)
 clf
 clear j
 for i = lSta				% station loop:
    yr = datevec(min(sta(i).t)) : ...
         datevec(max(sta(i).t));
    subplot(lSta(end), 1, i)
    if any(sta(i).mom.n <= 1)
       text(.1, .5, sprintf('%s has <%d burn days.', sta(i).name, max(sta(i).mom(l).n) + 1), 'FontSize', 20)
       axis off
    else
       %
       % Assign the strictly upper triangular correlation matrix:
       %
       p = zeros(nDat);
       m = 0;
       for k = 1 : nDat - 1		% row loop:
	  for j = k + 1 : nDat		% column loop (upper triangle):
	     m = m + 1;
	     p(k,j) = sta(i).mom.r(m);	% corr(d(k),d(j))
	  end
       end, clear j k m
       q = diag(sta(i).mom.s);		% std(d)
       %
       % Add the id and lower triangle, and multiply in the std:
       %
       p = q*(p + p' + eye(nDat))*q;	% cov(d)
       [r j] = eig(p, 'vector');
       %
       % Change to sqrt of precision matrix:
       %
       if min(j) <= 0		% suspect spurious correlations
	  fprintf('%5s %9.1e <=  eigenvalues <= %9.1e rectified.\n', sta(i).name, min(j), max(j))
	  [r j] = deal(r(:,j > 0), j(j > 0));
	  p = r*diag(1./sqrt(j));	% p*p' is the precision matrix orthogonal to the singular directions
       else
	  p = chol(inv(p), 'lower');	% p*p' is the full precision matrix
       end
       %
       % Time series of Mahalanobis deviations from the mean:
       %
       sta(i).Md.v = sqrt(sum(((sta(i).d - repmat(sta(i).mom.m, sta(i).nt, 1))*p).^2, 2));
       [~,~,~,h] = datevec(sta(i).t);	% hour-of-day for each time
       for l = 1 : sta(i).nWin		% station i, time-window loop:
	  b = datevec(sta(i).t);	% year, month, day, hour, minute, second
	  b = datenum(repmat(b(:,1), 1, 2), repmat(sta(i).bmdh(:,1,l)', sta(i).nt, 1) ...
	                                  , repmat(sta(i).bmdh(:,2,l)', sta(i).nt, 1));
	  %
	  % Enforce month-day-hour conditions:
	  %
	  f = find(b(:,1) <= sta(i).t & ...
	           b(:,2) >= sta(i).t & ...
	           ib(sta(i).bmdh(:,3,l), h));
	  [~, j] = sort(sta(i).Md.v(f));
	  %
	  % Minimum of time-conditioned Mahalanobis deviation, and its time:
	  %
	  sta(i).Md.x(l) = sta(i).Md.v(f(j(1)));
	  sta(i).Md.t(l) = sta(i).t(   f(j(1)));
	  %
	  % month-fraction of each year:
	  %
	  sta(i).Md.m(l) = (sta(i).Md.t(l) - ...
		datenum(sprintf('%4d-01-01T00:00:00Z', datevec(sta(i).Md.t(l))), datef))*12/365;
	  j = j(1 : 32);
	  %
	  % Write some smallest values:
	  %
	  t = num2cell([sta(i).Md.v(f(j)) sta(i).d(f(j),:)],1);
	  t = {datestr(sta(i).t(f(j)), datef) t{:}};
	  writetable(table(t{:}, 'VariableNames', {'time' 'M_dev' datList{:}}), ...
	     sprintf('txt/M_%s-%d.txt',sta(i).name,l))
       end
       for j = 1 : length(yr)		% year loop at station i:
	  Jan1 = datenum(sprintf('%4d-01-01T00:00:00Z', yr(j)), datef);
	  f = datevec(sta(i).t);	% year, month, day, hour, minute, second
	  f = f(:,1) == yr(j);		% times in year j:
	  t = (sta(i).t(f) ...		% months since January 1 00:00
	       - Jan1)*12/365;
	  line(t, sta(i).Md.v(f), 'Color', cm(end,:), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 1, 'ZData', -ones(sum(f),1))
	  for l = 1 : sta(i).nWin
	     g = datenum(yr([j j])', sta(i).bmdh(:,1,l), sta(i).bmdh(:,2,l));
	     %
	     % Enforce month-day-hour and data-value conditions:
	     %
	     g = f & ib(g, sta(i).t) & ib(sta(i).bmdh(:,3,l), h);
	     line((sta(i).t(g) - Jan1)*12/365, sta(i).Md.v(g), 'Color', cm(l,:), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 6, 'ZData', ones(sum(g),1))
	  end
       end
       line(sta(i).Md.m, sta(i).Md.x, 'DisplayName', 'min', 'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', 2^3, 'ZData', ones(sta(i).nWin,1))
       set(gca, 'YScale', 'log', 'YTick', 2.^(floor(log2(sta(i).Md.x(1))) : 2 : ...
	                                       ceil(log2(max(sta(i).Md.v(isfinite(sta(i).Md.v)))))))
       axis tight
       g = axis;
       axis([0 12 g(3:4)])
%      set(legend('Location', 'eastoutside'), 'FontSize', 5)
       [u{1:4}] = datevec(min(sta(i).Md.t));
       title(sprintf( ...
	     '{\\it\\delta}[%d,%d,%d,%d] = %5.2f \\leq (%5s-%d %d:%d M-dev. {\\it\\delta}[{\\ity},{\\itm},{\\itd},{\\ith}])', ...
	     u{:}, sta(i).Md.x(1), sta(i).name, l, yr([1 end])))
       if i == lSta(end)
	  xlabel('months since January 1 00:00')
       end
    end
 end, clear f g i j Jan1 k l m p q r t u v
 orient tall