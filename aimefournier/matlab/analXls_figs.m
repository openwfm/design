
% Author: Aime' Fournier

 clear a cm h
 n = 1;
 for i = lSta				% station (with burn requirements) loop:
    yr = datevec(min(sta(i).t)) : datevec(max(sta(i).t));
    nYr = length(yr);
    cm = colormap(jet(nYr));		% color for each year
    for l = 1 : sta(i).nWin
    figure(n)
    set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
    clf
%     fRan = repmat([Inf
%                   -Inf], 1, nDat);	% range of field values
    isp = false(1, nDat);		% plot started
    nPt = 0;				% nu. points plotted
    for j = 1 : nYr			% year loop at station i:
       [d{1 : 4}] = datevec(sta(i).t);
       f = find(                      d{1} == yr(j)              & ...
	        sta(i).bmdh(1,1,l) <= d{2}                       & ...
		                      d{2} <= sta(i).bmdh(2,1,l) & ...
		sta(i).bmdh(1,2,l) <= d{3}                       & ...
		                      d{3} <= sta(i).bmdh(2,2,l) & ...
		sta(i).bmdh(1,3,l) <= d{4}                       & ...
		                      d{4} <= sta(i).bmdh(2,3,l));
       Jan1 = datenum(sprintf('%4d-01-01T00:00:00Z', yr(j)), datef);
       t = (sta(i).t(f) - Jan1)*12/365;	% months since January 1 00:00
       nPt = nPt + length(f);
       for k = 1 : nDat			% data-type loop:
	  if ~all(isnan(sta(i).d(f,k)))
	     if isp(k)			% insert in started plot:
		subplot(h.a(k, i))
		h.p(k,j,i) = line(t, sta(i).d(f,k), 'Color', cm(j, :), 'LineStyle', 'none', 'Marker', '.');
	     else			% start plot:
		h.a(k,i) = subplot(nDat, 1, k);
		h.p(k,j,i) = plot(t, sta(i).d(f,k), '.', 'Color', cm(j, :));
		isp(k) = true;
	     end
% 	     if sum(strcmp({'wind_speed'}, datList{k}))
% 		set(gca, 'YScale', 'log')
% 	     end			% ... log scale for wind_speed
	     axis tight
% 	     fRan(:, k) = [min(fRan(1,k), min(sta(i).d(f,k)))
% 		           max(fRan(2,k), max(sta(i).d(f,k)))];
             if all(isfinite(sta(i).bReqs(:,k,l)))
		set(gca, 'YLim', sta(i).bReqs(:,k,l))
	     end
	     ylabel([strrep(datList{k},'_','\_') ' (' sta(i).u{k} ')'])
	  else
	     fprintf('All NaNs for %s_%d window %d of %d, %4s\n', ...
		sta(i).name, yr(j), l, sta(i).nWin, datList{k})
	  end
       end
    end
    for k = 1 : nDat
       r = arrayfun(@(x)~isa(x, 'matlab.graphics.GraphicsPlaceholder'), h.p(k,1 : nYr,i));
       legend(h.p(k,r,i), reshape(sprintf('%d', yr(r)), 4, sum(r))', 'Location', 'eastoutside')
    end
    title(h.a(1,i), sprintf('%s\\_%d:%d window %d of %d has %d times', ...
       sta(i).name, yr([1 end]), l, sta(i).nWin, nPt))
    xlabel('months since January 1 00:00')
    drawnow
    n = n + 1;
    end
 end,clear a b cm d f fRan i isp j Jan1 k l nPt r t