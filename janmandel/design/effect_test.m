function err=effect_test(L,N,r)
% effect_test(N,r)
% L = number of inputs
% N = number of bins
% r = number of repetitions

% generate model: y = a*x
a = ones(1,L);
model = @(x)a*x;
mean_vec=zeros(1,L);
std_vec =1:L;

% sampling
X = rLHS(equaln(mean_vec,std_vec,N),r);
for j=1:N
    for l=1:r
        Y(1,j,l) = model(X(:,j,l));
    end
end
V = effect(X,Y)
% X,Y,V
V_exact = (a.*std_vec).^2
err = V./V_exact(:)