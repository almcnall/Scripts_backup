pro surfacewater_anoms

;this computes and writes out the surface water anomaly maps as jpgs.
; starting with streamflow

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro


help, stream, Store_surf, RO

;;;;streamflow;;;;;;
stream_avg = median(stream, dimension=4) & help, stream_avg
mask=total(stream_avg,3,/nan)
good = where(mask gt 5)
small = where(mask le 5)
mask(good)=1
mask(small) = !values.f_nan
mask12 = rebin(mask, nx, ny, nmos)
stream_avg = stream_avg*mask12 & help, stream_avg

stream_avg36 = rebin(stream_avg,nx,ny,nmos,nyrs) & help, stream_avg36
streamPON = (stream/stream_avg36)*100

;from the total, mask values that are less than 8 so we get a streamy map
;plot a time series at the location of interest (how do i know if it lines up?)
txind = FLOOR( (36.8503 - map_ulx)/ 0.10)
tyind = FLOOR( (-0.82 - map_lry) / 0.10)

;;;surface storage;;;;;
surf_avg = median(store_surf, dimension=4) & help, surf_avg
surf_avg36 = rebin(surf_avg,nx,ny,nmos,nyrs) & help, surf_avg36
surfPON = (store_surf/surf_avg36)*100

;make a nice looking plot;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

min_lon = map_ulx
min_lat = map_lry
max_lat = map_uly
max_lon = map_lrx

shapefile = '/discover/nobackup/almcnall/GAUL_2013_2012_0.shapefiles/G2013_2012_0.shp'
;w = WINDOW(DIMENSIONS=[700,900]);works for EA 700x900
;w = WINDOW(DIMENSIONS=[1200,500]);works for EA 700x900
w = WINDOW(DIMENSIONS=[1200,1200]);works for EA 700x900

mlim = [min_lat,min_lon,max_lat,max_lon]
xsize=0.10
ysize=0.10

index = [0,50,70,90,110,130,150];
ncolors = n_elements(index)
ct=colortable(73)

y = 2017-startyr; 2017=25
mo = 2 ;0=jan, 5=june

;;;same thing for image, get the shapefile w/ south sudan
; get the SSEB colorbar for PON
w = window(DIMENSIONS=[1000,800])
ncolors = n_elements(index)
p1 = image(streamPON[*,*,mo,y], image_dimensions=[nx/10,ny/10], $
  image_location=[map_ulx,map_lry], margin = 0.1, /current)
  p1.RGB_TABLE=72  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)  &$ ; just rewrites the discrete colorbar
  rgbdump[*,108:108+38]=200 ;why is this 38?
  p1.rgb_table = rgbdump
  p1.MAX_VALUE=200 &$
  p1.min_value=0
  cb = COLORBAR(target=p1,ORIENTATION=1,/BORDER,TAPER=1, THICK=0,font_size=12)
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
    m1.mapgrid.linestyle = 'none' &$  ; could also use 6 here
    m1.mapgrid.color = [255, 255, 255] &$ ;150
    m1.mapgrid.font_size = 0

  m = MAPCONTINENTS( shapefile,/COUNTRIES,HIRES=1, THICK=1) &$
    p1.title = 'Streamflow PON: Mar 2017'
  

p1.save,'/home/almcnall/IDLplots/surface_PON.png'
close


;;;bin the colors
p1.RGB_TABLE=64  &$
  rgbind = FIX(FINDGEN(ncolors)*255./(ncolors-1))  &$  ; set the index of the colors to be pulled
  rgbdump = p1.rgb_table & rgbdump = CONGRID(rgbdump[*,rgbind],3,256)
;
;index = [0,50,70,90,110,130,150];
;ncolors = n_elements(index)
;CT=COLORTABLE(73) ;keep this so i can change values.
;y=n_elements(ETAs[0,0,0,*])-1
;m=1 ;zero index 1=feb
;;for y = 0,13 do begin &$
;tmptr = CONTOUR(PONs[*,*,m,y]*mask,$
;  FINDGEN(NX)*(xsize)+ min_lon, FINDGEN(NY)*(ysize)+min_lat, BACKGROUND_COLOR='WHITE', $

;  RGB_TABLE=CT, /FILL, ASPECT_RATIO=1, Xstyle=1,Ystyle=1, /overplot, $
;  C_VALUE=index, RGB_INDICES=FIX(FINDGEN(ncolors)*255./ncolors)) &$
;  ct[108:108+36,*] = 200  &$
;  tmptr.rgb_table=ct  &$
;  tmptr.mapgrid.linestyle = 6 & tmptr.mapgrid.label_position = 0
;; mycont = MAPCONTINENTS(shapefile, /COUNTRIES,HIRES=1, thick=2) &$
;;  tmptr.mapgrid.linestyle = 'none'  &$ ; could also use 6 here
;;  tmptr.mapgrid.FONT_SIZE = 10
;;tmptr.mapgrid.label_position = 0; x1, y1, x2, y2
;;cb = colorbar(target=tmptr,ORIENTATION=1,TAPER=1,/BORDER, font_size=12, TITLE='ETa anomaly %', POSITION=[.96,.35,0.99,.75])
;mc = MAPCONTINENTS(shapefile, /COUNTRIES,COLOR=[0,0,0],FILL_BACKGROUND=0,LIMIT=mlim, thick=2)
;tmptr.save,'/home/almcnall/figs4SciData/NOAHpon_FEB_2016_1027.png'
