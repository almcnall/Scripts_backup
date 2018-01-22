pro podor mask
;;;Podor mask;;;
;; senegal/mauritania box for aqueductv4.pro

wxind = FLOOR((-15.033 - map_ulx) / 0.10) & print, wxind
wyind = FLOOR((16.617 - map_lry) / 0.10) & print, wyind

ymap_ulx = -16 & ymap_lrx = -14.5
ymap_uly = 17. & ymap_lry = 16

left = (ymap_ulx-map_ulx)/0.1  & right= (ymap_lrx-map_ulx)/0.1
top= (ymap_uly-map_lry)/0.1   & bot= (ymap_lry-map_lry)/0.1

;Yemen mask so I can take look at the NDVI, CCI-SM and NOAH time series.
;If I make this a shape file then I can use it in LVT
mask = fltarr(NX, NY)*!values.f_nan
mask[left:right, bot:top] = 1

;make sure things look ok.
temp = image(mask, /buffer, min_value=0, max_value=1, /overplot)
temp = image(pop, /buffer, transparency=0, min_value=0, max_value=0.1, rgb_table=4)
c=colorbar()

temp.save, '/home/almcnall/IDLplots/TS_test.png'