pro make_countmap

;11/02/16 separated out this module from scenarioTri for generateing countmaps from ESP.
;this was originally done with the bootstrap method. but now switching to vanilla/traditional
;01/27/17 revisit
;01/30/17 after running ESP script, use this to make a countmap for each yr and var of interest.
;10/23/17 attempt to implement P(<80%) soil moisture maps, different from percentile approach here.
;(1) find typical multimonth total (e.g.SOND) for a give var (e.g. SM01)
;(2) make a matrix of this year's estimated total (its an ensemble)
;(3) count # of times (2) value is below 80% of average.
;(4) make the map...

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro

;yrs used for the ESPing
startyr = 1982
endyr = 2015 ;do i have 2016 estimates?
nyrs = endyr-startyr+1

yr = indgen(nyrs)+1982 & print, yr


params = get_domain01('EA')
eNX = params[0]
eNY = params[1]
emap_ulx = params[2]
emap_lrx = params[3]
emap_uly = params[4]
emap_lry = params[5]

map_ulx = emap_ulx & min_lon = map_ulx
map_lry = emap_lry & min_lat = map_lry
map_uly = emap_uly & max_lat = map_uly
map_lrx = emap_lrx & max_lon = map_lrx
NX = eNX
NY = eNY

;; if not read it in or run make_permap.pro
;permap = fltarr(nx, ny, 12, 3)
;ifile = file_search('/discover/nobackup/projects/fame/MODEL_RUNS/EA_Noah33/ESPvanilla/SM01_NOAH_permap_294_348_12_3_1982_2016.bin')
;openr, 1, ifile
;readu, 1, permap
;close,1

;first make sure you have the threshold map
;help, permap
;feb_permap = permap[*,*,1,*]
;mar_permap = permap[*,*,2,*]

;;rather than using percentiles/quartiles read in historic SOND SM01 w/ readin_FLDAS_NOAH_SM.pro
help, sm01 ;nx, ny,sond, 36
;might make more sense for this to be avg but total is fine for now.
ssnav = mean(total(sm01[*,*,*,0:34],3, /nan), dimension=3) & help, ssnav

;;need to keep the "observered" data from September! and concat that with SMest;;;
;;;not yet complete 10/23;;;;
Sept17 = SM01[*,*,0,-1]

;;also get october
indir3 = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CG_ESPV_EA/20171023/SURFACEMODEL/201710/'
ifile_oct = file_search(indir3+'LIS_HIST_201710*') & help, ifile_oct

Oct17 = fltarr(nx, ny, n_elements(ifile_oct))
for i = 0, n_elements(ifile_oct)-1 do begin &$
  print, ifile_oct[i] &$
  ;read in the variable of interest e.g. all SM
  VOI = 'SoilMoist_tavg' &$
  SM = get_nc(VOI, ifile_oct[i]) &$
  SMlayer = SM[*,*,0] &$
  Oct17[*,*,i] = SMlayer &$
  print, i &$
endfor
Oct17(where(Oct17 eq -9999.00)) = !values.f_nan
help, Oct17
Oct17 = mean(oct17, dimension=3, /nan)

;;;eventually move this out to a "readin_ESP_SM.pro" script. ok here for now.
;;;forecast intialization date 
startd = '20171020' ;'20170228'
;make sure i am looking at the right runs
NOAHdir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/'
indir2 = NOAHdir+'Noah33_CHIRPS_MERRA2_EA/ESPvanilla/Noah33_CM2_ESPV_EA/'+string(startd)
;indir2 = NOAHdir+'Noah33_RFE_GDAS_EA/ESPvanilla/Noah33_RG_ESPV_EA/'+string(startd)

;;generate countmap for a given month;;;;;
;m = month of interest from countmap e,g, february...
;percentile map bases at end of month, while ESP at first. e.g. MarchESP=FEBper

;ESPmonth - currently one at at time...but might want multimonths.
ESP_M = 11 ;jajnuary=1, feb=2, Mar1=3 April1=4, May1=5, June1=6
PER_M = ESP_M-1
M = PER_M-1
;PERmonth PerM = M-1
;ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))

;;break this into two loops (1) reading in (2) comparing to avg*0.80 and counting
;nmos=4; should be defined from readin_FLDAS_SM.pro

;;;;read in the estimates;;;;;;
SMcube = fltarr(nx,ny,2,34) ;1982-2015 = 34
cnt=0
for M=11,12 do begin &$
  ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', M) +'/LIS_HIST*.nc', /remove_all)) &$
 for i = 0, n_elements(ifile)-1 do begin &$
   print, ifile[i] &$
   ;read in the variable of interest e.g. all SM
   VOI = 'SoilMoist_tavg' &$
   SM = get_nc(VOI, ifile[i]) &$
   ;SMlayer = SM[*,*,0] &$
   SMcube[*,*,cnt,i] = SM[*,*,0] &$
 endfor &$
  cnt++ &$
endfor
SMcube(where(smcube eq -9999.0))=!values.f_nan

;;concatinate sept and october data;;;
SOND34 = fltarr(nx,ny,4,34)
for i=0,33 do begin &$
  SOND = [ [[sept17]], [[oct17]], [[reform(smcube[*,*,*,i])]] ] &$
  SOND34[*,*,*,i] = SOND &$
endfor

;;;compute the SOND total for all the different estimates;;;;;
SMest = total(sond34,3,/nan) & help, SMest
;delvar, smcube

;;check to see the results look ok (distrubuted around avg);;;;
mxind = FLOOR( (36.8701 - map_ulx)/ 0.1)
myind = FLOOR( (0.4856 - map_lry) / 0.1)

;Haramka Somalia 0.793458, 43.383063
mxind = FLOOR( (43.383063 - map_ulx)/ 0.1)
myind = FLOOR( (0.793458 - map_lry) / 0.1)
p1 = plot(smest[mxind, myind, *], '*')
p1.xrange = [0,32]
onelinex = POLYLINE(p1.xrange, [ssnav[mxind,myind],ssnav[mxind,myind]]*0.80 ,'--',COLOR='Gray') ;add a line for the mean

print, ssnav[mxind,myind] ; what is typical..looks like a wet yr for mpala, check bay

;;;;;make counts here, where value is lt 80% of average
thresh_perc = 0.80
thresh_grid = ssnav * thresh_perc

dry = fltarr(NX, NY)*0
temp = fltarr(NX,NY)*0
countmap = fltarr(NX,NY,34)*0

for i = 0, n_elements(SMest[0,0,*])-1 do begin &$
  low = where(SMEST[*,*,i] lt thresh_grid, complement=wet) &$
  temp(low) = 1 &$
  temp(wet) = 0 &$
  countmap[*,*,i] = temp &$
endfor

summap = total(countmap,3,/nan)
temp = image(summap, rgb_table=64)

scaled = (1./(nyrs-2.))*summap

;;;make map that matches greg's here

;NX = N_ELEMENTS(lon)
;NY = N_ELEMENTS(lat)
;min_lon = MIN(lon)      & max_lon = MAX(lon)
;min_lat = MIN(lat)      & max_lat = MAX(lat)
;map_lim = [min_lat,min_lon,max_lat,max_lon]
;xsize = ABS(lon[1]-lon[0])
;ysize = ABS(lat[1]-lat[0])
shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'

w = WINDOW(DIMENSIONS=[800,800])
mlim = [min_lat,min_lon,max_lat,max_lon]
m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1)
xsize=0.10
ysize=0.10

; now map Probabilities
tmpgr.erase
ncolors = 10
index = FINDGEN(ncolors+1) / ncolors
;tmpdat = (1./(nyrs-1))*ltcount[xmin:xmax,ymin:ymax]
tmpdat = scaled
tmpdat[WHERE(tmpdat lt 0.0000)] = !VALUES.F_NAN


tmpgr = CONTOUR(tmpdat, RGB_TABLE=26, FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
     /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='light gray',  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), XSTYLE=1, YSTYLE=1, /OVERPLOT)
tmprgb = tmpgr.rgb_indices  & tmprgb[0:1] = [14, 35]  &
tmpgr.rgb_indices =tmprgb
tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0
tmpgr.mapgrid.FONT_SIZE = 10
tmpgr.title = 'Prob less than 80% of avg (SOND) SM01'
grtitle = TEXT(0.5,0.91,STRING('Probability less than',FIX(thresh_perc*100),'% of Average (SOND)',f='(a,I0,a)'),ALIGNMENT=0.5,FONT_SIZE=24)
mc = MAPCONTINENTS(shapefile,/COUNTRIES, COLOR=[70,70,70],FILL_BACKGROUND=0,THICK=2,LIMIT=map_lim )
cb = colorbar(target=tmpgr,ORIENTATION=0,/BORDER,POSITION=[0.1,0.03,0.9,0.07],TAPER=0)
cb = colorbar(orientation=1)

;add the analogue yrs (2012, 2004) in a couple more times
AN1 = '2004'
ifile = file_search(strcompress(indir2+'/'+AN1+'/SURFACEMODEL/'+AN1+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))
;add 2012 ...do 8  more times
for j = 0,7 do begin &$  
  VOI = 'SoilMoist_tavg' &$
  ;read in all soil layers
  SM = get_nc(VOI, ifile) &$
  ;just keep the top layer
  SMlayer = SM[*,*,0] &$
  ;count n times that soil is less than 0.33 threshold
  dry = SMlayer lt permap[*,*,M,0] &$
  countmap[*,*,0] = countmap[*,*,0] + dry &$
  ;count n times that soil is less than 0.67 threshold
  avg = SMlayer lt permap[*,*,M,2] &$
  countmap[*,*,1] = countmap[*,*,1] + avg &$
  print, j &$
endfor 
  
;finalize the count map 3/2-2/3-1/3
ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))

countmap[*,*,2] = n_elements(ifile) ;say that 100% of values are wet (+16 for the weighted exp
countmap[*,*,2] = countmap[*,*,2]-countmap[*,*,1]; wet-average
countmap[*,*,1] = countmap[*,*,1]-countmap[*,*,0]; average - dry

;three panel count map
map_ulx = emap_ulx & min_lon = map_ulx
map_lry = emap_lry & min_lat = map_lry
map_uly = emap_uly & max_lat = map_uly
map_lrx = emap_lrx & max_lon = map_lrx

indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
mfile_E = file_search(indir+'lis_input_ea_elev.nc')

VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)
range = where(LC[*,*,6] gt 0.3, complement=other)
rmask = fltarr(NX,NY)+1.0
rmask(other)=!values.f_nan
rmask(range)=1

;;water and baresoil mask
indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
mfile_E = file_search(indir+'lis_input.MODISmode_ea.nc')

VOI = 'LANDCOVER'
LC = get_nc(VOI, mfile_E)
bare = where(LC[*,*,15] eq 1, complement=other)
water = where(LC[*,*,16] eq 1, complement=other)
Emask = fltarr(eNX,eNY)+1.0
Emask(bare)=!values.f_nan
Emask(water)=!values.f_nan

w = WINDOW(WINDOW_TITLE='June 31 outlook',DIMENSIONS=[NX+1600,NY+200])
xsize=0.10
ysize=0.10
mlim = [min_lat,min_lon,max_lat,max_lon]
ifile = file_search(strcompress(indir2+'/????/SURFACEMODEL/????'+STRING(format='(I2.2)', ESP_M) +'/LIS_HIST*.nc', /remove_all))
ncolors = n_elements(ifile) ;IBBP=20, UMD=14
tercile = ['dry', 'avg', 'wet']

for i = 0,2 do begin &$
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1, layout = [3,1,i+1])  &$
  p1 = image(countmap[*,*,i]*emask,rgb_table=20,image_dimensions=[nx*xsize,ny*ysize], image_location=[map_ulx,map_lry], $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT) &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1)) &$
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  ;rgbdump[*,0:(256/ncolors)] = rebin([190,190,190],3,(256/ncolors)+1)  &$
 ; rgbdump[*,0] = rebin([0,255,255],3,1)  &$
  p1.rgb_table = rgbdump  &$
  ;use this if using all colors, not needed for nsims/2
  p1.min_value = 0.5  &$
  p1.max_value = ncolors+0.5  &$
  p1.title = 'count of '+tercile[i] &$
  if i eq 2 then c = COLORBAR(target=p1,ORIENTATION=1,/BORDER_ON, POSITION=[0.96,0.08,0.99,0.9])  &$
  m1.mapgrid.linestyle = 6 &$
  m1.mapgrid.label_show = 0  &$
  m1.mapgrid.label_position = 0  &$
  mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)  &$
endfor

p1.title = 'ncolors'
