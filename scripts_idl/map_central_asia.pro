pro map_central_asia

help, precip, precipf, snow
precip_tot = total(precip*86400,3,/nan)
precipf_tot = total(precipf*86400,3,/nan)
snow_tot = total(snow*86400,3,/nan)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
params = get_domain001('CA')

sNX = params[0]
sNY = params[1]
smap_ulx = params[2]
smap_lrx = params[3]
smap_uly = params[4]
smap_lry = params[5]
;;;STICK with CONTOUR;;;;;;;
map_ulx = smap_ulx & min_lon = map_ulx
map_lry = smap_lry & min_lat = map_lry
map_uly = smap_uly & max_lat = map_uly
map_lrx = smap_lrx & max_lon = map_lrx
NX = sNX
NY = sNY

;ok, actually clip this down to an afghanistan size box
ymap_ulx = 60 & ymap_lrx = 76
ymap_uly = 40 & ymap_lry = 25.5


res = 0.01

left = (ymap_ulx-map_ulx)/res  & right= (ymap_lrx-map_ulx)/res-1
top= (ymap_uly-map_lry)/res   & bot= (ymap_lry-map_lry)/res-1
afg_precip = precip[left:right, bot:top,*] & help, afg_precip
;NX = 1600
;NY = 1452

shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;w = WINDOW(DIMENSIONS=[700,900]);works for EA 700x900
;w = WINDOW(DIMENSIONS=[1200,500]);works for EA 700x900
w = WINDOW(DIMENSIONS=[1200,1200], /buffer);works for EA 700x900

;60lon, 40lay, 76lon, 30lat
mlim = [min_lat,min_lon,max_lat,max_lon]
mlim = [28, 60, 40, 76]
xsize=0.010
ysize=0.010

index = indgen(10)
ncolors = n_elements(index)-1
ct=colortable(64) ;16
;y=34
;tic
;for mo = 0,8 do begin &$
  ;great now how to i zoom in on afghanistan?
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1) &$
  tmpgr = CONTOUR(precipf_tot, $
  FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
  RGB_TABLE=ct, /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white', $
  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
  MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT) &$
  ;ct[108:108+36,*] = 200  &$
  tmpgr.rgb_table=ct &$
  tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
  tmpgr.mapgrid.font_size=16
  cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.05,0.95,0.09],FONT_SIZE=18,/BORDER)
  ;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)
  ;mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)
  mc = MAPCONTINENTS( /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim, thick=3) &$
  tmpgr.title = 'accum. precio'
  tmpgr.font_size=18
  tmpgr.save,'/home/almcnall/IDLplots/precipf.png'
  
  
  ;;;;;;;
  p2 = image(total(precip*86400),3, /nan),rgb_table=62, FINDGEN(NX)/100.+ map_ulx,FINDGEN(NY)/100.+ map_lry,$
     /buffer)
    
  m1 = MAP('Geographic',LIMIT=mlim,/CURRENT,horizon_thick=1) &$
    tmpgr = image(total(precip*86400,3,/nan), $
    FINDGEN(NX)*(xsize) + min_lon, FINDGEN(NY)*(ysize) + min_lat, $
    RGB_TABLE=ct, /FILL, ASPECT_RATIO=1, BACKGROUND_COLOR='white', $
    C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./(ncolors-1)), $
    MAP_PROJECTION='Geographic', XSTYLE=1, YSTYLE=1, /OVERPLOT) &$
    ;ct[108:108+36,*] = 200  &$
    tmpgr.rgb_table=ct &$
    tmpgr.mapgrid.linestyle = 6 & tmpgr.mapgrid.label_position = 0 &$
    cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.05,0.95,0.09],FONT_SIZE=11,/BORDER)
  ;cb = COLORBAR(TARGET=tmpgr, POSITION=[0.05,0.2,0.95,0.25],FONT_SIZE=11,/BORDER)
  ;mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim)
  mc = MAPCONTINENTS( /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim) &$
    tmpgr.save,'/home/almcnall/IDLplots/precip.png'

    endfor
toc
close