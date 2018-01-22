pro readin_alexi
;checking out the alexi data
;regrid and make a time series for the western mask
; Data Format :   4-byte floating point binary (8 bits in a byte)
; missing data flag : -9999.^M
; spatial resolution : .026979648 deg
;Domain Boundaries^M
;northern latitude:       38.5082
;southern latitude:       -6.0082
;eastern longitude:       60.5602
;western longitude:       21.4398
;% 1 MJ /m^2 /day = 0.408 mm /day %
;http://www.fao.org/docrep/x0490e/x0490e04.htm
;et{year(yyyy)}(j)=nanmean(data(mask_index))*0.408;  % mm/day
;EDY72009001.dat
;ifile = file_search(indir+'/2009/EDY*dat')
;
;;for i = 0, n_elements(ifile)-1 do begin &$
;  i=0
;  openr,1,ifile[i] & print, ifile[i]
;  readu,1,buffer
;  close,1
;
;  buffer(where(buffer lt 0)) = !values.f_nan

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

;ingrid = dblarr(nx, ny, nz)
;buffer = dblarr(nx,ny)
buffer = fltarr(nx,ny)
ETday = FLTARR(NX,NY,31,nmos,nyrs)*!values.f_nan
data_dir = '/discover/nobackup/projects/fame/RS_DATA1/ALEXI/MENAE/EDY7_MENAE_TERR/'

;;;;;;;;;;;;;;;;;;;;;;;
;read in the daily data - check the SMdaily script
;MF is day of yr, rather than yr month...maybe i need the counter and days in a month, with the leap yr. blegh.
ndays_28 = [31,28,31,30,31,30,31,31,30,31,30,31]
ndays_29 = [31,29,31,30,31,30,31,31,30,31,30,31]

for YR = startyr,endyr do begin &$
 ;YR=2007
;is it a leap year?
  if yr MOD 4 eq 0 then print, string(yr)+' leap!' &$
  if yr MOD 4 eq 0 then ndays = ndays_29 else ndays = ndays_28 &$   
 ;get all the file for a give year
    fnames = file_search(strcompress(data_dir+string(YR)+'/EDY7'+string(YR)+'*.dat', /remove_all)) &$    
    j = 0 &$;count day of month
    i = 0 &$; month
    cnt = 0 &$
    for f = 0, n_elements(fnames)-1 do begin &$
      ifile = fnames[f] &$     
      fdoy = float(strmid(ifile,83,3)) &$
     ; print, cnt, fdoy-1, j, i+1, yr &$
      ;cnt needs to match file name, if not cnt=file name...
      if cnt NE fdoy-1 then print, "missing cnt "+string(cnt), fdoy, yr &$
      if cnt ne fdoy-1 then cnt = fdoy-1 &$
        
      if j eq ndays[i] then j = 0 AND i++ &$
      openr,1,ifile &$
      readu,1,buffer &$
      close,1 &$
      ETday[*,*,j,i,yr-startyr] = buffer*0.408 &$
      cnt++ &$
      j++ &$
    endfor &$
  endfor 
;endfor
ETday(where(ETday lt 0)) = !values.f_nan
ETdayup = reverse(ETday,2)

ofile = strcompress(data_dir+'alexi_1450_1650_31_12_7.bin', /remove_all)
openw,1,ofile
writeu,1,ETdayup
close,1


;;ok, now i need to write these data out...blegh! but for now just plot one SSEB and one ALEXi side by side

