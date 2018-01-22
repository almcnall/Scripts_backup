pro clip_ALEXI

;read in and subset the reformated alexi data
;write out as 10km East africa domain for comparison w/ FLDAS

  .compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
  .compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

  startyr = 2007
  endyr = 2013
  nyrs = endyr - startyr+1
  startmo = 1
  endmo = 12
  nmos = endmo-startmo+1
  ;read in 365 days even if they don't exist. Could make monthly average or something.

  NX = 1450
  NY = 1650
  ;NZ = 4500
  pix = 0.027
  smap_ulx = 21.439  & smap_lrx = 60.56
  smap_uly = 38.508  & smap_lry = -6.008

  ulx = (180.+smap_ulx)/pix & lrx = (180.+smap_lrx)/pix
  uly = (50.-smap_uly)/pix  & lry = (50.-smap_lry)/pix
  xNX = lrx - ulx + 1
  xNY = lry - uly + 1
;clim, regrid the monthly alexi data
ETday = FLTARR(NX,NY,31,nmos,nyrs)*!values.f_nan

;;;;;;
data_dir = '/discover/nobackup/projects/fame/RS_DATA1/ALEXI/MENAE/EDY7_MENAE_TERR/'

ifile = strcompress(data_dir+'alexi_1450_1650_31_12_7.bin', /remove_all)
openr,1,ifile
readu,1,ETday
close,1

;comnpute monthly total (missing data problem...) and rotate
ETmonth = total(etday,3, /nan) & help, ETmonth

;;;now subset to the domain of interest, or can i pull the point of interest using the map info here?
;-0.820278, 36.850278
;mpala..doesn't look quite right
mxind = FLOOR( (36.8503 - map_ulx)/ 0.027)
myind = FLOOR( (-0.82 - map_lry) / 0.027)

;tester file
test = ETmonth[*,*,0,0] & help, test
;;;clip to east africa domain...how do i do this again..first clip then rebin;;;
 params = get_domain01('EA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;;;;;;clip continental africa to east/west africa domain;;;;;;
ea_left = (map_ulx-smap_ulx)/pix & print, ea_left
ea_right = (map_lrx-smap_ulx)/pix & print, ea_right
ea_bot = abs(smap_lry-map_lry)/pix & print, ea_bot
ea_top = (map_uly-smap_lry)/pix & print, ea_top

;test subset
;I am aiming for 1091 (1088) x 1289 (NX/0.27, NY/0.27)
alexi_ea = ETmonth[ea_left-1:ea_right+2,0:ea_top,*,*] & help, alexi_ea
  

pad = fltarr(1091,212)*!values.f_nan & help, pad ;(216)
eacube01 = fltarr(294,348,12,7)*!values.f_nan

for y = 0, n_elements(etmonth[0,0,0,*])-1 do begin &$
  for m = 0, n_elements(etmonth[0,0,*,0])-1 do begin &$
    ;first pad the layer there may be a slightly better way to do this.
    eagrid = [[pad],[alexi_ea[*,*,m,y]] ]  & help, eagrid &$
    ;then regrid and write out 
    eagrid01 = congrid(eagrid,294, 348, /center) & help, eagrid01 &$
    eacube01[*,*,m,y] = eagrid01 &$
  endfor &$
endfor

ofile = strcompress(data_dir+'/EAST_10KM/ALEXI_EA_10KM_294_348_12_7.bin')
openw,1,ofile
writeu,1,eacube01
close,1

;;and read it back in....
ingrid = fltarr(294,348,12,7)
data_dir = '/discover/nobackup/projects/fame/RS_DATA1/ALEXI/MENAE/EDY7_MENAE_TERR/'
ifile = file_search(strcompress(data_dir+'/EAST_10KM/ALEXI_EA_10KM_294_348_12_7.bin',/remove_all)) & print, ifile
openr,1,ifile
readu,1,ingrid
close,1

eacube01 = ingrid

;make sure country boundries line up correctly with the original
p1 = image(eagrid, image_dimensions=[1088*pix,1285*pix], $ ;1289 originally...
   image_location=[map_ulx,map_lry],RGB_TABLE=73)
m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
m = MAPCONTINENTS( /COUNTRIES, THICK=1)

nx = 294
ny = 348
  ;;looks pretty good now regrid.....;;;;
  p1 = image(ingrid[*,*,0,0], image_dimensions=[NX*0.1,NY*0.1], $ ;1289 originally...
    image_location=[map_ulx,map_lry],RGB_TABLE=73)
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
  m = MAPCONTINENTS( /COUNTRIES, THICK=1)
  
  ;