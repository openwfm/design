% Adam Kochanski 09142016
% this is a silly script that downloads meteorolgical data from Mesowest using mosewest API

% we will construct a url in the following form:
% url1='http://api.mesowest.net/v2/stations/timeseries?stid=WBB&start=201306011800&end=201306021215&token=bf4e28a3ebee4a248ec430c64f1af5b3&output=csv'
% then we will donload the cvs content and save to disk

token='bf4e28a3ebee4a248ec430c64f1af5b3'  %security token needed to donaload Mesowest data
startdate =199901010000    %start time for data request YYYYMMDDHHMM
enddate   =201609140000      %end time for data request  YYYYMMDDHHMM
for stid = {'KCWV','KLHW','FSHU1','TT084','QLBA3', 'LCSS1'} % list of station ids to be downloaded
    % construct url for Mesowest API
    url=sprintf('http://api.mesowest.net/v2/stations/timeseries?stid=%s&start=%d&end=%d&token=%s&output=csv&obtimezone=UTC', ...
       stid{:},startdate,enddate,token);
    % construct name of the csv file as station_id_STARTDATE-ENDDATE.csv'
    fname=strcat(stid{:},'_',num2str(startdate),'-',num2str(enddate),'.csv');
    tic
    fprintf('Getting %s takes ', fname)
    % get the content of 'url' and save as 'fname'
    websave(fname,url)
    fprintf('%6.3fs\n', toc)
end