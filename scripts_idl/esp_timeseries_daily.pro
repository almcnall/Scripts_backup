pro ESP_timeseries
;read in all historic soil moisture
;this one contains ways to plot daily...v2 is just monthly.
;revisit for SERVIR training

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 2003
endyr = 2016
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = 'EA'
params = get_domain01(domain)
print, params

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;basin masks
help, rufi_mask, tana_mask

;coordinates for Thika
;-0.820278, 36.850278
txind = FLOOR( (36.850 - map_ulx)/ 0.1)
tyind = FLOOR( (-0.8203 - map_lry) / 0.1)

;coordinates for Mpala
mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
hxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
hyind = FLOOR( (0.793458 - map_lry) / 0.1)

;Bay Region Somalia 2.660781, 43.530140
bxind = FLOOR( (43.530140 - map_ulx)/ 0.1)
byind = FLOOR( (2.660781 - map_lry) / 0.1)

;;;read in SM01 from readin_FLDAS_noah_sm.pro;;;;;
;;;monthly plots;;;;;;;
histmean = median(sm01, dimension = 4) & help, histmean
p0=plot(histmean[mxind,myind,*], thick = 3, /overplot, title='c2m2 clim')
;
;for i = 0, n_elements(sm01[mxind,myind,0,*])-1 do begin &$
;  p2=plot(sm01[mxind,myind,*,i], /overplot, 'grey') &$
;  if i eq 0 then p2.title='c2m2' &$
;endfor
;;then plot monthly C2final - M2 for this year
p3=plot(SM01[mxind,myind,*,35], thick = 3, 'orange', /overplot, title='2017')

;;;daiy plots;;;;;;;
;;;get the daily data from CHIRPS-prelim (and take the mean);;;;
rundir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/'
;then plot Cprelim for this year...daily then monthly
;indirP = rundir+'Noah33_CG_ESPV_EA/20170413_CP/SURFACEMODEL/'

;;;;;for hindcasts can ignore the CHIRPS prelim step 
;indirP = rundir+'Noah33_CG_ESPV_EA/201708/SURFACEMODEL/'
;
;ingridP = fltarr(nx, ny, 31, 12)*!values.f_nan
;
;;for m = 1,3 do begin &$
;  m = 8
;  y = 2017 &$
;  YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
;  ifile = file_search(strcompress(indirP+YYYYMM+'/LIS_HIST*', /remove_all))  & help, ifile &$ ;28daysx4per day
;  for f = 0, n_elements(ifile)-1 do begin &$
;    VOI = 'SoilMoist_tavg' &$
;    ;VOI = 'Evap_tavg' &$
;
;    ;read in all soil layers
;    SM = get_nc(VOI, ifile[f]) &$
;    ;just keep the top layer
;    SM0_10 = SM[*,*,0] &$
;    ingridP[*,*,f,m-1] = SM0_10 &$
;  endfor &$
;;endfor
;
;;daily CHIRPS-prelim
;;reform to elimate the gap
;jfm = [ reform(ingridP[mxind, myind,0:30,0], 31), reform(ingridP[mxind, myind,0:27,1],28), reform(ingridP[mxind, myind,0:30,2],31) ]
;p1=plot(jfm, thick=3,'red', name = 'Cprelim', /overplot)
;delvar, ingridP
;
;;monthly plots
;Cprelim = mean(ingridP,dimension=3,/nan)
;p1 = plot(Cprelim[mxind,myind,*], 'red', thick=3, name='Cprelim', /overplot)
;;;insert august to the July Chirps-final and the esp-spegetti, or concat to all the ESP plots.
;TS = reform(SM01[mxind,myind,*,35]) & help, TS
;TS[7]= cprelim[mxind, myind, m-1]
;p3=plot(TS, thick = 3, 'orange', /overplot, title='2017')

;input file path is like..
;discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/


;;;;read in Jan, Feb daily CHIRPS-final, so i can see intial conditions for CPrelim
;indirF = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/SURFACEMODEL/'
indirF = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'
;ingridF = fltarr(nx, ny, 31, 12,2)*!values.f_nan
ingridSM = fltarr(nx, ny,200,34)*!values.f_nan
ingridP = fltarr(nx, ny,200,34)*!values.f_nan
ingridRO = fltarr(nx, ny,200,34)*!values.f_nan
ingridE = fltarr(nx, ny,200,34)*!values.f_nan

basinP = fltarr(200,34)*!values.f_nan

;;months for the forecast remain static;;;
;;eventually we'll loop thru yrs
for ens = 1982,2015 do begin &$
  startyr = ens &$;start with 1982 since no data in 1981
  endyr = ens+1  &$
  nyrs = endyr-startyr+1 &$

  startmo = 10 &$
  endmo = 3    &$

  if startmo le endmo then nmos = endmo - startmo +1  $
  else nmos = endmo - startmo +13 &$

 cnt = 0 &$
 yr = startyr &$
  for i = 0,nmos-1 do begin &$
    y = yr &$
    m = startmo + i &$
    if m gt 12 then begin &$
    m = m-12 &$
    y = y+1 &$
  endif &$

    YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
    fname = indirF+'EXP_SEPT30_DAILY/20120930/'+string(startyr)+'/SURFACEMODEL/'+YYYYMM &$
    ifile = file_search(strcompress(fname+'/LIS_HIST*', /remove_all)) &$ ;28daysx4per day
    for f = 0, n_elements(ifile)-1 do begin &$
      ;read in all soil layers & just keep top
;      VOI = 'SoilMoist_tavg' &$      
;      SM = get_nc(VOI, ifile[f]) &$
;      SM0_10 = SM[*,*,0] &$
;      ingridSM[*,*, cnt, ens-1982] = SM0_10 &$  
      
;      VOI = 'Rainf_f_tavg' &$
;      P = get_nc(VOI, ifile[f]) &$
;      P(where(p lt 0))=!values.f_nan &$
;      ;ingridP[*,*, cnt, ens-1982] = P &$
;      basinP[cnt,ens-1982] = mean(mean(p*tana_mask,dimension=1,/nan),dimension=1,/nan) &$
      
;       VOI = 'Rainf_f_tavg' &$
;       P = get_nc(VOI, ifile[f]) &$
;       ingridP[*,*, cnt, ens-1982] = P &$
;      
;      VOI = 'Evap_tavg' &$
;      E = get_nc(VOI, ifile[f]) &$
;      ingridE[*,*, cnt, ens-1982] = E &$
;      
      VOI = 'Qs_tavg' &$
      Q = get_nc(VOI, ifile[f]) &$
      
      VOI = 'Qsb_tavg' &$
      Qsub = get_nc(VOI, ifile[f]) &$
      ingridRO[*,*, cnt, ens-1982] = Q+Qsub &$
     
     cnt++ &$
    endfor &$
  endfor &$
  print, ens &$
endfor 
ingridRO(where(ingridRO lt 0)) = !values.f_nan

;;extract the basin after, it doesnt save time to do it at readin.
tana_grid = ingridRO*rebin(tana_mask,nx,ny,200,34) & help, tana_grid
tana_TS = mean(mean(tana_grid,dimension=1,/nan), dimension=1,/nan) & help, tana_ts

rufi_grid = ingridRO*rebin(rufi_mask,nx,ny,200,34) & help, rufi_grid
rufi_TS = mean(mean(rufi_grid,dimension=1,/nan), dimension=1,/nan) & help, rufi_ts

basinp_cum = total(rufi_TS, 1, /cumulative) & help, basinp_cum
p1 = plot(basinp_cum[*,0]*86400, /buffer)
for i = 0,33 do begin &$
  p1=plot(basinp_cum[*,i]*86400, /buffer, /overplot, thick=1, 'grey') &$
endfor
p1=plot(median(basinP_cum[0:179,*]*86400,dimension=2), /buffer,/overplot, thick=3, 'black')
;p1=plot(mean(basinP_cum*86400,dimension=2), /buffer,/overplot, thick=3, 'blue')
p1.title = ' ESP cumulative runoff scenarios Rufiji Basin, 2012'
p1.save,'/home/almcnall/IDLplots/TS_2012_RO_CUM_Rufiji.png'

;write out the mean, 33rd, 50th and 67th percentile, how do i do this?
;see get_ESP_median.pro  but this is different for days than months..will have to think
;if they are being written out then you can just count them.
;i shoudl really get the mean of the Tana Basin...

TS = rufi_ts
ensemb = transpose(TS*86400) & help, ensemb
ens_avg = transpose(mean(TS*86400,dimension=2)) & help, ens_avg
ens_med = transpose(median(TS*86400,dimension=2)) & help, ens_med
out_arr = [ens_avg,ens_med] & help, out_arr

ofile = '/home/almcnall/IDLplots/20121001_Rufiji_RO_mean_med.csv'
write_csv, ofile, out_arr

ofile = '/home/almcnall/IDLplots/20121001_Rufiji_RO_ens.csv'
write_csv,  ofile, ensemb




;;see intial_cond_std.pro for analysis of variance

;Fjfm = [ reform(ingridF[mxind, myind,0:30,0], 31), reform(ingridF[mxind, myind,0:27,1],28), reform(ingridF[mxind, myind,0:30,2],31) ]
;p2=plot(Fjfm, thick=3,'orange', name = 'Cfinal', /overplot)
;;monthly plots
;Cfinal = mean(ingridF,dimension=3,/nan)
;p2 = plot(Cfinal[mxind,myind,*], 'orange', thick=3, name='Cfinal', /overplot)

;;now plot combo, Cfinalial intialized + Cprelim
;ifile = file_search(strcompress(rundir+'/Noah33_CG_ESPV_EA/201703/SURFACEMODEL/201703/LIS_HIST*', /remove_all))
;ingridC = fltarr(nx, ny, 31)
;for f = 0, n_elements(ifile)-1 do begin &$
;  VOI = 'SoilMoist_tavg' &$
;  ;read in all soil layers
;  SM = get_nc(VOI, ifile[f]) &$
;  ;just keep the top layer
;  SM0_10 = SM[*,*,0] &$
;  ingridC[*,*,f] = SM0_10 &$
;endfor

;march = mean(ingrid, dimension=3,/nan)
march = reform(ingridC[mxind, myind,*],31)
a = fltarr(28+31)*!values.f_nan

intial = [ a , march ]
;intial = [ [[sm01[*,*,0:1,35]]], [[march]] ]

p3 = plot(intial, thick=3, 'green', /overplot, name = 'intial combo')
;monthly plots
Ccombo = mean(ingridC,dimension=3,/nan)
b = fltarr(2)*!values.f_nan
initial_m = [ b, ccombo[mxind, myind] ]
p3 = plot(initial_m,  '*', sym_size=4, sym_thick=3, name='Ccombo', xrange=[0,11], yrange=[0.1,0.3], /overplot)

;;then plot the ESP results from CHIRPS-final + CHIRPS-prelim - how do i do this?
;;;forecast intialization date
startd = '20170820'
;startd = '20170228'

;yrs used for the ESPing
startyr = 1982
endyr = 2015 ;do i have 2016 estimates?
nyrs = endyr-startyr+1

yr = indgen(nyrs)+1982 & print, yr


NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)+'/'
;indir2 = NOAHdir+'Noah33_RFE_GDAS_EA/ESPvanilla/Noah33_RG_ESPV_EA/'+string(startd)


;where did 208 come from? 11 because 12 months, starting in feb
;is there a reason to start this in jan?
;enter month of intitialzation 1 = 20170131, 3 = march, output for april though...
initmo = 8
nmos = 12
espgrid = fltarr(NX, NY, nmos,nyrs)*!values.f_nan
;espgrid = fltarr(NX, NY, 31,12,nyrs)*!values.f_nan

cnt = 0
for i = 0, nyrs-1 do begin &$
  ;just read in all the LIS_HISTFILES for a given run...super pasgetti
  ifile = file_search(strcompress(indir2+string(yr[i])+'/SURFACEMODEL/??????/LIS_HIST*', /remove_all))  & help, ifile &$
  for f = 0, n_elements(ifile)-1 do begin &$
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  SM0_10 = SM[*,*,0] &$
  ;start on the intialization month to keep the first months empty...ESPout on first of month?
  espgrid[*,*,f+initmo,cnt] = SM0_10 &$
endfor &$
cnt++ &$
print, cnt &$
endfor
espgrid(where(espgrid lt 0))=!values.f_nan

pnt_esp = espgrid[mxind,myind,*,*] & help, pnt_esp
pnt_esp[0,0,7,*]=cprelim[mxind, myind, m-1]
for n = 0, n_elements(pnt_esp[0,0,0,*])-1 do begin &$
  p1 = plot(pnt_esp[0, 0, *, n], /overplot, color='cyan', name = 'ESP ENS') &$
  ;p1.save, '/home/almcnall/IDLplots/ts_mxing2.png' &$
endfor
p2 = plot(mean(pnt_esp,dimension=4,/nan), 'b', thick=2)

;ugh, this is set up for DAYS in a month...
;cnt = 0
;for i = 0, nyrs-1 do begin &$
;    y = i+1982 &$
;    print, y &$
;    for m = 9,11 do begin &$
;    ;m = 8 &$
;    YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
;    ;just read in all the LIS_HISTFILES for a given run...super pasgetti
;    ifile = file_search(strcompress(indir2+string(yr[i])+'/SURFACEMODEL/'+string(YYYYMM)+'/LIS_HIST*', /remove_all))  & help, ifile &$
;    for f = 0, n_elements(ifile)-1 do begin &$
;      VOI = 'SoilMoist_tavg' &$
;      ;read in all soil layers
;      SM = get_nc(VOI, ifile[f]) &$
;      ;just keep the top layer
;      SM0_10 = SM[*,*,0] &$
;      ;start on the intialization month to keep the first months empty...ESPout on first of month?
;      espgrid[*,*,f,m-1,i] = SM0_10 &$
;    endfor &$
;  endfor &$
;  cnt++ &$
;  print, cnt &$
;endfor

;m_espgrid = mean(espgrid, dimension=3, /nan)
;what did i do with the intial condition??

for i = 0, nyrs-1 do begin &$
  m_espgrid[mxind, myind, 0:2,i] = initial_m &$
  p4 = plot(m_espgrid[mxind, myind, *,i], 'cyan', /overplot) &$
endfor
p5 = plot(m_espgrid[mxind, myind, *,0], 'cyan', /overplot, name='ESP')
null = legend(target=[p1,p2,p3, p5])

;pad = fltarr(31+28+31)*!values.f_nan
for n = 0, n_elements(espgrid[0,0,0,*])-1 do begin &$
  Ejfm = [ reform(espgrid[mxind, myind,0:30,0,n], 31), reform(espgrid[mxind, myind,0:27,1,n],28), $
          reform(espgrid[mxind, myind,0:30,2,n],31), reform(espgrid[mxind, myind,0:29,3,n],30) ] &$
  ;combo = [ pad, reform(espgrid[mxind, myind, *, n],109) ]  &$
  p7 = plot(Ejfm, /overplot, color='cyan', name = 'ESP ENS') &$
  ;if p7 eq 0 then p7.name='ESP ENS' &$
  ;p1.save, '/home/almcnall/IDLplots/ts_mxing2.png' &$
endfor


;add month tickmarks...how do I do this again?
p1.xminor = 0
p1.xrange = [0, 11]
p1.yrange = [0,0.35]
p1.xtickvalues = indgen(12)
xticks = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
p1.xtickname = xticks
p1.font_name='times'




