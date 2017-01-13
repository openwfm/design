
% Author: Aime' Fournier

 figure(2*sum(cell2mat({sta.nWin})) + 2)
 clf
 n = 0;
 for i = lSta				% station loop:
    yr = datevec(min(sta(i).t)) : datevec(max(sta(i).t));
    nYr = length(yr);
    cm = colormap(jet(nYr));		% color for each year
    for l = 1 : sta(i).nWin		% station-i window loop
       n = n + 1;
       subplot(sum(cell2mat({sta.nWin})), 1, n)
       if any(sta(i).mom(l).n <= 1)
	  text(.1, .5, sprintf('%s-%d has <%d burn days.', sta(i).name, l, max(sta(i).mom(l).n) + 1), 'FontSize', 20)
	  axis off
       else
	  for j = 1 : nYr		% year loop at station i:
	     %
	     % LGST can be -Inf:
	     %
	     k = find(isfinite(sta(i).Mds{l}) & (datevec(sta(i).t)*[1;0;0;0;0;0] == yr(j)));
	     [N, edges] = histcounts(sta(i).Mds{l}(k));
	     N = N/sum(N.*diff(edges));
	     x = .5*(edges(1 : end - 1) + edges(2 : end));
	     semilogx(x, N, '.', 'Color', cm(j,:))
	     line(x, 2^(-nDat/2)*x.^(nDat/2-1).*exp(-x/2)/gamma(nDat/2), 'Color', cm(j,:))
	     hold on
	  end, clear edges j k N x
	  hold off
	  axis tight
	  set(legend('Location', 'eastoutside'), 'FontSize', 5)
	  title(sprintf('%5s-%d %d:%d', sta(i).name, l, yr([1 end])))
	  if i == lSta(end) && l == sta(i).nWin
	     xlabel('M-dev. {\it\delta}[{\ity},{\itm},{\itd},{\ith}]')
	  end
       end
    end
 end, clear i j k l m p q r t u v
 orient tall