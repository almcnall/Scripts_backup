pro ESP_timeseriesV2
;read in all historic soil moisture
;this one contains ways to plot monthly v1 has ways to plot daily
;just for the current month (see v1 for chirps-prelim vs final comparisons)
;try to map long cycle Ethiopia (May-Sept ranks): get median from ESP, concat that w/ CHIRPS and run usual code.

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 1982
endyr = 2017
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


;coordinates for Mpala
;mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
;myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
;mxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
;myind = FLOOR( (0.793458 - map_lry) / 0.1)

;Bay Region Somalia 2.660781, 43.530140
mxind = FLOOR( (43.530140 - map_ulx)/ 0.1)
myind = FLOOR( (2.660781 - map_lry) / 0.1)

;;;read in SM01 from readin_FLDAS_noah_sm.pro;;;;;

;;;plot mean from SM01
histmean = median(sm01, dimension = 4) & help, histmean ;no diff when i exclude 2017
histmax = max(sm01, dimension = 4, /nan) & help, histmax ;no diff when i exclude 2017
histmin = min(sm01, dimension = 4, /nan) & help, histmin;no diff when i exclude 2017

p0=plot(histmean[mxind,myind,*], thick = 3, /overplot, title='c2m2 clim','c')
p0=plot(histmax[mxind,myind,*], thick = 1, /overplot, name='max','grey')
p0=plot(histmin[mxind,myind,*], thick = 1, /overplot, name='min','grey')

p0.xminor = 0
p0.xrange = [0, 11]
p0.yrange = [0,0.4]
p0.xtickvalues = indgen(12)
xticks = ['jan', 'feb', 'mar', 'apr', 'may', 'jun','jul','aug','sep','oct','nov','dec']
p0.xtickname = xticks
p0.font_name='times'

;;;get the daily data from CHIRPS-prelim (and take the mean for the month);;;;
rundir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/'
indirP = rundir+'Noah33_CG_ESPV_EA/201708/SURFACEMODEL/'

ingridP = fltarr(nx, ny, 31, 12)*!values.f_nan

  m = 8
  y = 2017 &$
  YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
  ifile = file_search(strcompress(indirP+YYYYMM+'/LIS_HIST*', /remove_all))  & help, ifile &$ ;28daysx4per day
  for f = 0, n_elements(ifile)-1 do begin &$
    VOI = 'SoilMoist_tavg' &$
    ;VOI = 'Evap_tavg' &$

    ;read in all soil layers
    SM = get_nc(VOI, ifile[f]) &$
    ;just keep the top layer
    SM0_10 = SM[*,*,0] &$
    ingridP[*,*,f,m-1] = SM0_10 &$
  endfor

;monthly plots
Cprelim = mean(ingridP,dimension=3,/nan)
p1 = plot(Cprelim[mxind,myind,*], 'red', thick=3, name='Cprelim', /overplot)

;;insert august to the July Chirps-final and the esp-spegetti, or concat to all the ESP plots.
TS = reform(SM01[mxind,myind,*,35]) & help, TS
TS[7]= cprelim[mxind, myind, m-1]
p3=plot(TS, thick = 3, 'r', /overplot, name='Cprelim+final')

;plot the current Chirps-final soil moisture do differentiate
p3=plot(SM01[mxind,myind,*,35], thick = 3, 'orange', /overplot, name='Cfinal')

;;then plot the ESP results, with the prelim intial value
;;;forecast intialization date
startd = '20170820'

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

;this set the intial value for the point...not very flexible.
pnt_esp = espgrid[mxind,myind,*,*] & help, pnt_esp
pnt_esp[0,0,7,*]=cprelim[mxind, myind, m-1]

for n = 0, n_elements(pnt_esp[0,0,0,*])-1 do begin &$
  p1 = plot(pnt_esp[0, 0, *, n], /overplot, color='cyan', name = 'ESP ENS') &$
  ;p1.save, '/home/almcnall/IDLplots/ts_mxing2.png' &$
endfor
p2 = plot(mean(pnt_esp,dimension=4,/nan), 'b', thick=2, /overplot, name='ens mean')
p2.title = 'pnt bay somalia SM01'
null = legend(target=[p0,p1,p2])

