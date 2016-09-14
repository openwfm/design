
% Author:	Aimé Fournier
% File:		analXls.m
% Purpose:	Analyze .xlsx spreadsheets

 clear
%
% The intention is to run this script section-by-section (between %%) from
% the Matlab editor using the Command-Enter keystroke;
% however, it may work simply from the Matlab command window too.
% It will display what it is doing.
%
% A few lines may need to be edited for customized use:
%
 wd = '~/research/UCD/FASMEE/fasmee/aimefournier/matlab/';
 cd(wd)			 		% directory of scripts
 matF = fullfile('mat','analXls.mat');	% .mat file name
 if ~exist(matF, 'file')		% spreadsheet processing not yet done
    datList = {'TMP' 'RELH' 'SKNT' ...	% data types of interest
       'GUST' 'DRCT'};
    nDat = length(datList);		% nu. data types
    bReqs = repmat([-Inf Inf], ...	% burn required ranges at 6 stations
       nDat + 1, 1, 6);
    bReqs([1:3 6],:,1) = [61 85		% TeMPerature range (deg F)
                          16 22		% RELative Humidity range (%)
		           0 15		% Speed in mi/h (not KNoTs)
		           9 10];	% Sep--Oct for station FSHU1
    bReqs([1:3 6],:,2) = [60 90		% TeMPerature range (deg F)
                          30 55		% RELative Humidity range (%)
		           6 20		% Speed in mi/h (not KNoTs)
		           1  3];	% Jan--Mar for station KCWV
    bReqs(:,:,3:4) = bReqs(:,:,[2 2]);	% stations KLHW,  LCSS1 like KCWV
    bReqs(:,:,5:6) = bReqs(:,:,[1 1]);	% stations QLBA3, TT084 like FSHU1
    ext = 'xlsx';			% spreadsheet file extension
%
% Below here, everything should work automatically...
%
    bReqs(1,:,:) = (bReqs(1,:,:) - ...	% convert deg F to deg C
       32)*5/9;
    bReqs(3,:,:) = bReqs(3,:,:)* ...	% convert to m/s
       1609.344/60^2;
    d = dir(fullfile(ext, ['*' ext]));	% files listing
    fprintf('Starting reading %d files ', length(d))
    sta = struct('name', unique( ...	% unique station names ...
       arrayfun(@(x) x.name(1:max( ...	% ... assuming before last '_'
       strfind(x.name, '_')) - 1), ...
       d, 'UniformOutput', false)));
    lSta = 1 : length(sta);		% station list
    fprintf('from %d stations.\n', lSta(end))
    for i = lSta			% station loop:
       j = cellfun(@(x) ...		% files matching station i:
	  ~isempty(x), strfind({d.name}, sta(i).name));
       sta(i).nYr = sum(j);		% nu. years at station i
       sta(i).yr = cellfun(@(x) ...	% year after last '_' before last '.'
	  eval(x(max(strfind(x, '_')) + 1 : min(strfind(x, '.')) - 1)), {d(j).name});
       if sta(i).nYr ~= ...		% check all years counted
	      length(sta(i).yr)
	  error('%d = sta(%d).nYr ~= length(sta(%d).yr) = %d', ...
	     sta(i).nYr, i, i, length(sta(i).yrs))
       end
    end, clear i j
    if length(cell2mat({sta.yr})) ~= ...% check all files processed:
	  length(d)
       error('%d = length(cell2mat({sta.yr})) ~= length(d) = %d', ...
	  length(cell2mat({sta.yr})), length(d))
    end
    datef = 'mm-dd-yyyy HH:MM    ';	% date format
    rDate = datenum( ...		% reference date
       '01-01-2005 00:00', datef);
    warning('off','MATLAB:xlsreadold:Truncation');
%     clear tst,n = 1;
    for i = lSta			% station loop:
       sta(i).d = struct('hdr', ...	% allocate structure:
	  cell(1, sta(i).nYr));
       for j = 1 : sta(i).nYr		% year loop at station i:
	  m = fullfile(ext, sprintf(...	% reconstruct spreadsheet file name:
	     '%s_%d.%s', sta(i).name, sta(i).yr(j), ext));
	  tic
	  [num, txt] = xlsread(m);	% txt prepends the header row
% 	  tst{n} = find(cellfun(@(x)~isempty(x),strfind(txt(:,1),'<')));n=n+1;
	  if ~isempty(num)
	     sta(i).d(j).nt = ...	% nu. times
		size(num, 1);
	     sta(i).d(j).hdr = ...	% header row
		txt(1, :);
	     sta(i).d(j).ts = ...	% time string
		txt(1 + (1 : sta(i).d(j).nt), 1);
	     sta(i).d(j).note = ...	% foot note:
		txt(2 + sta(i).d(j).nt : end, 1);
	     sta(i).d(j).t = cellfun(...% time values:
		@(x) datenum(x, datef) - rDate, sta(i).d(j).ts);
	     q = cell2mat(arrayfun(@(x)~isempty(strfind(x{1},'EDT')), sta(i).d(j).ts, 'UniformOutput', false));
	     sta(i).d(j).t(q) = ...	% convert to GMT:
		sta(i).d(j).t(q) + 4/24;
	     q = cell2mat(arrayfun(@(x)~isempty(strfind(x{1},'EST')), sta(i).d(j).ts, 'UniformOutput', false));
	     sta(i).d(j).t(q) = ...	% convert to GMT:
		sta(i).d(j).t(q) + 5/24;
	     sta(i).d(j).qFlg = ...	% quality flag:
		txt(1 + (1 : sta(i).d(j).nt), ...
		cellfun(@(x) ~isempty(x), strfind(txt(1, :), 'QFLG')));
	     txt(:,1) = [];		% delete column 1
	     for k = 1 : nDat		% data-type loop:
		l = cellfun( ...	% find column for this type:
		   @(x) ~isempty(x), strfind(txt(1, :), datList{k}));
		sta(i).d(j).f(:,k) = ...% get field type k:
		   num(:, l);
		sta(i).d(j).u(k) = ...	% get units after 1st ' ':
		   cellfun(@(x) x(min(strfind(x, ' '))+1 : end), txt(1, l), ...
		   'UniformOutput', false);
	     end
	  else
	     sta(i).d(j).nt = 0;
	  end
	  fprintf('Processing %s took %5.2fs\n', m, toc)
       end
    end, clear i j k l m num q txt
    save(matF)
 else
    tic
    fprintf('Loading %s takes ',matF)
    load(matF)
    fprintf('%5.1fs\n',toc)
 end
 %% 
 analXls_figs
 %% 
 d2c = @(x)-[sind(x),cosd(x)];		% direction 2 component transform
 kt = find(strcmp(datList,'TMP'))	% index for relative humidity
 kr = find(strcmp(datList,'RELH'))	% index for relative humidity
 ks = find(strcmp(datList,'SKNT'))	% index for wind speed
 kg = find(strcmp(datList,'GUST'))	% index for wind gust
 kd = find(strcmp(datList,'DRCT'))	% index for wind direction clockwise from north
 datList([kr ks kg kd]) = {... %'LRH'
    'DWP' 'UWND' 'VWND' 'LGST'};
 bReqs([kg kd],:,:) = ...		% keep SKNT requirement in UWND row of bReqs ...
    bReqs([kd kg],:,:);			% but swap GUST and DRCT requirements (currently null).
 for i = lSta				% station loop:
    for j = find(arrayfun(@(x) x.nt > 0, sta(i).d))
       sta(i).d(j).f(:,kr) = ...	% change RELH to dew point temperature:
	  RELH2DWT(sta(i).d(j).f(:,kr), sta(i).d(j).f(:,kt));
% 	  log10(sta(i).d(j).f(:,kr));	% _or_ just take its log10.
       sta(i).d(j).u{kr} = 'âˆž C';
       sta(i).d(j).f( ...		% replace DRCT NaNs when SKNT == 0 (DRCT not defined):
	  sta(i).d(j).f(:,ks) == 0,kd) = 0;
       sta(i).d(j).f(:,[ks kg kd]) = ...% apply d2c and move GUST -> LGST to end:
	  [bsxfun(@times, sta(i).d(j).f(:,ks), d2c(sta(i).d(j).f(:,kd))) log10(sta(i).d(j).f(:,kg))];
       sta(i).d(j).u{kd} = ...		% change label units:
	  sta(i).d(j).u{ks};
    end
 end,clear d2c i j kd kg kr ks kt
 %% 
 if ~any(strcmp(fieldnames(sta),'mom'))
    kt = find(strcmp(datList(1 : nDat), 'TMP' ))
    kd = find(strcmp(datList(1 : nDat), 'DWP' ))
    ku = find(strcmp(datList(1 : nDat), 'UWND'))
    kv = find(strcmp(datList(1 : nDat), 'VWND'))
    ib = @(a,x) a(1) < x & x < a(2);	% in-between condition
    for i = lSta			% station (with burn requirements) loop:
       sta(i).ags = struct('n', zeros(1, nDat), 'm', zeros(1, nDat), 's', zeros(1, nDat), 'r', zeros(1, nDat*(nDat - 1)/2));
       for j = 1 : sta(i).nYr		% year loop at station i:
	  if sta(i).d(j).nt <= 0	% if there aren't times to plot:
	     fprintf('No times for %s_%d\n', sta(i).name, sta(i).yr(j))
	     sta(i).mom(j).n = zeros(1, nDat             );
	     sta(i).mom(j).m = NaN(  1, nDat             );
	     sta(i).mom(j).s = NaN(  1, nDat             );
	     sta(i).mom(j).r = NaN(  1, nDat*(nDat - 1)/2);
	     continue			% re-enter loop at next j value
	  end
	  q = any(cell2mat(cellfun(@(x)strcmp(sta(i).d(j).qFlg, x), {'N/A' 'OK'}, 'UniformOutput', false)), 2);
	  fprintf('%5s_%d %4d days: %4d OK QFLG, ', sta(i).name, sta(i).yr(j), sta(i).d(j).nt, sum(q))
	  Jan1 = datenum(sprintf('01-01-%4d 00:00', sta(i).yr(j)), datef);
	  t = (sta(i).d(j).t ...	% months since January 1 00:00
	     + rDate - Jan1)*12/365;
	  b = ([datenum(sprintf('%02d-01-%4d 00:00', bReqs(nDat+1,1,i)  , sta(i).yr(j)), datef) ...
	        datenum(sprintf('%02d-01-%4d 00:00', bReqs(nDat+1,2,i)+1, sta(i).yr(j)), datef) ] ...
	     - Jan1)*12/365;		% time requirement in months
	  q = q & b(1) <= t & ...	% not too early, and ...
	          b(2) >  t;		% ... not too late.
	  fprintf('%4d OK time, ', sum(q))
	  q = q & ib(bReqs(kt,:,i), ...	% ... not too hot or cold.
	             sta(i).d(j).f(:,kt));
	  fprintf('%4d OK %s, ', sum(q), datList{kt})
	  q = q & ib(bReqs(kd,:,i), ...	% ... not too wet or dry.
	             RELH2DWT(sta(i).d(j).f(:,kd), sta(i).d(j).f(:,kt), -1));
	  fprintf('%4d OK RELH, ', sum(q))
	  q = q & ib(bReqs(ku,:,i), ...	% ... not too fast or slow.
	             sqrt(sum(sta(i).d(j).f(:,[ku kv]).^2, 2)));
          fprintf('%4d OK SKNT, ', sum(q))
	  q = bsxfun(@and, q, isfinite(sta(i).d(j).f));
	  sta(i).mom(j).n = sum(q);	% nu. times meeting criteria for each field
          fprintf('[%s\b] finite values\n', sprintf('%3d ', sta(i).mom(j).n))
	  sta(i).ags.n = sta(i).ags.n + sta(i).mom(j).n;
	  for k = 1 : nDat
	     if sta(i).mom(j).n(k) > 0
		sta(i).mom(j).m(k) = sum(sta(i).d(j).f(q(:,k),k))/sta(i).mom(j).n(k);
		sta(i).ags.m(k) = ((sta(i).ags.n(k) - sta(i).mom(j).n(k))*sta(i).ags   .m(k) + ...
		                                      sta(i).mom(j).n(k) *sta(i).mom(j).m(k))/sta(i).ags.n(k);
	     else
		sta(i).mom(j).m(k) = NaN;
	     end
	     if sta(i).mom(j).n(k) > 1
		sta(i).mom(j).s(k) = sqrt(sum((sta(i).d(j).f(q(:,k),k) - sta(i).mom(j).m(k)).^2)/(sta(i).mom(j).n(k) - 1));
	        sta(i).ags.s(k) = ((sta(i).ags.n(k) - sta(i).mom(j).n(k) - 1)*sta(i).ags   .s(k)   + ...
	                           (                  sta(i).mom(j).n(k) - 1)*sta(i).mom(j).s(k)^2) ...
	                           /(sta(i).ags.n(k) - 1);
		if sta(i).ags.n(k) > sta(i).mom(j).n(k)
		   sta(i).ags.s(k) = sta(i).ags.s(k) + ...
		      (sta(i).mom(j).n(k)*sta(i).ags.n(k)/(sta(i).ags.n(k) - sta(i).mom(j).n(k))) * ...
		      (sta(i).mom(j).m(k) - sta(i).ags.m(k))^2/(sta(i).ags.n(k) - 1);
		end
	     else
		sta(i).mom(j).s(k) = NaN;
	     end
	  end
	  m = 0;
	  for k = 1 : nDat - 1
	     for l = k + 1 : nDat
		m = m + 1;
		if all(sta(i).mom(j).n([k l]) > 1)
		   sta(i).mom(j).r(m) = sum( ...
		      (sta(i).d(j).f(q(:,k) & q(:,l),k) - sta(i).mom(j).m(k))  ...
		    .*(sta(i).d(j).f(q(:,k) & q(:,l),l) - sta(i).mom(j).m(l))) ...
		        /((sum(q(:,k) & q(:,l)) - 1) * sta(i).mom(j).s(k) * sta(i).mom(j).s(l));
	           sta(i).ags.r(m) = ((sta(i).ags.n(k) - sta(i).mom(j).n(k) - 1)*sta(i).ags   .r(m) + ...
	                              (                  sta(i).mom(j).n(k) - 1)*sta(i).mom(j).s(k)*sta(i).mom(j).s(l)*sta(i).mom(j).r(m)) ...
				  /(sta(i).ags.n(k) - 1);
		   if sta(i).ags.n(k) > sta(i).mom(j).n(k)
		      sta(i).ags.r(m) = sta(i).ags.r(m) + ...
	                 (sta(i).mom(j).n(k)*sta(i).ags.n(k)/(sta(i).ags.n(k) - sta(i).mom(j).n(k))) * ...
			 (sta(i).mom(j).m(k) - sta(i).ags.m(k))*(sta(i).mom(j).m(l) - sta(i).ags.m(l))/(sta(i).ags.n(k) - 1);
		   end
		else
		   sta(i).mom(j).r(m) = NaN;
		end
	     end
	  end
       end
       sta(i).ags.s = sqrt(sta(i).ags.s);
       m = 0;
       for k = 1 : nDat - 1
	  for l = k + 1 : nDat
	     m = m + 1;
	     sta(i).ags.r(m) = sta(i).ags.r(m)/(sta(i).ags.s(k)*sta(i).ags.s(l));
	  end
       end
    end, clear b i ib j Jan1 k kd kt ku kv l m q t
 end
 %% 
 analXls_stats
 %% 
 analXls_Mdists
 %% 
 tLim = [min(arrayfun(@(x)min(cell2mat(arrayfun(@(y) min(y.t), x.d, 'UniformOutput', false))), sta))
         max(arrayfun(@(x)max(cell2mat(arrayfun(@(y) max(y.t), x.d, 'UniformOutput', false))), sta))] + rDate;
