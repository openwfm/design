function err=effect_test(L,N,r)
% effect_test(N,r)
% L = number of inputs
% N = number of bins
% r = number of repetitions
% example:
% effect_test(2,100,20000)

% generate model: y = a*x
a = 1:L;
model = @(x)a*x;
mean_vec=zeros(1,L);
std_vec =1:L;

% sampling
D = equaln(mean_vec,std_vec,N);
P = rLHS(D,r);
for k=1:r      % rep
    for j=1:L  % var
        pp=P(j,:,k);
        X(j,:,k) = D(j,pp);
    end
end
for k=1:r   %rep
    for i=1:N
        Y(1,i,k) = model(X(:,i,k));
    end
end
[V,mean_all,var_all,eff] = effect(X,Y)
% X,Y,V
V_exact = (a.*std_vec).^2
rel_err = V./V_exact -1