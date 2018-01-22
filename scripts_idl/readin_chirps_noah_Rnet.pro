pro readin_CHIRPRS_NOAH_ET
;this reads in the CHIPRS+NOAH time series 1982-present at 0.1 degree
;taken from noahvSSEB

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
;.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro

rainfall = 'CHIRPS'
;rainfall = 'RFE2'

;if rainfall eq 'RFE2' then startyr = 2001 else startyr = 1982

startyr = 1982 ;start with 1982 since no data in 1981, or 2003 if for SSEB compare
endyr = 2017
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = 'WA'
params = get_domain01(domain)
;params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
if rainfall eq 'CHIRPS' then $
   data_dir = strcompress(indir+'Noah33_CHIRPS_MERRA2_'+domain+'/post/', /remove_all) else $
   data_dir = strcompress(indir+'Noah33_RFE_GDAS_'+domain+'/post/', /remove_all) & print, data_dir
if rainfall eq 'CHIRPS' then V = 'C' else V = 'A'
fname = 'FLDAS_NOAH01_'+V+'_'+domain+'_M.A'
print, fname
;ifile = file_search(data_dir+fname+STRING(FORMAT='(I4.4,I2.2,''.001.nc'')',y,m)) &$

;intialize the evap output var
LWnet = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
SWnet = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qle = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
Qh  = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
 ; yr=startyr
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
  ifile = file_search(data_dir+fname+STRING(FORMAT='(I4.4,I2.2,''.001.nc'')',y,m)) &$
  
  ;variable of interest
  VOI = 'Lwnet_tavg' &$ 
  Qs = get_nc(VOI, ifile) &$
  LWnet[*,*,i,yr-startyr] = Qs &$
;  
  VOI = 'Swnet_tavg' &$ ;Qle_tavg
  Qs2 = get_nc(VOI, ifile) &$
  SWnet[*,*,i,yr-startyr] = Qs2 &$
;;  
  VOI = 'Qle_tavg' &$ ;Qh_tavg
  Qs3 = get_nc(VOI, ifile) &$
  Qle[*,*,i,yr-startyr] = Qs3 &$
;;  
  VOI = 'Qh_tavg' &$ ;Qh_tavg
  Qs4 = get_nc(VOI, ifile) &$
  Qh[*,*,i,yr-startyr] = Qs4 &$

endfor &$
  delvar, Qs, Qs2, Qs3, Qs4 &$
endfor
;don't use nan since i guess there are neg values in there...
Swnet(where(Swnet eq -9999.0)) = !values.f_nan
Lwnet(where(Lwnet eq -9999.0)) = !values.f_nan
Qle(where(Qle eq -9999.0)) = !values.f_nan
Qh(where(Qh eq -9999.0)) = !values.f_nan


Rnet = Swnet + Lwnet

;i use the mean in cdo but this could be changed to total if desired.
Rnet_annual = mean(Rnet, dimension = 3, /nan) & help, rnet_annual
Qle_annual = mean(Qle, dimension = 3, /nan) & help, Qle_annual
Qh_annual = mean(Qh, dimension = 3, /nan) & help, Qh_annual


delvar, Qs, Swnet, Lwnet, Qle, Qh, Rnet

Rnet = mean(rnet_annual, dimension=3,/nan)
Qle = mean(Qle_annual, dimension=3,/nan)
Qh = mean(Qh_annual, dimension=3,/nan)

delvar, rnet_annual, qle_annual, qh_annual