readin_Pfaf2_basins

;readin different hymap basin file for easy masking
;update to readin the new basins that kris gave me.


.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;continental africa
;indir = '/discover/nobackup/almcnall/SHPfiles/'
;ifile = file_search(indir+'af_basin_level2_751_800.tif')
;basinA = read_tiff(ifile, GEOTIFF=g_tags)

;east africa
indir = '/discover/nobackup/almcnall/SHPfiles/'
ifile = file_search(indir+'ea_basin_level2_295_348.tif')
basinE = read_tiff(ifile)
basinE = basinE[1:294,*]

;;southern africa
;indir = '/discover/nobackup/almcnall/SHPfiles/'
;ifile = file_search(indir+'sa_basin_level2_486_443.tif')
;basinS = read_tiff(ifile, GEOTIFF=g_tags)
;
;;western africa
;indir = '/discover/nobackup/almcnall/SHPfiles/'
;ifile = file_search(indir+'wa_basin_level2_446_124.tif')
;basinW = read_tiff(ifile, GEOTIFF=g_tags)

;plot
basinE(where(basinE eq 0)) = !values.f_nan
temp = image(basinE, rgb_table=43, /buffer)
temp.save, '/home/almcnall/IDLplots/temp.png'


;indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/AFRICA/LDT_run/'
;ifileA = file_search(indir+'lis_input_af_elev.nc') & print, ifile
;indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
;ifileS = file_search(indir+'lis_input_sa_elev_hymap_test.nc')
;indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/' ;i would rather have hymap...
;ifileE = file_search(indir+'lis_input_ea_elev_hymapv2.nc') ;'lis_input.MODISmode_ea.nc')

;specifiy which domian
basin = basinE

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = 'EA'
params = get_domain01(domain)
print, params

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]


;;;;;;eastern africa basins;;;;;;;;;;
;nile = 22X Nile and subbasins
good = where(basin ge 220 AND basin lt 230, complement = other)
nile_mask = basin
nile_mask(good) = 1
nile_mask(other) = !values.f_nan

;;upper blue nile subset
good = where(basin eq 224, complement = other)
bnile_mask = basin
bnile_mask(good) = 1
bnile_mask(other) = !values.f_nan

;40 = juba-shebelle
good = where(basin eq 232, complement = other)
jsb_mask = basin
jsb_mask(good) = 1
jsb_mask(other) = !values.f_nan

;208 = awash basin - HYMAP only
;good = where(basin eq 208, complement = other)
;awash_mask = basin
;awash_mask(good) = 1
;awash_mask(other) = !values.f_nan

;;228 lake victoria basin;;;;
good = where(basin eq 228, complement = other)
LVB_mask = basin
LVB_mask(good) = 1
LVB_mask(other) = !values.f_nan

;112 = rufiji basin ***AGU******
good = where(basin eq 236, complement = other)
rufi_mask = basin
rufi_mask(good) = 1
rufi_mask(other) = !values.f_nan

;201= Tana basin (full, not upper)
good = where(basin eq 234, complement = other)
tana_mask = basin
tana_mask(good) = 1
tana_mask(other) = !values.f_nan

good = where(basin eq 268, complement = other)
luku_mask = basin
luku_mask(good) = 1
luku_mask(other) = !values.f_nan

;;upper tana basin subset HYMAP only for now
;ymap_ulx = 36.2 & ymap_lrx = 39.
;ymap_uly = -0.70 & ymap_lry = -0.85
;
;res = 0.1
;left = (ymap_ulx-map_ulx)/res  & right= (ymap_lrx-map_ulx)/res-1
;top= (ymap_uly-map_lry)/res   & bot= (ymap_lry-map_lry)/res-1
;utana_mask = tana_mask
;utana_mask[*,0:bot]=!values.f_nan
;utana_mask[right:294-1,*]=!values.f_nan
;utana_mask[*,top:348-1]=!values.f_nan

;;SOUTHERN AFRICA BASINS
;Southern Africa (15-500)
;18 = Zambezi basin
;25 = Orange river basin
;42 = Okavango
;58 = Limpopo basin
;133 = Ruvuma
;175 = Save
;390 = Incomati
;503 = Pagani

;112 = Rufiji Basin

;1932=Mananbolo basin HYMAP only
;good = where(basin eq 1932, complement = other)
;mana_mask = basin
;mana_mask(good) = 1
;mana_mask(other) = !values.f_nan


;390 = Incomati basin
;good = where(basin eq 390, complement = other)
;inco_mask = basin
;inco_mask(good) = 1
;inco_mask(other) = !values.f_nan

;503 = Pagani basin
;good = where(basin eq 503, complement = other)
;pag_mask = basin
;pag_mask(good) = 1
;pag_mask(other) = !values.f_nan

;112 = rufiji basin
good = where(basin eq 236, complement = other)
rufi_mask = basin
rufi_mask(good) = 1
rufi_mask(other) = !values.f_nan

;25 = orange river basin
good = where(basin eq 254, complement = other)
orng_mask = basin
orng_mask(good) = 1
orng_mask(other) = !values.f_nan
;zamb_mask[kxind:485,*]=!values.f_nan

;18=zambeie, karibe dam ;there are several sub-basins.
good = where(basin gt 240 AND basin lt 250, complement = other)
zamb_mask = basin
zamb_mask(good) = 1
zamb_mask(other) = !values.f_nan
;zamb_mask[kxind:485,*]=!values.f_nan

good = where(basin eq 252, complement = other)
limp_mask=basin
limp_mask(good) = 1
limp_mask(other) = !values.f_nan
;limp_mask[gxind:485,*]=!values.f_nan

;swaziland/hawane dam=534
;good = where(basin eq 534, complement = other)
;hwan_mask=basin
;hwan_mask(good) = 1
;hwan_mask(other) = !values.f_nan
;hwan_mask[gxind:485,*]=!values.f_nan
;
;;west africa basins of interest;;;;
good = where(basin gt 280 AND basin lt 290, complement = other)
nig_mask = basin
nig_mask(good) = 1
nig_mask(other) = !values.f_nan

;;volta basin
good = where(basin eq 292, complement = other)
volt_mask=basin
volt_mask(good) = 1
volt_mask(other) = !values.f_nan
