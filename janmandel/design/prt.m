function prt(s)
k=gcf;k=k.Number;
drawnow
file=['fig_',s,'.png'];
fprintf('Printing figure %i to %s\n',k,file)
print(k,'-dpng',file)
end