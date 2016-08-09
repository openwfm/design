
% Author: Aimé Fournier

 figure(11 + lSta(end))
 clf
 for i = lSta				% station loop:
    cm = colormap(jet(sta(i).nYr));	% color for each year
    p = zeros(nDat);
    m = 0;
    for k = 1 : nDat - 1		% row loop:
       for l = k + 1 : nDat		% upper triangle:
	  m = m + 1;
	  p(k,l) = sta(i).ags.r(m);	% corr(f(k),f(l))
       end
    end
    q = diag(sta(i).ags.s);		% std(f)
    p = q*(p + p' + eye(nDat))*q;	% cov(f)
%     disp(norm(p-p',1)/norm(p,1))
%     fprintf('%5s min eigenvalue %9.1e\n', sta(i).name, min(eig(sta(i).cov)))
    p = chol(inv(p), 'lower');		% p*p' is the precision matrix
    subplot(length(lSta), 1, i)
    sta(i).Md(5:6) = [Inf,-Inf];	% initialize extreme values
    for j = 1 : sta(i).nYr		% year loop at station i:
       q = any(cell2mat(cellfun(@(x)strcmp(sta(i).d(j).qFlg, x), {'N/A' 'OK'}, 'UniformOutput', false)), 2);
       if ~any(q)			% not even 1 'OK' or 'N/A' datum
	  fprintf('Not even 1 ''OK'' or ''N/A'' datum for %5s_%d\n', sta(i).name, sta(i).yr(j))
	  continue
       end
       r = sqrt(sum(((sta(i).d(j).f - repmat(sta(i).ags.m, sta(i).d(j).nt, 1))*p).^2, 2));
       q = q & isfinite(r);		% LGST can be -Inf
       r = r(q);
       Jan1 = datenum(sprintf('01-01-%4d 00:00', sta(i).yr(j)), datef);
       t = (sta(i).d(j).t(q) + rDate ...% months since January 1 00:00
	  - Jan1)*12/365;
       [u v] = min(r);
       if u < sta(i).Md(5)
	  sta(i).Md(5) = u;
	  sta(i).Md(3) = t(v);
	  sta(i).Md(1) = sta(i).yr(j);
       end
       [u v] = max(r);
       if u > sta(i).Md(6)
	  sta(i).Md(6) = u;
	  sta(i).Md(4) = t(v);
	  sta(i).Md(2) = sta(i).yr(j);
       end
       line(t, r, 'Color', cm(j,:), 'DisplayName', sprintf('{\\ity}=%d', sta(i).yr(j)), 'LineStyle', 'none', 'Marker', '.')
    end
    line(sta(i).Md(3), sta(i).Md(5), 'DisplayName', 'min', 'LineStyle', 'none', 'Marker', 'v', 'MarkerSize', 2^3)
    line(sta(i).Md(4), sta(i).Md(6), 'DisplayName', 'max', 'LineStyle', 'none', 'Marker', '^', 'MarkerSize', 2^3)
    set(gca, 'YScale', 'log', 'YTick', 2.^(floor(log2(sta(i).Md(5))) : 2 : ceil(log2(sta(i).Md(6)))))
    axis tight
    legend('Location','eastoutside')
    title(sprintf('{\\itd}[%d,%5.2f] = %5.2f \\leq (%5s\\_%d:%d Mahalanobis distance {\\itd}[{\\ity},{\\itt}] from {\\it\\mu}) \\leq {\\itd}[%d,%5.2f] = %5.2f', ...
       sta(i).Md([1 3 5]), sta(i).name, sta(i).yr([1 end]), sta(i).Md([2 4 6])))
    if i == lSta(end)
       xlabel('{\itt} = months since January 1 00:00')
    end
 end, clear i j k l m p q r t u v
 orient landscape
%  arrayfun(@(x)norm(x.cov-x.cov',1)/norm(x.cov,1),sta)
%  arrayfun(@(x)min(eig(x.cov)),sta)
