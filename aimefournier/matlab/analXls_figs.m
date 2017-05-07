% Author:               Aime' Fournier
% Project Title:        Modeling support for FASMEE experimental design using WRF-SFIRE-CHEM
% JFSP project number:  16-4-05-3

 cm = gray(max(arrayfun(@(x)x.nWin, sta)) + 2);
 cm(end,:) = [];			% don't use white color
 ib = @(a,x) a(1) <= x & x <= a(2);	% in-between condition
 for i = lSta				% station (with burn requirements) loop:
    figure(i)
    set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
    clf
    yr = datevec(min(sta(i).t)) : ...
         datevec(max(sta(i).t));	% years for station i
    nt = zeros(nDat, sta(i).nWin);	% number of OK times for each window
    for j = 1 : length(yr)		% year loop at station i:
       g = find(datevec(...		% times in year j:
	  sta(i).t) == yr(j));
       Jan1 = datenum(sprintf('%4d-01-01T00:00:00Z', yr(j)), datef);
       t = (sta(i).t(g) - Jan1)*12/365;	% months since January 1 00:00
       for k = nDat : -1 : 1		% data-type loop:
	  subplot(nDat, 1, k)
	  line( t, sta(i).d(g,k), 'Color', cm(end,:), 'LineStyle', 'none', ...
	     'Marker', '.', 'MarkerSize', 1, 'ZData', -ones(size(t)));
	  [~,~,~,d] = datevec(sta(i).t(g));
	  for l = 1 : sta(i).nWin
	     b = datenum(yr([j j])', ...% month-day limits for window l:
		sta(i).bmdh(:,1,l), sta(i).bmdh(:,2,l));
	     %
	     % Enforce month-day-hour and data-value conditions:
	     %
	     f = find(ib(       b          , sta(i).t(g)  ) & ...
		      ib(sta(i).bmdh(:,3,l), d            ) & ...
		      ib(sta(i).bReqs(:,k) , sta(i).d(g,k)) & ...
		      any(isfinite(sta(i).d(g,:)), 2)      );
	     if isempty(f)
		fprintf('No OK %s data for %s_%d window %d of %d\n', datList{k}, sta(i).name, yr(j), l, sta(i).nWin)
	     else
		nt(k,l) = nt(k,l) + length(f);
		h(l) = line( t(f), sta(i).d(g(f),k), 'Color', cm(l,:), 'DisplayName', sprintf('%d in window %d', nt(k,l), l), 'LineStyle', ...
		            'none', 'Marker', '.', 'MarkerSize', 1, 'ZData', ones(size(f)));
	     end
	  end
	  axis tight
	  if j == length(yr)
	     legend(h(1 : sta(i).nWin), 'Location', 'eastoutside')
	  end
	  ylabel([strrep(datList{k}, '_', '\_') ' (' sta(i).u{k} ')'])
	  if k == nDat
	     xlabel('months since January 1 00:00')
	  else
	     set(gca, 'XTickLabel', '')
	  end
       end
    end
    title(sprintf('%s\\_%d:%d has %d unconstrained times', sta(i).name, yr([1 end]), sta(i).nt))
    drawnow
    orient tall
 end,clear b cm d f g h i ib j Jan1 k l nt t yr
