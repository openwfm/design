function h=vis_smoke(xlong,xlat,p,ts)
% xlong longitude
% xlat  latitude
% p     structure with fields ph, phb, tr17_1 
% ts    number of time step


kdim = size(p.tr17_1,3);
z = (p.phb(:,:,:,ts) + p.ph(:,:,:,ts))/9.81;
z8c=0.5*(z(:,:,1:kdim)+z(:,:,2:kdim+1));
long3d = tencat(xlong,ones(kdim,1));
lat3d = tencat(xlat,ones(kdim,1));

conc = 1e5;
kmax=8;
for k=1:kmax,
    fv=isosurface(long3d,lat3d,z8c,p.tr17_1(:,:,:,ts),conc*2^(-k+1));
    h(k)=patch(fv);
    h(k).EdgeColor='none';
    h(k).FaceColor='black';
    h(k).FaceAlpha=(kmax-k+1)/kmax;
    grid on
    hold on
    drawnow
end
hold off