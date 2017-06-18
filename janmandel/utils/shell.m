function shell(s,fake)
disp(s)
if exist('fake','var') & fake,
   disp('command not executed')
   return
end
[status,result]=system(s);
if length(result)>0,
   disp(result)
end
if status ~=0,
    error('command failed')
end
end
