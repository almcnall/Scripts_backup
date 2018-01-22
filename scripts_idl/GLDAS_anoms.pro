pro GLDAS_anoms

;i need to set this up so it reads in all the files but only generates the mean from 2000-2016

.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro
startyr = 2000 ;start with 1982 since no data in 1981, or 2003 if for SSEB compare
endyr = 2017
nyrs = endyr-startyr+1

;re-do for all months
startmo = 1
endmo = 12
nmos = endmo - startmo+1

;read this one in for the mean.
indir = '/discover/nobackup/projects/fame/Validation/GLDAS2.1/'

;;;do it with the cdo file;;;;;
;ifile = file_search(indir+'ALL_rootmoist.nc')
;VOI = 'RootMoist_inst'
;RZSM = get_nc(VOI, ifile)

NX = 1440
NY = 600
;nmos = 12
;nyrs = 17
;reshape to 12 months, and 17 years
;RZSMcube = reform(RZSM, NX, NY, nmos, nyrs) & help, rzsmcube;
;get the monthly means
;RZmonmean = mean(rzsmcube,dimension=4,/nan) & help, RZmonmean
;repeat the matric for fast math
;RZmonmean = rebin(RZmonmean,NX,NY,12,17) & help, RZmonmean
;RZanom = RZSMcube-RZmonmean & help, RZanom

RZSMCUBE = FLTARR(NX,NY,NMOS, NYRS)
for yr=startyr,endyr do begin &$
  for i=0,nmos-1 do begin &$
  y = yr &$
  m = startmo + i &$
  if m gt 12 then begin &$
  m = m-12 &$
  y = y+1 &$
endif &$
;ifile = file_search(data_dir+STRING(FORMAT='(''FLDAS_NOAH01_C_EA_M.A'',I4.4,I2.2,''.001.nc'')',y,m)) &$
ifile = file_search(indir+STRING(FORMAT='(''GLDAS_NOAH025_M.A'',I4.4,I2.2,''.021.nc4'')',y,m)) &$ 


;variable of interest
VOI = 'RootMoist_inst' &$
Qs = get_nc(VOI, ifile) &$
;print, ifile, VOI &$
RZSMcube[*,*,i,yr-startyr] = Qs &$

endfor &$
endfor
RZSMcube(where(RZSMcube lt 0)) = !values.f_nan

;compute the mean for 2000-2016
RZmonmean = mean(rzsmcube[*,*,*,0:16],dimension=4,/nan) & help, RZmonmean
RZmonmean = rebin(RZmonmean,NX,NY,12,18) & help, RZmonmean
RZanom = RZSMcube-RZmonmean & help, RZanom

;get the tiff geotag
ifile = file_search (indir+'anom_test2.tif');'GIOVANNI-wmsLayer_A400G0x2.tif')
ingrid = read_tiff(ifile, GEOTIFF=g_tags)



;finish this on monday with faster conx
for m = 0, nmos-1 do begin &$
  for y = 0,nyrs-1 do begin &$
    ogrid = rzanom[*,*,m,y] &$
    ofile = indir+'GLDAS_RZ_anom_'+STRING(format='(I4.4,I2.2)', Y+2000, M+1)+'.tif' & print, ofile &$
    write_tiff, ofile, reverse(ogrid,2), geotiff=g_tags, /FLOAT &$
   endfor &$
 endfor

;plot 2009-13
startyr = 2000
for m = 0, nmos-1 do begin &$
  p1 = image(rzanom[*,*,m,(2010-startyr)-1], layout = [4,3,m+1], rgb_table=70, min_value=-150, max_value=150, /current) &$
endfor
