
% Author: Aime' Fournier

 n = 1;
 for i = lSta				% station (with burn requirements) loop:
    yr = datevec(min(sta(i).t)) : ...
         datevec(max(sta(i).t));	% years for station i
    nYr = length(yr);
    cm = colormap(jet(nYr));		% color for each year
    for l = 1 : sta(i).nWin
       figure(n)
       set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
       clf
       [d{1 : 4}] = datevec(sta(i).t);
       %
       % Enforce month-day-hour conditions:
       %
       f = find(sta(i).bmdh(1,1,l) <= d{2}                       & ...
		                      d{2} <= sta(i).bmdh(2,1,l) & ...
		sta(i).bmdh(1,2,l) <= d{3}                       & ...
		                      d{3} <= sta(i).bmdh(2,2,l) & ...
		sta(i).bmdh(1,3,l) <= d{4}                       & ...
		                      d{4} <= sta(i).bmdh(2,3,l) & ...
		any(isfinite(                 sta(i).d          ), 2));
       for k = nDat : -1 : 1		% data-type loop:
	  subplot(nDat, 8, 8*k + (-7:-1))
	  for j = 1 : nYr		% year loop at station i:
	     g = find(datevec(sta(i).t(f)) == yr(j));
	     Jan1 = datenum(sprintf('%4d-01-01T00:00:00Z', yr(j)), datef);
	     t = (sta(i).t(f(g)) ...	% months since January 1 00:00
		- Jan1)*12/365;
	     if ~sum(g)
		fprintf('No good data for %s_%d window %d of %d\n', sta(i).name, yr(j), l, sta(i).nWin)
		line(NaN(1, 2), NaN(1, 2), 'Color', cm(j, :), 'DisplayName', sprintf('%4d', yr(j)), 'LineStyle', 'none', 'Marker', '.');
	     else
		line(t, sta(i).d(f(g),k), 'Color', cm(j, :), 'DisplayName', sprintf('%4d', yr(j)), 'LineStyle', 'none', 'Marker', '.');
	     end
	  end
% 	  if sum(strcmp('wind_speed', datList{k}))
% 	     set(gca, 'YScale', 'log')
% 	  end			% ... log scale for wind_speed
	  axis tight
	  set(gca, 'XLim', ([datenum(sprintf('%4d-%2d-%2dT%2d:00:00Z', yr(nYr), sta(i).bmdh(1,:,l)), datef)
	                     datenum(sprintf('%4d-%2d-%2dT%2d:00:00Z', yr(nYr), sta(i).bmdh(2,:,l)), datef)] - Jan1)*12/365)
	  if all(isfinite(sta(i).bReqs(:,k,l)))
	     set(gca, 'YLim', sta(i).bReqs(:,k,l))
	  end
	  ylabel([strrep(datList{k}, '_', '\_') ' (' sta(i).u{k} ')'])
	  if k == nDat
	     xlabel('months since January 1 00:00')
	     set(legend('show'), 'Position', get(subplot(k, 8, 8*k, 'Visible', 'off'), 'Position'))
	  else
	     set(gca, 'XTickLabel', '')
	  end
       end
       title(sprintf('%s\\_%d:%d window %d of %d has %d times', sta(i).name, yr([1 end]), l, sta(i).nWin, length(f)))
       n = n + 1;
       drawnow
    end
 end,clear cm d f g i j Jan1 k l t