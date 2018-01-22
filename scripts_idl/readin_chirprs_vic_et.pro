pro readin_CHIRPS_VIC_ET
;this reads in the CHIPRS+NOAH time series 1982-present at 0.1 degree
;taken from aqueductv4.pro


.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/nve.pro
;.compile /home/almcnall/Scripts/scripts_idl/mve.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain25.pro

rainfall = 'CHIRPS'
;rainfall = 'RFE2'

startyr = 2003 ;start with 1982 since no data in 1981
endyr = 2017
nyrs = endyr-startyr+1

startmo = 1
endmo = 12
nmos = endmo - startmo+1

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain25('SA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;just for unroutined
indir = '/discover/nobackup/projects/fame/MODEL_RUNS/VIC_OUTPUT/'
if rainfall eq 'CHIRPS' then $
  data_dir = strcompress(indir+'OUTPUT_M2C_'+domain+'/post/', /remove_all) else $
  data_dir = strcompress(indir+'OUTPUT_RG71_'+domain+'v5/post/', /remove_all) & print, data_dir
if rainfall eq 'CHIRPS' then V = 'C' else V = 'A'
fname = 'FLDAS_VIC025_'+V+'_'+domain+'_M.A'
print, fname

;data_dir='/discover/nobackup/projects/fame/MODEL_RUNS/VIC_OUTPUT/OUTPUT_M2C_SA/post/'

Qsuf = FLTARR(NX,NY,nmos,nyrs)*!values.f_nan

;this loop reads in the selected months only
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_VIC025_C_WA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
ifile = file_search(data_dir+fname+STRING(FORMAT='(I4.4,I2.2,''.001.nc'')',y,m)) &$
print, ifile &$
VOI = 'Evap_tavg' &$ ;Qsb_tavg
;;VOI = 'Qs_tavg' &$
Qs = get_nc(VOI, ifile) &$
Qsuf[*,*,i,yr-startyr] = Qs &$

endfor &$
endfor
Qsuf(where(Qsuf lt 0)) = !values.f_nan

evap = Qsuf
delvar, Qsuf, qs