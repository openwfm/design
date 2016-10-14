
% Author: Aime' Fournier

 clear a cm h
 for i = lSta				% station (with burn requirements) loop:
    figure(i)
    set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
    clf
    yr = datevec(min(sta(i).t)) : datevec(max(sta(i).t));
    nYr = length(yr);
    cm = colormap(jet(nYr));		% color for each year
    fRan = repmat([Inf
                  -Inf], 1, nDat);	% range of field values
    isp = false(1, nDat);		% plot started
    nPt = 0;				% nu. points plotted
    for j = 1 : nYr			% year loop at station i:
       f = find(datevec(sta(i).t) == yr(j));
       Jan1 = datenum(sprintf('%4d-01-01T00:00:00Z', yr(j)), datef);
       t = (sta(i).t(f) - Jan1)*12/365;	% months since January 1 00:00
       b(1,:) = ([datenum(sprintf('%4d-%2d-%2dT00:00:00Z', yr(j), sta(i).bmdh(1, 1 : 2)), datef) ...
	          datenum(sprintf('%4d-%2d-%2dT00:00:00Z', yr(j), sta(i).bmdh(2, 1 : 2)), datef)] ...
	        - Jan1)*12/365;		% month/day window
       b(2,:) = sta(i).bmdh(:, 3);	% hour window
       nPt = nPt + length(f);
       for k = 1 : nDat			% data-type loop:
	  if ~all(isnan(sta(i).d(f,k)))
	     if isp(k)			% insert in started plot:
		subplot(h.a(k, i))
		h.p(k, j, i) = line(t, sta(i).d(f,k), 'Color', cm(j, :), 'LineStyle', 'none', 'Marker', '.');
	     else			% start plot:
		h.a(k, i) = subplot(nDat, 1, k);
		h.p(k, j, i) = plot(t, sta(i).d(f,k), '.', 'Color', cm(j, :));
		isp(k) = true;
	     end
	     if sum(strcmp({'wind_speed'}, datList{k}))
		set(gca, 'YScale', 'log')
	     end			% ... log scale for wind_speed
	     axis tight
	     fRan(:, k) = [min(fRan(1, k), min(sta(i).d(f,k)))
		           max(fRan(2, k), max(sta(i).d(f,k)))];
	     if j == nYr
		a = axis;
		h.b(k, i, 1) = patch([b(1,[1     1]) a([1 1])],  a([3 4 4 3])                  , 'r');
		h.b(k, i, 2) = patch([b(1,[  2 2  ]) a([2 2])],  a([4 3 3 4])                  , 'r');
		h.b(k, i, 3) = patch( b(1,[1 2 2 1])          , [a([  3 3  ]) sta(i).bR(k,[1 1],i)], 'r');
		      h.b(k, i, 4) = patch( b([2 1 1 2])          , [a([4     4]) bReqs(k,[2 2],i)], 'r');
		      set(h.b(k, i, :), 'EdgeColor', 'none', 'FaceColor', [1 1 1]*.7, 'FaceAlpha', .3)
		      axis(a)
		      ylabel(sprintf('%3.1f <\n %s (%s) \n< %3.1f', ...
			 fRan(1, k), datList{k}, sta(i).d(j).u{k}, fRan(2, k)))
		      r = arrayfun(@(x)~isa(x, 'matlab.graphics.GraphicsPlaceholder'), h.p(k,1:sta(i).nYr,i));
		      legend(h.p(k, r, i), reshape(sprintf('%d', sta(i).yr(r)), 4, sum(r))', 'Location', 'eastoutside')
		      if k == 1
			 title(sprintf('%s\\_%d:%d has %d times', sta(i).name, sta(i).yr([1 end]), nPt))
		      elseif k >= nDat - 1
			 xlabel('months since January 1 00:00')
		      end
		   end
		else
		   fprintf('All NaNs for %s_%d %4s\n', sta(i).name, sta(i).yr(j), datList{k})
		end
	     end
	  else
	     fprintf('Nothing OK for %s_%d\n', sta(i).name, sta(i).yr(j))
	  end
       else
	  fprintf('No times for %s_%d\n', sta(i).name, sta(i).yr(j))
       end
       drawnow
    end
 end,clear a b cm f fRan i isp j Jan1 k m nPt q r t
 
