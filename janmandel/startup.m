cwd=pwd
disp('Assuming wrf-fire installed in the same directory as fasmee')
cd ../../wrf-fire/wrfv2_fire/test/em_fire
startup
cd(cwd)
add={[cwd,'/design'],[cwd,'/ignition'],[cwd,'/utils'],[cwd,'/netcdf']};
for i=1:length(add)
   addpath(add{i});
   disp(add{i})
   ls(add{i})
end
clear cwd add i
