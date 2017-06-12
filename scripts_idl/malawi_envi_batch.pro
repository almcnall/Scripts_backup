pro malawi_envi_batch  ; indir, var ;add these when I understand how to run this from a script

;**************************************************************************
; The purpose of this program is to automate the process different variables from south malawi
; this program is not finished....2/1/11..I I come back to this sometime
; hints are in code from seth peterson
;*************************************************************************

expdir = 'EXP027' 
if expdir eq 'EXP027' then data='ubRFE2'

indir = strcompress("/gibber/lis_data/OUTPUT/"+expdir+"/NOAH/monthcubie/", /remove_all)
cd, indir

filter= '*img'
infiles=file_search(filter)

ROI=file_search(

COMPILE_OPT STRICTARR
envi, /restore_base_save_files
ENVI_BATCH_INIT

for i = 0, n_elements(infiles) - 1 do begin
    ENVI_OPEN_FILE,infiles[i],R_FID=fid,/NO_REALIZE

roi_ids = envi_get_roi_ids(fid=fid, roi_names=roi_names, /short_name)





device,decomposed=0



; FOR j=0,n_elements(var)-1;each file 
 j=0 
 k=0   
 print,indir+file_w[j]       ;just checking
 openr,1,indir+file_w[j]     ;opens the file
 
 readu,1,ingrid_w           ;reads it into ingrid  
 close,1
 
 mve,ingrid_w                 ;print out the max min mean and std deviation of var
 rgrid = reverse(ingrid_w,2)  ;IDL reads from bottom to top, needs to be reversed to plot
 AOI = rgrid(200:250,80:130,k) ;area of interest grid = Malawi
  
  ;FOR k= 8,nbands-1 DO BEGIN ; just do the rainy months
      AOI = rgrid(200:250,80:130,2)
      window,2,xsize=825, ysize=750
      pos1 = [.05,.05,.91,.95] ;for full window

      ;if the variable is temperature (or other red, high variable)
      ;loadct,3,rgb_table=tmpct   ;displays color table
      ;tmpct = reverse(tmpct,1)
      ;tvlct,tmpct

      ;if the viariable is blue high, red low (rainfall, runoff)
      ;fileps=strcompress('/home/mcnally/testmap_'+data+vars[j]+"_"+months[k]+'.eps', /remove_all)
      loadct,1,rgb_table=tmpct ;34 is rainbow
      tmpct = reverse(tmpct,1)
      tvlct,tmpct                 
      
      ;toggle,file=fileps;file=fileps[count] ; this isn't quite working but I am tierd of it 9/17/10
        tvim,AOI, title='Southern Africa ', range=[0,2,0.25], /scale, lcharsize=1.8, /noframe, pos = pos1
        map_set, 0,0,/cont,/cyl,limit=[-19.5,30,-8,42.75],/noerase, /noborder,pos=pos1, mlinethick=1,color=125
        map_continents, /countries, color=125,   mlinethick=2
      ;toggle     
   
   ;ENDFOR ;k-each band 


 ; ENDFOR ;j- each file

end ;end program


;vars = strarr(9); length = 9
;vars= ['airtem', 'evap', 'soilm1', 'soilm2', 'soilm3','soilm4','rain', 'runoff', 'Qsub'] 
;
;nx     = 301.
;ny     = 321.
;nbands_w = 4. ;wet season
;nbands_d = 5. ;dry season...I should run for full years for this reason alone
;
;months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11','12' ]
;ingrid_w = fltarr(nx,ny,nbands_w) ;initializes the array 
;ingrid_d = fltarr(nx,ny,nbands_d)
;
;file_w = file_search('*{09, 10, 11, 12, 01, 02, 03, 04}.img')
;file_d = file_search('*{05, 06, 07, 08}.img')