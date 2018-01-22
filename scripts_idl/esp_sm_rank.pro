pro ESP_SM_rank
;;can I adjust this script so that i can use the ESP time series? for the ranks i think i need to FULL TS.
;; or maybe i could add it at the end.

;;first read in ESPmedian from get_ESPmedian.pro
help, espmedian
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; SOME STATS STUFF WITH MULTI-MONTH ACCUMULATIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mo_names = ['January','February','March','April','May','June', $
  'July','August','September','October','November','December']
mo_init = ['J','F','M','A','M','J','J','A','S','O','N','D']
startyr = 1982          ; this is the first year that all data is available
startmo = 5
endmo = 9
if startmo le endmo then nmos = endmo - startmo +1  $
else nmos = endmo - startmo +13

; set some parameters for read-in and mapping
;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA2_EA/'
data_dir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/post/'
;data_dir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/HYMAP/OUTPUT_EA1981/post/'

;fname = data_dir+STRING('FLDAS_NOAH01_H_EA_M.A',startyr,startmo,'.001.nc',f='(a,I4.4,I2.2,a)')
fname = data_dir+STRING('FLDAS_NOAH01_C_EA_M.A',startyr,startmo,'.001.nc',f='(a,I4.4,I2.2,a)')

fid = NCDF_OPEN(fname,/NOWRITE)
NCDF_VARGET,fid,26,lon
NCDF_VARGET,fid,27,lat

;;for HYMAP outputs;;;;;
;fid = NCDF_OPEN(fname,/NOWRITE)
;NCDF_VARGET,fid,0,lon
;NCDF_VARGET,fid,1,lat

NX = N_ELEMENTS(lon)
NY = N_ELEMENTS(lat)
min_lon = MIN(lon)      & max_lon = MAX(lon)
min_lat = MIN(lat)      & max_lat = MAX(lat)
map_lim = [min_lat,min_lon,max_lat,max_lon]
xsize = ABS(lon[1]-lon[0])
ysize = ABS(lat[1]-lat[0])


;;;; READIN NOAH NETCDF FILES AND GET SOIL MOISTURE FOR EAST AFRICA,
;;currently using this rather than readin_noahX.pro, how to make flexible for ESP outlooks?
;;so this is reading by month, so does include 2017 up to july (36) but doesn't incl. Aug/Sept (35)
;; but doens't appear to give me short total due to limited months, looks like b/c i am only doing
;; 1982-2016 (35 yrs, rather than 36), so can add the new 5 month total in here...

for i=0,nmos-1 do begin &$
  moi = startmo +i &$
  if moi gt 12 then moi = moi -12 &$
  ;data_dir = '/home/ftp_out/people/mcnally/FLDAS/FLDAS4DISC/NOAH_CHIRPSv2.001_MERRA2_EA/'
  fnames = FILE_SEARCH(data_dir,STRING('FLDAS_NOAH01_C_EA_M.A????',moi,'.001.nc',f='(a,I2.2,a)')) &$
  ; fnames = FILE_SEARCH(data_dir,STRING('FLDAS_NOAH01_H_EA_M.A????',moi,'.001.nc',f='(a,I2.2,a)')) &$

  help, fnames &$ 
  nyrs = N_ELEMENTS(fnames) &$
  ;ncdf_list,fnames[0],/VARIABLES, /DIMENSIONS, /GATT, /VATT
  fid = NCDF_OPEN(fnames[0],/NOWRITE) &$

  SM = FLTARR(NX,NY,NYRS) &$; soil moisture
  for j=0,nyrs-1 do begin &$
  fid = NCDF_OPEN(fnames[j],/NOWRITE) &$
  SoilID = ncdf_varid(fid,'SoilMoi00_10cm_tavg') &$
  ; SoilID = ncdf_varid(fid,'Streamflow_tavg') &$
  ; SoilID = ncdf_varid(fid,'Evap_tavg') &$

  ;   SoilID = ncdf_varid(fid,'SoilMoi10_40cm_tavg') &$
  ;   SoilID = ncdf_varid(fid,'SoilMoi40_100cm_tavg')
  ;   SoilID = ncdf_varid(fid,'SoilMoi100_200cm_tavg')
  ncdf_varget,fid, SoilID, SM01 &$
  SM[*,*,j] = SM01 &$
endfor &$
if i eq 0 then SMtot = SM $ &$
else SMtot = SMtot + SM &$
endfor

SMtot_org = SMtot ;save just in case i need to recompute

;;add value to SMtot here from ESP (can this work for just one month?)
help, ESPmedian
;get the sum of the months of interest, may have problem w/ nan vs zero...
May2Sept = total(ESPmedian[*,*,4:8], 3) & help, may2sept
Smtot = [ [[SMtot]], [[May2Sept]] ] & help, SMtot


SMtot = SMtot / nmos  ; convert to average monthly SM
nyrs = N_ELEMENTS(SMtot[0,0,*])

;what is this doing?
n_neg = TOTAL(SMtot lt 0.0000,3)
glocs = WHERE(n_neg eq 0)
gind = ARRAY_INDICES([NX,NY],glocs,/DIMENSIONS)

SMtot[WHERE(SMtot lt 0.0000)] = !VALUES.F_NAN

;; get the ranks of the seasonal sums
.compile /home/almcnall/Scripts/scripts_idl/Get_Ranks.pro
RankTime = TIC('Time to calculate ranks')
ssnrnk = FLTARR(SIZE(SMtot,/DIMENSIONS)) - 1.
for i=0,N_ELEMENTS(glocs)-1 do $
  ssnrnk[gind[0,i],gind[1,i],*] = GET_RANKS(SMtot[gind[0,i],gind[1,i],*])
TOC, RankTime

shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

;;; Make some graphics of the data
w = WINDOW(DIMENSIONS=[900,900])

ncolors = 8
index = [-1.5, -0.5, 1.5, 2.5, 3.5, nyrs-2.5, nyrs-1.5, nyrs-0.5, nyrs+0.5]
col_names = ['light gray','sienna','orange red','orange','white','aqua','dodger blue','dark blue']
m1 = MAP('Geographic',LIMIT=map_lim,/CURRENT)
tmpgr = CONTOUR(ssnrnk[*,*,-1],FINDGEN(NX)/10. + min_lon, FINDGEN(NY)/10. + min_lat,$
  /FILL, ASPECT_RATIO=1, C_VALUE=index, C_COLOR=col_names,  $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT, /buffer)
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
;grtitle = TEXT(0.5,0.9,STRING(FORMAT='(''July Soil Moisture Rank'',I4.4)',year), ALIGNMENT=0.5,FONT_SIZE=16)
;grtitle = TEXT(0.5,0.955,'Oct-May Soil Moisture Rank '+STRING(startyr+nyrs-1,f='(I4.4)'), ALIGNMENT=0.5,FONT_SIZE=16)
mc = MAPCONTINENTS(shapefile, /COUNTRIES, COLOR=[70,70,70],FILL_BACKGROUND=0,THICK=2,LIMIT=map_lim )
cb = colorbar(RGB_TABLE=col_names[*,1:-1],ORIENTATION=1,/BORDER,POSITION=[0.92,0.15,0.96,0.85],TAPER=0, $
  TEXT_ORIENTATION=90,FONT_SIZE=10)
cb.TICKVALUES = FINDGEN(N_ELEMENTS(col_names[0,1:-1])) + 0.5
cb.TICKNAME = ['Driest','Second Driest','Third Driest',' ','Third Wettest','Second Wettest','Wettest']
grtitle = TEXT(0.5,0.955,'May-Sept outlook (0-10cm) Soil Moisture Rank 2017 ', ALIGNMENT=0.5,FONT_SIZE=16)
tmpgr.save, '/home/almcnall/IDLplots/SM01_Rank_May_July2017_v1.png', RESOLUTION=300
