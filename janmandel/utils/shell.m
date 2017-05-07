function shell(s)
disp(s)
[status,result]=system(s);
if length(result)>0,
   disp(result)
end
if status ~=0,
    error('command failed')
end
end
