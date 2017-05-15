function tit(t)
f=18;
k=gcf;k=k.Number;
fprintf('figure %i: %s\n',k,t)
grid on
set(gca,'fontsize',f)
title(t,'fontsize',f)
xlabel('longitude','fontsize',f);
ylabel('latitude','fontsize',f)
drawnow
end
