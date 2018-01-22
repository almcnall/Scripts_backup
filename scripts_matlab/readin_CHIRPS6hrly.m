%Try this: 

ncol=801;
nrow=751;
fname='rfe_gdas.bin.2017052300'
fid = fopen(fname, 'r','b'); 
%data1 = fread(fid, [nrow, ncol], 'int');
data1 = fread(fid, [nrow, ncol], 'float');
fclose(fid)
% mask the ocean
data2=data1; 
data2(data2==-1)=NaN;
figure; pcolor(data1'); shading flat; colorbar;
