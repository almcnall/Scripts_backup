readin_HYMAP_basins_VIC

;readin different hymap basin file for easy masking
;Nov-22 updated from Noah01 original

;.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_domain25.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;continental africa
;indir = '/discover/nobackup/projects/fame/MODEL_RUNS/NOAH_OUTPUT/daily/AFRICA/LDT_run/'
;ifileA = file_search(indir+'lis_input_af_elev.nc') & print, ifile

;indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/Param_Noah3.3/'
;ifileS = file_search(indir+'lis_input_sa_elev_hymap_test.nc')

indir = '/discover/nobackup/almcnall/LIS7runs/LIS7_beta_test/VIC_test/vic_africa/HYMAP/'
ifileS = file_search(indir+'lis_input_lis7.1_SA_HYMAP.d01.nc')

;ifileE = file_search(indir+'lis_input_ea_elev_hymapv2.nc') ;'lis_input.MODISmode_ea.nc')

;specifiy which domain 
ifile = ifileS


;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
domain = 'SA'
params = get_domain25(domain)
print, params

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;get the landcover mask just in case
;VOI = 'LANDCOVER'
;LC = get_nc(VOI, ifile)
;bare = where(LC[*,*,15] eq 1, complement=other)
;water = where(LC[*,*,16] eq 1, complement=other)
;Emask = fltarr(NX,NY)+1.0
;Emask(bare)=!values.f_nan
;Emask(water)=!values.f_nan

VOI = 'HYMAP_basin'
basin = get_nc(VOI, ifile)

;;;;;;eastern africa basins;;;;;;;;;;
;8 = nile
good = where(basin eq 8, complement = other)
nile_mask = basin
nile_mask(good) = 1
nile_mask(other) = !values.f_nan

;;upper blue nile subset
ymap_ulx = 34.5 & ymap_lrx = 39.5
ymap_uly = 12. & ymap_lry = 9.0

left = (ymap_ulx-map_ulx)*10.  & right= (ymap_lrx-map_ulx)*10.-1
top= (ymap_uly-map_lry)*10.   & bot= (ymap_lry-map_lry)*10.-1
blue_mask = nile_mask
blue_mask[*,0:bot]=!values.f_nan
blue_mask[0:left,*]=!values.f_nan
blue_mask[*,top:348-1]=!values.f_nan

;temp = image(blue_mask, rgb_table=4)

;40 = juba-shebelle
good = where(basin eq 40, complement = other)
jsb_mask = basin
jsb_mask(good) = 1
jsb_mask(other) = !values.f_nan

;208 = awash basin
good = where(basin eq 208, complement = other)
awash_mask = basin
awash_mask(good) = 1
awash_mask(other) = !values.f_nan

;112 = rufiji basin
good = where(basin eq 112, complement = other)
rufi_mask = basin
rufi_mask(good) = 1
rufi_mask(other) = !values.f_nan

;201= Tana basin
good = where(basin eq 201, complement = other)
tana_mask = basin
tana_mask(good) = 1
tana_mask(other) = !values.f_nan

;;upper tana basin subset
ymap_ulx = 36.2 & ymap_lrx = 39.
ymap_uly = -0.70 & ymap_lry = -0.85

res = 0.1
left = (ymap_ulx-map_ulx)/res  & right= (ymap_lrx-map_ulx)/res-1
top= (ymap_uly-map_lry)/res   & bot= (ymap_lry-map_lry)/res-1
utana_mask = tana_mask
utana_mask[*,0:bot]=!values.f_nan
utana_mask[right:294-1,*]=!values.f_nan
utana_mask[*,top:348-1]=!values.f_nan

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

;1932=Mananbolo basin
good = where(basin eq 1932, complement = other)
mana_mask = basin
mana_mask(good) = 1
mana_mask(other) = !values.f_nan


;390 = Incomati basin
good = where(basin eq 390, complement = other)
inco_mask = basin
inco_mask(good) = 1
inco_mask(other) = !values.f_nan

;503 = Pagani basin
good = where(basin eq 503, complement = other)
pag_mask = basin
pag_mask(good) = 1
pag_mask(other) = !values.f_nan

;112 = rufiji basin
good = where(basin eq 112, complement = other)
rufi_mask = basin
rufi_mask(good) = 1
rufi_mask(other) = !values.f_nan

;25 = orange river basin
good = where(basin eq 25, complement = other)
orng_mask = basin
orng_mask(good) = 1
orng_mask(other) = !values.f_nan
;zamb_mask[kxind:485,*]=!values.f_nan

;18=zambeie, karibe dam
good = where(basin eq 18, complement = other)
zamb_mask = basin
zamb_mask(good) = 1
zamb_mask(other) = !values.f_nan
;zamb_mask[kxind:485,*]=!values.f_nan

;VIC limpopo listed as 58 for Noah, confirmed diff is real.
good = where(basin eq 59, complement = other)
limp_mask=basin
limp_mask(good) = 1
limp_mask(other) = !values.f_nan
;limp_mask[gxind:485,*]=!values.f_nan

;swaziland/hawane dam=534
good = where(basin eq 534, complement = other)
hwan_mask=basin
hwan_mask(good) = 1
hwan_mask(other) = !values.f_nan
;hwan_mask[gxind:485,*]=!values.f_nan