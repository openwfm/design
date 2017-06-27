% Author:               Aime' Fournier
% Project Title:        Modeling support for FASMEE experimental design using WRF-SFIRE-CHEM
% JFSP project number:  16-4-05-3

 clear i k l m s
 cm = copper(nDat);
 nc = 3;				% subplot column ratio nc : nc : 1
 r = .02;				% aggregate-marker spacing
 for i = lSta				% station (with burn requirements) loop:
    figure(10 + i)
    set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
    clf
    m = 0;
    for k = 1 : nDat - 1
       subplot(nDat, 2*nc + 1, (2*nc + 1)*(k - 1) + (1 : nc) + nc)
       for l = k + 1 : nDat
	  m = m + 1;
	  s = arrayfun(@(x) x.r(m), sta(i).mom);
	  p(l - k) = line(sta(i).yr, s, 'Color', cm(l,:), 'DisplayName', sprintf('{\\it\\rho}[%4s,%4s]', datList{[k l]}), 'Marker', 'x');
	  line(sta(i).yr(end) + r*diff(sta(i).yr([1 end])), sta(i).ags.r(m), 'Color', cm(l,:), 'LineStyle', 'none', 'MarkerFaceColor', cm(l,:), 'Marker', 'p');
       end
       axis tight
       xlim(sta(i).yr([1 end]))
       s = get(gca, 'XTick');
       set(gca, 'Clipping', 'off', 'XTick', floor(s(1)) : ceil(diff(s([1 end]))/4) : ceil(s(end)))
       set(legend(subplot(nDat, 2*nc + 1, (2*nc + 1)*(k - 1) + 2*nc + 1), p(1 : nDat - k), 'Location', 'eastoutside'), 'FontName', 'fixedwidth')
       axis off
    end
    for k = 1 : nDat			% data-type loop:
       subplot(nDat, 2*nc + 1, (2*nc + 1)*(k - 1) + (1 : nc))
       m = arrayfun(@(x) x.m(k), sta(i).mom);
       s = arrayfun(@(x) x.s(k), sta(i).mom);
       plot(sta(i).yr, m, 'bo-', sta(i).yr, m + s, 'r^-', sta(i).yr, m - s, 'rv-')
       line(sta(i).yr( end     ) + r*diff(sta(i).yr([1 end])), sta(i).ags.m(k)                         , 'Color', 'b', 'LineStyle', 'none', 'MarkerFaceColor', 'b', 'Marker', 'p');
       line(sta(i).yr([end end]) + r*diff(sta(i).yr([1 end])), sta(i).ags.m(k) + sta(i).ags.s(k)*[-1 1], 'Color', 'r', 'LineStyle', 'none', 'MarkerFaceColor', 'r', 'Marker', 'p');
       axis tight
       if k == 1
	  title(sprintf('Station %s means {\\it\\mu}, standard deviations {\\it\\sigma} and correlations {\\it\\rho}\nStar markers = multi-year aggregates', sta(i).name))
       elseif k == nDat
	  xlabel('year')
       end
       ylabel(sprintf('{\\it\\mu}\\pm{\\it\\sigma}[%s] (%s)', datList{k}, sta(i).d(1).u{k}))
       xlim(sta(i).yr([1 end]))
       s = get(gca, 'XTick');
       set(gca, 'Clipping', 'off', 'XTick', floor(s(1)) : ceil(diff(s([1 end]))/4) : ceil(s(end)))
       subplot(nDat, 2*nc + 1, (2*nc + 1)*(nDat - 1) + (1 : nc) + nc)
       s = arrayfun(@(x) x.n(k), sta(i).mom);
       p(k) = line(sta(i).yr, s, 'Color', cm(nDat + 1 - k,:), 'DisplayName', sprintf('{\\itN}[%4s]\nburn days', datList{k}), 'Marker', '+');
%        line(sta(i).yr(end) + r*diff(sta(i).yr([1 end])), sta(i).ags.n(k), 'Color', cm(nDat + 1 - k,:), 'LineStyle', 'none', 'MarkerFaceColor', cm(nDat + 1 - k,:), 'Marker', 'p');
    end
    axis tight
    xlabel('year')
    xlim(sta(i).yr([1 end]))
    s = get(gca, 'XTick');
    set(gca, ...%'Clipping', 'off',
       'XTick', floor(s(1)) : ceil(diff(s([1 end]))/4) : ceil(s(end)))
    set(legend(subplot(nDat, 2*nc + 1, (2*nc + 1)*(nDat - 1) + 2*nc + 1), p(1 : nDat), 'Location', 'eastoutside'), 'FontName', 'fixedwidth')
    axis off
    orient landscape
    drawnow
 end,clear p i k l m r s
