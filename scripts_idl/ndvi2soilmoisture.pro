pro NDVI2soilmoisture

;i moved make_filteredNDVI to here 
;3/21/2013 - updated the code to use the new AMMA2013 data for a longer time series. 
;revisiting this for the HESS revisions

;*************Niger sites fallow/millet**************************************
;**************new AMMA 2013 files (2006-2011)*******************************************
sfile1 = file_search('/raid/chg-mcnally/observed_avgTKWK06.11.csv')
sfile2 = file_search('/raid/chg-mcnally/Agoufou_avg0102SM.csv');what are the years for this one? 2005-2008
sfile3 = file_search('/raid/chg-mcnally/Mpala_dekad.csv')

nfile1 = file_search('/raid/chg-mcnally/NDVI_WK_TK_AVG_2006_2011.csv')
;nfile2 = file_search('/raid/chg-mcnally/NDVIAg_2006_2009.csv') 
nfile2 = file_search('/raid/chg-mcnally/NDVI_AgoufouMali_2005_2008.csv')
; what was i doing with this AG file - it mgiht be wrong....maybe i want 2005-2008
nfile3 = file_search('/raid/chg-mcnally/NDVI_mpala_klee_2011_2012.csv')


ndvi1 = read_csv(nfile1)
ndvi2 = read_csv(nfile2)
ndvi3 = read_csv(nfile3)

soil1 = read_csv(sfile1)
soil2 = read_csv(sfile2)
soil3 = read_csv(sfile3)

nwk = ndvi1.field1
nag = ndvi2.field1
nmp = float(ndvi3.field1)

swk = float(soil1.field1); 216, 2006-2011..the review suggests that i don't use all of these points. save some for validation
sag = float(soil2.field1); 144, 2005-2008
smp = float(soil3.field1); 72, 2011-2012 ...i could update this i suppose...

;get the average NDVI and soil moisture for some period of record
nwk_avg = mean(reform(nwk[0:107],36,3),dimension=2,/nan)
swk_avg = mean(reform(swk[0:107],36,3), dimension=2, /nan)

;I'll test this for 2006-2008 in Mali as well, just to compare the coefficients
nag_avg = mean(reform(nag[36:143],36,3),dimension=2,/nan)
sag_avg = mean(reform(sag[36:143],36,3), dimension=2, /nan)

;abd for the mpala site
nmp_avg = mean(reform(nmp,36,2),dimension=2,/nan)
smp_avg = mean(reform(smp,36,2), dimension=2,/nan)/100

ofile = '/raid/chg-mcnally/sag_avg4R.csv'
write_csv,ofile,sag_avg

;pick which site I am going to look at...
savg = smp_avg
navg = nmp_avg
;now regress the short/avg timeseries
Y = savg[0:34]
;two lags
X = [ transpose(navg[0:34]),transpose(navg[1:35]) ]
;I am not really sure if this sigma is doing the right thing. 
reg = regress(X,Y,const=const,correlation=corr,yfit=yfit, sigma=sigma) & print, const, transpose(reg)

myfit = yfit

;Introduce the microwave soil moisture, how does it compare to obserations & what do coefficients look like?
ifile = file_search('/raid/chg-mcnally/ECV_microwaveSM_dekadal.2001.2010.img')
nx = 720
ny = 350

rpawgrid = fltarr(nx,ny,36,10)

openr,1,ifile
readu,1,rpawgrid
close,1

;pull out 2005-2008 for Mali
;Wankama 2006 - 2011
wxind = FLOOR((2.632 + 20.) / 0.10)
wyind = FLOOR((13.6456 + 5) / 0.10)

;Tondikiboro 2006-2011
txind = FLOOR((2.6956 + 20.) / 0.10)
tyind = FLOOR((13.548 + 5) / 0.10)

;Agoufou_1 15.35400    -1.47900  
axind = FLOOR((-1.479 + 20.) / 0.10)
ayind = FLOOR((15.3540 + 5) / 0.10)

;Mpala Kenya:
mxind = FLOOR((36.8701 + 20.) / 0.10)
myind = FLOOR((0.4856 + 5) / 0.10)

;;KLEE Kenya
kxind = FLOOR((36.8669 + 20.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

;microwave agoufou 2005-2008
mw_ag = mean(rpawgrid[axind,ayind,*,3:6], dimension=4, /nan)
p1 = plot(mw_ag/100000);double check the units on the ECV soil moisture..
p1 = plot(sag_avg,/overplot, linestyle=2)

;microwave Wankama Niger 2006-2008
mw_wk = mean(rpawgrid[wxind,wyind,*,4:6], dimension=4, /nan)
p1 = plot(mw_wk/10000);double check the units on the ECV soil moisture..
p1 = plot(swk_avg,/overplot, linestyle=2)

;microwave at Mpala 2011-2012 (ah I don't have these)
mw_mp = mean(rpawgrid[mxind,myind,*,*], dimension=4, /nan)
p1 = plot(mw_mp/10000);double check the units on the ECV soil moisture..
p1 = plot(smp_avg,/overplot, linestyle=2)
est = const+reg[0]*navg144[0:34]+reg[1]*navg144[1:35]
print, r_correlate(est,savg[0:34])
p1=plot(est, 'g')
p1=plot(savg,/overplot)

;short est long
est = const+reg[0]*navg144[0:70]+reg[1]*navg144[1:71]
print, r_correlate(est,savg144[0:70])

;regress the long timeseries but soil moisture doesn't start till dek 10, right?
y = savg144[10:142]
x = [ transpose(navg144[10:142]),transpose(navg144[11:143]) ]
reg = regress(x,y,const=const,correlation=corr,yfit=yfit, sigma=sigma) & print, const, reg, sigma
est144 = const+reg[0]*navg144[10:142]+reg[1]*navg144[11:143]
print, r_correlate(est144,savg144[10:142])

;this still seems to work :)
print, 100*(1-norm(yfit-savg)/norm(yfit-mean(savg, /nan))) ;(63)

;**********fit the longer 4 yr time series************************
est2 = const+reg[0]*navg144[0:142]+reg[1]*navg144[1:143]
est2 = reform([est2,!values.f_nan],36,6) ;huh, are these really exactly the same as yfit?
avgest = mean(est2,dimension=2, /nan)
print, 100*(1-norm(savg216-est2)/norm(savg216-mean(savg216, /nan))) ;35

;*******************the figure for the paper**************************
xtickvals = [0, 5, 10, 15, 20, 25, 30, 35]+2
p2 = plot(navg, thick = 3, 'black', name = 'NDVI', /overplot, $)
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '1-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','21-Nov'],$
         MARGIN = [0.15,0.2,0.15,0.1], $
         AXIS_STYLE=0, yminor = 0, xrange=[0,34])
         ;omg, new IDL i am going to kill you.
yax2 = AXIS('Y',LOCATION=[MAX(p2.xrange),0],TITLE='NDVI', $
       TEXTPOS=1,tickfont_size=16, minor = 0)
p1 = plot(savg*100, thick = 3, 'light grey', name = 'SM', xminor = 0, yminor = 0, $
         MARGIN = [0.15,0.2,0.15,0.1], $
         xtickvalues = xtickvals, $
         xtickname = ['11-Jan', '01-Mar','21-Apr','11-Jun','01-Aug','21-Sep','21-Oct','21-Nov'],$
         YTITLE='SM',AXIS_STYLE=1,/CURRENT)
;I shouldn't use yfit because it is not long enough -- maybe the avg of est will look better too!
p3 = plot(yfit*100, thick = 3, linestyle = 2, 'grey',name ='SM estimate', /overplot)
lgr2 = LEGEND(TARGET=[p1, p2, p3], font_size=16)
p1.xtickfont_size = 16
p1.ytickfont_size = 16
p1.ytitle='soil moisture (%VWC)'

;any better with another lag?
Y = savg[0:33]
;three lags
X = [ transpose(navg[0:33]),transpose(navg[1:34]), transpose(navg[2:35]) ]
reg = regress(X,Y,const=const,correlation=corr,yfit=yfit) & print, const, corr
print, 100*(1-norm(yfit-savg)/norm(yfit-mean(savg, /nan))); (69)
;
;Y = savg[1:33]
;;one neg, 2 pos
;X = [ transpose(navg[0:32]),transpose(navg[1:33]), transpose(navg[2:34]) ]
;reg = regress(X,Y,const=const,correlation=corr,yfit=yfit) & print, const, corr
;print, 100*(1-norm(yfit-savg)/norm(yfit-mean(savg, /nan))) ;why is it 72 here and 88 elsewhere (56)
;;ofile = '/jabber/chg-mcnally/AMMASOIL/filteredNDVI_WK12TK.csv'
;;write_csv,ofile,yfit

;**********fit the longer 4 yr time series************************
;;ugh, am i doing this right? 
est2 = const+reg[0]*navg216[0:214]+reg[1]*navg216[1:215]
print, 100*(1-norm(savg216-est2)/norm(savg216-mean(savg216, /nan))) ;35

;with three lags
est3 = const+reg[0]*navg216[0:213]+reg[1]*navg216[1:214]+reg[2]*navg216[2:215]
;print, 100*(1-norm(savg216-est)/norm(savg216-mean(savg216, /nan))) ;40 (33)
;
;;****MAKE THE FILTRED NDVI DATA*******************************************************
  
ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*img')
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/mask_bare75_sahel.img')

nx = 720
ny = 350
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
cube = fltarr(nx,ny,nz)
vegmask = fltarr(nx,ny)

;read in veg mask outside o' loop
openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

;make a big stack of ndvi files - so i have timeseries 2001-2011
;is there already another stack of NDVI?
for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
 ;mask out bare ground places....
  ingrid = ingrid*vegmask  &$
  cube[*,*,f] = ingrid &$
endfor 

;********8Redo this with Mpala Data**************************************
;coefficents from matlab, i could solve for these in IDL just to have them all in one spot.
; Would just need avg SM and avg NDVI (36 values)
;b =   [0.0005, -0.3615, 0.5924]
;b = [0.0077531848, -0.46763204 , 1.1149183, -0.39417591]
b = [0.0033570163 ,    -0.11283826   ,   0.39198246]
filtered = fltarr(nx,ny,nz-1);why minus 2?
;apply the ndvi filter 
for x = 0,nx -1 do begin &$
  for y = 0, ny-1 do begin &$
  if total(cube[x,y,*]) lt 0 then continue &$
  ;filtered[x,y,*] = b[0]+b[1]*cube[x,y,0:nz-3]+b[2]*cube[x,y,1:nz-2] +b[3]*cube[x,y,2:nz-1] &$
  filtered[x,y,*] = b[0]+b[1]*cube[x,y,0:nz-2]+b[2]*cube[x,y,1:nz-1] &$
 endfor &$
endfor
ofile = '/jabber/chg-mcnally/filterNDVI_soilmoisture_2001Jan_2012Oct_lag2.img'
openw, 1, ofile
writeu,1, filtered
close,1
;
;;one negative lag
;est = const+reg[0]*navg216[0:213]+reg[1]*navg216[1:214]+reg[2]*navg216[2:215]
;print, 100*(1-norm(savg216-est)/norm(savg216-mean(savg216, /nan))) ;40 (27)

;ofile = '/jabber/chg-mcnally/AMMASOIL/filteredNDVI_WK12TK144.csv'
;write_csv,ofile,est

;check it...looks fine!
p1=plot(est-mean(est, /nan),'b')
p1=plot(savg216-mean(savg216, /nan),/overplot)
;*****************the Kenya sites*************************
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/NDVI_mpala_klee_2011_2012.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')
kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')

result = read_csv(mfile)
mpala = float(result.field1)

result = read_csv(kfile)
KLEE = float(result.field1)

result = read_csv(vfile)
mNDVI = float(result.field1)
kNDVI = float(result.field2)

;take a look
p1 = plot(mpala/100, linestyle=2, name = 'mpala SM')
p2 = plot(KLEE/100, /overplot, name = 'klee SM')
p3 = plot(mNDVI,/overplot, linestyle = 2, 'g', name = 'mpala ndvi', tickinterval = 9)
p3.xtickname = []
p4 = plot(kNDVI,/overplot, 'g', name = 'klee ndvi')
!null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3]) 
p3.xtickfont_size = 18
p3.ytickfont_size = 18
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18);

X = [transpose(mNDVI[25:63]), transpose(mNDVI[26:64])]; i guess i had done it that way to get the season
Y = mpala[25:63]

Xk = [transpose(kNDVI[27:64]), transpose(kNDVI[28:65])]
Yk = KLEE[27:64]
;mpala = mean(reform(mpala,36,2), dimension = 2, /nan)
;KLEE = mean(reform(KLEE,36,2), dimension = 2, /nan)
;Nmpala = mean(reform(mNDVI,36,2), dimension = 2, /nan)
;NKLEE = mean(reform(kNDVI,36,2), dimension = 2, /nan)

regk = regress(Xk,Yk,const=const,correlation=corr,yfit=yfit) 
print, 100*(1-norm(Yk-yfit)/norm(Yk-mean(Yk, /nan)))

reg = regress(X,Y,const=const,correlation=corr,yfit=yfit) 
print, 100*(1-norm(Y-yfit)/norm(Y-mean(Y, /nan)))

xticks = ['sept-11','nov-11','jan-12','mar-12', 'may-12','jul-12','sept-12']
p1 = plot(yfit, thick=3, linestyle = 2, name = 'filterd NDVI',xtickinterval = 6)
 p1.xtickname= xticks
p2 = plot(Y, thick=3, 'b', /overplot, name = 'observed SM')
p1.xtickfont_size = 18
p1.ytickfont_size = 18
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.title='Mpala Filtered NDVI'
p1.title.font_size=18

xticks = ['oct-11','dec-11','feb-12','apr-12', 'jun-12','aug-12','oct-12']
p1 = plot(yfit, thick=3, linestyle = 2, name = 'filterd NDVI',xtickinterval = 6)
 p1.xtickname= xticks
p2 = plot(Yk, thick=3, 'b', /overplot, name = 'observed SM')
p1.xtickfont_size = 18
p1.ytickfont_size = 18
null = legend(target=[p1,p2], position=[0.2,0.3], font_size=18) ;
p1.title='KLEE Filtered NDVI'
p1.title.font_size=18
;****MAKE THE FILTRED NDVI DATA*******************************************************
  
ifile = file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/sahel/data*img')
vfile = file_search('/jabber/chg-mcnally/AMMAVeg/mask_bare75_sahel.img')

nx = 720
ny = 350
nz = n_elements(ifile)

ingrid = fltarr(nx,ny)
cube = fltarr(nx,ny,nz)
vegmask = fltarr(nx,ny)

;read in veg mask outside o' loop
openr,1,vfile
readu,1,vegmask
close,1
vegmask(where(vegmask eq 0.))=!values.f_nan

;make a big stack of ndvi files - so i have timeseries 2001-2011
;is there already another stack of NDVI?
for f = 0,n_elements(ifile)-1 do begin &$
  openr,1,ifile[f] &$
  readu,1,ingrid &$
  close,1 &$
 ;mask out bare ground places....
  ingrid = ingrid*vegmask  &$
  cube[*,*,f] = ingrid &$
endfor 

;********8Redo this with Mpala Data**************************************
;coefficents from matlab, i could solve for these in IDL just to have them all in one spot.
; Would just need avg SM and avg NDVI (36 values)
b =   [0.0005, -0.3615, 0.5924]
filtered = fltarr(nx,ny,nz-1);why minus 2?
;apply the ndvi filter 
for x = 0,nx -1 do begin &$
  for y = 0, ny-1 do begin &$
  if total(cube[x,y,*]) lt 0 then continue &$
  filtered[x,y,*] = b[0]+b[1]*cube[x,y,0:nz-2]+b[2]*cube[x,y,1:nz-1]  &$
  ;test = b[0]+b[1]*cube[xind,yind,0:nz-1]+b[2]*cube[xind,yind,1:nz-2]
 endfor &$
endfor
;ofile = '/jabber/chg-mcnally/filterNDVI_soilmoisture_200101_2012.10.2.img'
;openw, 1, ofile
;writeu,1, filtered
;close,1
;
;;this is when it is nice to have things separate rather than in a big old stack....
fnames = strmid(file_search('/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/data*img'),54,18)
for i = 0,n_elements(filtered[0,0,*])-1 do begin &$
  ogrid = filtered[*,*,i] &$
  
;  ofile = strcompress('/jabber/chg-mcnally/filterNDVI_sahel/SMest_'+fnames[i],/remove_all) &$
;  openw,1,ofile &$
;  writeu,1,ogrid &$
;  close,1 &$
endfor

;where are my stations? ;13.6476;2.6337;
;sahel window= 19W, 52E, -5S, 30N
xind = FLOOR((2.633 + 20.) / 0.10)
yind = FLOOR((13.6454 + 5) / 0.10)

;*********filter the horn************
;;I fixed this on 12/22/2012********
;i should clip NDVI to horn window for the sake of speed.
;read in the horn data
nx = 250
ny = 350
nz = 426
cube = fltarr(nx,ny,nz)
ifile = '/jabber/sandbox/mcnally/BRHA1-FEWSNet/eMODIS/01degree/horn/horn_2001_2012.img'
openr,1,ifile
readu,1,cube
close,1

b = [0.263062, -43.4734, 70.7494]; Mpala ;whoa this had a comma is that totally off?
;b = [6.16988   , -121.144, 184.346]; KLEE
;b =   [0.0005, -0.3615, 0.5924]; Niger
filtered = fltarr(nx,ny,nz-1)
;apply the ndvi filter 
for x = 0,nx -1 do begin &$
  for y = 0, ny-1 do begin &$
  if total(cube[x,y,*]) lt 0 then continue &$
  filtered[x,y,*] = b[0]+b[1]*cube[x,y,0:nz-2]+b[2]*cube[x,y,1:nz-1]  &$
 endfor &$
endfor

;ofile = '/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_Mpala.img'
;openw, 1, ofile
;writeu,1, filtered
;close,1

;**********************figure 10**************************
;***maybe this is the kinda thing i should do in ENVI*****
nnfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_WANK.HORN.img')
nkfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_KLEE.img')
nmfile = file_search('/jabber/chg-mcnally/filterNDVI_soilmoisture_2001_2012_Mpala.img')

kfile = file_search('/jabber/chg-mcnally/AMMASOIL/KLEE_dekad.csv')
mfile = file_search('/jabber/chg-mcnally/AMMASOIL/Mpala_dekad.csv')

nx = 250
ny = 350
nz = 425

NPhorn = fltarr(nx,ny,nz)
KPhorn = fltarr(nx,ny,nz)
MPhorn = fltarr(nx,ny,nz)

openr,1,nnfile
readu,1,NPhorn
close,1

openr,1,nkfile
readu,1,KPhorn
close,1

openr,1,nmfile
readu,1,MPhorn
close,1

mobs = read_csv(mfile)
mobs = float(mobs.field1)

kobs = read_csv(kfile)
kobs = float(kobs.field1)


;Mpala Kenya:
mxind = FLOOR((36.8701 - 27.) / 0.10);this says cor is 0.67...
myind = FLOOR((0.4856 + 5) / 0.10)

;KLEE
kxind = FLOOR((36.8669 - 27.) / 0.10)
kyind = FLOOR((0.2825 + 5) / 0.10)

pad = fltarr(1,1,7)
pad[*,*,*] = !values.f_nan

pNPhorn = [[[NPhorn[mxind,myind,360:424]]], [[pad]]] & help, pNPhorn
pKPhorn = [[[KPhorn[mxind,myind,360:424]]], [[pad]]] & help, pKPhorn
pMPhorn = [[[MPhorn[mxind,myind,360:424]]], [[pad]]] & help, pMPhorn

p1 = plot((pNPhorn-mean(pNPhorn, /nan))*250,'r')
p2 = plot(pKPhorn-mean(pKPhorn, /nan),'g', /overplot)
p3 = plot(pMPhorn-mean(pMPhorn,/nan),'b', /overplot)
p4 = plot(mobs-mean(mobs,/nan),thick=3, /overplot)
;I need to add in the obs....I should pad them out so I see the estimates beyond the obs.

p1.title = 'Different parameter estimates at Mpala'
p1.name = 'Niger params'
p2.name = 'KLEE params'
p3.name = 'Mpala params'
p4.name = 'obs'
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) ;
p1.title.font_size = 16
p1.ytitle = '%VWC'
;********KLEE*********
pNPhorn = [[[NPhorn[kxind,kyind,360:424]]], [[pad]]] & help, pNPhorn
pKPhorn = [[[KPhorn[kxind,kyind,360:424]]], [[pad]]] & help, pKPhorn
pMPhorn = [[[MPhorn[kxind,kyind,360:424]]], [[pad]]] & help, pMPhorn

p1 = plot((pNPhorn-mean(pNPhorn, /nan))*250,'r')
p2 = plot(pKPhorn-mean(pKPhorn, /nan),'g', /overplot)
p3 = plot(pMPhorn-mean(pMPhorn,/nan),'b', /overplot)
p4 = plot(kobs-mean(kobs,/nan),thick=3, /overplot)

p1.title = 'Different parameter estimates at KLEE'
p1.name = 'Niger params'
p2.name = 'KLEE params'
p3.name = 'Mpala params'
p4.name = 'obs'
null = legend(target=[p1,p2,p3,p4], position=[0.2,0.3], font_size=18) ;
p1.title.font_size = 16
p1.ytitle = '%VWC'

;******************old stuff**************************************
;these eliminated
;wk140 = float(soil.field1)
;wk170 = float(soil.field2)

;these are updated.
;wk240 = float(soil.field3) 
;wk270 = float(soil.field4) 
;tk40 = float(soil.field5) 
;tk70 = float(soil.field6)  



;savg144 = mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
;             transpose(tk40), transpose(tk70)], dimension = 1, /nan)
;savg = reform(mean([transpose(wk140), transpose(wk170), transpose(wk240), transpose(wk270),$
;             transpose(tk40), transpose(tk70)], dimension = 1, /nan),36,4)

;*****more old stuff october 2,2013****
;navg144 = float(ndvi.field1)
;wk = ndvi.field1
;tk = ndvi.field2

;savg144 = float(soil.field1)
;savg = reform(savg144,36,2)
;savg = mean(savg,dimension = 2, /nan)  

;navg216 = mean([transpose(wk),transpose(tk)], /nan, dimension = 1)
;navg = mean(reform(navg144, 36,2), dimension = 2, /nan)

;if I am going to do multiple regression i can't have missing values....luckilly there are only 2
;fin = where(finite(savg216), complement=null, count) & print, null
;fill = mean([savg216(null[0]-1), savg216(null[1]+1)]) & print, fill
;savg216(null) = fill
;
;ofile = strcompress('/jabber/chg-mcnally/AMMASOIL/observed_avgTKWK06_11_filled.csv', /remove_all)
;write_csv, ofile, savg216

;fin = where(finite(navg216), complement=null, count) & print, null ; just missing bavg216[210:215];




