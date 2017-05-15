function figures(res)
% figures.m
% first load res, or run fasmeee_setup and store the output as variable res
disp([res.times(24,:),' UTC'])
figure(1);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,24,1))
tit('Variance of W at 10m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_1')

figure(2);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,24,2))
tit('Variance of W at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_2')

figure(3);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,24,3))
tit('Variance of W at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_3')

end



    