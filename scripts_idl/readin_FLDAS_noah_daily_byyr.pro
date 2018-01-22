pro readin_FLDAS_NOAH_SM_daily_byyr
;this reads in the CHIPRS/RFE2+NOAH daily time series 1982-present at 0.1 degree
;revisit for the SERVIR training and the tana/rufiji example
; adjust this so that months don't have 31 days
; i could use this to later break the year into months...
;ndays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]  &$
;if (yr MOD 4) eq 0 then ndays[1] = 29  &$

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/nve.pro
.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 2009
endyr = 2013
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

;;;;;;update data directory here for RFE, CHIRPS, EA, SA, WA;;;;;;;;;;;;;;
;indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/'
indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
data_dir = strcompress(indir+'Noah33_CHIRPS_MERRA2_'+domain+'/SURFACEMODEL/', /remove_all)
;data_dir = strcompress(indir+'Noah33_RFE_GDAS_'+domain+'/post/', /remove_all)
if rainfall eq 'CHIRPS' then V = 'C' else V = 'A'
;fname = 'FLDAS_NOAH01_'+V+'_'+domain+'_M.A'

SMday = FLTARR(NX,NY,366,nyrs,4)*!values.f_nan
;SM2day = FLTARR(NX,NY,366,nyrs)*!values.f_nan
;SM01 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;SM02 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;SM03 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;SM04 = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

Pday = FLTARR(NX,NY,366,nyrs)*!values.f_nan
;P = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

ROday = FLTARR(NX,NY,366,nyrs)*!values.f_nan
;RO = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

ETday = FLTARR(NX,NY,366,nyrs)*!values.f_nan
;ET = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;this loop reads in the selected months only
for YR = startyr,endyr do begin &$
  ;YR=2009
 ; for i=0,nmos-1 do begin &$
    y = yr &$
  ;  m = startmo + i &$
    YYYY = STRING(format='(I4.4)', YR) & print, YYYY &$
 ;   if m gt 12 then begin &$
 ;     m = m-12 &$
 ;     y = y+1 &$
;    endif &$
    fnames = file_search(strcompress(data_dir+YYYY+'??'+'/LIS_HIST_'+YYYY+'??'+'*.d01.nc', /remove_all)) &$
    help, fnames &$
    for f = 0, n_elements(fnames)-1 do begin &$
      ifile = fnames[f] &$
      print, ifile &$
      ;variable of interest
       
     ;  just get the top layer of soil moisture
;      VOI = 'Rainf_tavg' &$ 
;      P = get_nc(VOI, ifile) &$
;      Pday[*,*,f,yr-startyr] = P &$
;      
;      VOI = 'Evap_tavg' &$
;      ET = get_nc(VOI, ifile) &$
;      ETday[*,*,f,yr-startyr] = ET &$ ;Qsb_tavg
;      
;      VOI = 'Qs_tavg' &$
;      Q1 = get_nc(VOI, ifile) &$
;      ;ROday[*,*,f,i,yr-startyr] = RO &$ ;Qsb_tavg
;     
;      VOI = 'Qsb_tavg' &$
;      Q2 = get_nc(VOI, ifile) &$
;     ROday[*,*,f,yr-startyr] = Q1+Q2 &$ ;Qsb_tavg
;;      
      VOI = 'SoilMoist_tavg' &$
      SM = get_nc(VOI, ifile) &$
      ;SM01 = SM[*,*,0] &$
      ;get all of the layers and take the mean
      SMday[*,*,f,yr-startyr,*] = SM &$
;      
;      SM02 = SM[*,*,1] &$
;      SM2day[*,*,f,i,yr-startyr] = SM02 &$
;      SM2day[*,*,f,i,yr-startyr] = SM02 &$

      
      ;read in the whole year and don't break up by month
;      VOI = 'Qsb_tavg' &$
;      Qsub = get_nc(VOI, ifile[f]) &$
;      ingridRO[*,*, cnt, yr-startyr] = Q+Qsub &$
;
;      cnt++ &$
        
    endfor &$
  endfor 
;endfor
;SMP(where(SMP lt 0)) = 0
SM01(where(SM01 lt 0)) = 0
;SM02(where(SM02 lt 0)) = 0
;SM03(where(SM03 lt 0)) = 0
;SM04(where(SM04 lt 0)) = 0

delvar, Qs

;convert to m3 per 10km2 pixel (how does this differ with VIC?)
SMm3 = SM01*10+SM02*30+SM03*60+SM04*100
delvar,  SM02, SM03, SM04, SMP
SMtot_annual = mean(SMtot, dimension=3, /nan)