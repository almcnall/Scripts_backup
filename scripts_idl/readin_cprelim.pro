pro readin_cprelim

;12/4/17 this script reads in the prelim data, useful for ESP runs or early looks at other indicators


  .compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
  .compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

  ;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
  domain = 'WA'
  params = get_domain01(domain)
  print, params

  NX = params[0]
  NY = params[1]
  map_ulx = params[2]
  map_lrx = params[3]
  map_uly = params[4]
  map_lry = params[5]
;

;(1);;;read in the prelim data to fill the CHIRPS final gap;;;;
;this can be used for ESP forecasts, or for prelim products;;;;;
;;;get the daily data from CHIRPS-prelim (and take the mean for the month);;;;
rundir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_WA/ESPvanilla/
indirP = rundir+'Noah33_CG_ESPV_WA/20171130/SURFACEMODEL/'; 201711/'

;rundir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/'
;indirP = rundir+'Noah33_CG_ESPV_EA/201708/SURFACEMODEL/'

ingridP = fltarr(nx, ny, 31, 12)*!values.f_nan

m = 11
y = 2017
YYYYMM = STRING(FORMAT='(I4.4,I2.2)',y,m) &$
  ifile = file_search(strcompress(indirP+YYYYMM+'/LIS_HIST*', /remove_all))  & help, ifile  ;28daysx4per day
for f = 0, n_elements(ifile)-1 do begin &$
  ;VOI = 'SoilMoist_tavg' &$
  ;VOI = 'Evap_tavg' &$

  VOI = 'Qs_tavg' &$
  Qs = get_nc(VOI, ifile[f]) &$

  VOI = 'Qsb_tavg' &$
  Qsb = get_nc(VOI, ifile[f]) &$

  ;read in all soil layers
  ;SM = get_nc(VOI, ifile[f]) &$
  ;just keep the top layer
  ;SM0_10 = SM[*,*,0] &$

  ;put in in an array for the appropriate month
  ;ingridP[*,*,f,m-1] = SM0_10 &$ ; soil, evap
  ingridP[*,*,f,m-1] = Qs+Qsb &$ ;combine runoff.
endfor
ingridP(where(ingridP lt 0))=!values.f_nan
;;;;;mean for gap month;;;;
Cprelim = mean(ingridP,dimension=3,/nan)
delvar, ingridP

;what do i want to do next? comput the soil moisture ranks,
;then work on the water stress maps (eak! when does kris get back?!)
;also fire up the actual ESP runs...
