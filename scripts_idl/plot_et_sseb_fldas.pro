pro plot_et_sseb_fldas

;get the ET data from readin_chirps_noah_et, readin_SSEB_ET_EA

help, avg_annual_evap, avg_annual_et

  shapefile = file_search('/discover/nobackup/projects/fame/Domains/FAME_Basins/Africa_Basins/af_catch2.shp') & help, shapefile
  noah_et = avg_annual_evap*86400*30

  w=window()
  p1 = image(avg_annual_et-noah_et, image_dimensions=[NX*0.1,NY*0.1], $ ;evap*86400*30
    image_location=[map_ulx,map_lry],RGB_TABLE=64, /current)
  m1 = MAP('Geographic',limit=[map_lry,map_ulx,map_uly,map_lrx], /overplot, horizon_thick=1)
  ;m = MAPCONTINENTS( /COUNTRIES, THICK=1, color=[255,255,255])
  mc = MAPCONTINENTS(shapefile,COLOR=[105,105,105],FILL_BACKGROUND=0,LIMIT=mlim, thick=1)
  m1.mapgrid.linestyle = 6 &$
    m1.mapgrid.label_show = 1  &$
    m1.mapgrid.label_position = 0
  c=colorbar(orientation=1)
