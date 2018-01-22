pro readin_SSEB_ET_EA10K

;moved from noahVsseb to its own script.
;01/15/17 update to include more recent EA, did not do SA or WA.
;07/08/17 make this a read-in script for SA...
;08/16/17 and west africa too!
;08/30/17 try to make a multimonth PON (2003-2015)

.compile /home/almcnall/Scripts/scripts_idl/get_domain01.pro
.compile /home/almcnall/Scripts/scripts_idl/get_nc.pro

;; params = [NX, NY, map_ulx, map_lrx, map_uly, map_lry]
params = get_domain01('SA')

NX = params[0]
NY = params[1]
map_ulx = params[2]
map_lrx = params[3]
map_uly = params[4]
map_lry = params[5]

;;rebin and write out to use in other scripts;;;;;

;repeat and save the files
startyr = 2003
endyr = 2017
startmo = 1
endmo = 12
nmos = endmo - startmo+1
nyrs = endyr-startyr+1

temp = intarr(NX,NY)
ET = intarr(NX,NY,NMOS,NYRS)


;indir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/EAST/'
indir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/SOUTH/'
;indir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/WEST/'


TIC
;;read in the 0.1x0.1 degree file instead
for y = startyr,endyr do begin &$
  for i = 0,nmos-1 do begin &$
    m = startmo + i &$
    if m gt 12 then begin &$
      m = m-12 &$
      y = y+1 &$
    endif &$
;  ifile = strcompress(indir+'/m'+string(y)+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm_EA_294_348.bin',/remove_all) &$
  ifile = strcompress(indir+'/m'+string(y)+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm_SA_486_443.bin',/remove_all) &$
;  ifile = strcompress(indir+'/m'+string(y)+STRING(format='(I2.2)', m)+'_modisSSEBopETv4_actual_mm_WA_446_124.bin',/remove_all) &$


  print, ifile &$
  
  openr,1,ifile &$
  readu,1,temp &$
  close,1 &$
 
  ET[*,*,i,y-startyr] = temp &$
endfor &$
endfor
TOC
ET = float(ET) & help, ET
ET(where(ET lt 0)) = !values.f_nan

; read one in to see if it looks right...looks fine.
;outdir = '/discover/nobackup/projects/fame/RS_DATA1/SSEB/ET_AFRICA/EAST/'
;ETA = intarr(NX,NY)
;openr,1,outdir+'/m201706_modisSSEBopETv4_actual_mm_EA_294_348.bin'
;readu,1, ETA
;close,1
;

;;see plot_et_sseb_fldas for annual difference maps