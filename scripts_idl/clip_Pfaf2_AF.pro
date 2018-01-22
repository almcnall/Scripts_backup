pro clip_Pfaf2_AF

; Sept 14, 2017 update to readin the new basins that kris gave me, 
; clip for now, maybe kris will make official fix laterz.


.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('WA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]


;continental africa
indir = '/discover/nobackup/almcnall/SHPfiles/'
ifile = file_search(indir+'af_basins_level2.tif')
ingrid = read_tiff(ifile, GEOTIFF=g_tags)
ingrid = reverse(ingrid,2) ; -31.300000       39.800000

;plot
;temp = image(ingrid, rgb_table=43)

;how do i get this to snap to the modeloutput grid? why do i get so itchy with details?
; currently the grid is 1090,943, but i want it down to 751x801
;wonder what it currently is...
;read in the SM_tiff since that is almost the right dimensions
ifile2 = file_search('/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/HYPERWALL/AF_SOILSTORE_ANOM_751x801_201612.tif')
ingrid2 = read_tiff(ifile2,GEOTIFF=g_tags2)
ingrid2 = reverse(ingrid2,2) ;-20.050000       39.950000

;look at my ususal clip grid...
;-31.3000000000000007,-54.5000000000000142 : 77.7000000000000028,39.7999999999999972
smap_ulx = g_tags.MODELTIEPOINTTAG[3] & print, smap_ulx, map_ulx
smap_lrx = 77.70  & print, smap_lrx, map_lrx
smap_uly = g_tags.MODELTIEPOINTTAG[4] & print, smap_uly, map_uly
smap_lry = -54.5 & print, smap_lry, map_lry

;envi tends to agree with these dimentions, while IDL reads in others from the TIFF

pix = 0.1 ;0.009652 ;0.0083
ulx = (180.+smap_ulx)/pix  & lrx = (180.+smap_lrx)/pix
uly = (50.-smap_uly)/pix   & lry = (50.-smap_lry)/pix
NX = lrx - ulx
NY = lry - uly
print, nx, ny
help, ingrid ;if it was a 1km then 772 x 808 ~ 751x801

;;;;;;;clip continental africa to continental africa domain;;;;;;
af_left = (map_ulx-smap_ulx)/pix & print, af_left
af_right = (map_lrx-smap_ulx)/pix & print, af_right
af_bot = abs(smap_lry-map_lry)/pix & print, af_bot
af_top = (map_uly-smap_lry)/pix & print, af_top

;try to get the SSEB grid as close to an integer multiple of the EROS domain as possible.
basin_af = ingrid[af_left:af_right,af_bot:942] & help, basin_af
basin_af(where(basin_af lt 0)) = !values.f_nan

;add two to the top
pad = fltarr(751,2) *!values.f_nan
basin_af= [[basin_af],[pad]]
temp = image(basin_af, rgb_table=43, /overplot, transparency=80)
temp2 = image(ingrid2,transparency=80,/current)

;;write out new basin file until Kris makes a more perfect one;;;
;ofile = '/discover/nobackup/almcnall/SHPfiles/af_basin_level2_751_800.tif'
;write_tiff, ofile, basin_af, geotiff=g_tags2, /FLOAT

;;;;;;;clip continental africa to east africa domain;;;;;;
;get an example tif file...do i have one somewhere?
indir = '/discover/nobackup/almcnall/Africa-POP/'
POP = read_tiff(indir+'EAfrica_POP_10km.tiff', GEOTIFF=g_tags3)

ea_left = (map_ulx-smap_ulx)/pix & print, ea_left
ea_right = (map_lrx-smap_ulx)/pix & print, ea_right
ea_bot = abs(smap_lry-map_lry)/pix & print, ea_bot
ea_top = (map_uly-smap_lry)/pix & print, ea_top

;lloks like i should ax an NX pixel (left or right?)
basin_ea = ingrid[ea_left:ea_right,ea_bot:ea_top] & help, basin_ea
basin_ea(where(basin_ea lt 0)) = !values.f_nan

temp = image(basin_ea, rgb_table=43, /overplot, transparency=80)

;;write out new basin file until Kris makes a more perfect one;;;
;ofile = '/discover/nobackup/almcnall/SHPfiles/ea_basin_level2_295_348.tif'
;write_tiff, ofile, basin_ea, geotiff=g_tags3, /FLOAT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;clip continental africa to southern africa domain;;;;;;
;get an example tif file...these don't have geotags...
indir = '/discover/nobackup/almcnall/Africa-POP/'
POP = read_tiff(indir+'SAfrica_POP_10km.tiff', GEOTIFF=g_tags3)

sa_left = (map_ulx-smap_ulx)/pix & print, sa_left
sa_right = (map_lrx-smap_ulx)/pix & print, sa_right
sa_bot = abs(smap_lry-map_lry)/pix & print, sa_bot
sa_top = (map_uly-smap_lry)/pix & print, sa_top

;lloks like i should ax an NX pixel (left or right?)
basin_sa = ingrid[sa_left:sa_right,sa_bot:sa_top] & help, basin_sa
basin_sa(where(basin_sa lt 0)) = !values.f_nan

temp = image(basin_sa, rgb_table=43, /overplot, transparency=80)

;;write out new basin file until Kris makes a more perfect one;;;
;ofile = '/discover/nobackup/almcnall/SHPfiles/sa_basin_level2_486_443.tif'
;write_tiff, ofile, basin_sa, geotiff=g_tags3, /FLOAT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;clip continental africa to west africa domain;;;;;;
;get an example tif file...these don't have geotags...
indir = '/discover/nobackup/almcnall/Africa-POP/'
POP = read_tiff(indir+'WAfrica_POP_10km.tiff', GEOTIFF=g_tags3)

wa_left = (map_ulx-smap_ulx)/pix & print, wa_left
wa_right = (map_lrx-smap_ulx)/pix & print, wa_right
wa_bot = abs(smap_lry-map_lry)/pix & print, wa_bot
wa_top = (map_uly-smap_lry)/pix & print, wa_top

;lloks like i should ax an NX pixel (left or right?)
basin_wa = ingrid[wa_left:wa_right,wa_bot:wa_top] & help, basin_wa
basin_wa(where(basin_wa lt 0)) = !values.f_nan

temp = image(basin_wa, rgb_table=43, /overplot, transparency=0)
temp = image(pop, rgb_table=43, /overplot, transparency=80)


;;write out new basin file until Kris makes a more perfect one;;;
;ofile = '/discover/nobackup/almcnall/SHPfiles/wa_basin_level2_446_124.tif'
;write_tiff, ofile, basin_wa, geotiff=g_tags3, /FLOAT
