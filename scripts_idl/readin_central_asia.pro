pro readin_central_asia

;readin central asia data (to find the accumulated rainfall from Dec 31-Jan 6)

;where is the data on discover?

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain001.pro

startyr = 2017 ;start with 1982 since no data in 1981
endyr = 2018
nyrs = endyr-startyr+1

;this isn't really gong to work, hu?
startmo = 12
endmo = 1

if startmo le endmo then nmos = endmo - startmo +1  $
else nmos = endmo - startmo +13

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = string('LIS_HIST_')
params = get_domain001('CA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

data_dir = '/gpfsm/dnb02/projects/p63/ASIA_FEWSNET/LIS7/OP/LIS_Asia_2017_2018/NOAH36/OUTPUT/SURFACEMODEL/'

;precip = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;precipf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan
;snow = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;if i know exactly which files i am interested in
ifile2 = strarr(7)
ifile2[0] = file_search(data_dir+'LIS_HIST_20171231*.nc')
ifile2[1:6] =  file_search(data_dir+'LIS_HIST_2018010{1,2,3,4,5,6}*.nc')

precip = FLTARR(NX,NY,n_elements(ifile2))*!values.f_nan
precipf = FLTARR(NX,NY,n_elements(ifile2))*!values.f_nan
snow = FLTARR(NX,NY,n_elements(ifile2))*!values.f_nan

for i = 0, n_elements(ifile2)-1 do begin &$

;this loop reads in the selected months only
;for yr=startyr,endyr do begin &$
;  for i=0,nmos-1 do begin &$
;  y = yr &$
;  m = startmo + i &$
;  if m gt 12 then begin &$
;  m = m-12 &$
;  y = y+1 &$
;endif &$
  ;ifile = file_search(data_dir+STRING(FORMAT='(''LIS_HIST_'',I4.4,I2.2,I2.2,''.0000.d01.nc'')',y,m,d)) &$
 ifile = ifile2[i] &$

  VOI = 'Rainf_tavg' &$
  Qs = get_nc(VOI, ifile) &$
  ;precip[*,*,i,yr-startyr] = Qs &$
  precip[*,*,i] = Qs &$
  
  VOI = 'Rainf_f_tavg' &$
  Qs2 = get_nc(VOI, ifile) &$
  ;precipf[*,*,i,yr-startyr] = Qs2 &$
  precipf[*,*,i] = Qs2 &$
  
  VOI = 'Snowf_tavg' &$
  Qs3 = get_nc(VOI, ifile) &$
  ;snow[*,*,i,yr-startyr] = Qs3 &$
  snow[*,*,i] = Qs3 &$
  
endfor
;endfor
precip(where(precip lt 0)) = !values.f_nan
precipf(where(precipf lt 0)) = !values.f_nan
snow(where(snow lt 0)) = !values.f_nan

