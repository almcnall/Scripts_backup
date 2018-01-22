pro get_ESPmedian

;this script reads in the ESP grid, and gets the median, to be concatinated with CHIRPS.
; start with SM then move on to ET and runoff.
; this does not do spegetti, for that see esp_timeseriesv2.pro
; 

;(1) read in the CHIRPS-prelim to fill the missing month (from readin_cprelim.pro)
;(2) readin the ESP grid (ok)
;(3) read in the CHIRPS-final for full time series (ok)
;(4) export data+ESPmedian to compute other metrics (ok)

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
;get prelim averaged variable from readin_cprelim.pro
help, cprelim

;;;;;;;;;;;;;;;;;;

;(2);;read in the ESP-grid
;;;forecast intialization date
startd = '20171126'

;yrs used for the ESPing
startyr = 1982
endyr = 2016 ;do i have 2016 estimates?
nyrs = endyr-startyr+1

yr = indgen(nyrs)+1982 & print, yr

NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_WA/ESPvanilla/Noah33_CM2_ESPV_WA/'+string(startd)+'/'
;indir2 = NOAHdir+'Noah33_RFE_GDAS_EA/ESPvanilla/Noah33_RG_ESPV_EA/'+string(startd)


;enter month of ESP intitialzation 1 = 20170131, 3 = march, output for april though...
; do i use nov for nov 26 or december 1?
initmo = 11
;initda = 26
nmos = 12
espgrid = fltarr(NX, NY, nmos,nyrs+1)*!values.f_nan
;espgrid = fltarr(NX, NY, 31,12,nyrs)*!values.f_nan
tic
cnt = 0
for i = 0, nyrs-1 do begin &$
  ;just read in all the LIS_HISTFILES for a given run...super pasgetti
  ifile = file_search(strcompress(indir2+string(yr[i])+'/SURFACEMODEL/??????/LIS_HIST*', /remove_all))  & help, ifile &$
  for f = 0, n_elements(ifile)-1 do begin &$
    ;VOI = 'SoilMoist_tavg' &$
    ;VOI = 'Evap_tavg' &$
    ;read in all soil layers
    ;SM = get_nc(VOI, ifile[f]) &$
    ;just keep the top layer
    ;SM0_10 = SM[*,*,0] &$
  
    VOI = 'Qs_tavg' &$
    Qs = get_nc(VOI, ifile[f]) &$

    VOI = 'Qsb_tavg' &$
    Qsb = get_nc(VOI, ifile[f]) &$ 
  
    ;for monthly output: start on the intialization month to keep the first months empty...ESPout on first of month?
    ;espgrid[*,*,f+initmo,cnt] = SM0_10 &$
    m = (f + initmo) MOD 12   &$
    if f + initmo eq 12 then cnt++ &$
    espgrid[*,*,m,cnt] = Qs+Qsb &$
    
    ;for daily output: average the values in a month..
    ;espgrid[*,*,f+initda,f+intimo,cnt] = Qs+Qsb &$
    ;countmap[*,*,0] = countmap[*,*,0] + dry
  endfor &$
  ;cnt++ &$
  print, cnt &$
endfor
toc
espgrid(where(espgrid lt 0))=!values.f_nan
delvar, Qs, Qsb
;take a look at the espgrid...looks fine
;mxind = FLOOR( (36.8503 - map_ulx)/ 0.1)
;myind = FLOOR( (-0.82 - map_lry) / 0.1)
;for i = 0, 33 do begin &$
;  p1=plot(reform(espgrid[mxind,myind,*,i]), /overplot) &$
;endfor

;;;;;;;;THE ESP OUTLOOK;;;;;;;
;;;get the median and the 67th and 33rd percentiles of the forecast

permap = fltarr(nx, ny, 12, 3)
for m = 0,11 do begin &$
  for x = 0, nx-1 do begin &$
  for y = 0, ny-1 do begin &$
  ;skip nans
  test = where(finite(espgrid[x,y,m,*]),count) &$
  if count eq -1 then continue &$
  ;look at one pixel time series at a time
  pix = espgrid[x,y,m,*] &$
  ;then find the index of the Xth percentile, how would i fit a distribution?
  permap[x,y,m,*] = cgPercentiles(pix , PERCENTILES=[0.33,0.5,0.67]) &$
endfor  &$
endfor

;then i need the count map to determine what the ESP has to say! crapppp!

;this gives the same result.
;espmedian = median(espgrid, dimension=4) & help, espmedian
esp33 = permap[*, *, *, 0]
espmedian = permap[*, *, *, 1]
esp67 = permap[*, *, *, 2]

; confirm that there is no ESP in November, and no prelim in DEC
; switch to ESP first of month protocol. Where CHIRPS-Prelim is valid Dec1 - use this to replace
; ESP december 1 (median), start using median with Jan1. 
m = 11
print, mean(espmedian[*,*,m-1], /nan)
print, mean(espmedian[*,*,m], /nan)
print, mean(Cprelim[*,*,m], /nan)
print, mean(Cprelim[*,*,m-1], /nan)

;filled in Nov30/Dec1 with Cprelim...ESP really starts Jan1
espmedian[*,*,11]=Cprelim[*,*,10]
esp33[*,*,11]=Cprelim[*,*,10]
esp67[*,*,11]=Cprelim[*,*,10]

;write out files for Kris/GIS..how to write netcdf
;;get CRS geotag for West Afrca from USGS/EROS file, make a function!
;;west africa
ifile = file_search('/discover/nobackup/almcnall/SHPfiles/wa_monthly_fldas_soilmoi00_10cm_tavg_1710.tif')
ingrid = read_tiff(ifile, GEOTIFF=g_tags) & print, g_tags

odir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_WA/RO_stack/'
ofile = odir+'/RO_ESP2018_median.tif'
write_tiff, ofile, reverse(espmedian,2), geotiff=g_tags, /FLOAT, PLANARCONFIG=2

odir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_WA/RO_stack/'
ofile = odir+'/RO_ESP2018_33percentile.tif'
write_tiff, ofile, reverse(esp33,2), geotiff=g_tags, /FLOAT, PLANARCONFIG=2

odir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_WA/RO_stack/'
ofile = odir+'/RO_ESP2018_67percentile.tif'
write_tiff, ofile, reverse(esp67,2), geotiff=g_tags, /FLOAT, PLANARCONFIG=2


delvar, espgrid

;;fill in the rest of the year with 2017 variable 
;;read in SM01, or other var (Evap, RO) and just get 2017
help, SM01, evap, RO
RO17 = RO[*,*,*,35] & help, RO17, espmedian
print, mean(RO17[*,*,m-2], /nan)
print, mean(espmedian[*,*,m-2],/nan)

;ok, now i have a cube that has Jan-July CHIRPS-final, Aug CHIRPS-prelim, Sept-Nov ESPmedian
espmedian[*,*,0:m-2] = RO17[*,*,0:m-2]

delvar, cprelim, ro17
;now i can compare this plot to the Somalia Bay plot that I made earlier...
;Bay Region Somalia 2.660781, 43.530140
mxind = FLOOR( (43.530140 - map_ulx)/ 0.1)
myind = FLOOR( (2.660781 - map_lry) / 0.1)
p1 = plot(espmedian[wxind, wyind, *],/buffer)

p1.save, '/home/almcnall/IDLplots/temp.png'


