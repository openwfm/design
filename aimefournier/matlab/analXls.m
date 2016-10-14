% Author:	Aimé Fournier
% File:		analXls.m
% Purpose:	Analyze .xlsx spreadsheets as described below.

 clear
%
% The intention is to run this script section-by-section (between "%%") from
% the Matlab editor using the Command-Enter keystroke;
% however, it may work simply from the Matlab command window too.
% It will display what it is doing.
%
% A few lines may need to be edited for customized use:
%
 ext = 'csv';				% spreadsheet file extension
 bReqF = fullfile(ext, ['bReqs.' ext]); % burn requirements file
 matF = fullfile('mat', 'analXls.mat');	% .mat file name
 wd = '~/research/UCD/FASMEE/fasmee/aimefournier/matlab/';
 cd(wd)			 		% directory of scripts
 %% 
 if ~exist(matF, 'file')		% spreadsheet processing not yet done
    datef = 'yyyy-mm-ddTHH:MM:SSZ';	% date format
    datList = {'air_temp' ...		% data types of interest
       'relative_humidity' 'wind_speed' 'wind_direction' 'wind_gust'};
    % datList = {'TMP' 'RELH' 'SKNT' 'GUST' 'DRCT'};
    %
    % Below here, everything should work automatically...
    %
    % Assign station and data names from bReqF:
    %
    T = table2cell(readtable(bReqF, 'ReadVariableNames', false));
    bReqH = cellfun(@(x) ...		% burn requirements header
       sscanf(x, '%s %s%*s%*s'), T(1,2 : end), 'UniformOutput', false);
    nReq = length(bReqH)/2;		% assume min, max for each requirement
    sta = cellfun(...			% formatted read of station names:
       @(x) sscanf(x, 'ID = %s'), T(2 : end,1), 'UniformOutput', false)';
    l = ones(1, length(sta));		% nu. time windows at stations
    for i = 2 : length(sta)		% seek multiple windows at each station
       j = find(strcmp(sta{i}, sta(1 : i - 1)));
       if length(j)			% length(j) > 0 means duplicate names ...
	  l([i j]) = length(j) + 1;
       end
    end,clear i j
    [sta i] = unique(sta);
    sta = struct('name', sta, 'nWin', num2cell(l(i)));
    lSta = 1 : length(sta);		% station list
    %
    % Assign burn required data min, max at each station:
    %
    k = 2;				% skip header row
    for i = lSta			% station loop:
       for j = 1 : sta(i).nWin		% window loop:
	  sta(i).bReqs(1 : 2, ...	% min & max values of data:
	     1 : nReq - 1, j) = reshape(cellfun(@str2num, T(k,2 : 2*nReq - 1)), 2, nReq - 1);
	  for l = 1 : 2			% start and finish of time window:
	     [~, sta(i).bmdh{l, 1 : 3, j}] = datevec(T{k,2*nReq - 1 + l});
	  end
	  k = k + 1;			% point to next row
	  fprintf('Station %5s, window %d requires ', sta(i).name, j)
	  for l = 1 : nReq - 1
	     fprintf('%d<=%s<=%d, ', sta(i).bReqs(1,l,j), bReqH{2*l}(4:end), sta(i).bReqs(2,l,j))
	     switch bReqH{2*l}(4:end)	% convert units:
		case 'SKNT'
		   sta(i).bReqs(:,l,j) = ...	% convert mi/h to m/s:
		      sta(i).bReqs(:,l,j)*1609.344/60^2;
		case 'TMP'
		   sta(i).bReqs(:,l,j) = ...	% convert deg F to deg C:
		      (sta(i).bReqs(:,l,j) - 32)*5/9;
	     end
	  end
	  fprintf('%02d/%02d<=day<=%02d/%02d, %02d<=hour<=%02d.\n', ...
	     cell2mat(sta(i).bmdh(:,1:2,j))', sta(i).bmdh{:,3,j})
       end
       sta(i).bmdh = cell2mat(sta(i).bmdh);
    end,clear i j T
    nDat = length(datList);		% nu. data types
    for i = lSta			% station loop:
       %
       % Read data from spreadsheet for station i:
       %
       d = dir(fullfile(ext, sprintf('%s*.%s', sta(i).name,ext)));
       fprintf('Processing file %35s, %d of %d, takes ', d.name, i, lSta(end))
       tic
       f = fopen(fullfile(ext, d.name));
       for j = 1 : intmax		% loop over text starting with '#':
	  T = fgetl(f);
	  if strcmp(T(1), '#')
	     g = max(find(T==':'));
	     eval(['sta(i).' matlab.lang.makeValidName(regexprep(T(min(find(T==' ')) + 1 : g - 1),' ','_')) ...
		'=''' T(g + 2 : end) ''';'])
	  else
	     break;			% T is the header now
	  end
       end
       sta(i).hdr = T;			% header row
       T = strsplit(strrep(T, ...	% truncate useless suffices and
	  '_set_1', ''), ',');		% split strings delimited by ','
       sta(i).datI = find(cellfun( ...	% data column indexes
	  @(x) sum(ismember(datList, x)), T));
       T = strsplit(fgetl(f), ',');	% units row
       sta(i).u = T(sta(i).datI - 1);
       T = textscan(f, ['%s%s' ...	% read 2 strings, then floats:
	  repmat('%f', 1, length(T) - 1)], 'Delimiter', ',');
       fclose(f);
       sta(i).t = datenum(T{2}, datef);	% time (days) in column 2
       sta(i).d = cell2mat( ...		% data in other columns
	  T(:,sta(i).datI));
       sta(i).nt = length(sta(i).t);	% nu. times
       fprintf('%5.1fs\n',toc)
    end, clear d f i j T
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
%
%	     n is the sample size
%	     m is the mean
%	     s is the std dev
%	     r is the correlation
%
	     sta(i).mom(j).n = zeros(1, nDat             );
	     sta(i).mom(j).m = NaN(  1, nDat             );
	     sta(i).mom(j).s = NaN(  1, nDat             );
	     sta(i).mom(j).r = NaN(  1, nDat*(nDat - 1)/2);
	     continue			% re-enter loop at next j value
	  end
%
% Explain q in words
%
	  q = any(cell2mat(cellfun(@(x)strcmp(sta(i).d(j).qFlg, x), {'N/A' 'OK'}, 'UniformOutput', false)), 2);
	  fprintf('%5s_%d %4d days: %4d OK QFLG, ', sta(i).name, sta(i).yr(j), sta(i).d(j).nt, sum(q))
	  Jan1 = datenum(sprintf('01-01-%4d 00:00', sta(i).yr(j)), datef);
	  t = (sta(i).d(j).t ...	% months since January 1 00:00
	      - Jan1)*12/365;
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
%
%		Compute the mean for this year:
%
		sta(i).mom(j).m(k) = sum(sta(i).d(j).f(q(:,k),k))/sta(i).mom(j).n(k);
%
%		Aggregate over years:
%
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
         max(arrayfun(@(x)max(cell2mat(arrayfun(@(y) max(y.t), x.d, 'UniformOutput', false))), sta))];
