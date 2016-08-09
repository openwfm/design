
% Author: Aimé Fournier

 clear a cm h
 for i = lSta				% station (with burn requirements) loop:
    figure(i)
    set(gcf,'Units','normalized','OuterPosition',[1/8 0 7/8 1],'Units','pixels')
    clf
    cm = colormap(jet(sta(i).nYr));	% color for each year
    fRan = repmat([Inf
                  -Inf],1, nDat);	% range of field values
    isp = false(1, nDat);		% plot started
    nPt = 0;				% nu. points plotted
%     dStat = zeros(1 + nDat + ...	% data statistics
%        nDat*(nDat + 1)/2, nSta);
    for j = 1 : sta(i).nYr		% year loop at station i:
       if sta(i).d(j).nt > 0		% if there are times to plot:
	  Jan1 = datenum(sprintf('01-01-%4d 00:00', sta(i).yr(j)), datef);
	  t = (sta(i).d(j).t + rDate ...% months since January 1 00:00
	     - Jan1)*12/365;
	  b = ([datenum(sprintf('%02d-01-%4d 00:00', bReqs(nDat+1,1,i)  , sta(i).yr(j)), datef) ...
	        datenum(sprintf('%02d-01-%4d 00:00', bReqs(nDat+1,2,i)+1, sta(i).yr(j)), datef) - 1/(24*60)] ...
	      - Jan1)*12/365;
	  q = strcmp(sta(i).d(j).qFlg, 'OK');
	  nPt = nPt + sum(q);
	  if sum(q)			% at least 1 'OK' datum
% 	     f = find(            le( b(             1  ),             t(q  ) ) & ...
% 		                  ge( b(             2  ),             t(q  ) ) & ...
% 		      all(bsxfun(@le, bReqs(1 : nDat,1,i), sta(i).d(j).f(q,:)') & ...
% 		          bsxfun(@ge, bReqs(1 : nDat,2,i), sta(i).d(j).f(q,:)'))');
% 	     dStat(1,i) = dStat(1,i) + length(f);
	     for k = 1 : nDat		% data-type loop:
% 		dStat
		if ~all(isnan(sta(i).d(j).f(q,k)))
		   if isp(k)		% insert in started plot:
		      subplot(h.a(k, i))
		      h.p(k, j, i) = line(t(q), sta(i).d(j).f(q, k), 'Color', cm(j, :), 'LineStyle', 'none', 'Marker', '.');
		   else			% start plot:
		      h.a(k, i) = subplot(nDat, 1, k);
		      h.p(k, j, i) = plot(t(q), sta(i).d(j).f(q, k), '.', 'Color', cm(j, :));
		      isp(k) = true;
		   end
		   if sum(strcmp({'SKNT'}, datList{k}))
		      set(gca, 'YScale', 'log')
		   end			% ... log scale for RELH and SKNT
		   axis tight
		   fRan(:, k) = [min(fRan(1, k), min(sta(i).d(j).f(q, k)))
		                 max(fRan(2, k), max(sta(i).d(j).f(q, k)))];
		   if j == sta(i).nYr
		      a = axis;
		      h.b(k, i, 1) = patch([b([1     1]) a([1 1])],  a([3 4 4 3])                  , 'r');
		      h.b(k, i, 2) = patch([b([  2 2  ]) a([2 2])],  a([4 3 3 4])                  , 'r');
		      h.b(k, i, 3) = patch( b([1 2 2 1])          , [a([  3 3  ]) bReqs(k,[1 1],i)], 'r');
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
 
