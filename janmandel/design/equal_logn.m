function [D,logm,logs]=equal_logn(ab,p,N)
logab=log(ab);
[logm,logs]=bounds2n(logab,p);
logD = equaln(logm,logs,N);
D=exp(logD);
