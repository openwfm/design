function varargout=shell(s,fake)
% [status[,result]]=shell(s[,fake])
% 
disp(s)
if exist('fake','var') & fake,
    status=0;
    result='fake, not executed';
else
    [status,result]=system(s);
end
disp(result)
if status,
    disp('command failed')
end
if nargout>=1,
    varargout{1}=status;
end
if nargout>=2,
    varargout{2}=result;
end
end
