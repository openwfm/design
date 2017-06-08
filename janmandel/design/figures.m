function figures(res)
% figures.m
% first load res, or run fasmeee_setup and store the output as variable res
ts=24;
disp([res.times(ts,:),' UTC'])

if 0
    
figure(1);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,1))
tit('Variance of W at 10m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_var_1')

figure(2);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,2))
tit('Variance of W at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_var_2')

figure(3);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,3))
tit('Variance of W at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_var_3')

figure(4);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,1)./res.w10.var(:,:,ts))
tit('Sensitivity index of W at 10m - fuel moisture')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_eff_1')

figure(5);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,2)./res.w10.var(:,:,ts))
tit('Sensitivity index of W at 10m - heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_eff_2')

figure(6);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,3)./res.w10.var(:,:,ts))
tit('Sensitivity index of W at 10m - heat multiplier')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_eff_3')

figure(7);clf
mesh(res.xlong,res.xlat,res.w10.var(:,:,ts))
tit('Variance of W at 10m')
axis([-112.2 -112 38.35 38.55 0 1e-3])
prt('w10_var')

figure(8);clf
mesh(res.xlong,res.xlat,res.w10.mean(:,:,ts))
tit('Mean of W at 10m')
% axis([-112.2 -112 38.35 38.55 -1.5 1.5])
prt('w10_mean')

figure(9);clf
mesh(res.xlong,res.xlat,res.hgt(:,:))
tit('Terrain altitude')
axis([-112.2 -112 38.35 38.55 1500 3500])
prt('hgt')

end

if 0
    
disp('sum of variances over time step')
ub=1e-2;

figure(10);clf
mesh(res.xlong,res.xlat,sum(res.w10.V(:,:,:,1),3))
tit('Variance of W at 10m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('w10_sum_var_1')

figure(11);clf
mesh(res.xlong,res.xlat,sum(res.w10.V(:,:,:,2),3))
tit('Variance of W at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('w10_sum_var_2')

figure(12);clf
mesh(res.xlong,res.xlat,sum(res.w10.V(:,:,:,3),3))
tit('Variance of W at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('w10_sum_eff_3')

figure(13);clf
mesh(res.xlong,res.xlat,sum(res.w10.V(:,:,:,1),3)./sum(res.w10.var(:,:,:),3))
tit('Sensitivity index of W at 10m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_sum_eff_1')

figure(14);clf
mesh(res.xlong,res.xlat,sum(res.w10.V(:,:,:,2),3)./sum(res.w10.var(:,:,:),3))
tit('Sensitivity index of W at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_sum_eff_2')

figure(15);clf
mesh(res.xlong,res.xlat,sum(res.w10.V(:,:,:,3),3)./sum(res.w10.var(:,:,:),3))
tit('Variance of W at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_sum_eff_3')


end

if 0
    
ub=5e9

disp('sum of variances of smoke over time steps')

figure(16);clf
mesh(res.xlong,res.xlat,sum(res.smoke10.V(:,:,:,1),3))
tit('Variance of smoke at 10m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('s10_sum_var_1')

figure(17);clf
mesh(res.xlong,res.xlat,sum(res.smoke10.V(:,:,:,2),3))
tit('Variance of smoke at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('s10_sum_var_2')

figure(18);clf
mesh(res.xlong,res.xlat,sum(res.smoke10.V(:,:,:,3),3))
tit('Variance of smoke at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('s10_sum_var_3')

figure(19);clf
mesh(res.xlong,res.xlat,sum(res.smoke10.V(:,:,:,1),3)./sum(res.smoke10.var(:,:,:),3))
tit('Sensitivity index of smoke at 10m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 1])
prt('s10_sum_eff_1')

figure(20);clf
mesh(res.xlong,res.xlat,sum(res.smoke10.V(:,:,:,2),3)./sum(res.smoke10.var(:,:,:),3))
tit('Sensitivity index of smoke at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 1])
prt('s10_sum_eff_2')

figure(21);clf
mesh(res.xlong,res.xlat,sum(res.smoke10.V(:,:,:,3),3)./sum(res.smoke10.var(:,:,:),3))
tit('Variance of smoke at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 1])
prt('s10_sum_eff_3')

end

if 0
    
figure(22);clf
mesh(res.xlong,res.xlat,res.smoke3500a.V(:,:,ts,1))
tit('Variance of smoke at 3500m due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_var_1')

figure(2);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,2))
tit('Variance of W at 10m due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_var_2')

figure(3);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,3))
tit('Variance of W at 10m due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 6e-4])
prt('w10_var_3')

figure(4);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,1)./res.w10.var(:,:,ts))
tit('Sensitivity index of W at 10m - fuel moisture')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_eff_1')

figure(5);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,2)./res.w10.var(:,:,ts))
tit('Sensitivity index of W at 10m - heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_eff_2')

figure(6);clf
mesh(res.xlong,res.xlat,res.w10.V(:,:,ts,3)./res.w10.var(:,:,ts))
tit('Sensitivity index of W at 10m - heat multiplier')
axis([-112.2 -112 38.35 38.55 0 1])
prt('w10_eff_3')

figure(7);clf
mesh(res.xlong,res.xlat,res.w10.var(:,:,ts))
tit('Variance of W at 10m')
axis([-112.2 -112 38.35 38.55 0 1e-3])
prt('w10_var')

figure(8);clf
mesh(res.xlong,res.xlat,res.w10.mean(:,:,ts))
tit('Mean of W at 10m')
% axis([-112.2 -112 38.35 38.55 -1.5 1.5])
prt('w10_mean')

figure(9);clf
mesh(res.xlong,res.xlat,res.hgt(:,:))
tit('Terrain altitude')
axis([-112.2 -112 38.35 38.55 1500 3500])
prt('hgt')

end


if 0
    
ub=5e-9

disp('sum of variances of smoke over time steps')

figure(16);clf
mesh(res.xlong,res.xlat,sum(res.smoke5000a.V(:,:,:,1),3))
tit('Variance of smoke at 5000m alt due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('s5000a_sum_var_1')

figure(17);clf
mesh(res.xlong,res.xlat,sum(res.smoke5000a.V(:,:,:,2),3))
tit('Variance of smoke at 5000m alt due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('s5000a_sum_var_2')

figure(18);clf
mesh(res.xlong,res.xlat,sum(res.smoke5000a.V(:,:,:,3),3))
tit('Variance of smoke at 5000m alt due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 ub])
prt('s5000a_sum_var_3')

figure(19);clf
mesh(res.xlong,res.xlat,sum(res.smoke5000a.V(:,:,:,1),3)./sum(res.smoke5000a.var(:,:,:),3))
tit('Sensitivity index of smoke at 5000m alt due to fuel moisture')
axis([-112.2 -112 38.35 38.55 0 1])
prt('s5000a_sum_eff_1')

figure(20);clf
mesh(res.xlong,res.xlat,sum(res.smoke5000a.V(:,:,:,2),3)./sum(res.smoke5000a.var(:,:,:),3))
tit('Sensitivity index of smoke at 5000m alt due to heat insertion depth')
axis([-112.2 -112 38.35 38.55 0 1])
prt('s5000a_sum_eff_2')

figure(21);clf
mesh(res.xlong,res.xlat,sum(res.smoke5000a.V(:,:,:,3),3)./sum(res.smoke5000a.var(:,:,:),3))
tit('Sensitivity index of smoke at 5000m alt due to heat multiplier')
axis([-112.2 -112 38.35 38.55 0 1])
prt('s5000a_sum_eff_3')

end

if 1
    
    disp('sum of variances FGRNHFX over time steps')

figure(26);clf
contour(res.fxlong,res.fxlat,sum(res.fgrnhfx.V(:,:,:,1),3)),colorbar
tit('Variance of fire heat flux due to fuel moisture')
grid on,axis([-112.095,-112.08, 38.44, 38.455])
prt('fgrnhfx_sum_var_1')

figure(27);clf
contour(res.fxlong,res.fxlat,sum(res.fgrnhfx.V(:,:,:,2),3)),colorbar
tit('Variance of fire heat flux due to heat insertion depth')
grid on,axis([-112.095,-112.08, 38.44, 38.455])
prt('fgrnhfx_sum_var_2')

figure(28);clf
contour(res.fxlong,res.fxlat,sum(res.fgrnhfx.V(:,:,:,3),3)),colorbar
tit('Variance of fire heat flux due to heat multiplier')
grid on,axis([-112.095,-112.08, 38.44, 38.455])
prt('fgrnhfx_sum_var_3')

figure(29);clf
mesh(res.fxlong,res.fxlat,sum(res.fgrnhfx.V(:,:,:,1),3)./sum(res.fgrnhfx.var(:,:,:),3))
tit('Sensitivity index of fire heat flux for the fuel moisture')
axis([-112.095,-112.08, 38.44, 38.455,0, 1])
prt('fgrnhfx_sum_eff_1')

figure(30);clf
mesh(res.fxlong,res.fxlat,sum(res.fgrnhfx.V(:,:,:,2),3)./sum(res.fgrnhfx.var(:,:,:),3))
tit('Sensitivity index of fire heat flux for the heat insertion depth')
axis([-112.095,-112.08, 38.44, 38.455, 0, 1])
prt('fgrnhfx_sum_eff_2')

figure(31);clf
mesh(res.fxlong,res.fxlat,sum(res.fgrnhfx.V(:,:,:,3),3)./sum(res.fgrnhfx.var(:,:,:),3))
tit('Sensitivity index of fire heat flux for the heat multiplier')
axis([-112.095,-112.08, 38.44, 38.455 ,0, 1])
prt('fgrnhfx_sum_eff_3')

end

end



    