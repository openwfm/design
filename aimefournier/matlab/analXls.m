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
 wd = '~/research/UCD/FASMEE/fasmee/aimefournier/matlab/'
 cd(wd)			 		% directory of scripts
 %% 
 if ~exist(matF, 'file')		% spreadsheet processing not yet done
    datef = 'yyyy-mm-ddTHH:MM:SSZ';	% date format
    datList = {'air_temp' ...		% data types of interest
       'relative_humidity' 'wind_speed' 'wind_direction' 'wind_gust'}
    % datList = {'TMP' 'RELH' 'SKNT' 'GUST' 'DRCT'};
    %
    % Below here, everything should work automatically...
    %
    nDat = length(datList);		% nu. data types
    %
    % Assign station and data names from bReqF to cell array sta:
    %
    T = table2cell(readtable(bReqF, 'ReadVariableNames', false));
    bReqH = cellfun(@(x) ...		% burn requirements header
       sscanf(x, '%s %s%*s%*s'), T(1,2 : end), 'UniformOutput', false)
    nReq = length(bReqH)/2;		% assume min, max for each requirement
    fprintf('%s contains %d (min,max) burn-requirement pairs', bReqF, nReq)
    sta = cellfun(...			% formatted read of station names:
       @(x) sscanf(x, 'ID = %s'), T(2 : end,1), 'UniformOutput', false)';
    l = ones(1, length(sta));		% allocate nu. time windows at stations
    for i = 2 : length(sta)		% seek multiple windows at each station
       j = find(strcmp(sta{i}, sta(1 : i - 1)));
       if length(j)			% length(j) > 0 means duplicate names ...
	  l([i j]) = length(j) + 1;	% assign equal counts to duplicates
       end
    end,clear i j
    [sta i] = unique(sta);
    %
    % Change unique(sta) into a structure:
    %
    sta = struct('name', sta, 'nWin', num2cell(l(i)));
    fprintf(' for stations\n\t%s\b.\n', sprintf('%s ', sta.name))
    lSta = 1 : length(sta);		% station list
    %
    % Assign burn required data min, max at each station:
    %
    k = 2;				% skip header row
    for i = lSta			% station loop:
       for j = 1 : sta(i).nWin		% window loop:
	  fprintf('Station %5s, window %d requires\n ', sta(i).name, j)
	  m = reshape(cellfun(@str2num, T(k,2 : 2*nReq - 1)), 2, nReq - 1);
	  for l = 1 : nDat
	     f = find(strcmp( ...	% compare to data type list:
		datList{l}, cellfun(@(x) x(4:end), bReqH(2*(1 : nReq - 1)), 'UniformOutput', false)));
	     if isempty(f)
		sta(i).bReqs(1 : 2,l,j) = [-Inf Inf];
	     else
		sta(i).bReqs(1 : 2, ...	% min & max values of data:
		   l,j) = m(:,f);
		fprintf('%d<=%s<=%d, ', sta(i).bReqs(1,l,j), bReqH{2*f}(4:end), sta(i).bReqs(2,l,j))
		switch bReqH{2*f}(4:end)% convert units:
		   case 'wind_speed'	% convert mi/h to m/s:
		      sta(i).bReqs(:,l,j) = ...
			 sta(i).bReqs(:,l,j)*1609.344/60^2;
		   case 'air_temp'		% convert deg F to deg C:
		      sta(i).bReqs(:,l,j) = ...
			 (sta(i).bReqs(:,l,j) - 32)*5/9;
		end
	     end
	  end
	  for l = 1 : 2			% start and finish of time window:
	     [~, sta(i).bmdh{l,1 : 3,j}] = datevec(T{k,2*nReq - 1 + l});
	  end
	  k = k + 1;			% point to next row
	  fprintf('%02d/%02d<=day<=%02d/%02d, %02d<=hour<=%02d.\n', ...
	     cell2mat(sta(i).bmdh(:,1:2,j))', sta(i).bmdh{:,3,j})
       end
       sta(i).bmdh = cell2mat(sta(i).bmdh);
    end,clear f i j k l m T
    for i = lSta			% station loop:
       %
       % Read data from spreadsheet for station i:
       %
       d = dir(fullfile(ext, sprintf('%s*.%s', sta(i).name,ext)));
       fprintf('Processing file %35s, %d of %d, takes ', d.name, i, lSta(end))
       tic
       f = fopen(fullfile(ext, d.name));
       for j = 1 : intmax		% loop over metadata rows (starting with '#'):
	  T = fgetl(f);
	  if strcmp(T(1), '#')
	     g = max(find(T==':'));
	     eval(['sta(i).' matlab.lang.makeValidName(regexprep(T(min(find(T==' ')) + 1 : g - 1),' ','_')) ...
		'=''' T(g + 2 : end) ''';'])
	  else
	     break;			% now T is the main data header now
	  end
       end
       sta(i).hdr = T;			% header row
       T = strsplit(strrep(T, ...	% truncate useless suffices and
	  '_set_1', ''), ',');		% split strings delimited by ','
       sta(i).datI = find(cellfun( ...	% data column indexes
	  @(x) sum(ismember(datList, x)), T));
       T = strsplit(fgetl(f), ',');
       sta(i).u = T(sta(i).datI - 1);	% units row
       T = textscan(f, ['%s%s' ...	% read 2 strings, then some floats, then skip to EOL:
	  repmat('%f', 1, max(sta(i).datI) - 2) '%*[^\n]'], 'Delimiter', ',');
       fclose(f);
       sta(i).t = datenum(T{2}, datef);	% time (days) in column 2
       % sta(i).yr = unique(num2cell(datestr(sta(i).t, 'yyyy'), 2));
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
 %
 % Print the analXls_figs figures:
 %
 n = 1;
 for i = lSta
    for l = 1 : sta(i).nWin
       print(n, '-dpng', sprintf('figures/%s_w%d_data', sta(i).name, l))
       n = n + 1;
    end
 end
%% 
 fprintf('Transform (%s\b)\n', sprintf('%s ', datList{:}))
 d2c = @(x)-[sind(x),cosd(x)];		% direction-to-component transform
 %
 % Get indexes for data types:
 %
 kd = find(strcmp(datList,'wind_direction'));
 kg = find(strcmp(datList,'wind_gust'));% index for wind gust
 kr = find(strcmp(datList,'relative_humidity'));
 ks = find(strcmp(datList,'wind_speed'));
 kt = find(strcmp(datList,'air_temp'));	% index for temperature
 %
 % Assign new data-type names:
 %
 datList([kr ks kd kg]) = {... %'LRH'
    'DWP' 'UWND' 'VWND' 'LGST'};
 fprintf('\tto (%s\b).\n', sprintf('%s ', datList{:}))
 for i = lSta				% station loop:
    sta(i).d(:,kr) = ...		% change RELH to dew-point temperature:
       RELH2DWT(sta(i).d(:,kr), sta(i).d(:,kt));
%      log10(sta(i).d(:,kr));		% _or_ just take its log10.
    sta(i).u{kr} = 'Celsius';		% update units
    sta(i).d(sta(i).d(:,ks) == 0,kd) ...% replace wind_direction NaNs when wind_direction not defined:
        = 0;
    sta(i).d(:,[ks kd kg]) = ...	% apply d2c and GUST -> LGST:
       [bsxfun(@times, sta(i).d(:,ks), d2c(sta(i).d(:,kd))) log10(sta(i).d(:,kg))];
    sta(i).u{kd} = sta(i).u{ks};	% change label units
 end,clear d2c i j kd kg kr ks kt
 %% 
 if ~any(strcmp(fieldnames(sta),'mom'))	% Moments not computed yet
    %
    % Get indexes for data types:
    %
    kt = find(strcmp(datList(1 : nDat), 'air_temp' ));
    kd = find(strcmp(datList(1 : nDat), 'DWP'      ));
    ku = find(strcmp(datList(1 : nDat), 'UWND'     ));
    kv = find(strcmp(datList(1 : nDat), 'VWND'     ));
    ib = @(a,x) a(1) <= x & x <= a(2);	% in-between condition
%     n = sum(cell2mat({sta.nWin})) + 1;
    for i = lSta			% station (with burn requirements) loop:
       [~, d{1 : 3}] = datevec(sta(i).t);
       for l = 1 : sta(i).nWin		% window loop at station i:
	  %
	  % logical f tests the burn requirements, 1st for month, day, hour:
	  %
          f = ib(sta(i).bmdh( :, 1,l), d{1}) & ...
	      ib(sta(i).bmdh( :, 2,l), d{2}) & ...
	      ib(sta(i).bmdh( :, 3,l), d{3});
	  fprintf('%5s, %4dd in window %d: ', sta(i).name, sum(f), l)
	  %
	  % ... then not too hot or cold:
	  %
	  f = f & ib(sta(i).bReqs(:,kt,l), sta(i).d(:,kt));
	  fprintf('%4d OK air_temp, ', sum(f))
	  %
	  % ... then not too wet or dry:
	  %
	  f = f & ib(sta(i).bReqs(:,kd,l), RELH2DWT(sta(i).d(:,kd), sta(i).d(:,kt), -1));
	  fprintf('%4d OK relative_humidity, ', sum(f))
	  %
	  % ... then not too fast or slow:
	  %
	  f = f & ib(sta(i).bReqs(:,ku,l), sqrt(sum(sta(i).d(:,[ku kv]).^2, 2)));
          fprintf('%4d OK wind_speed, ', sum(f))
	  f = bsxfun(@and, f, isfinite(sta(i).d));
	  %
	  % sample size n:
	  %
	  sta(i).mom(l).n = sum(f);
	  %
	  % Allocate sample mean m, std dev s, upper-diagonal correlation r:
	  %
	  sta(i).mom(l).m = NaN(  1, nDat             );
	  sta(i).mom(l).s = NaN(  1, nDat             );
	  sta(i).mom(l).r = NaN(  1, nDat*(nDat - 1)/2);
          fprintf('[%s\b] finite values\n', sprintf('%3d ', sta(i).mom(l).n))
	  for k = 1 : nDat
	     if sta(i).mom(l).n(k) > 0
		%
		% Compute the sample mean:
		%
		sta(i).mom(l).m(k) = mean(sta(i).d(f(:,k),k));
	     else
		fprintf('%s-%d %s has no data\n', sta(i).name, l, datList{k})
	     end
	     if sta(i).mom(l).n(k) > 1
		%
		% Compute the std dev:
		%
		sta(i).mom(l).s(k) = std(sta(i).d(f(:,k),k));
	     else
		fprintf('%s-%d %s has one datum\n', sta(i).name, l, datList{k})
	     end
	  end
	  g = logical(prod(f, 2));	% 'AND' through all requirements
	  if sum(g) > 1			% at least 2 data pass requirements
% 	     figure(n)
% 	     set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
% 	     clf
	     m = 0;			% initialize correlation index
	     for k = 1 : nDat - 1	% correlation row k
		for j = k + 1 : nDat	% correlation column j (upper diagonal)
		   m = m + 1;		% update correlation index
		   %
		   % Compute the j,k--correlation:
		   %
		   a = corrcoef(sta(i).d(g,j), sta(i).d(g,k));
		   sta(i).mom(l).r(m) = a(1,2);
% 		   subplot(nDat - 1, nDat - 1, (nDat - 1)*(k - 1) + j - 1, 'align')
% 		   plot(sta(i).d(~g,j), sta(i).d(~g,k), 'c.', ...
% 		        sta(i).d( g,j), sta(i).d( g,k), 'ro', 'MarkerFaceColor', 'r')
% 		   set(covEllip(sta(i).mom(l).s([j k]), sta(i).mom(l).r(m), sta(i).mom(l).m([j k])), ...
% 		      'Color', 'b', 'LineWidth', 2)
% 		   if j == k + 1
% 		      if k == 1
% 			 title(sprintf('Station %s window %d', sta(i).name, l))
% 		      end
% 		      xlabel(sprintf('%s (%s)', strrep(datList{j}, '_', '\_'), sta(i).u{j}))
% 		      ylabel(sprintf('%s (%s)', strrep(datList{k}, '_', '\_'), sta(i).u{k}))
% 		   else
% 		      set(gca, 'XTickLabel', '', 'YTickLabel', '')
% 		   end
% 		   axis tight
		end
	     end
% 	     drawnow
% 	     orient tall
% 	     orient landscape		% needs to follow 'tall'
% 	     print(n, '-dpng', sprintf('figures/%s_w%d_scat', sta(i).name, l))
% 	     n = n + 1;
	  else
	     fprintf('\n%s-%d has no good data\n\n', sta(i).name, l)
	  end
       end
    end, clear a f g i ib j k kd kt ku kv l m n
 end
 %% 
%  analXls_stats
 %% 
 analXls_Mdists
 %% 
 analXls_Mhists