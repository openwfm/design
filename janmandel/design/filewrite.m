function filewrite(filename,var)
% filewrite(filename,variable)
% write a variable in file as binary
% adapted from fileread

[fid, msg] = fopen(filename,'w');
if fid == -1
    error(['cannot open file ', filename, ' ',msg]);
end

try
    out = fwrite(fid,var);
catch exception
    fclose(fid);
    throw(exception);
end

fclose(fid);