pro clip_SSEB_ET_AF01K

;05/13/16 this script clips the monthly, continental Africa SSEB to the differnet EROS domains.
;moved from noahVsseb to its own script.
;01/15/17 update to include more recent EA, did not do SA or WA.
;07/08/17 make this a read-in script.
;08/16/17 make this the clip script, and set up for monthly updates.

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;;try reading in the SSEB data for east africa
;;first read one in to get the domain info for upper left x and y.
indir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/';
;ifile = file_search(strcompress(indir+'/ma0401.modisSSEBopET.tif',/remove_all))
ifile = file_search(strcompress(indir+'ET_AFRICA/AFRICA/m201708_modisSSEBopETv4_actual_mm.tif',/remove_all))

ingrid = read_tiff(ifile, geotiff=gtag)
ingrid = reverse(ingrid,2)

smap_ulx = gtag.MODELTIEPOINTTAG[3]
smap_lrx = 55.0 ;
smap_uly = gtag.MODELTIEPOINTTAG[4]
smap_lry = -37.88;-37.059

;envi tends to agree with these dimentions, while IDL reads in others from the TIFF

pix = 0.00965 ;0.009652 ;0.0083
ulx = (180.+smap_ulx)/pix  & lrx = (180.+smap_lrx)/pix
uly = (50.-smap_uly)/pix   & lry = (50.-smap_lry)/pix
NX = lrx - ulx
NY = lry - uly
print, nx, ny
help, ingrid ;if it was a 1km then 772 x 808 ~ 751x801

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('WA')

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

;check the west africa domain - this should be in separate script
;try to get the SSEB grid as close to an integer multiple of the EROS domain as possible.
sseb_ea = ingrid[ea_left+60:ea_right-20,ea_bot+20:ea_top]

;aiming for 5036 (5027) x 4590.67 (4581)
sseb_sa = ingrid[ea_left-5:ea_right+5,ea_bot+3:ea_top+12]

;aiming for 4460 (4613) x 1240 (1276)
sseb_wa = ingrid[ea_left:ea_right,ea_bot:ea_top]

help, sseb_wa ;3042, 3597
;temp = congrid(sseb_ea, 294, 348)
temp = congrid(sseb_wa,nx, ny)
;make sure country boundries line up correctly with the original, wa = 4613, 1276
p1 = image(sseb_wa, image_dimensions=[4613*pix,1276*pix], $ 
     image_location=[map_ulx,map_lry],RGB_TABLE=73) 
     m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
      m = MAPCONTINENTS( /COUNTRIES, THICK=2) &$

;make sure the country boundary lines up correctly with the clipped
w=window()
p1 = image(temp, image_dimensions=[NX*0.1,NY*0.1], $
     image_location=[map_ulx,map_lry],RGB_TABLE=4, /current, min_value=0)
     m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
     m = MAPCONTINENTS( /COUNTRIES, THICK=1, color=[255,255,255]) 
     c=colorbar()
;;rebin and write out to use in other scripts;;;;;

;repeat for many and save the files
startyr = 2017
endyr = 2017
NMOS = 1
;temp = ingrid[ea_left:ea_right,ea_bot:ea_top]
dim = size(temp,/dimensions) & print, dim
SNX = dim[0]
SNY = dim[1]

ETA = bytarr(NX,NY,NMOS,(endyr-startyr)+1)
;ETA = bytarr(3537,4182,12,(endyr-startyr)+1)
;ETA = bytarr(294,348,12,(endyr-startyr)+1)

indir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/AFRICA/'
;outdir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/EAST/'
;outdir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/SOUTH/'
outdir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/WEST/'


TIC
;;read in the 0.1x0.1 degree file instead
for y = startyr,endyr do begin &$
  ;m = 7 &$
  for m = 8,10 do begin &$
  yr = string(y)&$
  ifile = file_search(strcompress(indir+'/m'+yr+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm.tif',/remove_all)) &$
  ;read in the file & rotate
  ingrid = read_tiff(ifile, geotiff=gtag) &$
  ingrid = reverse(ingrid,2) &$
  
  ;subset to correct dims & rebin to new dims
  
  ;;EAST AFRICA;;;
  ;temp1 = ingrid[ea_left+60:ea_right-20,ea_bot+20:ea_top] &$
  ;temp2 = congrid(temp1,294,348) &$
  
  ;SOUTH AFRICA;;;
;  temp1 = ingrid[ea_left-5:ea_right+5,ea_bot+3:ea_top+12] &$
;  temp2 = congrid(temp1,NX,NY) &$
  
  ;WEST AFRICA;;;
  temp1 = ingrid[ea_left:ea_right,ea_bot:ea_top] &$
  temp2 = congrid(temp1,NX,NY) &$
  ;make new file name & write out to regional directory
  ;ofile = strcompress(outdir+'/m'+yr+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm_EA_294_348.bin',/remove_all) &$
  ;ofile = strcompress(outdir+'/m'+yr+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm_SA_486_443.bin',/remove_all) &$
  ofile = strcompress(outdir+'/m'+yr+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm_WA_446_124.bin',/remove_all) &$


  openw,1,ofile &$
  writeu,1,temp2 &$
  close,1 &$
endfor &$
endfor
TOC

; read one in to see if it looks right...looks fine. 
outdir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/WEST/'
;NX = 294
;NY = 348

ETA = intarr(NX,NY)
;openr,1,outdir+'/m201706_modisSSEBopETv4_actual_mm_EA_294_348.bin'
;openr,1,outdir+'/m201707_modisSSEBopETv4_actual_mm_SA_486_443.bin'
openr,1,outdir+'/m201707_modisSSEBopETv4_actual_mm_WA_446_124.bin'

readu,1, ETA
close,1

w=window()
p1 = image(ETA, image_dimensions=[NX*0.1,NY*0.1], $
  image_location=[map_ulx,map_lry],RGB_TABLE=4, /current, min_value=0, max_value=1)
m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
m = MAPCONTINENTS( /COUNTRIES, THICK=1, color=[255,255,255])
c=colorbar()

