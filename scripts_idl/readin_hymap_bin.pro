;convert binary to tiffs for Kris
;or .bil if i can remember how to do thoes.
;i think there is a problem with the fldas_010 files

indir = '/discover/nobackup/agetiran/LIS/LIS7/pos/out/fldas_010/'
ifiles = file_search(indir+'lis_basin_0100.bin')

ingrid = fltarr(714,590)

openr,1,ifiles[0]
readu,1,ingrid
close,1

ingrid = SWAP_ENDIAN(ingrid)
print, min(ingrid) & print, max(ingrid)
temp = image(ingrid,min_value=0, max_value=10)

;;;this succesfully opens;;;;
indir = '/discover/nobackup/projects/lis/LS_PARAMETERS/HYMAP_10KM_GLOBAL/'
ifiles = file_search(indir+'basin.bin')


ingrid = fltarr(360*10,150*10)

openr,1,ifiles[0]
readu,1,ingrid
close,1

print, min(ingrid) & print, max(ingrid)
temp = image(ingrid,min_value=0, max_value=10)