% Author:               Aime' Fournier
% Project Title:        Modeling support for FASMEE experimental design using WRF-SFIRE-CHEM
% JFSP project number:  16-4-05-3
% File:		        analXls.m
% Purpose:	        Analyze .xlsx spreadsheets as described below.

 clear

%
% The intention is to run this script section-by-section (between "%%") from
% the Matlab editor using the Command-Enter keystroke;
% however, it may work simply from the Matlab command window too.
% It will display what it is doing.
%
% The following few lines may need to be edited for customized use:
%
 ext = 'csv';				% spreadsheet file extension
 bReqF = fullfile(ext, ['bReqs.' ext]); % burn requirements file
 matF = fullfile('mat', 'analXls.mat');	% .mat file name
 wd = '~/research/UCD/FASMEE/fasmee/aimefournier/matlab/'
 cd(wd)			 		% directory of scripts
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
       if ~isempty(j)			% length(j) > 0 means duplicate names ...
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
		   case 'air_temp'	% convert deg F to deg C:
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
	     g = find(T == ':', 1, 'last' );
	     eval(['sta(i).' matlab.lang.makeValidName(regexprep(T(find(T == ' ', 1 ) + 1 : g - 1),' ','_')) ...
		'=''' T(g + 2 : end) ''';'])
	  else
	     break;			% now T is the main data header now
	  end
       end
       sta(i).hdr = T;			% header row
       T = strsplit(strrep(T, ...	% truncate useless suffices and
	  '_set_1', ''), ',');		% split strings delimited by ','
       datI = find(cellfun( ...		% data column indexes
	  @(x) sum(ismember(datList, x)), T));
       T = strsplit(fgetl(f), ',');
       sta(i).u = T(datI - 1);		% units row
       T = textscan(f, ['%s%s' ...	% read 2 strings, then some floats, then skip to EOL:
	  repmat('%f', 1, max(datI) - 2) '%*[^\n]'], 'Delimiter', ',');
       fclose(f);
       sta(i).t = datenum(T{2}, datef);	% time (days) in column 2
       % sta(i).yr = unique(num2cell(datestr(sta(i).t, 'yyyy'), 2));
       sta(i).d = cell2mat( ...		% data in other columns
	  T(:,datI));
       k = find(strcmp(datList,'air_temp'));
       T = find(sta(i).d(:,k) < -63 |  57 < sta(i).d(:,k));
       sta(i).d(T,:) = [];		% eliminate extreme air_temp
       sta(i).t(T  ) = [];
       k = find(strcmp(datList,'relative_humidity'));
       T = find(sta(i).d(:,k) <   0 | 100 < sta(i).d(:,k));
       sta(i).d(T,:) = [];		% eliminate impossible relative_humidity
       sta(i).t(T  ) = [];
       [~, k] = intersect(datList, {'wind_speed', 'wind_gust'}, 'stable');
       T = find(any(sta(i).d(:,k) <   0 | 103 < sta(i).d(:,k), 2));
       sta(i).d(T,:) = [];		% eliminate extreme or impossible wind
       sta(i).t(T  ) = [];
       sta(i).nt = length(sta(i).t);	% nu. times
       fprintf('%5.1fs\n',toc)
    end, clear d datI f i j T
    save(matF)
 else
    tic
    fprintf('Loading %s takes ',matF)
    load(matF)
    fprintf('%5.1fs\n',toc)
 end

 %% 
 analXls_figs				% Don't run after transforming below!
 %% 
 %
 % Print the analXls_figs figures:
 %
 for i = lSta
    print(i, '-dpng', sprintf('figures/%s_data', sta(i).name))
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
       RELH2DWT(sta(i).d(:,kr), sta(i).d(:,kt)); %#ok<*FNDSB>
%      log10(sta(i).d(:,kr));		% _or_ just take its log10.
    sta(i).u{kr} = 'Celsius';		% update units
    sta(i).d(sta(i).d(:,ks) == 0,kd) ...% replace wind_direction NaNs when wind_direction not defined:
        = 0;
    sta(i).d(:,[ks kd kg]) = ...	% apply d2c and GUST -> LGST:
       [bsxfun(@times, sta(i).d(:,ks), d2c(sta(i).d(:,kd))) log10(sta(i).d(:,kg))];
    sta(i).u{kd} = sta(i).u{ks};	% change label units
 end,clear d2c i j kd kg kr ks kt
 %% 
 if ~any(strcmp(fieldnames(sta), 'mom'))% Moments not computed yet
    %
    % Get indexes for data types:
    %
    kt = find(strcmp(datList(1 : nDat), 'air_temp' ));
    kd = find(strcmp(datList(1 : nDat), 'DWP'      ));
    ku = find(strcmp(datList(1 : nDat), 'UWND'     ));
    kv = find(strcmp(datList(1 : nDat), 'VWND'     ));
    cm = gray(max(arrayfun(@(x)x.nWin, sta)) + 2);
    cm(end,:) = [];			% don't use white color
    ib = @(a,x) a(1) <= x & x <= a(2);	% in-between condition
    for i = lSta			% station (with burn requirements) loop:
       %
       % logical f tests the burn requirements, 1st, not too hot or cold:
       %
       f = ib(sta(i).bReqs(:,kt,1), sta(i).d(:,kt));
       fprintf('%5s has %4dd OK air_temp, ', sta(i).name, sum(f))
       %
       % ... then not too wet or dry:
       %
       f = f & ib(sta(i).bReqs(:,kd,1), RELH2DWT(sta(i).d(:,kd), sta(i).d(:,kt), -1));
       fprintf('%4d OK relative_humidity, ', sum(f))
       %
       % ... then not too fast or slow:
       %
       f = f & ib(sta(i).bReqs(:,ku,1), sqrt(sum(sta(i).d(:,[ku kv]).^2, 2)));
       fprintf('%4d OK wind_speed, ', sum(f))
       f = bsxfun(@and, f, isfinite(sta(i).d));
       %
       % sample size n:
       %
       sta(i).mom.n = sum(f);
       %
       % Allocate sample mean m, std dev s, upper-diagonal correlation r:
       %
       sta(i).mom.m = NaN(  1, nDat             );
       sta(i).mom.s = NaN(  1, nDat             );
       sta(i).mom.r = NaN(  1, nDat*(nDat - 1)/2);
       fprintf('[%s\b] finite values\n', sprintf('%3d ', sta(i).mom.n))
       for k = 1 : nDat
	  if sta(i).mom.n(k) > 0
	     %
	     % Compute the sample mean:
	     %
	     sta(i).mom.m(k) = mean(sta(i).d(f(:,k),k));
	  else
	     fprintf('%s %s has no data\n', sta(i).name, datList{k})
	  end
	  if sta(i).mom.n(k) > 1
	     %
	     % Compute the std dev:
	     %
	     sta(i).mom.s(k) = std(sta(i).d(f(:,k),k));
	  else
	     fprintf('%s %s has one datum\n', sta(i).name, datList{k})
	  end
       end
       figure(lSta(end) + i)
       set(gcf, 'Units', 'normalized', 'OuterPosition', [1/8 0 7/8 1], 'Units', 'pixels')
       clf
       f = logical(prod(f, 2));		% 'AND' through all requirements
       [~,~,~,h] = datevec(sta(i).t);	% hour-of-day for each time
       if sum(f) > 1			% at least 2 data pass requirements
	  m = 0;			% initialize correlation index
	  for k = 1 : nDat - 1		% correlation row k
	     for j = k + 1 : nDat	% correlation column j (upper diagonal)
		m = m + 1;		% update correlation index
		%
		% Compute the j,k--correlation:
		%
		a = corrcoef(sta(i).d(f,j), sta(i).d(f,k));
		sta(i).mom.r(m) = a(1,2);
		subplot(nDat - 1, nDat - 1, (nDat - 1)*(k - 1) + j - 1, 'align')
		plot(sta(i).d(~f,j), sta(i).d(~f,k), '.', 'Color', cm(end,:), 'MarkerSize', 1, 'ZData', -ones(sum(~f), 1))
		l = 1;			% same color for all windows
% 		for l = 1 : sta(i).nWin
% 		   b = datevec(sta(i).t);
% 		   b = datenum(repmat(b(:,1), 1, 2), repmat(sta(i).bmdh(:,1,l)', sta(i).nt, 1) ...
% 		                                   , repmat(sta(i).bmdh(:,2,l)', sta(i).nt, 1));
		   %
		   % Enforce month-day-hour and data-value conditions:
		   %
		   g = f;% &   b(:,1) <= sta(i).t & sta(i).t <= b(:,2) & ib(sta(i).bmdh(:,3,l), h) ;
		   line(sta(i).d(g,j), sta(i).d(g,k), 'Color', cm(  l,:), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 6, 'ZData', ones(sum(g), 1))
% 		   g = f & ~(b(:,1) <= sta(i).t & sta(i).t <= b(:,2) & ib(sta(i).bmdh(:,3,l), h));
% 		   line(sta(i).d(g,j), sta(i).d(g,k), 'Color', cm(end,:), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 1)
% 		end
		set(covEllip(sta(i).mom.s([j k]), sta(i).mom.r(m), sta(i).mom.m([j k]), 32), ...
		   'Color', 'g', 'LineWidth', 3, 'ZData', 2*ones(32, 1))
		if j == k + 1
		   if k == 1
		      title(sprintf('Station %s', sta(i).name))
		   end
		   xlabel(sprintf('%s (%s)', strrep(datList{j}, '_', '\_'), sta(i).u{j}))
		   ylabel(sprintf('%s (%s)', strrep(datList{k}, '_', '\_'), sta(i).u{k}))
		else
		   set(gca, 'XTickLabel', '', 'YTickLabel', '')
		end
		axis([sta(i).mom.m(j)+[-1 1]*3*sta(i).mom.s(j) ...
		      sta(i).mom.m(k)+[-1 1]*3*sta(i).mom.s(k)])
	     end
	  end
	  drawnow
	  orient tall
	  orient landscape		% needs to follow 'tall'
       else
	  fprintf('\n%s has no good data\n\n', sta(i).name)
       end
    end, clear a f g i ib j k kd kt ku kv l m n
 end
 %% 
 for i = lSta			% station (with burn requirements) loop:
    figure(lSta(end) + i)
    print('-dpng', sprintf('figures/%s_scat', sta(i).name))
 end
 
 %% 
%  analXls_stats
 %% 
 analXls_Mdists
 %% 
 analXls_Mhists
