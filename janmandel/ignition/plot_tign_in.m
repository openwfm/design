m=max(tign_in(tign_in(:)<max(tign_in(:))));
[ii,jj,vv]=find(tign_in<m+100);
si=min(ii):max(ii);sj=min(jj):max(jj);
h=mesh(dom.fxlong(si,sj),dom.fxlat(si,sj),min(tign_in(si,sj),m+100));
hold on
plot3_ign(ign,realmax,'r.');
hold off
